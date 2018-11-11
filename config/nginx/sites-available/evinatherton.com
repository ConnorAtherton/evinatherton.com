#
# Rewrite http requests to https
# Rewrite requests for http://www.domain.ext to https://domain.com
#
server {
  listen 80;
  server_name www.evinatherton.com evinatherton.com;
  return 301 https://evinatherton.com$request_uri;
}

# proxy to node server listening on port 3000
upstream thin_server {
  server 127.0.0.1:3000;
}

#
# HTTPS server
#
server {
  listen 443 ssl;

  # Remove trailing slash
  rewrite ^/(.*)/$ /$1 permanent;

  # Path for static files
  root /var/www/evinatherton.com/current/public/;
  server_name evinatherton.com;

  ssl_certificate /etc/letsencrypt/live/evinatherton.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/evinatherton.com/privkey.pem;

  # Perfect forward secrecy
  ssl_prefer_server_ciphers on;
  ssl_dhparam /etc/nginx/ssl/dhparams.pem;
  ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4";

  # Optimize SSL by caching session parameters for 10 minutes. This cuts down on the number of expensive SSL handshakes.
  # The handshake is the most CPU-intensive operation, and by default it is re-negotiated on every new/parallel connection.
  # By enabling a cache (of type "shared between all Nginx workers"), we tell the client to re-use the already negotiated state.
  # a 1mb cache can hold about 4000 sessions, so we can hold 40000 sessions
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout  24h;
  # Use a higher keepalive timeout to reduce the need for repeated handshakes
  # default = 75 secs
  keepalive_timeout 300;
  # disable for poodle vulnerability
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  # This version tells browsers to treat all subdomains the same as this site and to load exclusively over HTTPS
  # remember the certificate for a year and automatically connect to HTTPS for this domain
  add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

  # config to don't allow the browser to render the page inside an frame or iframe
  # and avoid clickjacking http://en.wikipedia.org/wiki/Clickjacking
  #
  # https://developer.mozilla.org/en-US/docs/HTTP/X-Frame-Options
  add_header X-Frame-Options DENY;

  # when serving user-supplied content, include a X-Content-Type-Options: nosniff header along with the Content-Type: header,
  # to disable content-type sniffing on some browsers.
  # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
  # currently suppoorted in IE > 8 http://blogs.msdn.com/b/ie/archive/2008/09/02/ie8-security-part-vi-beta-2-update.aspx
  # http://msdn.microsoft.com/en-us/library/ie/gg622941(v=vs.85).aspx
  # 'soon' on Firefox https://bugzilla.mozilla.org/show_bug.cgi?id=471020
  add_header X-Content-Type-Options nosniff;

  # This header enables the Cross-site scripting (XSS) filter built into most recent web browsers.
  # It's usually enabled by default anyway, so the role of this header is to re-enable the filter for
  # this particular website if it was disabled by the user.
  # https://www.owasp.org/index.php/List_of_useful_HTTP_headers
  add_header X-XSS-Protection "1; mode=block";

  location / {
    try_files $uri @app;
  }

  # Proxy to app server running on port 3000
  location @app {
    proxy_pass http://thin_server;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
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
