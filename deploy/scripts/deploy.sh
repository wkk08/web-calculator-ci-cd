#!/bin/bash
# 蓝绿部署脚本

set -e  # 遇到错误时退出

# 参数检查
if [ $# -ne 2 ]; then
    echo "使用方法: $0 <image_tag> <color>"
    echo "示例: $0 ghcr.io/user/repo:sha blue"
    exit 1
fi

IMAGE_TAG=$1
COLOR=$2
DEPLOY_DIR="/opt/web-calculator"

echo "========================================="
echo "开始部署"
echo "镜像标签: $IMAGE_TAG"
echo "部署颜色: $COLOR"
echo "========================================="

# 1. 创建部署目录
mkdir -p $DEPLOY_DIR
mkdir -p $DEPLOY_DIR/nginx/conf.d

# 2. 拉取新镜像
echo "拉取新镜像..."
docker pull $IMAGE_TAG

# 3. 更新环境变量
echo "更新环境变量..."
if [ "$COLOR" = "blue" ]; then
    sed -i "s|BLUE_TAG=.*|BLUE_TAG=$IMAGE_TAG|" $DEPLOY_DIR/.env
elif [ "$COLOR" = "green" ]; then
    sed -i "s|GREEN_TAG=.*|GREEN_TAG=$IMAGE_TAG|" $DEPLOY_DIR/.env
fi

# 4. 启动新版本容器
echo "启动新版本容器 (颜色: $COLOR)..."

if [ "$COLOR" = "blue" ]; then
    docker-compose -f $DEPLOY_DIR/docker-compose.yml up -d app_blue
elif [ "$COLOR" = "green" ]; then
    docker-compose -f $DEPLOY_DIR/docker-compose.yml up -d app_green
fi

# 5. 等待健康检查
echo "等待健康检查..."
sleep 15

# 6. 运行健康检查脚本
echo "执行健康检查..."
$DEPLOY_DIR/scripts/health_check

echo "✅ 部署完成!"
echo "新版本已启动，等待流量切换..."