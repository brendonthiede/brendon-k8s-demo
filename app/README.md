# Sample Apps

## Running apps locally

To run the sample apps locally, you can use docker-compose:

```powershell
docker-compose up --build
```

The UI for the app will be available http://localhost

## Deploying to Kubernetes

With the containers pushed to Docker Hub, we can deploy to Kubernetes with the following:

```bash
echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ui
  name: ui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ui
  template:
    metadata:
      labels:
        app: ui
    spec:
      containers:
      - image: thiedebr/crud-ui:latest
        name: crud-ui
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: ui
  name: ui
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: ui
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: api
  name: api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - image: thiedebr/crud-api:latest
        name: crud-api
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: api
  name: api
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8887
  selector:
    app: api
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: localhost
  annotations:
    ingress.kubernetes.io/ssl-redirect: 'false'
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ui
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
" | kubectl apply -f -
```
