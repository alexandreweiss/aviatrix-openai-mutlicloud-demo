#cloud-config
package_update: true
package_upgrade: false
packages:
  - nginx
write_files:
  - path: /etc/nginx/sites-available/default
    permissions: '0644'
    content: |
      server {
          listen 443 ssl;
          server_name ${chat_certificate_cn};

          ssl_certificate /home/ubuntu/chat_cert.pem;
          ssl_certificate_key /home/ubuntu/chat_key.pem;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers HIGH:!aNULL:!MD5;

          location / {
              proxy_pass https://${aws_oai_server_ip_address}:50505;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_ssl_verify off;
          }
      }

      server {
          listen 443 ssl;
          server_name ${app_certificate_cn};

          ssl_certificate /home/ubuntu/app_cert.pem;
          ssl_certificate_key /home/ubuntu/app_key.pem;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers HIGH:!aNULL:!MD5;

          location / {
              proxy_pass http://${container_ip_address}:8080;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_ssl_verify off;
          }
      }
runcmd:
  - openssl req -x509 -nodes -newkey rsa:2048 -keyout /home/ubuntu/chat_key.pem -out /home/ubuntu/chat_cert.pem -days 365 -subj "/CN=${chat_certificate_cn}"
  - openssl req -x509 -nodes -newkey rsa:2048 -keyout /home/ubuntu/app_key.pem -out /home/ubuntu/app_cert.pem -days 365 -subj "/CN=${app_certificate_cn}"
  - chown ubuntu:ubuntu /home/ubuntu/*.pem
  - systemctl enable nginx
  - systemctl restart nginx
  - nohup bash -c "sleep 10 && sudo netplan apply" >/dev/null 2>&1 &