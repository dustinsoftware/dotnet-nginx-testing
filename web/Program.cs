using System.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/", () => "OK");

app.MapGet("/async-slow", async (int? delay = null) => {
    await Task.Delay(delay ?? 1000);
    return "OK";
});

app.MapGet("/sync-slow", (int? delay = null) => {
    Thread.Sleep(delay ?? 1000);
    return "OK";
});

app.MapGet("/very-bad-sync-slow", async (int? delay = null) => {
    var syncTask = Task.Run(() => {
        Thread.Sleep(delay ?? 1000);
        return "OK";
    });
    return syncTask.Result;
});

app.MapGet("/weatherforecast", () =>
{
    var forecast =  Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.MapGet("/healthcheck", async () => {
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    using var command = new SqlCommand("SELECT COUNT(1) FROM [MyTable]", connection);
    var count = (int)await command.ExecuteScalarAsync();

    return "OK";
});

app.MapGet("/sql-async-slow", async (int? delay = null) => {
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();

    using var command = new SqlCommand(@"
    use MyDatabase;
    WAITFOR DELAY '00:00:01';
    SELECT TOP 10 Name
    FROM [dbo].[MyTable]
    ORDER BY CreatedAt DESC;
    ", connection);

    // this stored proc returns a single column (name) with 10 rows. build a list and return them.
    var names = new List<string>();
    using var reader = await command.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        names.Add(reader.GetString(0));
    }   
    
    return names;
});

app.UseMiddleware<ThreadPoolCheckMiddleware>();


app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
