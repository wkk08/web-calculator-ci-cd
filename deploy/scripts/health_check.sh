#!/bin/bash
# 健康检查脚本

set -e

DEPLOY_DIR="/opt/web-calculator"
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "开始健康检查..."

# 检查当前活跃颜色
if [ -f "$DEPLOY_DIR/current_color" ]; then
    ACTIVE_COLOR=$(cat $DEPLOY_DIR/current_color)
else
    ACTIVE_COLOR="blue"
fi

echo "检查活跃颜色: $ACTIVE_COLOR"

# 根据颜色确定端口
if [ "$ACTIVE_COLOR" = "blue" ]; then
    PORT=5000
    SERVICE_NAME="app_blue"
else
    PORT=5001
    SERVICE_NAME="app_green"
fi

# 检查容器状态
echo "检查容器状态..."
container_id=$(docker ps -qf "name=webcalc_$ACTIVE_COLOR")
if [ -z "$container_id" ]; then
    echo "❌ 容器未运行"
    exit 1
fi

# 检查健康状态
echo "检查容器健康状态..."
health_status=$(docker inspect --format='{{.State.Health.Status}}' $container_id)
if [ "$health_status" != "healthy" ]; then
    echo "❌ 容器不健康: $health_status"
    exit 1
fi

# 检查应用端点
echo "检查应用端点..."
for i in $(seq 1 $MAX_RETRIES); do
    if curl -s -f http://localhost:$PORT/health > /dev/null; then
        echo "✅ 健康检查通过 (第 $i 次尝试)"
        echo "容器ID: $container_id"
        echo "健康状态: $health_status"
        exit 0
    fi
    echo "等待服务就绪... ($i/$MAX_RETRIES)"
    sleep $RETRY_INTERVAL
done

echo "❌ 健康检查失败: 服务在 ${MAX_RETRIES} 次尝试后未就绪"
exit 1