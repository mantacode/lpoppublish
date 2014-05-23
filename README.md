lpoppublish will listen for messages on N lists on a redis instance and publish those messages on redis channels.

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Install redis (See download and install instructions http://redis.io/topics/quickstart)

Install coffee-script

		> npm install -g coffee-script

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
    -i, --interval <number>  the number of miliseconds to wait before polling
    -r, --requests <number>  the number of requests to make each interval
```

Here is an example of listening on 3 lists and publishing to 3 channels with a sleep of 100 miliseconds and we poll twice during each interval.

    > lpoppublish -q a,b,c -c a,b,c -i 100 -r 2

# Running Tests

## Unit Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run the tets, just run grunt

    > grunt

# TODO

Specify the host and port in which redis lives
