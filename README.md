# Initial Configuration Guide

## Overview

The **skeleton-infra** repository provides example configurations for various infrastructure use cases. The **initial-conf** setup is designed for first-time deployments to help users understand the basic folder structure and setup. This deployment includes two primary resources:

* **VPC (Virtual Private Cloud)** – A prerequisite for ECS Cluster deployment.
* **ECS Cluster** – A container orchestration service dependent on VPC.

## Getting Started

1. Copy the `initial-conf` directory into your team-specific repository.
2. Ensure that you also copy the `.gitignore` file.
3. Rename the `skeleton-dev` directory to match your specific AWS account.
4. Deploy the infrastructure following the steps below.

## Deployment Steps

**1. Deploy Resources Separately**

Deploy the **global VPC**, which can be shared across multiple ECS Clusters in different environments:

```
terragrunt run-all apply --provider-cache --working-dir skeleton-dev/global/eu-central-1/common/vpc/dev/
```

Deploy an ECS Cluster under the **T1 environment**:

```
terragrunt run-all apply --provider-cache --working-dir skeleton-dev/t1/eu-central-1/skeleton/ecs_clusters/mycluster/
```

**2. Deploy All Resources Under an AWS Account**

Instead of deploying resources separately, you can deploy all resources within your AWS account at once:

```
terragrunt run-all apply --provider-cache --working-dir skeleton-dev
```

**3. Create a New ECS Cluster Under T1**

To create an additional ECS Cluster in **T1**, follow these steps:

1. Copy the existing `mycluster` folder.
2. Rename the copy to `mycluster2` under `ecs_clusters`.
3. Deploy the second ECS Cluster:

```
terragrunt run-all apply --provider-cache --working-dir skeleton-dev/t1/eu-central-1/skeleton/ecs_clusters/mycluster2/
```

**4. Create a New T2 Environment**

To create a **T2 environment**, follow these steps:

1. Copy the existing **T1** folder.
2. Rename the copy to **T2**.
3. Deploy the ECS Cluster under **T2**:

```
terragrunt run-all apply --provider-cache --working-dir skeleton-dev/t2/eu-central-1/skeleton/ecs_clusters/
```

**5. Remove All Resources**

To remove all deployed resources, run:

```
terragrunt run-all destroy --provider-cache --working-dir skeleton-dev
```

### NOTES:

Using fastest deployment parameters by skipping dependencies, yes button and global caching:

`terragrunt run-all apply --non-interactive --provider-cache --queue-exclude-external --working-dir <path>`
