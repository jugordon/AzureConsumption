using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace CostManagement.Models
{
    public class AzureCostExport
    {
        [JsonProperty("value")]
        public List<ExportValues> Values { get; set; }
    }

    public class ExportValues
    {
        [JsonProperty("id")]
        public string ID { get; set; }

        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("properties")]

        public ExportProperties Properties { get; set; }

    }

    public class ExportProperties
    {
        [JsonProperty("schedule")]
        public ExportSchedule Schedule { get; set; }
        [JsonProperty("deliveryInfo")]
        public DeliveryInfo DeliveryInfo { get; set; }
    }

    public class ExportSchedule
    {
        [JsonProperty("status")]
        public string Status { get; set; }

        [JsonProperty("recurrence")]
        public string Recurrence { get; set; }
    }

    public class DeliveryInfo
    {
        [JsonProperty("destination")]
        public Destination Destination { get; set; }
    }

    public class Destination
    {
        [JsonProperty("resourceId")]
        public string ResourceID { get; set; }

        [JsonProperty("container")]
        public string Container { get; set; }
        [JsonProperty("rootFolderPath")]
        public string RootFolderPath { get; set; }
    }
}
