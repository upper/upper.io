/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const React = require('react');

const CompLibrary = require('../../core/CompLibrary.js');

const MarkdownBlock = CompLibrary.MarkdownBlock; /* Used to read markdown */
const Container = CompLibrary.Container;
const GridBlock = CompLibrary.GridBlock;

class HomeSplash extends React.Component {
  render() {
    const {siteConfig, language = ''} = this.props;
    const {baseUrl, docsUrl} = siteConfig;
    const docsPart = `${docsUrl ? `${docsUrl}/` : ''}`;
    const langPart = `${language ? `${language}/` : ''}`;
    const docUrl = doc => `${baseUrl}${docsPart}${langPart}${doc}`;

    const SplashContainer = props => (
      <div className="homeContainer">
        <div className="homeSplashFade">
          <div className="wrapper homeWrapper">{props.children}</div>
        </div>
      </div>
    );

    const Logo = props => (
      <div className="projectLogo">
        <img src={props.img_src} alt="upper/db" />
      </div>
    );

    const ProjectTitle = props => (
      <h2 className="projectTitle">
        {props.title}
        <small>{props.tagline}</small>
      </h2>
    );

    const PromoSection = props => (
      <div className="section promoSection">
        <div className="promoRow">
          <div className="pluginRowBlock">{props.children}</div>
        </div>
      </div>
    );

    const Button = props => (
      <div className="pluginWrapper buttonWrapper">
        <a className="button" href={props.href} target={props.target}>
          {props.children}
        </a>
      </div>
    );

    return (
      <SplashContainer>
        <Logo img_src={`${baseUrl}img/gopher.svg`} />
        <div className="inner">
          <ProjectTitle tagline={siteConfig.tagline} title={siteConfig.title} />
          <PromoSection>
            <Button href="//tour.dev.upper.io" target="_blank">Take the tour</Button>
          </PromoSection>
        </div>
      </SplashContainer>
    );
  }
}

class Index extends React.Component {
  render() {
    const {config: siteConfig, language = ''} = this.props;
    const {baseUrl} = siteConfig;

    const Block = props => (
      <Container
        padding={['bottom', 'top']}
        id={props.id}
        background={props.background}>
        <GridBlock
          align={props.align || 'center'}
          contents={props.children}
          layout={props.layout}
        />
      </Container>
    );

    const helloWorld = () => {
      return [
        'package main',
        '',
        'import (',
        '    "fmt"',
        '    "log"',
        '',
        '    "github.com/upper/db/v4/adapter/postgresql"',
        ')',
        '',
        'func main() {',
        '    sess, err := postgresql.Open(postgresql.ConnectionURL{',
        '        Database: `booktown`,',
        '        Host:     `demo.upper.io`,',
        '        User:     `demouser`,',
        '        Password: `demop4ss`,',
        '    })',
        '    if err != nil {',
        '        log.Fatal("Open: ", err)',
        '    }',
        '    defer sess.Close()',
        '',
        '    fmt.Printf("connected to database: %q", sess.Name())',
        '}',
      ].join("\n")
    }

    const CodeSample = () => (
      <Block id="try" background="light" align="left">
        {[
          {
            content: "We've designed the API with productivity and readability in mind.\n"+
            "The following snippet demonstrates how to connect to a database via the"+
            "`postgresql` adapter.\n\n"+
            "$$\n" +
            helloWorld() +
            "\n$$",
            title: 'Code sample',
          },
        ]}
      </Block>
    );

    const Description = () => (
      <Block background="dark" align="left">
        {[
          {
            content:
              'The goal of `upper/db` is to give you tools for the most common '+
              'operations with databases and stay out of the way in more '+
              'advanced cases. If you feel like writing tons of simple '+
              '`SELECT *` statements by hand is not the best use of your time, '+
              'then `upper/db` is the library for you.',
            image: `${baseUrl}img/undraw_note_list.svg`,
            imageAlign: 'right',
            title: "Made for productivity",
          },
        ]}
      </Block>
    );

    const QuickStart = () => (
      <Block align="left">
        {[
          {
            content:
              "We've prepared a learning playground with useful tips for you to try out `upper/db`. "+
              "Take the [tour](//tour.upper.io)! :-)",
            image: `${baseUrl}img/undraw_youtube_tutorial.svg`,
            imageAlign: 'right',
            title: 'Quick start: take the tour',
          },
        ]}
      </Block>
    );

    const Features = () => (
      <Block layout="fourColumn">
        {[
          {
            content: 'Our agnostic API is compatible with SQL and NoSQL databases',
            image: `${baseUrl}img/undraw_react.svg`,
            imageAlign: 'top',
            title: 'Agnostic API',
          },
          {
            content: 'Use the SQL builder or raw SQL statements for advanced cases',
            image: `${baseUrl}img/undraw_react.svg`,
            imageAlign: 'top',
            title: 'SQL friendly',
          },
          {
            content: 'An (optional) ORM-like layer is available for all your data modelling needs',
            image: `${baseUrl}img/undraw_react.svg`,
            imageAlign: 'top',
            title: 'ORM-like layer',
          },
        ]}
      </Block>
    );

    return (
      <div>
        <HomeSplash siteConfig={siteConfig} language={language} />
        <div className="mainContainer">
          <Features />
          <Description />
          <CodeSample />
          <QuickStart />
        </div>
      </div>
    );
  }
}

module.exports = Index;
