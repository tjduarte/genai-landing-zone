# Azure AI Landing Zone

## Initial Setup

### Login with an admin account using Azure CLI

```bash
az login --tenant {{Tenant ID}}
az account set -n {{Subscription ID}}
```

### Terraform init

```bash
terraform init
terraform plan -out plan -var-file variables.tfvars
terraform apply plan
```

## After Deployment

### Azure AI Search Configuration

1. Open the Azure AI Search service in the Azure Portal
2. Navigate to Networking and then Shared private access
3. Click on + Add shared private access
4. Give it a name
5. Select the subscription where the Azure OpenAI service has been created
6. Select the Resource Type **Microsoft.CognitiveServices/accounts**
7. Select the Azure OpenAI resource you would like to connect to
8. Select the Target sub-resource **openai_account**
9. Click **Create**
10. The provisioning can take a couple of minutes
11. When it is done the Connection state should state **Pending**
12. At this point open the Azure OpenAI service in the Azure Portal
13. Navigate to Networking and then Private endpoint connections
14. Select the connection with a Connection state **Pending** and then click **Approve**