# vagrant-lamp-bootstrap

A super-simple install.sh to setup a LAMP stack inside Vagrant 100% automatically.

### Whaaaaat ?

This is a reduced-to-the-max Vagrant setup file for a quick development stack. It will:

* select a project folder name and make it, `'data'` by default

* select a vm box to setup, `'ubuntu/xenial64'` by default

* select an IP and make the box accessable by the host at this IP, `'192.168.33.83'` by default

* select a password for MySQL setup, `'0000'` by default

* sync the project folder selected with `'/var/www/html'` inside the box

* automatically create bootstrap.sh file and perform all the commands  directly after setting up the box for the first time

The bootstrap.sh will:

* update, dist-upgrade

* install apache2, php 7.0, MySQL, git, Composer and php dependencies

* activate display_errors and display_startup_errors in the php.ini file

* add `'Options +Indexes +FollowSymLinks +MultiViews'` , `'AllowOverride All'` and `'Require all granted'` to the vhost settings (000-default.conf)

* activate mod_rewrite to the vhost settings

* service apache2 restart

* cleaning the installation by deleting the index.html file from Apache2 and deleting the bootstrap.sh file when its job is done

### How to use ?

* install Virtualbox (v5.1.30)

* install Vagrant (v2.0.1)

* Put install.sh inside the box folder (an empty folder) and execute it by do a `'bash install.sh'` on the command line.

### Thanks 

* Fork : https://github.com/panique/vagrant-lamp-bootstrap

