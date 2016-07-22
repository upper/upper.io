FROM nginx

RUN apt-get update

RUN apt-get install -y vim tmux

ADD bin/ /usr/sbin/

RUN configure-nginx.sh

RUN mkdir -p /var/www

VOLUME ["/var/www", "/var/log/nginx", "/etc/nginx/conf.d.t", "/etc/private"]

EXPOSE 80 443
WORKDIR /etc/nginx

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx"]
