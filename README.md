# slack-lambda

Docker images of Slackware Linux to deploy to AWS Lambda.

## Overview

When deployed, the images in this repository will simply send back the JSON payload received. You can use these as a template for packaging your application lambda by instead adding your go or rust binary or installing node or python and your application. I am currently using a Slackware base image for node, python and rust applications deployed on AWS Lambda.

My recommendation is to use stable, but if you want to deploy an arm64 image, you must use current. The usual warnings about constant change and potential instability of current apply of course.

Also if you want to deploy a node application, current includes the latest node LTS without having to compile it yourself. You could also still use Slackware as your base image, but install a node binary with nvm or directly download the binary yourself too.

## Tests

There is a minimal smoke test of the images you can run with:

    $ run_tests.sh

This requires:

- docker
- docker-compose
- bats

Pull requests are welcome.
