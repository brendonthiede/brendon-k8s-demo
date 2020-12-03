# CRUD API

This trivial app can be ran locally by executing:

```powershell
go run server.go
```

To create it as a Docker image, use something like this:

```powershell
docker build . -t thiedebr/playground:crud-api
```

To run the Docker image locally, you can use this:

```powershell
docker run -p 8887:8887 --rm thiedebr/playground:crud-api
```

To publish the image to DockerHub, just do:

```powershell
docker push thiedebr/playground:crud-api
```
