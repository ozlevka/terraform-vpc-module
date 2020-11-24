FROM ubuntu:20.04


# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Or your actual UID, GID on Linux if not the default 1000
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG TERRAFORM_VERSION="0.13.2"
ARG KUBECTL_VERSION="v1.18.12"
ARG HELM_VERSION="v2.16.3"

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog wget curl unzip ca-certificates git 2>&1 \
    # Install python 3 and pip 3
    && apt-get install -y --no-install-recommends python3 python3-pip python3-setuptools ssh-client \
    #Install awscli 
    && pip3 install awscli \
    # Install terraform
    && wget -O ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip && mv terraform /usr/local/bin \
    && rm -f ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    # Install kubectl
    && curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/bin/ \
    # Install Helm
    && curl -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar xvfz "helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && chmod +x ./linux-amd64/helm \
    && mv ./linux-amd64/helm /usr/bin \
    && rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64 \
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME 

ENV DEBIAN_FRONTEND=