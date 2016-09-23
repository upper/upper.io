FROM docker.io/xiam/vanity:0.1.3

EXPOSE 9001

ENTRYPOINT [ \
  "/bin/vanity", \
  "-addr",        ":9001", \
  "-repo-root",   "https://github.com/upper", \
  "-vanity-root", "https://upper.io" \
]
