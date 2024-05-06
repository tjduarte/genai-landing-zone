# 🚀 Building Enterprise Landing Zones for AI Apps

![Sample Architecture](images/sample_architecture.png)

This repository contains all the artifacts that have been used to build the infrastructure presented at Microsoft Build AI Day in Switzerland during my session.
With minimum setup, you can clone this repository and start working with your IT team to build an initial landing zone aimed at unlocking the usage of Azure OpenAI in your organization.

## Contents

```
├── images (Images used in the readme.md file)
├── samples
│   ├── load-balancer/loadbalancer (A .NET 8 console application to test chat completion API calls against Azure Open AI and API Management)
│   ├── storage (Contains documents uploaded to Azure AI search for demo purposes)
├── terraform
│   ├── deployment (Contains the terraform modules used to deploy the infrastructure used during the session)
│   │   ├── **/*.tf
│   ├── post-configuration (Contains the terraform modules used to configure Azure AI Search with a data source, an indexer, a skillset and an index)
│   │   ├── **/*.tf
├── tests
│   ├── chat-completion.ps1 (Test an API call to Azure Open AI Chat completion endpoint from the Virtual Machine)
│   ├── lookup-services.ps1 (Performs an nslookup to the 4 endpoints of the services with private endpoints)
│   ├── lookup-services.bash (Performs an nslookup to the 4 endpoints of the services with private endpoints)
└── .gitignore
```

## Quick Start

### Step 1
Clone or download this repository to your machine.

### Step 2
Create a terraform variable file to be used as an input (*.tfvars). 
The example below illustrates how the file should be structured. 
You can also open [variables.tf](terraform/deployment/variables.tf) and check the required variables and formats.

```terraform
variable "resource_suffix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group" {
  type = object({
    name = string
  })
}

variable "network_resource_group" {
  type = object({
    name = string
  })
}

variable "open_ai" {
  type = object({
    name      = string
    locations = list(string)
  })
}

variable "storage" {
  type = object({
    name           = string,
    container_name = string
  })
}

variable "ai_search" {
  type = object({
    name        = string,
    api_version = string
  })
}

variable "apim" {
  type = object({
    name = string
  })
}

variable "front_door" {
  type = object({
    name = string
  })
}

variable "tags" {
  type = map(string)
}

variable "virtual_network" {
  type = object({
    name          = string,
    address_space = list(string)
    subnets = object({
      ai   = string,
      apim = string,
      vm   = string
    })
  })
}

variable "virtual_machine" {
  type = object({
    name = string
  })
}
```

### Step 3

Open a terminal window and login with an account with contributor permissions on the subscription you wish to use.

```bash
az login --tenant [Tenant_ID]
az account set -n [Subscription_ID]
```

### Step 4

Initialize your terraform workspace inside /terraform/deployment and plan the deployment.

```bash
terraform init
terraform plan -out plan -var-file variables.tfvars
```

Once you are happy with the changes apply the plan

```bash
terraform apply plan
```

### Step 5

After the deployment has been successfully done, initialize your terraform workspace inside /terraform/post-configuration and plan the deployment.
This module creates the Index, Data source, Skillset and Indexer required to process documents uploaded to the storage account.

```bash
terraform init
terraform plan -out plan -var-file variables.tfvars
```

Once you are happy with the changes apply the plan

```bash
terraform apply plan
```

## Support

If you encounter any issue or have questions about this repo, please open a discussion.
I will be monitoring it for some time after the presentation.

Have fun!