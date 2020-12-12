FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

COPY . ./

RUN dotnet restore DockerApi.csproj
RUN dotnet publish DockerApi.csproj -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS final
WORKDIR /api
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "DockerApi.dll"]