#!/bin/bash

# Replace with your desired domain and file path
DOMAIN="myjenkins-app.duckdns.org"
CONFIG_FILE="/etc/nginx/sites-available/$DOMAIN"

# Create Nginx configuration file
sudo tee "$CONFIG_FILE" > /dev/null <<'EOL'
upstream jenkins{
    server 127.0.0.1:8080;
}

server{
    listen      80;
    server_name myjenkins-app.duckdns.org;

    access_log  /var/log/nginx/jenkins.access.log;
    error_log   /var/log/nginx/jenkins.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://jenkins;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }

}


EOL

# Enable the configuration file
sudo ln -s "$CONFIG_FILE" "/etc/nginx/sites-enabled/"

# Test for syntax errors
sudo nginx -t

# If syntax is OK, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    sudo certbot --nginx -d $DOMAIN
    sudo systemctl status certbot.timer
    sudo certbot renew --dry-run

    echo "Nginx configuration and Encryption reloaded successfully."
else
    echo "Error: Nginx configuration has syntax errors. Please check and fix."
fi
