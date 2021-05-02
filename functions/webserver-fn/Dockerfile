FROM golang:alpine as build-stage
WORKDIR /function
ADD go.mod /function/
RUN go mod download

COPY . /function

RUN CGO_ENABLED=0 go build -o /func

FROM fnproject/go
WORKDIR /function
COPY ./static /function/static
COPY --from=build-stage /func /function/func
CMD ./func
