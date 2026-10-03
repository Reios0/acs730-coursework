# Lab 2

Instructions for this section will be provided in class and on Blackboard when we reach it.

Put your work for Lab 2 in this folder.

## Deployment steps
First things first, before anything else, the script was set such that it stops at the first error. It installs Python3 with dnf 
then creates a service user if it doesn't already exist. It creates the application directory and creates an index.html, then installs the 
systemd unit by copying the service file before running `daemon-reload` so systemd can see it. It enables and starts the service before
finally making a curl request to check locally.

## Difference between systemctl start and systemctl enable
`systemctl start` starts the service, but doesn't persist after shutdown while `systemctl enable` allows it to start on every boot (or
survive reboots).

## Why SSH is restricted
SSH is restricted so that it is limited to a single address (the workstation's IP). This is so no one else can even attempt to login.
HTTP is open because it is what the web server exists to provide (anybody can access the web server and take a look at it).

## Application user
The application runs as `acs730web`, which is an user (or system account) with no home directory, no login shell, and no administrative
rights. `acs730web` is used instead of root because if the account ever gets compromised, the attacker only has limited permissions instead
of full administrative access.

## Experiments
### `start` without `enable`
**Prediction:** `curl` fails with connection refused with `systemctl status` saying something about it being inactive.
**What happened:** `curl` was refused and status showed `inactive (dead)`.

### Tighten HTTP
**Prediction:** `curl` from workstation will hang and time out but my laptop's browser should still load.
**What happened:** `curl` timed out while the page loaded on my laptop's browser. The difference is that my laptop's IP was explicitly 
allowed.
