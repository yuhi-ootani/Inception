
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
# -newkey: generate a private key uses the RSA algorithm with 2048 bits long
# -keyout: save the generated private key to the path
# -out: saves the generated (self-signed) -x509 format certificate to the path
# -subj: provides all certificate subject details (country, state, org, common name, etc.) non-interactively in one string.
RUN  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=JP/ST=Tokyo/L=Shinjuku/O=42Tokyo/OU=Student/CN=oyuhi.42tokyo.jp/UID=oyuhi" 
#-newkey rsa:2048 -days 365 

# past the original inception configuratoin file to the nginx
COPY conf/inception.conf /etc/nginx/conf.d/default.conf

# # OPTIONAL: Ensure the directory is accessible (rwx for owner, rx for others)
# RUN chmod 755 /var/www/html
# # chown [OPTIONS] USER:GROUP PATH 
# # Change ownership of all files/dirs to the web server user and group (www-data)
# # www-data is the default user Nginx and PHP-FPM run under in Debian/Ubuntu
# RUN chown -R www-data:www-data /var/www/html 


# run nginx in the foreground instead of in the background
CMD ["nginx", "-g", "daemon off;"]
