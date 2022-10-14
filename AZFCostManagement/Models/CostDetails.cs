using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace CostManagement.Models
{
    public class CostDetails
    {
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("manifest")]
        public Manifest Manifest { get; set; }
    }

    public class Manifest
    {
        [JsonProperty("dataFormat")]

        public string DataFormat { get; set; }

        [JsonProperty("blobs")]
        public List<Blob> Blobs { get; set; }
    }
    public class Blob
    {
        [JsonProperty("bloblink")]
        public string BlobLink { get; set; }
    }

}
