\# x86\_64 HTTP Server in Assembly



A minimal HTTP server written in x86-64 Linux Assembly using raw Linux syscalls.



This project was built to understand how web servers work at the lowest level: socket creation, binding, listening, accepting connections, parsing HTTP requests, reading and writing files, and handling multiple clients using `fork`.



\## Features



\* Written in x86-64 Assembly

\* Uses raw Linux syscalls

\* No C standard library

\* No external dependencies

\* Basic HTTP GET support

\* Basic HTTP POST support

\* File reading and writing

\* Fork-based concurrency

\* Educational low-level networking project



\## Project Structure



```text

.

├── src/

│   └── server.s

├── experiments/

│   ├── alternate-get-post-server.s

│   ├── get-only-server.s

│   └── post-only-server.s

├── Makefile

├── .gitignore

└── README.md

```



\## Requirements



This project targets Linux x86-64.



You need:



\* Linux or WSL

\* GNU assembler `as`

\* GNU linker `ld`

\* `make`

\* `curl` for testing



\## Build



```bash

make

```



This creates the executable:



```text

build/http-server

```



\## Run



```bash

./build/http-server

```



The server listens on port `8080`.



\## Test GET



Create a test file:



```bash

echo "Hello from Assembly" > hello.txt

```



Then request it:



```bash

curl http://127.0.0.1:8080/hello.txt

```



Expected output:



```text

Hello from Assembly

```



\## Test POST



Send data to a file:



```bash

curl -X POST http://127.0.0.1:8080/upload.txt --data "Data written by Assembly"

```



Then read it back:



```bash

curl http://127.0.0.1:8080/upload.txt

```



Expected output:



```text

Data written by Assembly

```



\## What I Learned



Through this project, I practiced:



\* Linux syscall programming

\* Low-level socket programming

\* HTTP request parsing

\* File descriptor management

\* Process creation with `fork`

\* Debugging low-level server behavior

\* Understanding how web servers work internally



\## Security Notes



This server is educational and should not be used in production.



Current limitations include:



\* No path traversal protection

\* No robust HTTP parsing

\* Fixed-size buffers

\* Minimal error handling

\* No authentication

\* No TLS support



The goal is not to build a production-ready web server, but to understand the low-level mechanisms behind one.



\## Demo



A short demo of this project is available on my LinkedIn profile.



\## License



MIT License



