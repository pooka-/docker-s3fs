FROM alpine:3.11

RUN apk add --no-cache \
  g++ \
  make \
  autoconf \
  automake \
  fuse-dev \
  curl \
  curl-dev \
  libxml2-dev \
  libressl-dev

WORKDIR /opt
RUN curl -sSL https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.85.tar.gz | tar zx -C /opt \
  && cd s3fs-fuse-1.85 \
  && ./autogen.sh \
  && ./configure --prefix=/usr \
  && make \
  && make install

ENV MOUNT_DIR=/mnt/s3 \
    REGION=ap-northeast-1

ENTRYPOINT ["sh"]
CMD [ \
  "-c", \
  "echo ${AWS_ACCESS_KEY}:${AWS_SECRET_KEY} > /root/.passwd-s3fs; chmod 600 /root/.passwd-s3fs; \
    /usr/bin/s3fs \
      -f \
      -o allow_other \
      -o use_cache=/tmp \
      -o use_path_request_style \
      -o endpoint=${REGION} \
      -o passwd_file=/root/.passwd-s3fs \
      -o url=https://s3-${REGION}.amazonaws.com \
      ${BUCKET} \
      ${MOUNT_DIR}" \
]

LABEL com.aznyan.docker.image.name=s3fs
LABEL com.aznyan.docker.image.arch=amd64
LABEL com.aznyan.docker.image.version=1.0.1
LABEL com.aznyan.docker.image.app.version=v1.85
