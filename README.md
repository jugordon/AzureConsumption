# Azure Consumption Monitoring Solution

This project will allow you to have an end to end solution to monitor your Azure Consumption, leveraging the use of some Azure Data Services and Azure Cost Management API ( https://learn.microsoft.com/en-us/rest/api/cost-management/ )

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

## High level architecture 

![diagramaSolucion](https://user-images.githubusercontent.com/43896401/194111466-baf1b709-27f6-4ad2-bd3c-ffff7d3b9a31.jpg)

## Setup Guide

### Getting permission to authenticate with the Cost management API

1. Create a service principal
2. Add permissions to the SP
   - For Customers with Enterprise Agreements please https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals
   - For customers with Microsoft Agreements https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/understand-mca-roles#manage-billing-roles-in-the-azure-portal

## Deploy of Azure Function
1. Download the zip file functionApp/costMasterPipelinev3.zip that containsthe deployment files of the function
2. In Azure CLI execute the following commands :
   - Az login   and login with your Azure credentials
   - az account set --subscription <subscriptionId>  , replace <subscriptionId> with the subscriptionId where you have your Azure Resources
   - az functionapp deployment source config-zip -g <resource_group> -n \<app_name> --src <zip_file_path>
3. Wait a couple of minutes and you should see both functions deployed :
  ![Functions deployed](https://github.com/jugordon/AzureConsumption/blob/main/resources/bothfunctions.png)

## Configure Key Vault Secrets

![KeyVault Secrets](https://github.com/jugordon/AzureConsumption/blob/main/resources/keyvaultsecrets.png)


## Configure Azure Function Environment Variables
Configure the following environment variables : 
1. 

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
![ADF Pipeline](https://github.com/jugordon/AzureConsumption/blob/main/resources/dataFactoryPipeline.jpg)

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

