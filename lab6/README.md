# Lab 6

## Which runner-to-instance mechanism you used, and why
The workflow reaches the instances through Session Manager because theres no port 22 open. The runner uses the temporary AWS credentials to authenticate so theres no private key in the repository secrets.


## What changed=0 on a second run proves
A second run reporting that theres nothing changes means that every task looked at the real state of the host and found that it already matches what the roles asks for so nothing needs to be changed.


## Why deregistering an AMI is not enough
Deregistering an AMI only removes the pointer (since an AMI is a pointer). The EBS is what stores the data and incurs the bill, and it still stays even after deregistering the AMI.


## A table when your two measured numbers
| Method | Seconds | What's included |
| --- | --- | --- |
| Converge on boot | 140s| Terraform replacing the instance, booting, SSM agent registration, dnf package installation, playbook, then service start |
| Golden AMI | 32s | running instances, booting, then starting the service |


## Where the time actually went
For the converge (slow) path, most of the time was spent waiting for the SSM agent to register and pulling packages over the network through dnf.


## The cost a golden AMI moves rather than removes
Golden AMIs still need to register the SSM agent and download packages, but its done once on build time instead of an instance-by-instance basis. It saves time in the long run, but costly if its only done once.


## What breaks with golden AMIs
An image stays as it is after build time, so any updates released afterwards is not applicable and requires the AMI to be rebuilt to apply.


## What breaks with converge-on-boot
Every time an instance launches, it must download the packages so there is a network dependency on the boot path. If there are connectivity issues, the instances will boot but won't become ready.


## Recommendation
My recommendation is the Golden AMI, because we launch instances in groups for autoscaling. If its only one or two instances that needs to be launched, then I'd choose the converge-on-boot.


## Experiments

### Breaking idempotency with shell task
Prediction: The second run reports changed=1 for mkdir and changed=0 for creates
Result: Changed=1 for mkdir and changed=0 for creates. This is because shell commands always gets reported as changed as Ansible cannot know what the command did, so it assumes the worst. Creates tells Ansible to first check if the directory (or file) already exists before running a task, which is why Ansible now marks it as changed=0.

### state: latest vs. state: present
Prediction: Both runs return changed=0. My answer changes depending on whether there was an update that day.
Result: Change=0 for both. In a pipeline that runs on every merge, I'd use present instead of latest for a predictable and idempotent deployment. Unexpected upgrades/updates could break compatibility, which may cause the pipeline to erroneously point at an unrelated area as the root cause of failure.
