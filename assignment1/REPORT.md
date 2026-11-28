# Assignment 1

## Introduction

This assignment extends the Terraform from the earlier labs into a multi-environment deployment. The Terraform configuration is split into reusable modules with `dev`, `staging`, and `prod` directories modifying/overriding the modules with environment-specific variables. Each directory keeps its own state key in the shared S3 bucket. A GitHub Actions workflow applies staging automatically on a merge to `main` while prod waits for a required reviewer. The AWS credentials are scoped to the `staging` and `prod` environments, a placeholder database password lives in SSM Parameter Store, and a CloudWatch alarm watches instance CPU utilization.

## Scoped credentials

The three AWS secrets exist only as environment secrets on `staging` and `prod`. The repository-level copies were deleted. As instructed, the refresh command at the start of every session will now be:

```
./scripts/refresh-gha-creds.sh Reios0/acs730-coursework staging prod
```

The old command still works successfully, but it writes repository-level secrets that the jobs no longer reads anymore so the workflow will fail.

## OIDC trust policy for prod

This is the trust policy (referenced from lecture notes) that I would attach to the prod role in a real AWS account:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::056432246332:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:Reios0/acs730-coursework:environment:prod"
        }
      }
    }
  ]
}
```

The `Principal` limits who can ask to assume the role. Only tokens issued by GitHub's OIDC provider are considered. Other identity providers and IAM users are not valid callers.

`sts:AssumeRoleWithWebIdentity` allows for the swapping of tokens for credentials so no access key needs to sit in GitHub (risk of leaking).

The `aud` condition checks who the token was minted for (only AWS is allowed). A token GitHub issued for service can't be used against AWS STS to get this role.

The `sub` condition is the most important part for this OIDC policy as it directly relates to the prod environment. When a job declares `environment: prod`, GitHub sets the token's `sub` to `repo:Reios0/acs730-coursework:environment:prod`. To run in that environment, the job has to pass its protection rules first, which means the required reviewer and the main-only branch policy in this context. Setting `sub` to the environment means getting the role needs the same approval as deploying.

A repo-wide wildcard such as `repo:Reios0/acs730-coursework:*` removes that protection stated above. It matches every workflow, branch and pull request in the repository. Anyone with push access could create a branch, add a workflow with `permissions: id-token: write`, and assume the prod role. That workflow never uses the `prod` environment, so no reviewer is required. The same wildcard would let a staging job assume the prod role. I used `StringEquals` and not `StringLike` because unlike the wildcard, there is no pattern to match. The exact value narrows it to one environment (prod).

## Secrets management pre-step

Terraform only reads the database password placeholder and should not create it to prevent a circular dependency. However, if nobody creates it, a fresh environment will fail. Therefore, I created the parameters by hand:

```
for e in dev staging prod; do
  aws ssm put-parameter --name /acs730/assignment1/$e/db_password \
    --type SecureString --value 'placeholder' \
    --overwrite --region us-east-1
done
```


## Recommendation: GitHub Actions or AWS-native

For a team that is fully committed to AWS with no multi-cloud plans, I would recommend the AWS-native pipeline. The code can stay in GitHub and be connected to AWS.

The first reason for this recommendation is where the identity lives. An AWS-native pipeline can run under roles that belong to the account so there is no need to federate. With Actions, the team has to maintain an OIDC trust and keep its `sub`condition exact. One accidentally wildcard can give prod access to anyone. If the team chooses to not use OIDC, then they would need to do what we've been doing throughout the course by running the pipeline using session keys with a refresh script that had to be run every session.

The second reason is network access. A build that runs inside the account's private network can reach private databases or internal endpoints. A GitHub-hosted runner can't do that (or it will be very difficult). Self-hosted runners can do that, although it does come with the cost of having to patch and pay for it even when idle.

The last reason is who can change the approval process. The protection rules in GitHub are repository settings, so anyone with admin access to the repository can edit or remove it. On the other hand, pipeline permissions are dependent on the account's permissions and changes to it will be logged/audited for accountability.


## Conclusion

Going in, I expected the hard part of this assignment to be configuring and splitting Terraform. Most of my care went into the things around it such as: giving each environment its own state key, not using the old refresh command, and capturing evidence at the right moment, since some captures (the pending approval screenshot and the alarm) can't be redone. Planning how to approach the assignment also took a large share of the time. I forgot the alarm's dimensions on the first pass, and the apply still became green, which showed me that a successful apply only means Terraform did what I wrote and not that it does what I meant. What I took from this is that automation depends as much on how the environment is set up as on the scripts themselves.

