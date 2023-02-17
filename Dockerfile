# how to build?
# docker login
## .....input your docker id and password
#docker build . -t tinyfilemanager/tinyfilemanager:master
#docker push tinyfilemanager/tinyfilemanager:master

# how to use?
# docker run -d -v /absolute/path:/tfm/data -p 80:80 --restart=always --name tfm tinyfilemanager/tinyfilemanager:master

FROM php:8-zts-alpine

# if run in China
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --no-cache libzip-dev && \
    docker-php-ext-install zip

WORKDIR /tfm

COPY tinyfilemanager.php index.php
COPY translation.json .

CMD ["sh", "-c", "php -S 0.0.0.0:80"]
