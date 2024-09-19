FROM golang:alpine AS builder

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build ./server.go
RUN pwd
RUN ls -la 1>&2

FROM scratch
COPY  --from=builder /app/server /server
CMD ["/server"]

EXPOSE 8887
