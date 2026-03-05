param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionName
)

$ErrorActionPreference = "Stop"

Write-Host "Creating Clean Architecture Solution: $SolutionName"

# root
New-Item -ItemType Directory $SolutionName
Set-Location $SolutionName

dotnet new sln -n $SolutionName

New-Item -ItemType Directory src
New-Item -ItemType Directory tests

# projects

dotnet new classlib -n "$SolutionName.Domain" -o "src/$SolutionName.Domain"
dotnet new classlib -n "$SolutionName.Application" -o "src/$SolutionName.Application"
dotnet new classlib -n "$SolutionName.Infrastructure" -o "src/$SolutionName.Infrastructure"
dotnet new webapi -n "$SolutionName.API" -o "src/$SolutionName.API"

dotnet new xunit -n "$SolutionName.UnitTests" -o "tests/$SolutionName.UnitTests"

# solution add

Get-ChildItem -Recurse -Filter *.csproj ./src | ForEach-Object {
    dotnet sln add $_.FullName
}

Get-ChildItem -Recurse -Filter *.csproj ./tests | ForEach-Object {
    dotnet sln add $_.FullName
}

# references

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" reference `
           "src/$SolutionName.Domain/$SolutionName.Domain.csproj"

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj"

# folders

mkdir "src/$SolutionName.Domain/Entities"
mkdir "src/$SolutionName.Domain/Common"

mkdir "src/$SolutionName.Application/Features"
mkdir "src/$SolutionName.Application/Features/Example"
mkdir "src/$SolutionName.Application/Interfaces"
mkdir "src/$SolutionName.Application/Behaviors"

mkdir "src/$SolutionName.Infrastructure/Persistence"
mkdir "src/$SolutionName.Infrastructure/Repositories"

mkdir "src/$SolutionName.API/Middleware"

# packages

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package MediatR
dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package FluentValidation
dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package AutoMapper

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore
dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.SqlServer

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Serilog.AspNetCore
dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Swashbuckle.AspNetCore

# ----------------------
# BaseEntity
# ----------------------

$baseEntity = @"
namespace $SolutionName.Domain.Common;

public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedDate { get; set; }
}
"@

$baseEntity | Out-File "src/$SolutionName.Domain/Common/BaseEntity.cs"

# ----------------------
# Example Entity
# ----------------------

$entity = @"
using $SolutionName.Domain.Common;

namespace $SolutionName.Domain.Entities;

public class Product : BaseEntity
{
    public string Name { get; set; }
}
"@

mkdir "src/$SolutionName.Domain/Entities"
$entity | Out-File "src/$SolutionName.Domain/Entities/Product.cs"

# ----------------------
# Example CQRS Query
# ----------------------

$query = @"
using MediatR;

namespace $SolutionName.Application.Features.Example;

public record GetProductsQuery : IRequest<List<string>>;
"@

$query | Out-File "src/$SolutionName.Application/Features/Example/GetProductsQuery.cs"

# handler

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

$handler | Out-File "src/$SolutionName.Application/Features/Example/GetProductsHandler.cs"

# ----------------------
# DbContext
# ----------------------

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

$dbcontext | Out-File "src/$SolutionName.Infrastructure/Persistence/AppDbContext.cs"

# ----------------------
# Global Exception Middleware
# ----------------------

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

$middleware | Out-File "src/$SolutionName.API/Middleware/ExceptionMiddleware.cs"

Write-Host ""
Write-Host "Clean Architecture project created successfully."
Write-Host ""
Write-Host "Solution Name: $SolutionName"