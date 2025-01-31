using System.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Logging.AddConsole();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

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

    using var command = new SqlCommand($@"
    use MyDatabase;
    WAITFOR DELAY '00:00:{Math.Min(60000, Math.Max(0, Math.Floor((delay ?? 1000) / 1000m)))}';
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

app.MapGet("/http-async-slow", async (int? delay = null) => {
    using var httpClient = new HttpClient();
    var response = await httpClient.GetAsync($"http://mock-http-server:5237/http-async-slow?delay={delay ?? 1000}");
    var responseString = await response.EnsureSuccessStatusCode().Content.ReadAsStringAsync();
    return responseString;
});

app.UseMiddleware<ThreadPoolCheckMiddleware>();


app.Run();
