#cloud-config
package_update: true
package_upgrade: false
packages:
  - npm
  - python3-venv
  - python3-pip
  - rustc
  - cargo
  - git
write_files:
  - path: /etc/netplan/99-custom-dns.yaml
    permissions: '0600'
    content: |
      network:
        version: 2
        ethernets:
          ens5:
            nameservers:
              addresses: [${dns_server_ip}]
            dhcp4-overrides:
              use-dns: false
              use-domains: false
runcmd:
  - git clone https://github.com/microsoft/sample-app-aoai-chatGPT.git /home/ubuntu/sample-app-aoai-chatGPT
  - chown -R ubuntu:ubuntu /home/ubuntu/sample-app-aoai-chatGPT
  - cp /home/ubuntu/sample-app-aoai-chatGPT/.env.sample /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_OPENAI_MODEL=.*/AZURE_OPENAI_MODEL=${azure_openai_deployment_name}/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_OPENAI_KEY=.*/AZURE_OPENAI_KEY=${azure_openai_key}/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_OPENAI_MODEL_NAME=.*/AZURE_OPENAI_MODEL_NAME=${azure_openai_model}/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s#^AZURE_OPENAI_ENDPOINT=.*#AZURE_OPENAI_ENDPOINT=${azure_openai_endpoint}#" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_SEARCH_SERVICE=.*/AZURE_SEARCH_SERVICE=${azure_search_service}/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_SEARCH_INDEX=.*/AZURE_SEARCH_INDEX=${azure_search_index}/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^DATASOURCE_TYPE=.*/DATASOURCE_TYPE=AzureCognitiveSearch/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_SEARCH_CONTENT_COLUMNS=.*/AZURE_SEARCH_CONTENT_COLUMNS=content/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/^AZURE_SEARCH_ENABLE_IN_DOMAIN=False/AZURE_SEARCH_ENABLE_IN_DOMAIN=True/" /home/ubuntu/sample-app-aoai-chatGPT/.env
  - sed -i "s/127\.0\.0\.1/0.0.0.0/g" /home/ubuntu/sample-app-aoai-chatGPT/start.sh
  - sed -i "s/--reload/--reload --cert \/home\/ubuntu\/cert.pem --key \/home\/ubuntu\/key.pem/g" /home/ubuntu/sample-app-aoai-chatGPT/start.sh
  - echo "AUTH_ENABLED=False" >> /home/ubuntu/sample-app-aoai-chatGPT/.env
  - openssl req -x509 -nodes -newkey rsa:2048 -keyout /home/ubuntu/key.pem -out /home/ubuntu/cert.pem -days 365 -subj "/CN=${certificate_cn}"
  - chown ubuntu:ubuntu /home/ubuntu/*.pem
  - . /home/ubuntu/sample-app-aoai-chatGPT/start.sh
  - nohup bash -c "sleep 10 && netplan apply" >/dev/null 2>&1 &