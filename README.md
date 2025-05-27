# Azure Consumption Monitoring Solution

This project will allow you to have an end to end solution to monitor your Azure Consumption, leveraging the use of some Azure Data Services and Azure Cost Management API ( https://learn.microsoft.com/en-us/rest/api/cost-management/ )

## High level architecture 

![diagramaSolucion](https://github.com/jugordon/AzureConsumption/blob/main/resources/newCostArchitecture.png) 


## Requirements

Permissions 
1. User with EntraID administration permissions in Azure ( It will be used for setting the role of the service principal)
2. Azure subscription and a resource group with permission to create resources

Software required for the deployment : 
1. [PowerBI Desktop](https://www.microsoft.com/en-us/download/details.aspx?id=58494)
2. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=msi )
3. [SQL Server Management studio or any SQL client](https://learn.microsoft.com/en-us/ssms/install/install)

Create the following Azure resources:
1. [Storage account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal#create-a-storage-account-1).   - Standard Tier and LRS
2. [Azure Function](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-app-portal) - Consumption, .NET 8 (LTS ) isolated
3. [Azure SQL Single Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart?view=azuresql&tabs=azure-portal) - General purpose , serverless recommended , locally redundant storage
4. [Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory) - V2
5. [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/quick-create-portal) - Pricing tier standard , disable purge protection, permission model Azure role-based access control


## Setup Guide

### Getting permission to authenticate with the Cost management API

1. Create a service principal
   - Save the following values : application ID , tenantID and secret value 
2. Add the role Enrollment reader to the Service Principal : 
   - For Customers with Enterprise Agreements (EA) please follow this guide : https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals
   - For customers with Microsoft Agreements please follow this guide : https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/understand-mca-roles#manage-billing-roles-in-the-azure-portal

## Create Azure Storage Container
1. Go to your storage account service and create a new containaer ( suggested name costexport)

![New Container](https://github.com/jugordon/AzureConsumption/blob/main/resources/newContainer.png)

## Deploy of Azure Function
1. Download the zip file functionApp/CostManagementFunction.zip that contains the deployment files of the function
2. In Azure CLI execute the following commands :
   - Az login   and login with your Azure credentials
   - az account set --subscription <subscriptionId>  , replace <subscriptionId> with the subscriptionId where you have your Azure Resources
   - az functionapp deployment source config-zip -g <resource_group> -n \<app_name> --src <zip_file_path>
3. Wait a couple of minutes and you should see both functions deployed :
  ![Functions deployed](https://github.com/jugordon/AzureConsumption/blob/main/resources/bothfunctions.png)

## Configure Key Vault Secrets

Add the following key vault secrets : 
1. AccountKey -> Access key of storage account
2. AzureSQL -> Connection string of SQL Database ( .NET SQL Authentication) ( https://learn.microsoft.com/en-us/azure/azure-sql/database/connect-query-content-reference-guide?view=azuresql#get-adonet-connection-information-optional---sql-database-only )
3. SecretValue -> Secret of the service principal ( obtained from service principal creation )

![KeyVault Secrets](https://github.com/jugordon/AzureConsumption/blob/main/resources/keyvaultsecrets.png)

### Allow the function app to read key vault secret permissions
1. In the function app, enable system identity
2. ![Function identity](https://github.com/jugordon/AzureConsumption/blob/main/resources/functionIdentity.png)
3. In the key vault account, go to Access Control (IAM) and add the role Key Vault Secret User to the managed identity of the function app

![KeyVault Secrets](https://github.com/jugordon/AzureConsumption/blob/main/resources/keyvaultsecretuser.png)

## Configure Azure Function Environment Variables
Add the following environment variables : 
1. AccountName -> Name of the storage account
2. BillID -> BillID or enrollment number
3. ClientID -> Application ID of the service principal ( obtained from service principal creation )
4. ContainerName -> Name of storage container previously created
5. KeyVault -> Name of the key vault account
6. TenantID -> Tenant ID ( obtained from service principal creation )

![FunctionEnvVariables](https://github.com/jugordon/AzureConsumption/blob/main/resources/functionEnvVariables.png)

## SQL Database objects

### Table Objects 
Inside the Table folder execute the following file : 
1. consumption_tables.sql

### Stored procedures 
Inside the StoredProcedures folder execute the following file : 
1. funcionGetNumeric.sql
2. StoredProcedures_operacion.sql
3. costos_procesamiento.sql

### Permissions
Inside the Table folder execute the following file : 
1. permissions.sql

## Azure Data Factory configuration
![ADF Pipeline](https://github.com/jugordon/AzureConsumption/blob/main/resources/dataFactoryPipeline.png)

Now we are going to import the Azure Data Factory that will orchestrate the complete data flow between the Azure Consumption API and the SQL Database

1. Download the pipeline template to your computer from ADFPipeline/costMasterPipelinev3.zip.
2. Import the template into ADF Piplines ![Import pipeline](https://github.com/jugordon/AzureConsumption/blob/main/resources/importTemplate.jpg)
3. Configure the linked services for each one of the following elements :
4. a. Blob Storage account
5. b. SQL Database 
6. c. Azure Functions 

## Schedule the daily execution of the pipeline using triggers

1. Select new triger ![New trigger](https://github.com/jugordon/AzureConsumption/blob/main/resources/new_trigger.png)
2. Configure the daily trigger
3. ![Trigger wizard](https://github.com/jugordon/AzureConsumption/blob/main/resources/trigger_wizard.png)

