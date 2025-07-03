#!/bin/bash

# Argüman olarak gelen Organizasyon adını ve PAT'i değişkenlere atıyoruz
ORG_NAME=$1
ACCESS_TOKEN=$2

# Runner versiyonu
RUNNER_VERSION="2.311.0"

# GitHub API'sini kullanarak geçici bir kayıt token'ı alıyoruz
# İşte PAT'in asıl kullanım amacı budur!
echo "Fetching registration token from GitHub API..."
REG_TOKEN=$(curl -s -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/orgs/${ORG_NAME}/actions/runners/registration-token | jq .token --raw-output)

# GitHub'dan runner yazılımını indiriyoruz
echo "Downloading runner software..."
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Runner'ı yapılandırıyoruz
# --unattended: interaktif olmadan çalışır
# --url: bağlanacağı organizasyon
# --token: az önce API'den aldığımız geçici kayıt token'ı
# --name: runner'a benzersiz bir isim veriyoruz (pod'un hostname'i)
echo "Configuring runner..."
./config.sh --unattended --url https://github.com/${ORG_NAME} --token ${REG_TOKEN} --name "k8s-runner-$(hostname)" --work _work

# Runner'ı çalıştırıyoruz ve script'in sonlanmasını engelliyoruz
echo "Starting runner..."
./run.sh & wait $!
