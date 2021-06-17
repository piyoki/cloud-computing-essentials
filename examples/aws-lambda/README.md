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

## KMS Encryption

![](https://d2908q01vomqb2.cloudfront.net/fe2ef495a1152561572949784c16bf23abb28057/2020/07/28/EncryptedECRImagesS3v2.1.png)

Encrypt `environment variable` with AWS KMS and store them in git repos. AWS KMS is a powerful tool to encrypt `plaintext` into `cyphertext`. In cryptographic terms, plaintext is simply unencrypted text and ciphertext is the encrypted result. In our instance, plaintext is simply the contents of our configuration file. As it is more cost effective to encrypt the contents of a configuration file against a single `KMS key`. Running the aws kms encrypt command will encrypt the contents of the file and store it in AWS KMS. The contents of the following `JSON` configuration file can be encrypted with a single `KMS Key` as shown in the example below:

```json
{
  "mongoUsername": "mongo-user",
  "mongoPassword": "IRrE!jwcJkz5wGFb$Sx*$N@8^",
  "googleApiKey": "81cc9770-c3be-44d2-a18d-9039db1f062b",
  "facebookApiKey": "6b494a8e-f9a2-4774-8cb9-281bd73e9270"
}
```

The below command will encrypt plaintext to ciphertext, encode the ciphertext to Base64 and return this result wrapped in JSON. Then the Base64 encoded ciphertext will be extracted from JSON, and it will be decoded to binary. Finally, the binary will be saved to a file, as binary is the expected input of the AWS KMS Decrypt command.

```bash
aws kms encrypt --key-id 64dbfdcc-8519-4f8f-a1b2-d704e652259b \
  --plaintext file://secrets.json \
  --output text \
  --query CiphertextBlob | base64 --decode > secrets.encrypted.json
```

Decrypt is quite similar to encrypt. The command below decrypts the `ciphertext` back to `plaintext` and saves the results to `secrets.decrypted.json`

```bash
aws kms decrypt --ciphertext-blob fileb://secrets.encrypted.json \
  --output text --query Plaintext | base64 --decode > secrets.decrypted.json
```

#### Advanced Method

A more in depth way to encrypt `environment variable` can be done in the way as shown below:

![](https://miro.medium.com/max/3676/0*ONFTYCpnrZNuWhBY.png)

The following examples create a variable of `MyStrongPass` string and encrypt it with the KMS key:

```bash
PLAINTEXT=MyStrongPass
ENCRYPTED_PASSWORD=$(aws kms encrypt --key-id <key-id> \
  --plaintext fileb://<(echo -n ${PLAINTEXT}) \
  --output text --query CiphertextBlob)
echo $ENCRYPTED_PASSWORD > secret.encrypted.txt
cat secret.encrypted.txt
```

Decode the encrypted environment variable with the KMS key:

```bash
aws kms decrypt --key-id <key-id> \
  --ciphertext-blob fileb://<(cat secret.encrypted.txt | base64 -d ) --query Plaintext --output text | base64 -d
```

#### TODO:

- Add `context` as part of the encryption and decryption
- Add JSON encryption

#### References:

- [Introducing Amazon ECR server-side encryption using AWS Key Management System](https://aws.amazon.com/blogs/containers/introducing-amazon-ecr-server-side-encryption-using-aws-key-management-system/)
- [Encrypt/decrypt environment variables with AWS KM](https://faun.pub/aws-kms-encrypt-decrypt-environment-variables-497527e1c8cf)
- [How to Encrypt Secrets with the AWS Key Management Service (KMS)](https://www.humankode.com/security/how-to-encrypt-secrets-with-the-aws-key-management-service-kms)
- [How To Use AWS KMS In AWS Lambda](https://openupthecloud.com/kms-aws-lambda/)

---

## Clean Up

```bash
terraform destroy
```
