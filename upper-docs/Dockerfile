FROM menteslibres/luminos

COPY settings.prod.yaml /etc/settings.yaml

EXPOSE 9000

ENTRYPOINT [ \
	"/bin/luminos", \
	"-c", "/etc/settings.yaml", \
	"run" \
]
