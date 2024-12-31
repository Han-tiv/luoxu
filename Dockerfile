# 使用官方 Python 镜像作为基础镜像
FROM python:3.9-slim-buster

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install -r requirements.txt

# 安装必要的系统依赖 (例如 OpenCC)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopencc-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust 和 nightly 工具链
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"

# 复制 querytrans 目录并构建
WORKDIR /app/querytrans
COPY querytrans .
RUN rustup run nightly cargo build --release

# 将构建好的 querytrans.so 复制到 /app 目录
WORKDIR /app
RUN cp querytrans/target/release/libquerytrans.so querytrans.so

# 复制 luoxu 项目的其他文件
COPY . .

# 复制 config.toml.example 并创建 config.toml (可以根据需要进行修改)
COPY config.toml.example config.toml

# 设置环境变量 (例如 Telegram API Key，数据库连接信息等)
# 建议使用 docker-compose 的 environment 或 .env 文件来管理敏感信息
# ENV TELEGRAM_API_ID=your_api_id
# ENV TELEGRAM_API_HASH=your_api_hash
# ENV DATABASE_URL="postgresql://user:password@host:port/dbname"

# 定义启动命令
CMD ["python", "-m", "luoxu"]
