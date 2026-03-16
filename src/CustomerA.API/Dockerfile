FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CustomerA.API.csproj", "."]
RUN dotnet restore "CustomerA.API.csproj"
COPY . .
RUN dotnet build "CustomerA.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CustomerA.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CustomerA.API.dll"]