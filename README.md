lpoppublish will listen for messages on N lists on a redis instance and publish those messages on redis channels.

# Installation and Environment Setup

Install node.js (See download and isntall instructions here: http://nodejs.org/).

Clone this repository

    > git clone git@github.com:NathanGRomano/lpoppublish.git

cd into the app directory and install the dependencies

    > npm install && npm shrinkwrap --dev

If you would like to install lpoppublish as a command line tool

    > npm install -g

# Running the Application

Start off by

    > lpoppublish

You will get this output

```
  Usage: lpoppublish.coffee [options]

  Options:

    -h, --help               output usage information
    -V, --version            output the version number
    -q, --queues <string>    the queues to read from
    -c, --channels <string>  the channels to write to
```

Here is an example of listening on 3 lists and publishing to 3 channels

    > lpoppublish -q a,b,c -c a,b,c

# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tets, just run grunt

    > grunt

# TODO

CPU intensive.  Maybe use a sleep.  Currently I am using setImmediate() in the #run method
