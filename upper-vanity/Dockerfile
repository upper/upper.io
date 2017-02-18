FROM docker.io/xiam/vanity:0.2

EXPOSE 9001

ENTRYPOINT [ \
  "/bin/vanity", \
  "-addr",        ":9001", \
  "-repo-root",   "https://github.com/upper", \
  "-vanity-root", "https://upper.io" \
]
