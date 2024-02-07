using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Data.SqlClient;
using System.Text;


namespace DemoFuncAPI
{
    public static class Function1
    {
        [FunctionName("Hello")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            var message = new StringBuilder();
            try
            {

                var connectionString = Environment.GetEnvironmentVariable("sqldb_connection");
                message.AppendLine(connectionString);
                using SqlConnection conn = new SqlConnection(connectionString);
                conn.Open();
                var text = "SELECT count(*) FROM [SalesLT].[Product]";

                using SqlCommand cmd = new SqlCommand(text, conn);
                // Execute the command and log the # rows affected.
                var rowCount = await cmd.ExecuteScalarAsync();

                message.AppendLine($"Total {rowCount} products found in database");
            }
            catch (Exception ex)
            {
                message.AppendLine(ex.Message);
            }


            return new OkObjectResult(message.ToString());
        }


        [FunctionName("Gaga")]
        public static async Task<IActionResult> RunGaga(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {

            return new OkObjectResult($"Looks good");
        }
    }
}
