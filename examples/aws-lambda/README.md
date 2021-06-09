# AWS Lambda Provisioning

## Setup Insturctions

### Provision with Terraform

Execute the following command

```bash
terraform init
terraform plan
terraform apply -var "image_tag=<VERSION>"
```

---

### Provision with Makefile

#### Step 1: Setup IAM

Find the instructions in the links below:

- [Creating an IAM user in your AWS account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)
- [Your AWS account ID and its alias](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html)
- [AWS Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)

#### Step 2: Setup AWS Configure

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Quick configuration with aws configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

#### Step 3: Setup ECR

- [Using Amazon ECR with the AWS CLI](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html)

Modify your AWS credentials in the `makefile` and type the following command

```bash
make ecr-login
```

#### Step 4: Build the Container Image

```bash
make build-image
```

#### Step 5: Test the Container

Spins up the container

```bash
make test-container
```

Invoke the containerized functions

```bash
curl "http://localhost:9000/2015-03-31/functions/function/invocations" \
    -d '{"data":"I am a Niceguy!"}' && echo
```

NOTES:

- you may modify the parameters in the `main.go` and rebuild the container to play around with it!
- make sure you also change the `version tag` as you build the new container image

#### Step 6: Create a ECR Repository with AWS_CLI

```bash
make ecr-create-repository
```

#### Step 7: Deploy to AWS

Tag the image

```bash
make tag-image
```

Push the image to ECR

```bash
make push-image
```

NOTES:

- If there is a new version of the image, simply re-tag the image and push it again

#### Step 8: Create the Lambda Function Associated With This Container Image

- Go to `AWS Console` >> `AWS Lambda` >> `Create Function`
- Select `Container Image`, give the function a name, and then Browse images to look for the right image in my `ECR`

> Using the Lambda API

```
make create-function
cat response.json && echo
```

> Updating the function code (AWS Console)

After you deploy a container image to a function, the image is read-only. To update the function code, you must first deploy a new image version. [Create a new image version](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html), and then store the image in the Amazon ECR repository.

**To configure the function to use an updated container image**

1. Open the [Functions page](https://console.aws.amazon.com/lambda/home#/functions) on the Lambda console.

2. Choose the function to update.

3. Under **Image**, choose **Deploy new image**.

4. Choose **Browse images**.

5. In the **Select container image** dialog box, select the Amazon ECR repository from the dropdown list, and then select the new image version.

6. Choose **Save**.
