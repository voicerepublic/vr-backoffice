Deployment Notes
================


Buster new deployment
---------------------

    rbenv install 2.4.9
    rbenv local 2.4.9
    gem install bundler -v 1.11.2
    # rm Gemfile.lock
    # bundle update
    bundle install

Then one needs to create the layout
	/home/backend/app/current -> this git repo or a released version of it
	/home/backend/app/shared/log/
	/home/backend/app/shared/config/
		necessary???
Updates to the files in
	/home/backend/app/current/config/
		modified:   config/settings.yml

		Ignored files:
		  (use "git add -f <file>..." to include in what will be committed)
			config/database.yml
			config/settings.local.yml
	!!!

Plus postgresql server update



Building the frontend
----------------------

Install clojure
Install lein:
	down and run https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
fix for java 11: add [javax.xml.bind/jaxb-api "2.4.0-b180830.0359"] to 
the deps in project.clj
run
	lein figwheel
(but doesn't do anything for now)




ERROR rbenv: 1.9.3-p448 is not installed
----------------------------------------

    backend@voicerepublic-staging:~$ rbenv versions
    backend@voicerepublic-staging:~$ rbenv install 1.9.3-p448
    Downloading yaml-0.1.6.tar.gz...
    [...]
    backend@voicerepublic-staging:~$ rbenv versions
    1.9.3-p448
    backend@voicerepublic-staging:~$ rbenv global 1.9.3-p448
    backend@voicerepublic-staging:~$ rbenv versions
    * 1.9.3-p448 (set by /home/backend/.rbenv/version)
  

rbenv: bundle: command not found
--------------------------------

    backend@voicerepublic-staging:~$ gem install bundler
    Fetching: bundler-1.6.1.gem (100%)
    [...]


Warning: unicorn_wrapper restart
--------------------------------
DEBUG [78ea7dd4]  pkill:
DEBUG [78ea7dd4]  killing pid 1231 failed
DEBUG [78ea7dd4]  : Operation not permitted

This error shows up in the log while deploying, since it tries to kill
processes it doesn't own. While this is not a problem, it is somewhat
irritating.
