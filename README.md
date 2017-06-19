## Cloning this repository
```
cd ~/
git clone https://github.com/kostyrev/tf-rstudio-server.git
cd tf-rstudio-server
```

## Using AMI

### Configure required environment variables
`cp .envrc.dist .envrc`
and set appropriate environment variables in it.  

#### AWS_PROFILE
`AWS_PROFILE` is used to configure `aws_access_key_id` and `aws_secret_access_key` to access AWS API in some AWS account.  
For example, you could name you profile `fasten-analytics` and configure it:
```
mkdir ~/.aws/
cat >> ~/.aws/credentials <<EOF
[fasten-analytics]
aws_access_key_id=AKIAIXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXX
EOF
```
#### TF_VAR_spot_price
`TF_VAR_spot_price` is a price you willing to pay for an instance on the spot market.
Gradually increase this value until you request for instance is fulfilled

Export those environment variables by sourcing `.envrc` manually  
`. .envrc`  
or [install](https://github.com/kostyrev/ansible-role-direnv#install-from-github) [direnv](https://github.com/direnv/direnv) and execute
`direnv allow .`

### Use terraform to request an instance
[Install](https://github.com/kostyrev/ansible-role-terraform) [terraform](https://www.terraform.io/)
`cd terraform`
Before any operations with terraform run  
`terraform plan`  
to verify that terraform will do what you planned it to do.

If everything seems to be ok execute
```
terraform apply
```

### Connect to the instance
`ssh ubuntu@$(terraform output public_address)`  

### Demo
[![asciicast](https://asciinema.org/a/0rvnu96wixgr1hqdk7x0tkzri.png)](https://asciinema.org/a/0rvnu96wixgr1hqdk7x0tkzri)
