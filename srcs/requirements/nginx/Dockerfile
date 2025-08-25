
#https://www.debian.org/releases/
FROM debian:bookworm-slim

#apt-get update — refresh the local APT package index lists and knows the latest available versions of packages.
#apt-get install -y --no-install-recommends nginx ca-certificates — install NGINX and the CA trust bundle; auto-yes; skip optional “recommended” packages.
#-p = parents, creates the full path if missing, and does not complain if the folder already exists.

#rm -rf /var/lib/apt/lists/* — delete cached APT index files to reduce the final image size.
RUN apt-get update \
    && apt-get install -y nginx \
    && mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes \
    && -keyout /etc/nginx/ssl/inception.key \
    && -out /etc/nginx/ssl/inception.crt \
    && -subj "/C=JP/ST=Tokyo/L=Shujuku/O=42Tokyo/OU=Student/CN=<login>.42tokyo.jp/UID=<login>" 
# --no-install-recommends nginx ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

# #Purpose: Adds metadata to the image saying “this container listens on port 80 inside the container.”
# EXPOSE 80

# # run nginx in the foreground instead of in the background
# CMD ["nginx", "-g", "daemon off;"]



# RUN apt-get update \
#  && apt-get install -y --no-install-recommends nginx openssl ca-certificates \
#  && rm -rf /var/lib/apt/lists/*

# # Remove the default HTTP site (port 80)
# RUN rm -f /etc/nginx/sites-enabled/default

# # Generate a self-signed cert (for local testing)
# RUN openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
#   -keyout /etc/ssl/private/selfsigned.key \
#   -out /etc/ssl/certs/selfsigned.crt \
#   -subj "/CN=localhost"

# # Minimal HTTPS server config (TLSv1.2/1.3 only)
# RUN mkdir -p /etc/nginx/conf.d
# COPY default.conf /etc/nginx/conf.d/default.conf

# # Simple page to serve
# RUN mkdir -p /usr/share/nginx/html \
#  && printf '%s\n' 'Hello from HTTPS (TLS 1.2/1.3)!' > /usr/share/nginx/html/index.html

# EXPOSE 443
# CMD ["nginx", "-g", "daemon off;"]
