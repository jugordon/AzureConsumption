using System;
using System.Collections.Generic;
using System.Text;

namespace AZFCostManagement.Models
{
    public class AzureAppReg
    {
        public string TenantID { get; set; }
        public string ClientID { get; set; }
        public string SecretValue { get; set; }
    }
}
