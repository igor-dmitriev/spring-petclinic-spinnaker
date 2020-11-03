# Spinnaker

Terraform
NOTE: Review Prerequisite below.<br/>
Make sure you have `default` profile in your `~/.aws/credentials`
```
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
```

NOTE: It is better to disable Trigger before launching the terraform script to prevent automatic pipeline executions on a new machine<br/>
Run the script:<br/>
```
terraform apply -var-file=default.tfvars -auto-approve
```
NOTE: `userdata` is not used cause some config files must be copied to the ec2 machine !!!<br/>
All Spinnaker configs, pipelines, notifications, projects are stored in MySQL DB.<br/>
Spinnaker pipeline is triggered from Jenkins.<br/>

### Prerequisite