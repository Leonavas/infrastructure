upstream api {
    server {{ apiHost }}:{{ apiPort }};
}

server {
    listen      443 ssl;
    listen [::]:443 ssl;

    server_name {{ dnsRecord }};

    ssl on;
    ssl_certificate /etc/letsencrypt/live/{{ dnsRecord }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{{ dnsRecord }}/privkey.pem;

    ssl_session_timeout 180m;
    ssl_session_cache shared:SSL:20m;
    ssl_session_tickets off;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DHE+AES128:!ADH:!AECDH:!MD5;

    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_trusted_certificate /etc/letsencrypt/live/{{ dnsRecord }}/chain.pem;

    location {{ apiLocation }} {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://api;
        proxy_redirect off;
    }
}