# Rancher Server Deployment to Azure

1. Run `terraform init` to initialize Terraform. Terraform will download the
necessary configurations to be able to communicate with Azure Cloud.

    ```text
    $ terraform init
    ```

1. Run `terraform plan` to show the changes and prompt for approval.
    ```text
    $ terraform plan
    ```

1. Run `terraform apply` to show the changes and prompt for approval.

    ```text
    $ terraform apply
    ```


## Steps used to configure VM
*These steps are not required and are only to demonstrate the steps to configure the vm manually.*

- Deploy ubuntu 18.04 LTS VM in Azure

- Steps to configure ubuntu vm
    ```text
    sudo apt update && sudo apt upgrade

    sudo apt-get remove docker docker-engine docker.io
    sudo apt install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
    ```

- Create Azure service principal
    ```text
    az ad sp create-for-rbac --name rancherSP
    ```
