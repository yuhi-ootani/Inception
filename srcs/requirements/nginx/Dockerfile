
#https://www.debian.org/releases/
FROM debian:bookworm-slim


#apt-get update — refreshes the local APT package index (list of available packages and versions) 
#so the system knows the latest available versions.
RUN apt-get update 

#apt-get install -y --no-install-recommends nginx ca-certificates — 
# install NGINX and the CA trust bundle; auto-yes; skip optional “recommended” packages.
RUN apt-get install -y nginx openssl

# -p = parents, creates the full path if missing, and does not complain if the folder already exists.
RUN mkdir -p /etc/nginx/ssl 

# openssl: The command-line tool for working with cryptography (keys, certificates, signing, encryption)
# req: OpenSSL’s command for creating certificate signing requests (CSRs)
# -x509: Instead of creating a CSR needed to be signed by CA, directly create an X.509 certificate(a self-signed certificate with private key). 
# -nodes: ells OpenSSL not to encrypt the private key with a password, so it can be used without asking for one each
# -keyout: save the generated private key to the path
# -out: saves the generated (self-signed) -x509 format certificate to the path
# -subj: provides all certificate subject details (country, state, org, common name, etc.) non-interactively in one string.
RUN  openssl req -x509 -nodes \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=JP/ST=Tokyo/L=Shujuku/O=42Tokyo/OU=Student/CN=oyuhi.42tokyo.jp/UID=oyuhi" 

# 
COPY conf/inception.conf /etc/nginx/conf.d/default.conf

# --no-install-recommends nginx ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

#rm -rf /var/lib/apt/lists/* — delete cached APT index files to reduce the final image size.

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


# # Simple page to serve
# RUN mkdir -p /usr/share/nginx/html \
#  && printf '%s\n' 'Hello from HTTPS (TLS 1.2/1.3)!' > /usr/share/nginx/html/index.html

# EXPOSE 443
# CMD ["nginx", "-g", "daemon off;"]
