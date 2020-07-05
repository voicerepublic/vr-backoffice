Server setup notes
===================

# see notes below concerning the case where the frontend user != app
# or the backend user != backend
VRFRONTENDUSER=vr-app
VRBACKENDUSER=vr-backend

# install basic hetzner buster image

# git for rbenv installation
# vim for my brain
# postgres for server, client and ruby extension building
# build-essential and rest for ruby building
# jre and nodejs for lein(ingen)
apt install -y git vim build-essential gcc g++ libssl-dev libreadline-dev zlib1g-dev \
	postgresql-server-dev-11 postgresql-11  postgresql-client-11	\
	clojure default-jre-headless nodejs


adduser --disabled-password $VRFRONTENDUSER
adduser --disabled-password $VRBACKENDUSER

#
app install rabbitmq-server

su - $VRBACKENDUSER
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
echo 'PATH=$HOME/.rbenv/bin:$PATH' >> .bashrc        
echo 'eval "$(rbenv init -)"' >> .bashrc
exit

su - $VRFRONTENDUSER
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
echo 'PATH=$HOME/.rbenv/bin:$PATH' >> .bashrc             
echo 'eval "$(rbenv init -)"' >> .bashrc
exit

su - $VRBACKENDUSER
rbenv install 2.4.9
rbenv local 2.4.9
gem install bundler -v 1.17.3


# create necessary files in
cd /home/$VRBACKENDUSER
sudo -u $VRBACKENDUSER mkdir -p /home/$VRBACKENDUSER/app/shared/config
sudo -u $VRBACKENDUSER touch /home/$VRBACKENDUSER/app/shared/config/database.yml
sudo -u $VRBACKENDUSER touch /home/$VRBACKENDUSER/app/shared/config/settings.local.yml
# The actual **CONTENT** of these files needs to be copied/installed/moved over
# from git@github.com:voicerepublic/voicerepublic-config.git
# directory backend/app-config
chgrp root /home/$VRBACKENDUSER/app/shared/config/database.yml
chmod 0600 /home/$VRBACKENDUSER/app/shared/config/database.yml
echo "MANUAL WORK NEEDS TO BE DONE - READ THE SOURCE!"


su - $VRBACKENDUSER
cd
mkdir bin
cd bin
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
chmod ugo+x lein
exit

# we need to re-login to get correct path
su - $VRBACKENDUSER
lein
exit

# we need to setup $VRBACKENDUSER bin directory and .unicorn-config
# from git@github.com:voicerepublic/voicerepublic-config.git
# directory backend/homedir
echo "MANUAL WORK NEEDS TO BE DONE - READ THE SOURCE!"
# TODO
# .unicorn-config refers to /home/backend which needs to be switched to $VRBACKENDUSER


#####################
# At this point we could start the backend, but the pg database is not initialized
# and the backend role not applied to user vr-backend!!
# If *not* running as user "backend", add the "backend" role to the current user
# 	CREATE ROLE <username> LOGIN INHERIT ;
# 	GRANT backend TO <username> ;
# and change the database.yml (see below) to use <username>





Database move
-------------
on old server:
	pg_dump rails_production > ~/pgdump_`date -I`.sql && gzip ~/pgdump_`date -I`.sql && ll pgdump_*
move to new server
on new server
	dropdb rails_production
	createdb rails_production
	psql -f pgdump_YYYY-MM-DD postgres




On development server
----------------------
install ruby rbenv via 2.4.9, gemfile, .... (not really sure how to get this running)
then
	 bundle exec cap staging deploy
currently not fully running, though ... (bundle build breaks due to missing deps)


Deployment Notes
================


Buster new deployment
---------------------

    rbenv install 2.4.9
    rbenv local 2.4.9
    gem install bundler -v 1.17.3
    # rm Gemfile.lock
    # bundle update
    bundle install

If *not* running as user "backend", add the "backend" role to the current user
	CREATE ROLE <username> LOGIN INHERIT ;
	GRANT backend TO <username> ;
and change the database.yml (see below) to use <username>

Then one needs to create the layout
2020-07-05
This should be done by capistrano!

	/home/backend/app/current -> this git repo or a released version of it
	/home/backend/app/shared/log/
	/home/backend/app/shared/config/
	/home/backend/app/current/config/
		add:
		- settings.local.yml -> ../../shared/config/settings.local.yml
		- database.yml       -> ../../sahred/config/database.yml
		modified:
		- config/settings.yml: AWS API keys


Plus postgresql server update



Building the frontend
----------------------

Install clojure
Install lein:
	down and run https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
fix for java 11: add [javax.xml.bind/jaxb-api "2.4.0-b180830.0359"] to 
see also https://www.deps.co/blog/how-to-upgrade-clojure-projects-to-use-java-11/
the deps in project.clj

Build the necessary files???
	lein cljsbuild once

Testing???
	lein figwheel
(but doesn't do anything somehow)



NGINX Configuration
-------------------

- install nginx
- files added
    /etc/nginx/
	./sites-available/nginx-port-444
	./sites-available/default-ssl
	# NO!!! default!!
	./sites-enabled/default-ssl -> ../sites-available/default-ssl
	./sites-enabled/nginx-port-444 -> ../sites-available/nginx-port-444
	./snippets/letsencrypt-acme-challenge.conf
	./snippets/ssl_config.conf

/etc/letsencrypt via certbot



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
