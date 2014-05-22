lpoppublish will listen for messages on N lists on a redis instance and publish those messages on redis channels.

# Installation and Environment Setup

Install node.js (See download and isntall instructions here: http://nodejs.org/).

Clone this repository

    > git clone git@github.com:NathanGRomano/lpoppublish.git

cd into the app directory and install the dependencies

    > npm install && npm shrinkwrap --dev

If you would like to install lpoppublish as a command line tool

    > npm install -g

# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tets, just run grunt

    > grunt

# TODO

