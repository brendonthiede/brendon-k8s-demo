# CRUD API

This trivial app can be ran locally by executing:

```powershell
go run server.go
```

## Build Docker image

Create a [multi-arch builder](https://docs.docker.com/build/building/multi-platform/) (only needed once):

```powershell
# List the current builders 
docker buildx ls

# Create a builder with the default settings
docker buildx create --name multiarch --driver docker-container --bootstrap

# Show details about the builder
docker buildx inspect multiarch
```

To create it as a Docker image, use something like this:

```powershell
docker buildx create --name multiarch --platform linux/amd64,linux/arm64 --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'
docker buildx inspect multiarch --bootstrap
docker buildx build --builder multiarch --platform linux/amd64,linux/arm64 -t thiedebr/crud-api:latest .
docker build . -t thiedebr/crud-api:latest
```

To run the Docker image locally, you can use this:

```powershell
docker run -p 8887:8887 --rm thiedebr/crud-api:latest
```

To publish the image to DockerHub, just do:

```powershell
docker buildx build --push --builder multiarch --platform linux/amd64,linux/arm64 -t thiedebr/crud-api:latest .
```
