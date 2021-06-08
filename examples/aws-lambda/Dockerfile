
FROM public.ecr.aws/bitnami/golang:latest AS build
WORKDIR /app
ADD go.mod main.go ./
RUN go get github.com/aws/aws-lambda-go/lambda
RUN GOARCH=amd64 CGO_ENABLED=0 GOOS=linux go build -o app

FROM public.ecr.aws/lambda/go:1
COPY --from=build /app ${LAMBDA_TASK_ROOT}
CMD [ "app" ]
