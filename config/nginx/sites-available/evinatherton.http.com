# proxy to rack server listening on port 3000
upstream rack_server {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  server_name www.evinatherton.com evinatherton.com;

  add_header X-XSS-Protection "1; mode=block";

  # Proxy to app server running on port 3000
  location @app {
    proxy_pass http://rack_server;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }

  location / {
    try_files $uri @app;
  }

  # Serve cached static assets through nginx
  # location /assets {
  #  expires 1y;
  #  access_log off;
  #  add_header Cache-Control "public";
  # }

  # always strip leading slashes
  rewrite ^/(.*)/$ /$1 permanent;
}
