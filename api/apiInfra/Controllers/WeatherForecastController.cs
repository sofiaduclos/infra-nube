using Microsoft.AspNetCore.Mvc;

namespace apiInfra.Controllers
{
    [ApiController]
    [Route("invoice")]
    public class WeatherForecastController : ControllerBase
    {

        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger)
        {
            _logger = logger;
        }

        [HttpGet()]
        [ProducesResponseType(typeof(Invoice), 404)]
        public IActionResult Get()
        {
            Invoice dummy = new Invoice();
            dummy.Amount = 1290.75;
            dummy.Date = DateTime.Now;
            dummy.Id = 19981;
            dummy.Description = "Car service";
            return Ok(dummy);
        }
    }
}