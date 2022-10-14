using CostManagement.Models;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace CostManagement.Helpers
{
    public static class ResponseHelper
    {
        public static async Task<string> GetResponse(string token, string URI, string body)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri("https://management.azure.com/"),
            };
            httpClient.DefaultRequestHeaders.Remove("Authorization");
            httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);

            var request = new HttpRequestMessage
            {
                Method = HttpMethod.Post,
                RequestUri = new Uri(URI),
                Content = new StringContent(body, Encoding.UTF8, "application/json"),
            };

            var response = await httpClient.SendAsync(request).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsStringAsync().ConfigureAwait(false);
        }
        public static async Task<string> GetResponse(string token, string URI)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri("https://management.azure.com/")
            };
            httpClient.DefaultRequestHeaders.Remove("Authorization");
            httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);

            HttpResponseMessage response = await httpClient.GetAsync(URI);
            response.EnsureSuccessStatusCode();
            return await response.Content.ReadAsStringAsync();
        }
        public static async Task<string> PutResponse(string token, string URI, string body)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri("https://management.azure.com/"),
            };
            httpClient.DefaultRequestHeaders.Remove("Authorization");
            httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);
            var Content = new StringContent(body, Encoding.UTF8, "application/json");

            var response = await httpClient.PutAsync(new Uri(URI), Content).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsStringAsync().ConfigureAwait(false);
        }
        public static async Task<string> PostResponse(string token, string URI)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri("https://management.azure.com/")
            };
            httpClient.DefaultRequestHeaders.Remove("Authorization");
            httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);
            try
            {
                HttpResponseMessage response = await httpClient.PostAsync(URI, null);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception exc)
            {
                Console.WriteLine($"Se ha detectado el siguiente error: {exc.Message} al llamar la url {URI}");
                return "Error";
            }
        }

        public static async Task<AzureResponse> PostBodyResponse(string token, string URI, string body)
        {
            var httpClient = new HttpClient()
            {
                BaseAddress = new Uri("https://management.azure.com/"),
            };
            httpClient.DefaultRequestHeaders.Remove("Authorization");
            httpClient.DefaultRequestHeaders.Add("Authorization", "Bearer " + token);
            var Content = new StringContent(body, Encoding.UTF8, "application/json");
            var response = await httpClient.PostAsync(URI, Content).ConfigureAwait(false);
            response.EnsureSuccessStatusCode();

            var azureresponse = new AzureResponse
            {
                Location = response.Headers.Location.ToString(),
                Message = await response.Content.ReadAsStringAsync().ConfigureAwait(false)
            };
            return azureresponse;
        }
    }
}
