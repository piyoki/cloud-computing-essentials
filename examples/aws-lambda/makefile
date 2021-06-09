###

REGION=ap-northeast-1
AWS_ACCOUNT_ID=233482784995
VERSION=0.0.2
REPO_NAME=lambda-container-demo
REPO_URI=$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(REPO_NAME)

ecr-login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

build-image:
	docker image build -t $(REPO_NAME):$(VERSION) .

run-image:
	docker run -d -p 9000:8080 \
    $(REPO_NAME):$(VERSION)

test-container:
	curl "http://localhost:9000/2015-03-31/functions/function/invocations" \
    -d '{"name":"Niceguy"}' && echo

ecr-create-repository:
	aws ecr create-repository \
		--repository-name lambda-container-demo \
  	--image-scanning-configuration scanOnPush=true \
		--region $(REGION)

tag-image:
	docker tag $(REPO_NAME):$(VERSION) $(REPO_URI):$(VERSION)

push-image:
	docker push $(REPO_URI):$(VERSION)

create-function:
	aws lambda create-function --region $(REGION) --function-name $(REPO_NAME) \
    --package-type Image \
		--code ImageUri=$(REPO_URI):$(VERSION) \
		--role arn:aws:iam::233482784995:role/lambda-role

invoke-function:
	@export PAYLOAD=$(echo '{"name": "Niceguy"}' | base64)
	aws lambda invoke --function-name $(REPO_NAME) \
		--payload $(PAYLOAD) response.json
