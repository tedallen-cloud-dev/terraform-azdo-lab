# terraform-azdo-lab
Azure DevOps + Terraform: CI/CD Infrastructure Deployment (Self-Hosted Agent)
# Azure DevOps + Terraform: CI/CD Infrastructure Deployment (Self-Hosted Agent)

This project demonstrates an end-to-end Infrastructure-as-Code workflow using **Terraform** and **Azure DevOps Pipelines** to provision Azure networking resources. The pipeline executes `terraform init`, `validate`, `plan`, and `apply`, and deploys infrastructure into Azure in a repeatable, version-controlled way.

## What This Project Does
The pipeline provisions:
- A Resource Group
- A Virtual Network (VNet)
- Multiple Subnets (e.g., app + db)

## What I Deployed (Azure)
Terraform provisions the following resources:

- **Resource Group:** `rg-terraform-azdo-lab`
- **Virtual Network:** `vnet-terraform-azdo-lab`
- **Subnets:** `subnet-app`, `subnet-db`

## Why This Is Portfolio-Worthy
This setup mirrors a real DevOps pattern:
- Infrastructure is defined as code (Terraform)
- Changes are executed via a CI/CD pipeline (Azure DevOps)
- A self-hosted agent can unblock builds when Microsoft-hosted parallelism isn’t available
- The workflow is repeatable and version-controlled

## Architecture (High Level)
1. Developer pushes Terraform/YAML changes to Azure Repos
2. Azure DevOps Pipeline runs on a **self-hosted macOS agent**
3. Pipeline authenticates using an Azure Service Connection
4. Terraform stores state in an Azure Storage backend
5. Terraform plans and applies changes to Azure resources

## Pipeline Overview
The pipeline is defined in `azure-pipelines.yml` and uses:
- `TerraformInstaller@1` to install Terraform
- `TerraformTaskV4@4` to run `init`, `validate`, `plan`, and `apply`

The pipeline includes two stages:
- `tfvalidate`: init + validate
- `tfdeploy`: init + plan + apply (runs only if validation succeeds)

## Remote State Backend
Terraform uses the `azurerm` backend. Backend values are passed during pipeline `init` using variables:
- Resource Group: `adoTFpipe`
- Storage Account: `bkestg`
- Container: `bkecontainer`
- Key: `state`

> Note: Backend resources must exist and the Service Connection must have access.

## Self-Hosted Agent Notes
This pipeline runs on a self-hosted agent pool (e.g., `selfhosted-mac`). This was used to avoid Azure DevOps hosted parallelism limitations and to run jobs immediately.

## How to Run Locally (Optional)
```bash
terraform fmt
terraform init
terraform validate
terraform plan
