FROM rust:latest

WORKDIR /app

COPY . .

RUN cargo build --release

# 将可执行文件复制到 /usr/local/bin 中，使其在容器内可执行
RUN cp target/release/luoxu-cutwords /usr/local/bin/
