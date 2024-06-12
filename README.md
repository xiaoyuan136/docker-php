### 自定义Dockerfile
```bash
#构建镜像命令
docker build -t xiaoyuan136/php:8.1-fpm .
#运行容器
docker run --name php -d xiaoyuan136/php:8.1-fpm
```