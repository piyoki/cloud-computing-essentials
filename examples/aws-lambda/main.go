package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Body struct {
	Message string `json:"message"`
	Data    string `json:"data"`
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Printf("Processing request data for request %s.\n", request.RequestContext.RequestID)
	fmt.Printf("Body size = %d.\n", len(request.Body))

	fmt.Println("Headers:")
	for key, value := range request.Headers {
		fmt.Printf("    %s: %s\n", key, value)
	}

	// process data
	rawIn, err := json.Marshal(Body{Message: "Request received!", Data: request.Body})
	if err != nil {
		panic(err)
	}

	return events.APIGatewayProxyResponse{
		IsBase64Encoded: false,
		StatusCode:      200,
		Body:            string(rawIn),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
yousdhjasjdlasjd
