FROM alpine:latest as builder
MAINTAINER HackXiu <hakkxiu@gmail.com>

ARG NGINX_VERSION=1.16.1
ARG NGINX_RTMP_VERSION=1.2.7

RUN	apk update		&&	\
	apk add				\
		git			    \
		gcc			    \
		binutils		\
		gmp			    \
		isl			    \
		libgomp			\
		libatomic		\
		libgcc			\
		openssl			\
		pkgconf			\
		pkgconfig		\
		mpfr3			\
		mpc1			\
		libstdc++		\
		ca-certificates		\
		libssh2			\
		curl			\
		expat			\
		pcre			\
		musl-dev		\
		libc-dev		\
		pcre-dev		\
		zlib-dev		\
		openssl-dev		\
		curl			\
		make


RUN	cd /tmp/									&&	\
	curl -s --remote-name https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz			&&	\
	git clone https://github.com/winshining/nginx-http-flv-module.git -b v${NGINX_RTMP_VERSION}

RUN	cd /tmp										&&  \
	tar xzf nginx-${NGINX_VERSION}.tar.gz               &&  \
	#tar xzf nginx-module-rtmp-${NGINX_RTMP_VERSION}.tar.gz                    &&  \
	cd nginx-${NGINX_VERSION}							&&  \
	./configure                                          \
		--prefix=/opt/nginx                              \
		--with-http_ssl_module                           \
		--add-module=../nginx-http-flv-module                \
		--with-cc-opt="-Wimplicit-fallthrough=0"        &&  \
	make										&&  \
	make install              
FROM alpine:latest
RUN apk update		&& \
	apk add			   \
		openssl		   \
		libstdc++	   \
		ca-certificates	   \
		pcre

COPY --from=0 /opt/nginx /opt/nginx
COPY --from=0 /tmp/nginx-http-flv-module/stat.xsl /opt/nginx/conf/stat.xsl
RUN rm -rf /opt/nginx/conf/nginx.conf               &&  \
	cd .. \                                         &&  \
	rm -rf /tmp/nginx-${NGINX_VERSION}              &&  \
	rm -rf /tmp/nginx-http-flv-module    
ADD run.sh /

EXPOSE 1935
EXPOSE 8080

CMD /run.sh
