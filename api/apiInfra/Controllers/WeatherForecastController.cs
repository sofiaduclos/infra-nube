using Microsoft.AspNetCore.Mvc;
using Amazon.SQS;
using Amazon.SQS.Model;
using Newtonsoft.Json;

namespace apiInfra.Controllers
{
    [ApiController]
    [Route("invoice")]
    public class WeatherForecastController : ControllerBase
    {

        private readonly ILogger<WeatherForecastController> _logger;
        private readonly IAmazonSQS _sqsClient;

        public WeatherForecastController(ILogger<WeatherForecastController> logger, IAmazonSQS sqsClient)
        {
            _logger = logger;
            _sqsClient = sqsClient;
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

            var sendMessageRequest = new SendMessageRequest
            {
                QueueUrl = "YOUR_SQS_QUEUE_URL",
                MessageBody = messageBody
            };

            await _sqsClient.SendMessageAsync(sendMessageRequest);

            return Ok();
        }
    }
}