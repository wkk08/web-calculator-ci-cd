#!/bin/bash
# 在阿里云服务器上运行 - root用户版本

set -e

echo "初始化部署服务器 (root用户)..."

# 1. 确保SSH公钥已配置（用于GitHub Actions登录）
echo "确保~/.ssh/authorized_keys已配置..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
# 这里需要您手动添加公钥到 ~/.ssh/authorized_keys
echo "请确保GitHub Actions使用的SSH公钥已添加到 ~/.ssh/authorized_keys"

# 2. 创建部署目录
mkdir -p /opt/web-calculator
mkdir -p /opt/web-calculator/nginx/conf.d
mkdir -p /opt/web-calculator/scripts
mkdir -p /opt/web-calculator/backups
chown -R root:root /opt/web-calculator

echo "部署目录创建完成: /opt/web-calculator"

# 3. 安装Docker和Docker Compose（如果未安装）
if ! command -v docker &> /dev/null; then
    echo "安装Docker..."
    curl -fsSL https://get.docker.com | sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "安装Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
         -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 4. 检查防火墙/安全组设置
echo "检查防火墙设置..."
echo "确保阿里云安全组开放了以下端口:"
echo "  - 22 (SSH)"
echo "  - 80 (HTTP)"
echo "  - 443 (HTTPS，可选)"

# 5. 检查Docker服务状态
systemctl enable docker
systemctl start docker

echo "✅ 服务器初始化完成 (root用户)"
echo "部署目录: /opt/web-calculator"
echo "您现在可以："
echo "1. 将deploy目录下的文件复制到 /opt/web-calculator/"
echo "2. 给脚本添加执行权限: chmod +x /opt/web-calculator/scripts/*"
echo "3. 测试部署: cd /opt/web-calculator && ./scripts/deploy 'ghcr.io/wkk08/web-calculator-ci-cd:latest' 'blue'"