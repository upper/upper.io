FROM menteslibres/luminos:0.9.3

WORKDIR /var/docs

COPY settings.prod.yaml /etc/settings.yaml

EXPOSE 9000

VOLUME ["/var/docs"]

ENTRYPOINT [ \
	"/bin/luminos", \
	"-c", "/etc/settings.yaml", \
	"run" \
]
