FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

COPY . .

RUN dotnet restore DockerApi.csproj
RUN dotnet publish DockerApi.csproj -c Release -o /app/docker-api

FROM build AS publish

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS final
WORKDIR /app
COPY --from=publish /app/docker-api .
ENTRYPOINT ["dotnet", "DockerApi.dll"]