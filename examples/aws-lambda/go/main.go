package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	"os"
)

type Body struct {
	Message string `json:"message"`
	Data    string `json:"data"`
	ENV     string `json:"secret"`
}

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Printf("Processing request data for request %s.\n", request.RequestContext.RequestID)
	fmt.Printf("Body Size = %d.\n", len(request.Body))
	fmt.Printf("Secret: %s.\n", os.Getenv("SECRET"))
	fmt.Printf("KeyId: %s.\n", os.Getenv("KeyId"))

	fmt.Println("Headers:")
	for key, value := range request.Headers {
		fmt.Printf("    %s: %s\n", key, value)
	}

	// Initialize a session that the SDK uses to load
	// credentials from the shared credentials file ~/.aws/credentials
	// and configuration from the shared configuration file ~/.aws/config.
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	// Create KMS service client
	svc := kms.New(sess)

	// process data
	rawSecret, err := base64.StdEncoding.DecodeString(os.Getenv("SECRET"))
	if err != nil {
		panic(err)
	}
	blob := []byte(rawSecret)

	// Decrypt the data
	result, err := svc.Decrypt(&kms.DecryptInput{CiphertextBlob: blob})
	if err != nil {
		panic(err)
	}

	rawOut, err := json.Marshal(Body{Message: "Request received!", ENV: string(result.Plaintext), Data: string(request.Body)})
	fmt.Printf("result: %s.\n", string(result.Plaintext))
	if err != nil {
		panic(err)
	}

	return events.APIGatewayProxyResponse{
		IsBase64Encoded: false,
		StatusCode:      200,
		Body:            string(rawOut),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
