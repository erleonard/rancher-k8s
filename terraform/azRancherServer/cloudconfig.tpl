#cloud-config

package_update: true
package_upgrade: true
package_reboot_if_required: false

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - software-properties-common

runcmd:
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update -y
  - apt-get -y install docker-ce docker-ce-cli containerd.io
  - systemctl start docker
  - systemctl enable docker
  - docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher