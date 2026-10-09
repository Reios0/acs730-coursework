# Lab 3

## Terraform Version
Terraform v1.16.5

## Why OIDC and Session-Scoped Secrets
A real account would use OIDC rather than stored keys because GitHub's token issuer is registered as an identity provider and an IAM role trusts it (for 
that repository) so it gets a short-lived token from STS with no long-lived secret to rotate or possibly leak. This course uses session-scoped secrets
because AWS Academy denies IAM writes, which limits the damage if leaked because the session secrets expire as soon as the lab session ends.

## Experiments

### Remove the backend
Prediction: Running `terraform init -migrate-state` with the backend removed will create a state file. If that's committed, the GitHub runner will start
from an empty state every time and create a second copy of everything (`1 to add` for each plan).
What I saw: A state file was created with another file called `aws_ssm_parameter.lab3` (the file that would've been duplicated).

### Give the apply step a pull request
Prediction: It runs on all pull request changes so anyone who can open a pull request can change `lab3/main.tf`. This would then be applied to my AWS account with
my session credentials without any review/merge. My credentials would essentially be exposed for anyone to use (as long as they can open a pull request).
What I saw: Terraform apply ran on pull request changes instead of only when pushing to main. The safety net where the pull request only propose changes instead
of deploying them is gone. The apply did nothing during the experiment because nothing changed but if changes were made to `main.tf`, it would've applied
that change to my AWS account.
