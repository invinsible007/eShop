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

COPY ["src/PaymentProcessor/PaymentProcessor.csproj", "src/PaymentProcessor/"]
COPY ["src/EventBusRabbitMQ/EventBusRabbitMQ.csproj", "src/EventBusRabbitMQ/"]
COPY ["src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj", "src/eShop.ServiceDefaults/"]
COPY ["src/EventBus/EventBus.csproj", "src/EventBus/"]

# Restore dependencies for Web.csproj
RUN dotnet restore "src/PaymentProcessor/PaymentProcessor.csproj"

# Copy full application source code
COPY ["src/PaymentProcessor/", "src/PaymentProcessor/"]
COPY ["src/EventBusRabbitMQ/", "src/EventBusRabbitMQ/"]
COPY ["src/eShop.ServiceDefaults/", "src/eShop.ServiceDefaults/"]
COPY ["src/EventBus/", "src/EventBus/"]


WORKDIR "/src/src/PaymentProcessor/"

# Stage 3: Publish Application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "PaymentProcessor.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false --no-restore

# Stage 4: Final Image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PaymentProcessor.dll"]





