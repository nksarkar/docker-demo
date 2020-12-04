# docker-demo
## Creating a new dotnet project
1. Create webapi project: ***dotnet new webapi -n DockerApi*** This command creates dotnet project with latest installed SDK. If you want to create a project with older version check this: https://docs.microsoft.com/en-us/dotnet/core/versions/selection
2. Build project: ***dotnet build***
3. Run project: ***dotnet run***
4. Test in browser: https://localhost:5001/WeatherForecast

## Creating a container image 
1. Add a docker file named 'Dockerfile'

```docker
# Base image with same SDK version of the dotnet project. This is required to build the project
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
# (Create and )Set the working directory in the container
WORKDIR /app
# Copies all files (except listed in .dockerignore) from source current directory (DockerApi/) to container working directory 
COPY . .

# Resolve dependencies/ Install NuGet packages
RUN dotnet restore DockerApi.csproj
# Build and publish with configuration flag Release into folder named /app/docker-api
RUN dotnet publish DockerApi.csproj -c Release -o out

# Generate runtime image.
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS final
# Sets the working directory to /api
WORKDIR /api
# Combines build steps 'build' and '/app/out' and copies into working directory 'api'.
COPY --from=build /app/out .
# dotnet command to run project dll.
ENTRYPOINT ["dotnet", "DockerApi.dll"]
```
2. Add .dockerignore file to exclude unnecessary files in the container image.
3. Build docker file: ***docker build -t nks33/dockerapi .*** ### Tagging convention: https://docs.docker.com/engine/reference/commandline/tag/ 
4. Run docker file: ***docker run -p 8080:80 nks33/dockerapi***
5. Test in browser: http://localhost:8080/WeatherForecast
6. Docker image is now ready to deploy. The folder structure in the container image should look like:

<img src="https://user-images.githubusercontent.com/40652401/101164727-60b0e000-369a-11eb-8ea2-1baf4581520c.png" width="819" height="357" />