FROM golang:1.15-alpine as build-env

WORKDIR /app

COPY go.mod /go.sum /app/
RUN go mod download

COPY . /app/

RUN CGO_ENABLED=0 go build -o /serve

FROM alpine:latest as runtime

WORKDIR /app

COPY ./static /app/static/
COPY --from=build-env /serve /app/serve
RUN chmod +x /app/serve
CMD ./serve
