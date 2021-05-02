FROM golang:alpine as build-stage
WORKDIR /function
RUN apk update && apk upgrade
RUN apk add --no-cache git
RUN git clone https://github.com/yqlbu/cloud-computing-essentials.git

ADD go.mod /function/
RUN go mod download

RUN cp -r cloud-computing-essentials/static /function/static
COPY ./func.go /function

RUN CGO_ENABLED=0 go build -o /func

FROM fnproject/go
WORKDIR /function
COPY --from=build-stage /func /function/func
COPY --from=build-stage /function/static /function/static
CMD ./func
