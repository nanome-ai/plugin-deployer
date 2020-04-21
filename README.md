# Auto Deploy the Nanome Plugin Starter Pack

A quick script to deploy the Nanome plugin starter pack

## Nanome Plugin Starter Pack Deployment Instructions

In order to successfully complete the deployment of Nanome’s starter pack group of plugins, you will need to verify that your license is Stack Enabled and you have the Stack Configuration details in-hand (consists of an IP address and a port). 

For Non-Enterprise Customers, please verify that your Nanome Licenses are Plugin Enabled with your Nanome representative.

As of March 17, 2020 - the plugins a part of the starter pack are:

- Chemical Properties - cheminformatics calculation using RDKit
- Docking - using Smina software
- Real-Time Atom Scoring - using DSX software
- RMSD - structural alignment
- Structure Prep - re-calculate bonds and ribbons for Quest users
- Vault - web-based file management (perfect for Quest)

### Step 1: Provisioning the Dedicated Plugins Virtual Machine

Specifications:
Amazon AWS T2.medium EC2 Linux machine with 30 GB of disk storage or equivalent

Equivalent

- A Linux based operation system (Ubuntu or CentOS)
- 2 CPU - equiv. to an Intel Broadwell E5-2686v4 or higher
- 4GB of RAM
- 30GB of Storage space

### Step 2: SSH into the VM + Install Git & Docker

SSH into the VM using the IP address and the user

```sh
ssh ec2-user@<ip-address>

sudo yum install git
sudo yum install docker
sudo service docker start
```

### Step 3: Pull the plugin starter pack auto-deploy script and run it

```sh
git clone https://github.com/nanome-ai/plugin-deployer
cd plugin-deployer

sudo ./deploy.sh -a <your Nanome Stack Config IP> -p <your Nanome Stack Config port>
```

NOTE: to add arguments specific to a plugin, append any number of `--plugin <plugin-name> [args]` to the `./deploy.sh` command.

### Step 4: Docker Container Health Check

Now check to make sure all the docker containers are working properly

```sh
docker ps
```

This should list out the plugins that are currently running. Please verify that none of the containers in the column labeled 'X' has a "restarting (x sec)".

### Step 5: Validate the connection from the VR client

Go ahead and log onto the VR client computer and launch Nanome

\*Note the VR Client computer and the dedicated Plugins VM need to be a part of the same IT firewall network
