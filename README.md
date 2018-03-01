# vagrant-lamp-script

https://github.com/Simonbdbc/vagrant-lamp-script

A super-simple install.sh to setup a LAMP stack inside Vagrant 100% automatically.

### Whaaaaat ?

This is a Vagrant setup file for a quick development stack. It will:

* Ask you about:

  * select a project folder name and make it, `'data'` by default

  * select a vm box to setup, `'ubuntu/xenial64'` by default

  * select an IP and make the box accessable by the host at this IP, `'192.168.33.83'` by default

  * select a password for MySQL setup, `'0000'` by default

* sync the project folder selected with `'/var/www/html'` inside the box

* automatically create bootstrap.sh for provisioning Vagrantfile and perform all the commands directly after setting up the box for the first time

The bootstrap.sh will:

* update, upgrade

* install apache2, php 7.0, MySQL and php dependencies

* activate all error_reporting, display_errors and display_startup_errors in the php.ini file

* add `'Options +Indexes +FollowSymLinks +MultiViews'` , `'AllowOverride All'` and `'Require all granted'` to the vhost settings (000-default.conf)

* activate mod_rewrite to the vhost settings

* service apache2 restart

* verify Composer installer SHA-384 signature and install it

* cleaning the installation by deleting the index.html file from Apache2 and deleting the bootstrap.sh file when its job is done

* while provisioning all standard output are redirect to `/vagrant/.vagrant/vm-build.log`

### How to use ?

* install Virtualbox (v5.1.30)

* install Vagrant (v2.0.1)

* Put install.sh inside the box folder (an empty folder) and execute it by do a `'bash install.sh'` on the command line.

### Thanks 

* https://github.com/panique/vagrant-lamp-bootstrap

* https://github.com/michaelward82/vagrant-provisioning-shell-function-helper

