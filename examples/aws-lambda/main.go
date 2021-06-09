package main

import (
	"fmt"

	"context"
	"github.com/aws/aws-lambda-go/lambda"
)

type Request struct {
	Data string `json:"data"`
}

type Response struct {
	StatusCode    string `json:"statusCode"`
	StatusMessage string `json:"statusMessage"`
	Body          Body
}

type Body struct {
	Message string `json:"message"`
}

func HandleRequest(ctx context.Context, request Request) (Response, error) {

	fmt.Sprintf("data: %s", request.Data)

	return Response{
		StatusCode:    "200",
		StatusMessage: "Success",
		Body:          Body{Message: "received"},
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
