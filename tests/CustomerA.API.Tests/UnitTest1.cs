using Xunit;
using CustomerA.API.Services;

public class UnitTest1
{
    [Fact]
    public void TestWeatherServiceReturnsForecasts()
    {
        var service = new WeatherService();
        var forecasts = service.GetForecasts();
        Assert.NotEmpty(forecasts);
        Assert.Equal(5, forecasts.Count());
    }
}