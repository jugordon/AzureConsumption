# Azure Consumption Monitoring Solution

This project will allow you to have an end to end solution to monitor your Azure Consumption, leveraging the use of some Azure Data Services and Azure Cost Management API ( https://learn.microsoft.com/en-us/rest/api/cost-management/ )

## Requirements

Permissions 
1. User with EntraID administration permissions in Azure ( It will be used for setting the role of the service principal)
2. Azure subscription and a resource group with permission to create resources

Software required for the deployment : 
1. [PowerBI Desktop] (https://www.microsoft.com/en-us/download/details.aspx?id=58494) ![image](https://github.com/user-attachments/assets/088a8eac-a29e-48d0-b020-6669b362e681)
2. Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=msi ) ![image](https://github.com/user-attachments/assets/eebbb788-d7fb-463f-8ce3-8fd9c39fc946)
3. SQL Server Management studio or any SQL client (https://learn.microsoft.com/en-us/ssms/install/install) ![image](https://github.com/user-attachments/assets/38ff9452-8e01-48ed-88a9-76e3b1795583)

Create the following Azure resources:
1. [Storage account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal#create-a-storage-account-1).   - Standard Tier and LRS
2. [Azure Function](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-app-portal) - Consumption, .NET 8 (LTS ) isolated
3. [Azure SQL Single Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/single-database-create-quickstart?view=azuresql&tabs=azure-portal) - General purpose , serverless recommended , locally redundant storage
4. [Azure Data Factory](https://learn.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory) - V2

## High level architecture 

![diagramaSolucion](https://user-images.githubusercontent.com/43896401/194111466-baf1b709-27f6-4ad2-bd3c-ffff7d3b9a31.jpg)

## Getting permission to authenticate with the Cost management API

1. Create a service principal
2. Add permissions to the SP
   - For Customers with Enterprise Agreements please https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals
   - For customers with Microsoft Agreements https://learn.microsoft.com/en-us/azure/cost-management-billing/manage/understand-mca-roles#manage-billing-roles-in-the-azure-portal

## Deploy of Azure Function

## SQL Database objects

1. Open the files objetosSQLConsumo.sql and StoredProcedures in your prefered text editor.
2. Replace {nombre_cliente} with the name of your organization
3. Run the file objectosSQLConsumo.sql in  your database.
4. Run the file StoredProcedures in  your database.

## Azure Data Factory configuration

(https://github.com/jugordon/AzureConsumption/blob/main/resources/ADFPipeline.jpg)



1. Download the template to your computer costMasterPipelineGenericov2.
2. Import the template into ADF Piplines ![Import pipeline](https://github.com/jugordon/AzureConsumption/blob/main/resources/importTemplate.jpg)
3. Configure the linked services for each one of the following elements :
4. a. Blob Storage account
5. b. SQL Database 
6. c. Azure Functions 



Current limitation : You can only extract data from the last 3 months + the current month.
