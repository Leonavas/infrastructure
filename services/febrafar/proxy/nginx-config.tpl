upstream api {
    server 127.0.0.1:9002;
}

server {
    listen      443 ssl;
    listen [::]:443 ssl;

    server_name prezao.io;

    ssl on;
    ssl_certificate /etc/letsencrypt/live/prezao.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/prezao.io/privkey.pem;

    ssl_session_timeout 180m;
    ssl_session_cache shared:SSL:20m;
    ssl_session_tickets off;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DHE+AES128:!ADH:!AECDH:!MD5;

    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_trusted_certificate /etc/letsencrypt/live/prezao.io/chain.pem;

    location /api {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

        proxy_pass http://api;
        proxy_redirect off;
    }
}