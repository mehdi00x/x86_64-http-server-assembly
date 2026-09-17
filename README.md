# HTTP Server in x86-64 Assembly

A minimal HTTP server written in x86-64 Assembly for Linux, using **raw syscalls only**: no C library, no external dependencies.

Goal: understand what a web server does at the lowest level, between the CPU, the kernel and the network.

## Features

- Syscall flow: `socket` → `bind` → `listen` → `accept` → `read` / `write`
- HTTP `GET` (serve a file) and `POST` (write a file)
- Multiple clients with `fork`

## Build and run

Requirements: Linux or WSL (x86-64), `as`, `ld`, `make`.

```bash
make
./build/http-server      # listens on port 8080
```

## Test

```bash
echo "Hello from Assembly" > hello.txt
curl http://127.0.0.1:8080/hello.txt

curl -X POST http://127.0.0.1:8080/upload.txt --data "Data written by Assembly"
curl http://127.0.0.1:8080/upload.txt
```

## Repository structure

```text
src/server.s        main server
experiments/        GET-only, POST-only and alternate versions
Makefile
```

## Security notes

Educational project, not for production. Known limitations: no path traversal protection, minimal HTTP parsing, fixed-size buffers, minimal error handling, no TLS.

## License

MIT
