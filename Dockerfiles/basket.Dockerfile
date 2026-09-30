# Stage 1: Runtime Base
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# Stage 2: SDK Build & Restore
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["*.props", "./"]
COPY ["*.json", "./"]

COPY ["src/Basket.API/Basket.API.csproj", "src/Basket.API/"]
COPY ["src/EventBusRabbitMQ/EventBusRabbitMQ.csproj", "src/EventBusRabbitMQ/"]
COPY ["src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj", "src/eShop.ServiceDefaults/"]
COPY ["src/EventBus/EventBus.csproj", "src/EventBus/"]

# Restore dependencies for Web.csproj
RUN dotnet restore "src/Basket.API/Basket.API.csproj"

# Copy full application source code
COPY ["src/Basket.API/", "src/Basket.API/"]
COPY ["src/EventBusRabbitMQ/", "src/EventBusRabbitMQ/"]
COPY ["src/eShop.ServiceDefaults/", "src/eShop.ServiceDefaults/"]
COPY ["src/EventBus/", "src/EventBus/"]
COPY ["src/Shared/", "src/Shared/"]


WORKDIR "/src/src/Basket.API"

# Stage 3: Publish Application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Basket.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false --no-restore

# Stage 4: Final Image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Basket.API.dll"]





