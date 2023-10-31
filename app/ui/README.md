# ui

## Project setup

```powershell
npm install
```

### Compiles and hot-reloads for development

```powershell
npm run serve
```

### Compiles and minifies for production

```powershell
npm run build
```

### Lints and fixes files

```powershell
npm run lint
```

### Customize configuration

See [Configuration Reference](https://cli.vuejs.org/config/).

### Run in Docker

```powershell
docker run -p 8888:80 --rm thiedebr/crud-ui:latest
```

### Build Docker image

Create a [multi-arch builder](https://docs.docker.com/build/building/multi-platform/) (only needed once):

```powershell
# List the current builders 
docker buildx ls

# Create a builder with the default settings
docker buildx create --name multiarch --driver docker-container --bootstrap

# Show details about the builder
docker buildx inspect multiarch
```

Run a build without pushing it to DockerHub:

```powershell
docker buildx build --platform linux/amd64,linux/arm64 -t thiedebr/crud-ui:latest .
```

Run a build and push it to DockerHub:

```powershell
docker buildx build --push --builder multiarch --platform linux/amd64,linux/arm64 -t thiedebr/crud-ui:latest .
```
