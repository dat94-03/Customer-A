using CustomerA.API.Models;

namespace CustomerA.API.Services;

public interface IWeatherService
{
    IEnumerable<WeatherForecast> GetForecasts();
}