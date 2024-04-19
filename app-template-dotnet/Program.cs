var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

var app = builder.Build();

string foo = System.Environment.GetEnvironmentVariable("IDEX_FOO");

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

app.MapGet("/", () => "Hello World");
app.MapGet("/health", () => "application is healthy");

app.Run();

