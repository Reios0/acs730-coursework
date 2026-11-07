# Lab 5

## Why for_each here and count there

**Subnets use for_each:** They have stable names so Terraform tracks them as aws_subnet.public["a"] and ["b"]. The map key is the identity so adding key "c" creates one
new subnet. Remove "a" destroys only "a" and doesn't touch "b".

**Why count would be a trap:** The addresses are [0], [1], and [2] with count, and Terraform matches state to config by position. Deleting the middle entry shifts everything
after it so Terraform would see a different subnet at the same index and plans to destroy and recreate subnets that were not meant to be touched.

**The bucket uses count:** create_artifact_bucket is a yes/no choice about one resource so there are only two outcomes: "0 to add" and "1 to add". There are no set of items
whose identities need to remain stable.

**Similarities to programming:** A map correlates each key to a resource so specific resources can be added/deleted/modified. An array/list only cares about storing a bunch
of resources together, with no way of knowing which resource is at which index at all times. Removing something from a specific index will shift everything forward by 1, 
mutating the places of all resources.

**Rule of thumb:** Use count when we only care about how many, and for_each when we care about which ones.

## Why not plan and apply against real AWS on every pull request

- **Cost per run:** Every PR would build and destroy real AWS infrastructure which depletes the budget. LocalStack is free and leaves nothing behind.

- **Long-lived credentials:** Applying from Actions needs an AWS access key in GitHub secrets, which has the risk of leaking and require rotating. IAM writes are denied in 
AWS Academy so the access can't be scoped.

- **Academy sessions expire:** Lab credentials only last for hours, so a PR opened at night can fail the next morning for reasons unrelated to the code. If people start to 
ignore red checks because of this, then thats worse than just having no checks at all.

- **Slow and flaky:** Each run can take minutes which is slow. It is also flaky because API rate limits, eventual-consistency errors and concurrent PRs colliding on names and
state in one account can cause failures unrelated to the change.

- **Limits of LocalStack:** A green run for LocalStack only proves that the configuration is coherent and it builds. It doesn't prove IAM is correct because LocalStack 
doesn't enforce it. It also doesn't prove that user_data works since it never boots the actual instance. An actual AWS check belongs on merge or on a schedule, not on every 
PR.

## What I built

One Terraform configuration that targets LocalStack or real AWS through `use_localstack` consisting of: a VPC, two public subnets, internet gateway, route table and its
association, security group, and an EC2 web server with user_data. The CI runs fmt/validate first, then plan and apply against a LocalStack service container without real
AWS credentials.

## Experiments

### Experiment 3

**Prediction:** The "fmt and validate" job will fail at the `terraform fmt -check` step and the LocalStack job gets skipped.

**Explanation:** `Validate` passes but `terraform fmt -check` fails on any file that isn't formatted correctly. Since the LocalStack requires the `gates` job to pass, it 
doesn't start which saves the time it would have spent pulling the container and running a full apply (roughly a minute). Running `terraform fmt -recursive` fixes it.

### Experiment 4

**Prediction:** `terraform output artifact_bucket` will print `null` and changing `one()` to `[0]` will cause an error.

**Explanation:** With the bucket turned off, `count` is 0 so the resource is an empty list. `one()` turns an empty list into `null` but since it got changed to `[0]` which 
asks for the first item of an empty list, Terraform fails with an index error.
