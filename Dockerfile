# 使用官方 Python 镜像作为基础镜像
FROM python:3.9-slim-buster

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install -r requirements.txt

# 安装必要的系统依赖 (例如 OpenCC 和 Rust 构建依赖)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libopencc-dev \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置 PKG_CONFIG_PATH 环境变量
# 检查 opencc 是否已安装
RUN dpkg -l | grep libopencc

# 查找 opencc.pc 文件的确切位置
RUN find /usr /opt /etc -name opencc.pc
RUN ldconfig
ENV PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig"
# 安装 Rust 和 nightly 工具链
# 下载 rustup-init 脚本
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init

# 运行 rustup-init
RUN chmod +x rustup-init && ./rustup-init -y --no-modify-path --default-toolchain none

# 设置环境变量
ENV RUSTUP_HOME=/root/.rustup
ENV CARGO_HOME=/root/.cargo
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装 nightly 工具链
RUN rustup toolchain install nightly

# 复制 querytrans 目录并构建
WORKDIR /app/querytrans
COPY querytrans ./
# 修复 将 querytrans 目录复制到 /app/querytrans
RUN cargo build --release

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
