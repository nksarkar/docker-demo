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

## Pushing image to docker hub
Run this command to manually push the image to docker hub. You will have to login to your docker hub account before you can push. Note: This process will be automated later
Command: ***docker push nks33/dockerapi***

## Provisioning infrastructure using Terraform
Add a new file with name main.tf.
```docker
# Define provider
provider "azurerm" {
    version = "~> 2.13.0"
    features {}
}

# Create resource group
resource "azurerm_resource_group" "tf_rg" {
  name                  = "docker-demo-rg"
  location              = "Australia East"
}

# Create container
resource "azurerm_container_group" "tf_container_grp" {
  name                  = "docker-demo-container-grp"
  location              = azurerm_resource_group.tf_rg.location
  resource_group_name   = azurerm_resource_group.tf_rg.name
  ip_address_type       = "public"
  dns_name_label        = "dockerdemo"
  os_type               = "Linux"
  container {
    name                = "dockerdemoapi"
    image               = "nks33/dockerapi"
    cpu                 = "1"
    memory              = "1"
    ports{
        port            = 80
        protocol        = "TCP" 
    }
  }
}
```
1. Login to Azure account using: ***az login***. Prompts a popup for interactive login. You can also setup service principal following the steps: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret. 
*Note: Restart VSCode after setting up envionment variables.*
2. Initialize terraform: ***terraform init***
3. Review terraform plan: ***terraform plan***
4. Apply terraform plan: ***terraform apply***. This step creates resources into azure account
