# Lab 3

## Terraform Version
Terraform v1.16.5

## Why OIDC and Session-Scoped Secrets
A real account would use OIDC rather than stored keys because GitHub's token issuer is registered as an identity provider and an IAM role trusts it (for 
that repository) so it gets a short-lived token from STS with no long-lived secret to rotate or possibly leak. This course uses session-scoped secrets
because AWS Academy denies IAM writes, which limits the damage if leaked because the session secrets expire as soon as the lab session ends.
