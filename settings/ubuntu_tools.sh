#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
export ISTIO_VERSION="1.9.8"
export KUBECTL_VERSION="1.21.4-00"
export TERRAFORM_VERSION="0.14.10"



echo "Installing Docker..."
sudo apt-get update
sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart
# create the docker group
sudo groupadd docker >/dev/null 2>&1 || true
# Make sure we can actually use docker as the current user
sudo usermod -aG docker $USER >/dev/null 2>&1 || true

# Install Kubectl 1.21 as that's latest version that works with TSB
echo "Installing Kubectl..."
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg \
  https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo \
  "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get remove -y kubectl
sudo apt-get install -y kubectl=${KUBECTL_VERSION}
sudo echo 'source <(kubectl completion zsh)' >>~/.zshrc

echo "Installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update
sudo apt-get install -y terraform="${TERRAFORM_VERSION}"

echo "Installing Azure CLI"
curl --silent -sL https://packages.microsoft.com/keys/microsoft.asc \
  | sudo gpg --yes --dearmor \
  | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli

echo "Installing Istio CLI"
curl --silent -L https://istio.io/downloadIstio | TARGET_ARCH="amd64" sh -
mv ./istio-${ISTIO_VERSION} ${HOME}
chown -R ${USER} ~/"istio-${ISTIO_VERSION}"
sudo mv ~/istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin

echo "Installing GH CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

echo "Installing AWS CLI"
sudo apt-get install -y awscli

echo "Installing AWS aws-iam-authenticator"
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin



echo "Installing Gcloud CLI"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install -y google-cloud-sdk

echo "installing the jq"
sudo apt-get -y install jq

echo "installing the kubectx"
sudo curl -o /usr/local/bin/kubectx -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx
sudo curl -o /usr/local/bin/kubens -L https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
sudo chmod +x /usr/local/bin/kubectx
sudo chmod +x /usr/local/bin/kubens

echo "installing the kubeps1"
curl -o ~/.kube-ps1.sh -L https://raw.githubusercontent.com/jonmosco/kube-ps1/master/kube-ps1.sh
sudo echo "source ${HOME}/.kube-ps1.sh" >>~/.zshrc
sudo echo PROMPT=\'\$\(kube_ps1\)\''$PROMPT' >>~/.zshrc
echo "installing the kubechc"
git clone https://github.com/aabouzaid/kubech ~/.kubech
sudo echo 'source ~/.kubech/kubech' >> ~/.zshrc
sudo echo 'source ~/.kubech/completion/kubech.bash' >> ~/.zshrc

echo "installing the tmate"
sudo apt-get update
sudo apt-get install -y tmate

echo "installing the fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
echo "please relogin since the docker needs to re-evaluate "
exit 1
