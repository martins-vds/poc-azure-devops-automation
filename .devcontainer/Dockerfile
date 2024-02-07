FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list' && \
    apt update && apt -y upgrade && \ 
    apt install -y xz-utils && \
    apt install -y curl && \
    apt install -y wget apt-transport-https software-properties-common && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt install -y nodejs && \
    npm install -g npm@latest && \
    npm install -g typescript && \
    npm install -g @azure/static-web-apps-cli && \
    wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell_7.4.1-1.deb_amd64.deb && \
    dpkg -i powershell_7.4.1-1.deb_amd64.deb && \
    apt install -f && \
    rm powershell_7.4.1-1.deb_amd64.deb && \
    apt install azure-functions-core-tools-4 && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
    az upgrade --all --yes --only-show-errors && \
    az bicep install
