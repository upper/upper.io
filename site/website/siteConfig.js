/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// See https://docusaurus.io/docs/site-config for all the possible
// site configuration options.

// List of projects/orgs using your project for the users page.
const users = [
];

const siteConfig = {
  title: 'upper/db', // Title for your website.
  tagline: 'A productive data access layer for Go',
  url: 'https://upper.io', // Your website URL
  baseUrl: '/', // Base URL for your project */
  // For github.io type URLs, you would set the url and baseUrl like:
  //   url: 'https://facebook.github.io',
  //   baseUrl: '/test-site/',
  docsUrl: 'v4',

  // Used for publishing and more
  projectName: 'upper.io',
  organizationName: 'upper.io',
  // For top-level user or org sites, the organization is still the same.
  // e.g., for the https://JoelMarcey.github.io site, it would be set like...
  //   organizationName: 'JoelMarcey'

  // For no header links in the top nav bar -> headerLinks: [],
  headerLinks: [
    {doc: 'getting-started/index', label: 'Getting started'},
    {href: 'https://tour.upper.io', label: 'Tour'},
    //{blog: true, label: 'Blog'},
    {href: 'https://github.com/upper/db', label: 'Github'},
  ],

  // If you have users set above, you add it here:
  //users,

  /* path to images for header/footer */
  headerIcon: 'img/gopher.svg',
  footerIcon: 'img/gopher.svg',
  favicon: 'img/gopher.svg',

  /* Colors for website */
  colors: {
    primaryColor: '#373d40',
    secondaryColor: '#54dbf9',
  },

  /* Custom fonts for website */
  fonts: {
    myFont: [
      "Times New Roman",
      "Serif"
    ],
    myOtherFont: [
      "-apple-system",
      "system-ui"
    ]
  },

  // This copyright info is used in /core/Footer.js and blog RSS/Atom feeds.
  copyright: `Copyright © ${new Date().getFullYear()} The upper/db Authors`,

  highlight: {
    // Highlight.js theme to use for syntax highlighting in code blocks.
    theme: 'default',
  },

  // Add custom scripts here that would be placed in <script> tags.
  scripts: [
    'https://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js',
    'https://buttons.github.io/buttons.js',
    'https://demo.upper.io/static/playground-full.js',
    'https://demo.upper.io/static/snippets.js',
    '/js/playground.js',
  ],

  stylesheets: [
    'https://demo.upper.io/static/example.css',
    'https://demo.upper.io/static/codemirror.css',
    'https://codemirror.net/theme/material.css',
    '/css/playground.css'
  ],

  // On page navigation for the current documentation page.
  onPageNav: 'separate',
  // No .html extensions for paths.
  cleanUrl: true,

  // Open Graph and Twitter card images.
  ogImage: 'img/undraw_online.svg',
  twitterImage: 'img/undraw_tweetstorm.svg',

  // For sites with a sizable amount of content, set collapsible to true.
  // Expand/collapse the links and subcategories under categories.
  // docsSideNavCollapsible: true,

  // Show documentation's last contributor's name.
  // enableUpdateBy: true,

  // Show documentation's last update time.
  // enableUpdateTime: true,

  // You may provide arbitrary config keys to be used as needed by your
  // template. For example, if you need your repo's URL...
  repoUrl: 'https://github.com/upper/db',

  markdownPlugins: [
    require('./lib/goplayground-embed'),
  ],
};

module.exports = siteConfig;
