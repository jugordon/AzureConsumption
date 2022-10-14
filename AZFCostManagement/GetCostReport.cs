using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using CostManagement.Helpers;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Azure.Storage.Blobs;
using Azure;
using System.Threading;
using CostManagement.Models;
using ExecutionContext = Microsoft.Azure.WebJobs.ExecutionContext;
using AZFCostManagement.Models;

namespace AZFCostManagement
{
    public static class GetCostReport
    {
        private static ILogger Log;

        [FunctionName("GetCostReport")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            Log = log;
            Log.LogInformation("Iniciando el llamado para la exportación de costos");
            var AppReg = new AzureAppReg();
            var Storage = new StorageAccountSettings();
            var config = ConfigHelper.BuildConfig(context, log);
            
            Storage.Name = config["AccountName"];
            Storage.Key = config["AccountKey"];
            AppReg.TenantID = config["TenantID"];
            AppReg.ClientID = config["ClientID"];
            AppReg.SecretValue = config["SecretValue"];
            string BillId = config["BillID"];
            //Assign value to max check if error  default 15 times
            if (!int.TryParse(config["MaxChecks"], out int MaxChecks))
                MaxChecks = 15;

            CostManagementConfig costManagementConfig = await ReadRequestProperties(req);
            var CurrentDate = DateHelper.GetDate().AddMonths(costManagementConfig.Period);
            string ArchiveSuffix = CurrentDate.ToString("MMyyyy");
            string PeriodName = CurrentDate.ToString("yyyyMM");
            string token = await GetAccessToken(AppReg);
            var json = await CallExport(token, BillId, PeriodName);

            int Checks = 0;
            while (json.StartsWith("https://") && Checks < MaxChecks)
            {
                Console.WriteLine("Revisar avance de la exportacón cada 20 segundos");
                Thread.Sleep(20000);
                json = await GetStatus(token, json);
                Checks++;
            }
            if (json.StartsWith("https://"))
            {
                log.LogError("Se termino el tiempo de espera, debería volver a ejecutar el proceso");
                return new BadRequestObjectResult("Time Out");
            }
            else if (string.IsNullOrWhiteSpace(json))
            {
                log.LogError("No se recibio la respuesta esperada, por favor revise las configuraciones de su 'App Registration'");
                return new BadRequestObjectResult("Empty or null response");
            }

            var JSONObject = JsonConvert.DeserializeObject<CostDetails>(json);
            foreach (var url in JSONObject.Manifest.Blobs)
            {
                log.LogInformation("Copiando el archivo generado a un Blob Local");
                await SavetoLocal(url.BlobLink,Storage, ArchiveSuffix);
            }

            string responseMessage = "Se ha ejecutado la operación.";
            return new OkObjectResult(responseMessage);
        }

        private static async Task<string> GetAccessToken(AzureAppReg AppReg)
        {
            Log.LogInformation("Obteniendo token de autenticación");
            string authContextURL = "https://login.windows.net/" + AppReg.TenantID;
            var authenticationContext = new AuthenticationContext(authContextURL);
            var credential = new ClientCredential(AppReg.ClientID, AppReg.SecretValue);
            var result = await authenticationContext
            .AcquireTokenAsync("https://management.azure.com/", credential);
            if (result == null)
            {
                throw new InvalidOperationException("Failed to obtain the JWT token");
            }
            string token = result.AccessToken;
            return token;
        }
        private static async Task<string> GetStatus(string token, string uri)
        {
            Log.LogInformation("Obteniendo el estado de la operación de exportación");
            var HttpsResponse = await ResponseHelper.GetResponse(token, uri);

            if (string.IsNullOrWhiteSpace(HttpsResponse))
            {
                Log.LogInformation("El sistema sigue procesando. Se debe esperar más");
                return uri;
            }
            else
            {
                return HttpsResponse;
            }
        }
        private static async Task<string> CallExport(string token, string billingAccountId, string PeriodName)
        {
            Console.WriteLine("Se inicia la obtención de entidades");
            string URI = $"https://management.azure.com/providers/Microsoft.Billing/billingAccounts/{billingAccountId}/providers/Microsoft.CostManagement/generateCostDetailsReport?api-version=2022-05-01";
            var data = new
            {
                metric = "ActualCost",
                billingPeriod = $"{PeriodName}"
            };
            var body = JsonConvert.SerializeObject(data);
            var HttpsResponse = await ResponseHelper.PostBodyResponse(token, URI, body);
            if (string.IsNullOrWhiteSpace(HttpsResponse.Message))
            {
                Console.WriteLine("El sistema esta procesando. Se revisará el estado un poco más tarde.");
                return HttpsResponse.Location;
            }
            else
            {
                return HttpsResponse.Message;
            }
        }
        private static async Task SavetoLocal(string url, StorageAccountSettings storage, string ArchiveSuffix)
        {
            Console.WriteLine("Copiando...");
            string connectionString = $"DefaultEndpointsProtocol=https;AccountName={storage.Name};AccountKey={storage.Key};EndpointSuffix=core.windows.net";
            string containerName = "costexport";
            try
            {
                BlobContainerClient Destinycontainer = new BlobContainerClient(connectionString, containerName);
                Destinycontainer.CreateIfNotExists();
                
                BlobClient destBlob = Destinycontainer.GetBlobClient($"AzureCost/Details{ArchiveSuffix}.csv");
                Log.LogInformation("Iniciando la copia, esta copia puede tardar unos minutos...");
                await destBlob.StartCopyFromUriAsync(new Uri(url));
            }
            catch (RequestFailedException ex)
            {
                Console.WriteLine(ex.Message);
                return;
            }
        }
        private static async Task<CostManagementConfig> ReadRequestProperties(HttpRequest req)
        {
            string Period = req.Query["Period"];
            string requestBody = String.Empty;
            using (StreamReader streamReader = new StreamReader(req.Body))
            {
                requestBody = await streamReader.ReadToEndAsync();
            }
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            Period ??= data?.Period;
            if (!int.TryParse(Period, out int PeriodValue))
                PeriodValue = 0;
            //Limit Period 
            if (PeriodValue > 3)
                PeriodValue = 3;
            //Change as negative
            PeriodValue = -Math.Abs(PeriodValue);

            var CostManagementConfig = new CostManagementConfig() { Period = PeriodValue };  
            return CostManagementConfig;
        }
    }
}
