# CRUD API

This trivial app can be ran locally by executing:

```powershell
go run server.go
```

To create it as a Docker image, use something like this:

```powershell
docker build . -t thiedebr/crud-api:latest
```

To run the Docker image locally, you can use this:

```powershell
docker run -p 8887:8887 --rm thiedebr/crud-api:latest
```

To publish the image to DockerHub, just do:

```powershell
docker push thiedebr/crud-api:latest
```
