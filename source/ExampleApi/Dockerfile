FROM microsoft/dotnet:2.2-aspnetcore-runtime-alpine AS base

WORKDIR /app
COPY ./ /app

ENTRYPOINT ["dotnet", "ExampleApi.dll"]