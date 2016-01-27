[![Build Status](https://travis-ci.org/flyinprogrammer/ujexhibitor.svg?branch=master)](https://travis-ci.org/flyinprogrammer/ujexhibitor)

# What is this?
A container that runs an Exhibitor managed Zookeeper. What is special about this
version is that I have hacked Exhibitor to have the Zookeeper logs route to stdout.
Which means we can use standard docker log drivers instead of using volume mounts.

# Running tests

Step 1, get some ruby, then:

    gem install bundler
    bundle install
    bundle exec rake test

# Running container

To run 1 instance locally:

    docker run -it --net=host -e EXHIBITOR_HOSTNAME=$(docker-machine ip default) flyinprogrammer/ujexhibitor
