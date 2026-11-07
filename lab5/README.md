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

