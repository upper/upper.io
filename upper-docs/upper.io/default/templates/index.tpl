<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <link href="//fonts.googleapis.com/css?family=Raleway:500,700|Source+Serif+Pro:400,700|Source+Code+Pro:400,600" rel="stylesheet" type="text/css" />
    <link href="{{ asset "/css/style.css" }}" rel="stylesheet" />
    <link href="{{ asset "/css/syntax.css" }}" rel="stylesheet">
    <title>
      {{ if .IsHome }}
        {{ setting "page/head/title" }}
      {{ else }}
        {{ if .Title }}
          {{ .Title }} {{ if setting "page/head/title" }} &middot; {{ setting "page/head/title" }} {{ end }}
        {{ else }}
          {{ setting "page/head/title" }}
        {{ end }}
      {{ end }}
    </title>
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="{{ asset "/apple-touch-icon-precomposed.png" }}">
    <link rel="shortcut icon" href="{{ asset "/favicon.ico"}}">

    <!-- Code highlighting -->
    <link rel="stylesheet" href="//menteslibres.net/static/highlightjs/styles/default.css?v0000">
    <script src="//menteslibres.net/static/highlightjs/highlight.pack.js?v0000"></script>
    <script>hljs.initHighlightingOnLoad();</script>

    <script src="{{asset "js/main.js"}}"></script>
  </head>

  <body>
    <header class="main-header">
      <nav class="nav--main">
        <div class="nav--sections">
          {{ if .BreadCrumb }}
            <ul class="breadcrumb">
              {{ range .BreadCrumb }}
                <li><a href="{{ asset .link }}">{{ .text }}</a></li>
              {{ end }}
            </ul>
          {{ end }}
        </div>
      </nav>
      {{ if not (.URLMatch "^/.+/.+") }}
        <div class="hero">
          <div class="container">
            <img class="hero__background" src="{{ asset "/images/city.svg" }}" />
            <div class="hero__info">
              <img class="hero__gopher" src="{{ asset "/images/gopher.svg" }}" />
              <h1 class="hero__title">
                <a href="/db">
                  <img src="{{ asset "/images/logo.svg" }}" />
                  <span>upper.io/db</span>
                </a>
              </h1>
              <p class="hero__description">The <b>upper.io</b> toolkit</p>
            </div>
            <div class="github">
              <a class="github__icon" target="_blank" href="https://github.com/upper">check it out at github.com/upper</a>
            </div>
          </div>
        </div>
      {{ end }}
    </header>
    <main>

        {{ if (.URLMatch "^/.+/.+") }}
          {{ if .Content }}
            <nav class="sections__nav">
              <div class="nav__trigger--sections__nav" id="sections-menu-trigger">Index</div>
              <div class="sections__nav__block" id="sections-menu">
                <h2 class="sections__nav__title">
                  {{ range .GetTitlesFromLevel 0 }}
                    <a href="{{ .url }}">{{ .text }}</a>
                  {{ end }}
                </h2>
                <ul>
                {{ range .GetTitlesFromLevel 1 }}
                  <li><a href="{{ .url }}">{{ .text }}</a></li>
                {{ end }}
                </ul>
              </div>
            </nav>
            <article>
          {{ end }}
        {{ end }}

        <div class="container">
          {{ if eq .CurrentPage.URL "/db" }}
            <p class="pressly text-center hidden-extra-small">Proudly sponsored by
              <a href="https://www.pressly.com" target="_blank"><img class="vertical-middle logo-pressly" src="{{ asset "images/pressly.png" }}" /></a>
            </p>
            <div class="features grid-3">
              <div class="feature">
                <h2 class="feature__title">Getting started</h2>
                <p class="feature__description">
                  <a href="/db/getting-started">Let's work</a> with databases
                  in a less tedious and more productive way.
                </p>
                <a href="/db/getting-started">
                <img class="feature__icon" src="{{ asset "images/figure-01.svg" }}" />
                </a>
              </div>
              <div class="feature">
                <h2 class="feature__title">Code examples</h2>
                <p class="feature__description">
                  Learn how to implement common patterns with our <a
                  href="/db/examples">code examples</a>.
                </p>
                <a href="/db/examples">
                <img class="feature__icon" src="{{ asset "images/figure-02.svg" }}" />
                </a>
              </div>
              <div class="feature">
                <h2 class="feature__title">Contribute</h2>
                <p class="feature__description">
                  Get your hands dirty and <a href="/db/contribute">contribute</a>
                  with code, examples or documentation.
                </p>
                <a href="/db/contribute">
                  <img class="feature__icon" src="{{ asset "images/figure-03.svg" }}" />
                </a>
              </div>
            </div>
          {{ else }}

            {{ if .Content }}
              {{ .ContentHeader }}
              {{ .Content }}
              {{ .ContentFooter }}
            {{end}}

            {{ if setting "page/body/copyright" }}
              <p>{{ setting "page/body/copyright" | htmltext }}</p>
            {{ end }}

          {{ end }}
        </div>
    </main>
    <script src="{{ asset "/js/app.js" }}"></script>
    {{ if setting "page/body/scripts/footer" }}
      <script type="text/javascript">
        {{ setting "page/body/scripts/footer" | jstext }}
      </script>
    {{ end }}
  </body>
</html>
