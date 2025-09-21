# Assembly HTTP Server

This project implements a **minimal HTTP server in x86-64 Assembly (Linux syscall interface)**.  
It supports **GET** and **POST** requests, parsing file paths from HTTP requests and serving or writing files accordingly.  

---

## 📂 Project Structure

- **`server.asm`** – Main server implementation.  
  - Creates a TCP socket and binds it to a port.  
  - Accepts incoming connections using `socket`, `bind`, `listen`, `accept`.  
  - Forks into **parent** (connection handler) and **child** (request processor).  
  - Handles parsing of HTTP requests (`GET` and `POST`).  

- **`get.asm`** – Example GET handler logic, separated for clarity.  
  - Reads requested file from disk.  
  - Sends back an HTTP response header + file content.  

- **`post.asm`** – Example POST handler logic.  
  - Extracts `Content-Length` from request headers.  
  - Writes request body to a file.  
  - Responds with HTTP `200 OK`.  

- **`build.sh` / `Makefile`** – Compilation commands for assembling and linking the server.  

---

## ⚙️ Compilation & Running

You need **NASM** and **ld** installed.  

```bash
# Assemble and link
nasm -f elf64 server.asm -o server.o
ld server.o -o server

# Run the server (binds to port 80 or 20480 depending on sockaddr_in setup)
sudo ./server
