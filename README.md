Heroku buildpack: Play >= 2.3
=============================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for [Play framework](http://www.playframework.org/) apps.

*Note: This buildpack only applies to Play 2.3.x apps and newer. Earlier Play 2.x.x apps are handled by the [Scala buildpack](https://github.com/heroku/heroku-buildpack-scala)*

Usage
-----

Example usage:

    $ ls
    activator			app				conf				public
    activator-launch-1.2.2.jar	build.sbt			project

    $ heroku create --buildpack http://github.com/jkutner/heroku-buildpack-play2.git

    $ git push heroku master
    ...
    -----> Play 2.x - Java app detected
    -----> Installing OpenJDK 1.6...done
    -----> Running: activator stage
    ...
    

The buildpack will detect your app as using the Play! framework if it has an `application.conf` in a `conf` directory. Your dependencies will be resolved and your app compiled with `activator`.

License
-------

Licensed under the MIT License. See LICENSE file.
