
using System.Reflection;
using Events.WebAPI.Runtime;
using Events.WebAPI.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Formatters;
using NSwag.Generation.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers(options =>
{
    options.ReturnHttpNotAcceptable = true;
    options.RespectBrowserAcceptHeader = true;

    RestrictToJsonContentType(options);
    //ConfigureJsonFormatters(options);
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApiDocument(document => { GenerateOpenApiSpec(document, "v1"); });


// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSingleton<EventsService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseOpenApi();
    app.UseSwaggerUi();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();


app.Run();

void RestrictToJsonContentType(MvcOptions options)
{
    var allButJsonInputFormatters =
        options.InputFormatters.Where(formatter => formatter is not SystemTextJsonInputFormatter);

    foreach (IInputFormatter inputFormatter in allButJsonInputFormatters)
    {
        options.InputFormatters.Remove(inputFormatter);
    }

    // Removing for text/plain, see https://docs.microsoft.com/en-us/aspnet/core/web-api/advanced/formatting?view=aspnetcore-3.0#special-case-formatters
    options.OutputFormatters.RemoveType<StringOutputFormatter>();
}

void GenerateOpenApiSpec(AspNetCoreOpenApiDocumentGeneratorSettings nswagSettings, string documentName)
{
    string apiTitle = "Savanh Events API";

    bool includeAllOperations = false;
    string? apiType = null;

    if (!string.IsNullOrEmpty(builder.Configuration["API_TYPE"]))
    {
        apiType = builder.Configuration["API_TYPE"];
    }

    if (!string.IsNullOrEmpty(builder.Configuration["INCLUDE_ALL_OPERATIONS"]))
    {
        _ = bool.TryParse(builder.Configuration["INCLUDE_ALL_OPERATIONS"], out includeAllOperations);
    }

    if (!string.IsNullOrEmpty(builder.Configuration["API_TITLE"]))
    {
        apiTitle = builder.Configuration["API_TITLE"];
        apiTitle = apiTitle.Replace("_", " ");
    }

    Console.WriteLine($"Generating api doc : AllOperations: {includeAllOperations} // ApiType: {apiType}");
    nswagSettings.OperationProcessors.Add(new OpenApiSpecOperationProcessor(includeAllOperations, apiType));
    nswagSettings.DocumentName = documentName;
    nswagSettings.Title = apiTitle;
    nswagSettings.Version = Assembly.GetExecutingAssembly().GetName().Version?.ToString();
}