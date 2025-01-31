var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/http-async-slow", async (int? delay = null) => {
    await Task.Delay(delay ?? 1000);
    return "OK";
});

app.Run();
