<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <link href="//fonts.googleapis.com/css?family=Raleway:500,700|Source+Serif+Pro:400,700|Source+Code+Pro:400,600" rel="stylesheet" type="text/css" />

    <link href="https://demo.upper.io/static/example.css" rel="stylesheet" type="text/css" />

    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
    <script src="https://demo.upper.io/static/playground.js"></script>
    <script src="https://demo.upper.io/static/snippets.js"></script>

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

    <script>
    goPlaygroundOptions({
      'shareRedirect': 'https://demo.upper.io/p/',
      'shareURL': 'https://demo.upper.io/share',
      'compileURL': 'https://demo.upper.io/compile',
      'fmtURL': 'https://demo.upper.io/fmt',
      'shareOpenNewWindow': true
    });
    </script>

    <script src="{{asset "/js/main.js"}}"></script>
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
        <div class="nav--adapters">
          <span class="nav__trigger--adapters" id="adapters-menu-trigger">tools</span>
          <ul id="adapters-menu">
            <li>{{ anchor "/postgresql" "PostgreSQL" }}</li>
            <li>{{ anchor "/mysql" "MySQL" }}</li>
            <li>{{ anchor "/sqlite" "SQLite" }}</li>
            <li>{{ anchor "/ql" "QL" }}</li>
            <li>{{ anchor "/mongo" "MongoDB" }}</li>
            <li>{{ anchor "/builder" "SQL Builder" }}</li>
          </ul>
        </div>
      </nav>
      {{ if not (.URLMatch "^/.+") }}
        <div class="hero">
          <div class="container">
            <img class="hero__background" src="{{ asset "/images/city.svg" }}" />
            <div class="hero__info">
              <img class="hero__gopher" src="{{ asset "/images/gopher.svg" }}" />
              <h1 class="hero__title">
                <a href="{{ asset "/" }}">
                  <img src="{{ asset "/images/logo.svg" }}" />
                  <span>upper.io/db</span>
                </a>
              </h1>
              <p class="hero__description">The non-magical database mapper that stays out of your way</p>
            </div>
            <div class="github">
              <a class="github__icon" target="_blank" href="https://github.com/upper/db">Check out the project at Github</a>
            </div>
          </div>
        </div>
      {{ end }}
    </header>
    <main>

        {{ if (.URLMatch "^/.+") }}
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
          {{ if eq .CurrentPage.URL "/" }}
            <p class="pressly text-center hidden-extra-small">Proudly sponsored by
              <a href="https://www.pressly.com" target="_blank"><img class="vertical-middle logo-pressly" src="{{ asset "images/pressly.png" }}" /></a>
            </p>
            <div class="features grid-3">
              <div class="feature">
                <h2 class="feature__title">{{ anchor "/getting-started" "Getting started" }}</h2>
                <p class="feature__description">
                  {{ anchor "/getting-started" "Let's work"}} with databases
                  in a less tedious and more productive way.
                </p>
                <a href="{{ asset "/examples" }}">
                  <img class="feature__icon" src="{{ asset "images/figure-01.svg" }}" />
                </a>
              </div>
              <div class="feature">
                <h2 class="feature__title">{{ anchor "/examples" "Code examples" }}</h2>
                <p class="feature__description">
                  Learn how to implement common patterns with our
                  {{ anchor "/examples" "code examples" }}
                </p>
                <a href="{{ asset "/examples" }}">
                  <img class="feature__icon" src="{{ asset "images/figure-02.svg" }}" />
                </a>
              </div>
              <div class="feature">
                <h2 class="feature__title">{{ anchor "/contribute" "Contribute" }}</h2>
                <p class="feature__description">
                  Get your hands dirty and {{ anchor "/contribute" "contribute" }}
                  with code, examples and documentation.
                </p>
                <a href="{{ asset "/examples" }}">
                  <img class="feature__icon" src="{{ asset "images/figure-03.svg" }}" />
                </a>
              </div>
            </div>
            <h2>Playground</h2>
            <textarea class="go-playground-snippet" data-expanded="1" data-title="Live Example: Opening a database and listing table rows">{{ include "webroot/examples/open/main.go" }}</textarea>
            <textarea class="go-playground-snippet" data-title="Live Example: Same as above but using the SQL builder">{{ include "webroot/examples/builder/main.go" }}</textarea>
            <textarea class="go-playground-snippet" data-title="Live Example: Building a JOIN statement">{{ include "webroot/examples/join/main.go" }}</textarea>
            <p>
              We have plenty of {{ anchor "/examples" "code examples" }} you can continue looking at.
            </p>
            <h2>Keep on learning</h2>
            <p>
              Want more details? continue with our
              {{ anchor "/getting-started" "getting started" }} page.
            </p>
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
