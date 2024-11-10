using Microsoft.AspNetCore.Mvc;
using Amazon.SQS;
using Amazon.SQS.Model;
using Newtonsoft.Json;
using Amazon.SimpleSystemsManagement;
using Amazon.SimpleSystemsManagement.Model;

namespace apiInfra.Controllers
{
    [ApiController]
    [Route("invoice")]
    public class WeatherForecastController : ControllerBase
    {

        private readonly ILogger<WeatherForecastController> _logger;
        private readonly IAmazonSQS _sqsClient;
        private readonly IAmazonSimpleSystemsManagement _ssmClient;

        public WeatherForecastController(ILogger<WeatherForecastController> logger, IAmazonSQS sqsClient, IAmazonSimpleSystemsManagement ssmClient)
        {
            _logger = logger;
            _sqsClient = sqsClient;
            _ssmClient = ssmClient;
        }

        [HttpPost()]
        [ProducesResponseType(typeof(Invoice), 404)]
        public async Task<IActionResult> Post([FromBody] Invoice invoice)
        {
            if (invoice == null)
            {
                return BadRequest("Invoice cannot be null.");
            }

            string messageBody = JsonConvert.SerializeObject(invoice);

            var request = new GetParameterRequest
            {
                Name = "/myapp/sqs_queue_url",
                WithDecryption = true
            };
            var response = await _ssmClient.GetParameterAsync(request);
            string queueUrl = response.Parameter.Value;

            var sendMessageRequest = new SendMessageRequest
            {
                QueueUrl = queueUrl,
                MessageBody = messageBody
            };

            await _sqsClient.SendMessageAsync(sendMessageRequest);

            return Ok();
        }
    }
}