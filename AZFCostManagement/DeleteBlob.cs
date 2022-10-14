using CostManagement.Helpers;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Azure.Storage.Blobs;
using AZFCostManagement.Models;

namespace AZFCostManagement
{
    public static class DeleteBlob
    {
        
        
        [FunctionName("DeleteBlob")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            var Storage = new StorageAccountSettings();
            var config = ConfigHelper.BuildConfig(context, log);
            Storage.Name = config["AccountName"];
            Storage.Key = config["AccountKey"];
            await DeleteBlobs(Storage);

            return new OkObjectResult("Se ha enviado a eliminar el blob. Esta operación puede tardar unos minutos");
        }

        private static async Task DeleteBlobs(StorageAccountSettings Storage)
        {
            string connectionString = $"DefaultEndpointsProtocol=https;AccountName={Storage.Name};AccountKey={Storage.Key};EndpointSuffix=core.windows.net";
            string containerName = "costexport";
            BlobContainerClient container = new BlobContainerClient(connectionString, containerName);
            await container.DeleteIfExistsAsync();
        }

    }
}
