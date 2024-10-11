
format:
	terraform fmt

validate:
	terraform validate

plan:
	terraform plan -var-file="dev.tfvars"

apply:
	terraform apply -var-file="dev.tfvars"

destroy:
	terraform destroy -var-file="dev.tfvars"
