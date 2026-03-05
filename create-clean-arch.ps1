param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionName
)

$ErrorActionPreference = "Stop"

function Create-Folder {
    param($path)

    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function Info {
    param($text)
    Write-Host "➜ $text" -ForegroundColor Cyan
}

Info "Creating solution $SolutionName"

Create-Folder $SolutionName
Set-Location $SolutionName

dotnet new sln -n $SolutionName

Create-Folder src
Create-Folder tests

# Projects

Info "Creating projects"

dotnet new classlib -n "$SolutionName.Domain" -o "src/$SolutionName.Domain"
dotnet new classlib -n "$SolutionName.Application" -o "src/$SolutionName.Application"
dotnet new classlib -n "$SolutionName.Infrastructure" -o "src/$SolutionName.Infrastructure"
dotnet new webapi -n "$SolutionName.API" -o "src/$SolutionName.API"
dotnet new xunit -n "$SolutionName.UnitTests" -o "tests/$SolutionName.UnitTests"

# Add to solution

Info "Adding projects to solution"

Get-ChildItem -Recurse -Filter *.csproj ./src | ForEach-Object {
    dotnet sln add $_.FullName
}

Get-ChildItem -Recurse -Filter *.csproj ./tests | ForEach-Object {
    dotnet sln add $_.FullName
}

# References

Info "Adding project references"

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" reference `
           "src/$SolutionName.Domain/$SolutionName.Domain.csproj"

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj"

# Architecture folders

Info "Creating architecture folders"

Create-Folder "src/$SolutionName.Domain/Entities"
Create-Folder "src/$SolutionName.Domain/Common"

Create-Folder "src/$SolutionName.Application/Interfaces"
Create-Folder "src/$SolutionName.Application/Features"
Create-Folder "src/$SolutionName.Application/Features/Example"

Create-Folder "src/$SolutionName.Infrastructure/Persistence"
Create-Folder "src/$SolutionName.Infrastructure/Repositories"

Create-Folder "src/$SolutionName.API/Middleware"

# Packages

Info "Installing packages"

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package MediatR
dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package FluentValidation
dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package AutoMapper

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore
dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.SqlServer

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Serilog.AspNetCore
dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Swashbuckle.AspNetCore
dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Microsoft.AspNetCore.Diagnostics.HealthChecks

# BaseEntity

$baseEntity = @"
namespace $SolutionName.Domain.Common;

public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedDate { get; set; }
}
"@

Set-Content "src/$SolutionName.Domain/Common/BaseEntity.cs" $baseEntity

# Result Pattern

$result = @"
namespace $SolutionName.Domain.Common;

public class Result
{
    public bool Success { get; }
    public string Error { get; }

    protected Result(bool success, string error)
    {
        Success = success;
        Error = error;
    }

    public static Result Ok() => new(true, null);
    public static Result Fail(string error) => new(false, error);
}
"@

Set-Content "src/$SolutionName.Domain/Common/Result.cs" $result

# Example Entity

$product = @"
using $SolutionName.Domain.Common;

namespace $SolutionName.Domain.Entities;

public class Product : BaseEntity
{
    public string Name { get; set; }
}
"@

Set-Content "src/$SolutionName.Domain/Entities/Product.cs" $product

# DbContext

$dbcontext = @"
using Microsoft.EntityFrameworkCore;
using $SolutionName.Domain.Entities;

namespace $SolutionName.Infrastructure.Persistence;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Product> Products => Set<Product>();
}
"@

Set-Content "src/$SolutionName.Infrastructure/Persistence/AppDbContext.cs" $dbcontext

# CQRS Example

$query = @"
using MediatR;

namespace $SolutionName.Application.Features.Example;

public record GetProductsQuery : IRequest<List<string>>;
"@

Set-Content "src/$SolutionName.Application/Features/Example/GetProductsQuery.cs" $query

$handler = @"
using MediatR;

namespace $SolutionName.Application.Features.Example;

public class GetProductsHandler : IRequestHandler<GetProductsQuery, List<string>>
{
    public Task<List<string>> Handle(GetProductsQuery request, CancellationToken cancellationToken)
    {
        return Task.FromResult(new List<string>{ ""Example Product"" });
    }
}
"@

Set-Content "src/$SolutionName.Application/Features/Example/GetProductsHandler.cs" $handler

# Exception Middleware

$middleware = @"
namespace $SolutionName.API.Middleware;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch(Exception ex)
        {
            context.Response.StatusCode = 500;
            await context.Response.WriteAsync(ex.Message);
        }
    }
}
"@

Set-Content "src/$SolutionName.API/Middleware/ExceptionMiddleware.cs" $middleware

# Program.cs

$program = @"
using $SolutionName.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using MediatR;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseInMemoryDatabase(""AppDb""));

builder.Services.AddMediatR(cfg =>
    cfg.RegisterServicesFromAssemblyContaining(typeof($SolutionName.Application.Features.Example.GetProductsQuery)));

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();
app.MapHealthChecks(""/health"");

app.Run();
"@

Set-Content "src/$SolutionName.API/Program.cs" $program

# Dockerfile

$docker = @"
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY . .
ENTRYPOINT [""dotnet"", ""$SolutionName.API.dll""]
"@

Set-Content "src/$SolutionName.API/Dockerfile" $docker

Write-Host ""
Write-Host "Enterprise Clean Architecture project created." -ForegroundColor Green
Write-Host "Solution: $SolutionName"
Write-Host ""