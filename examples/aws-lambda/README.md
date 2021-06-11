# AWS Lambda Provisioning

## Setup Insturctions

- [Provision with Terraform](#provision-with-terraform)
- [Provision with Makefile](#provision-with-makefile)
- [Invoke Lambda Function with API Gateway](#invoke-lamda-function-with-api-gateway)
- [KMS Encryption](#kms-encryption)
- [Clean Up](#clean-up)

### Provision with Terraform

Execute the following command

```bash
terraform init
terraform plan -var "image_tag=<VERSION>" -var "secret=<SECRET_STRING>"
terraform apply -var "image_tag=<VERSION>" -var "secret=<SECRET_STRING>"
```

---

### Provision with Makefile

#### Step 1: Setup IAM

Find the instructions in the links below:

- [Creating an IAM user in your AWS account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console)
- [Your AWS account ID and its alias](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html)
- [AWS Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
- [ECR Policy to Lambda](https://docs.aws.amazon.com/lambda/latest/dg/configuration-images.html#configuration-images-permissions)

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

NOTES:

- you may modify the parameters in the `main.go` and rebuild the container to play around with it!
- make sure you also change the `version tag` as you build the new container image

#### Step 5: Create a ECR Repository with AWS_CLI

```bash
make ecr-create-repository
```

#### Step 6: Deploy to AWS

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

#### Step 7: Create the Lambda Function Associated With This Container Image

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

---

## Invoke Lamda Function with API Gateway

```bash
curl -X POST \
  -d '{"data": "Hello from the NiceGuy!"}' \
  <API Gateway Endpoint>
```

NOTES: you may obtain the `API Gateway Endpoint'` from the `Terraform Output`

## Clean Up

```bash
terraform destroy
```

## KMS Encryption

![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2020/07/28/EncryptedECRImagesS3v2.1.png)

#### References:

- [Introducing Amazon ECR server-side encryption using AWS Key Management System](https://aws.amazon.com/blogs/containers/introducing-amazon-ecr-server-side-encryption-using-aws-key-management-system/)
