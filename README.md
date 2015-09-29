# Immown Docker

Immown Docker bootstraps the Immown application stack for super fast developer onboarding.

Requirements
  - Docker (tested with 1.8.2)
  - docker-compose
  - docker-machine
  - Mac OS X (Probably won't work on Linux without some modifications to the bash script and definitely not on Windows)

Once you have all the requirements, bootstrapping the stack should be really fast.

What happens when I bootstrap the stack?

1. Docker clones images for mysql, redis, and nginx
2. Docker builds images for the immown api and web app codebases
3. Edits the hosts file to insert a resolver for immown.dev
4. boots the entire stack of 5 containers
5. Installs the default MySQL schema

If you make it to the end you should be able to visit http://immown.dev in your browser to see the web app fully connected to the API and MySQL.

The database won't have any data yet, so I recommend you go into the `crawl` codebase and run the `sample-platter`. Be sure to run `npm install` on this codebase because it is not containerized.


The database will be cleared of data everytime you rerun the `init.sh` but if you want to preserve your data once you have initially bootstrapped the stack, simply run `docker-compose up` from the directory and it should bring all the services back online.


### Version
0.0.1


PS: Yes the S3 keys are revoked and the API keys changed.
