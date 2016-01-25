FROM nginx

ADD bin/ /usr/sbin/

RUN configure-nginx.sh

VOLUME ["/var/log/nginx", "/etc/nginx/conf.d.t"]

EXPOSE 80 443
WORKDIR /etc/nginx

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx"]
