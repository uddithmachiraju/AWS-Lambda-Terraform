init:
	@echo "Initilizing Terraform"
	terraform init 

plan:
	@echo "Plan the Terraform file"
	terraform plan -out=aws-lambda

apply:
	@echo "Apply the Terraform"
	terraform apply aws-lambda 

outputs:
	@echo "Get the outputs of the terraform"
	terraform output 

destroy:
	@echo "Destroy the Architecture"
	terraform destroy 

update:
	@echo "Updating the lambda function"
	terraform plan -out=aws-lambda
	terraform apply aws-lambda