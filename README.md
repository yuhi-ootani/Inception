# Inception
Docker project

## What I learn 

### NGINX  
NGINX (pronounced engine-x) is a high-performance web server and reverse proxy server.  
->A web server serves static files (HTML, CSS, JS, images, etc.) to clients (browsers).  
->A reverse proxy sits in front of backend services (like WordPress or databases) and forwards client requests to them, while adding features like load balancing, caching, and security.

### TLSv1.2 / TLSv1.3  
NGINX in your container will be configured to use HTTPS (encrypted communication).

### PHP-FPM stands for PHP FastCGI Process Manager.  
->PHP itself is the language used by WordPress (all its backend code is PHP).  
->But web servers (like NGINX) cannot run PHP code directly — they only serve static files.  
->That’s where PHP-FPM comes in: it runs PHP scripts in the background and communicates with the web server (NGINX in your case) through a protocol called FastCGI.

### MariaDB   
: is an open-source relational database system, a drop-in replacement for MySQL.  
->It stores and organizes data in tables (rows and columns).  
->You can query and update the data using SQL (Structured Query Language).  
->MariaDB is often used for web apps because it’s lightweight, reliable, and MySQL-compatible.

### Docker volume
: is a way to store **data outside the container’s writable layer** so that  
Data is **persistent** (it survives when a container is stopped or deleted).  
Data can be **shared** between containers.

### Docker network
: is a virtual network created by Docker so that containers can communicate with each other.  
->By default, containers are isolated.  
->When you put them on the same Docker network, they can reach each other using container names (DNS) instead of IP addresses.  
->Docker manages the routing, so you don’t need to manually set IPs.

### PID 1 in Docker

#### What is PID 1?
On Linux, every process has a **Process ID (PID)**.  
- The very first process started gets **PID = 1**.  
- PID 1 is special:  
  - Acts as the **init process**.  
  - Must **reap zombie processes** (child processes that finish).  
  - Receives **system signals** (e.g., `SIGTERM`, `SIGINT`).  

#### Why PID 1 matters in Docker
Inside a container, the **first process you start becomes PID 1**.  

If your service is **not** PID 1 (e.g., you start it in the background and keep the container alive with `tail -f`), then:  
- Signals may not reach the real service.  
- Docker may fail to stop or restart it cleanly.  
- Zombie processes can accumulate.  

#### Best Practices
- ✅ Run your main service **in the foreground** so it becomes PID 1.  
- ✅ Do **not daemonize** inside containers.  
- ❌ Avoid hacky keep-alive commands, such as:  
  - `tail -f /dev/null`  
  - `sleep infinity`  
  - `while true; do sleep 1000; done`  
  - Running services with `&`  


