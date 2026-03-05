param(
    [Parameter(Mandatory=$true)]
    [string]$SolutionName
)

Write-Host "Creating Clean Architecture Solution: $SolutionName" -ForegroundColor Green

# root
New-Item -ItemType Directory $SolutionName
Set-Location $SolutionName

# solution
dotnet new sln -n $SolutionName

# folders
New-Item -ItemType Directory src
New-Item -ItemType Directory tests

# projects
dotnet new classlib -n "$SolutionName.Domain" -o "src/$SolutionName.Domain"
dotnet new classlib -n "$SolutionName.Application" -o "src/$SolutionName.Application"
dotnet new classlib -n "$SolutionName.Infrastructure" -o "src/$SolutionName.Infrastructure"
dotnet new webapi -n "$SolutionName.API" -o "src/$SolutionName.API"

dotnet new xunit -n "$SolutionName.UnitTests" -o "tests/$SolutionName.UnitTests"
dotnet new xunit -n "$SolutionName.IntegrationTests" -o "tests/$SolutionName.IntegrationTests"

# add to solution
Get-ChildItem -Recurse -Filter *.csproj ./src | ForEach-Object {
    dotnet sln add $_.FullName
}

Get-ChildItem -Recurse -Filter *.csproj ./tests | ForEach-Object {
    dotnet sln add $_.FullName
}

# project references

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" reference `
           "src/$SolutionName.Domain/$SolutionName.Domain.csproj"

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Application/$SolutionName.Application.csproj"

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" reference `
           "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj"

# ----------------------
# Domain folders
# ----------------------

New-Item "src/$SolutionName.Domain/Entities" -ItemType Directory
New-Item "src/$SolutionName.Domain/ValueObjects" -ItemType Directory
New-Item "src/$SolutionName.Domain/Enums" -ItemType Directory
New-Item "src/$SolutionName.Domain/Events" -ItemType Directory
New-Item "src/$SolutionName.Domain/Interfaces" -ItemType Directory
New-Item "src/$SolutionName.Domain/Common" -ItemType Directory

# ----------------------
# Application folders
# ----------------------

New-Item "src/$SolutionName.Application/Features" -ItemType Directory
New-Item "src/$SolutionName.Application/DTOs" -ItemType Directory
New-Item "src/$SolutionName.Application/Interfaces" -ItemType Directory
New-Item "src/$SolutionName.Application/Behaviors" -ItemType Directory
New-Item "src/$SolutionName.Application/Exceptions" -ItemType Directory
New-Item "src/$SolutionName.Application/Mappings" -ItemType Directory

# ----------------------
# Infrastructure folders
# ----------------------

New-Item "src/$SolutionName.Infrastructure/Persistence" -ItemType Directory
New-Item "src/$SolutionName.Infrastructure/Repositories" -ItemType Directory
New-Item "src/$SolutionName.Infrastructure/Services" -ItemType Directory
New-Item "src/$SolutionName.Infrastructure/Configurations" -ItemType Directory

# ----------------------
# API folders
# ----------------------

New-Item "src/$SolutionName.API/Middleware" -ItemType Directory
New-Item "src/$SolutionName.API/Filters" -ItemType Directory
New-Item "src/$SolutionName.API/Extensions" -ItemType Directory

# ----------------------
# NuGet packages
# ----------------------

Write-Host "Installing NuGet packages..."

# Application

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package MediatR

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package FluentValidation

dotnet add "src/$SolutionName.Application/$SolutionName.Application.csproj" package AutoMapper

# Infrastructure

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore

dotnet add "src/$SolutionName.Infrastructure/$SolutionName.Infrastructure.csproj" package Microsoft.EntityFrameworkCore.SqlServer

# API

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Serilog.AspNetCore

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Swashbuckle.AspNetCore

dotnet add "src/$SolutionName.API/$SolutionName.API.csproj" package Microsoft.AspNetCore.Diagnostics.HealthChecks

# Test packages

dotnet add "tests/$SolutionName.UnitTests/$SolutionName.UnitTests.csproj" package FluentAssertions

dotnet add "tests/$SolutionName.UnitTests/$SolutionName.UnitTests.csproj" package Moq

dotnet add "tests/$SolutionName.IntegrationTests/$SolutionName.IntegrationTests.csproj" package Microsoft.AspNetCore.Mvc.Testing

Write-Host ""
Write-Host "Clean Architecture project created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Solution: $SolutionName"