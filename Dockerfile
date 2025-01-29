FROM mcr.microsoft.com/dotnet/sdk:8.0@sha256:35792ea4ad1db051981f62b313f1be3b46b1f45cadbaa3c288cd0d3056eefb83 AS build
WORKDIR /App

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/sdk:8.0@sha256:35792ea4ad1db051981f62b313f1be3b46b1f45cadbaa3c288cd0d3056eefb83
WORKDIR /App
COPY --from=build /App/out .

RUN dotnet tool install -g dotnet-counters

# Monitor this by running /root/.dotnet/tools/dotnet-counters monitor --process-id 1

ENTRYPOINT ["dotnet", "dotnet-nginx-testing.dll", "--urls", "http://*:8151"]
