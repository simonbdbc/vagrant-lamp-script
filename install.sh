#!/usr/bin/env bash

# ask about folder name
echo "
--------------------------> 1/4 <-------------------------
     "
echo "> Choose vagrant folder name :"
echo "Or press 'enter' to select default name : 'data'
     "
read PROJECTFOLDER
PROJECTFOLDER=${PROJECTFOLDER:-data}
echo "----------------------------------------------------------"
echo -e "OK \e[1m ${PROJECTFOLDER} \e[21m folder will be created"
echo "----------------------------------------------------------"
read -p "Press 'enter' to continue or press 'ctl+c' to quit"

# ask about vm box
echo "
--------------------------> 2/4 <-------------------------
     "
echo "> Choose vm box :"
echo "Or press 'enter' to select default box : 'ubuntu/xenial64'
     "
read VMBOX
VMBOX=${VMBOX:-'ubuntu/xenial64'}
echo "----------------------------------------------------------"
echo -e "OK box \e[1m ${VMBOX} \e[21m selected"
echo "----------------------------------------------------------"
read -p "Press 'enter' to continue or press 'ctl+c' to quit"

# ask about private ip
echo "
--------------------------> 3/4 <-------------------------
     "
echo "> Choose private ip : 192.168.33.?? (only 2 last numbers)"
echo "Or press 'enter' to select default value : '83'
     "
read PRIVATEIP
PRIVATEIP=${PRIVATEIP:-83}
echo "----------------------------------------------------------"
echo -e "OK ip \e[1m 192.168.33.${PRIVATEIP} \e[21m selected"
echo "----------------------------------------------------------"
read -p "Press 'enter' to continue or press 'ctl+c' to quit"

#ask about password
echo "
--------------------------> 4/4 <-------------------------
     "
echo "> Choose MySQL password :"
echo "Or press 'enter' to select default password : '0000'
     "
read PASSWORD
PASSWORD=${PASSWORD:-0000}
echo "----------------------------------------------------------"
echo -e "OK password \e[1m ${PASSWORD} \e[21m saved for MySQL setup"
echo "----------------------------------------------------------
----------------------------------------------------------
     "
read -p "Press 'enter' to launch setup or press 'ctl+c' to quit
     "
echo "----------------------------------------------------------
     "

# create project folder
mkdir "./${PROJECTFOLDER}"

# create and setup Vagrantfile
VAGRANTFILE=$(cat <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "${VMBOX}"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.${PRIVATEIP}"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./${PROJECTFOLDER}", "/var/www/html"

  # A (shell) script that runs after first setup of your box
  # Provisioning the bootstrap file:   
  if File.exists?("./${PROJECTFOLDER}/bootstrap.sh")
    config.vm.provision :shell, path: "./${PROJECTFOLDER}/bootstrap.sh"
  else
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
EOF
)
echo "${VAGRANTFILE}" > ./Vagrantfile

# create and setup bootstrap.sh file
BOOTSTRAP=$(cat <<EOF1
#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='0000'

# Loading messages while all provisioning
exe () {
    MESSAGE_PREFIX="\b\b\b\b\b\b\b\b\b\b"
    echo -e "\$MESSAGE_PREFIX Execute: \$1"
    LOOP=0
    while true;
    do
        if ! [ \$LOOP == 0 ]; then echo -e "\$MESSAGE_PREFIX > long process in progress...waiting please...     "; fi;
        sleep 20;
        LOOP=\$((LOOP+1))
    done & ERROR=\$("\${@:2}" >> /vagrant/.vagrant/vm-build.log 2>&1)
    status=\$?
    kill \$!; trap 'kill \$!' SIGTERM

    if [ \$status -ne 0 ];
    then
        echo -e "\$MESSAGE_PREFIX ✖ Error" >&2
        echo -e "\$ERROR" >&2
    else
        echo -e "\$MESSAGE_PREFIX ✔ Success"
    fi
    return $status
}

# update / upgrade
exe '--- Update Packages List ---' \
    sudo apt-get -y update
exe '--- Install Updates Packages ---' \
    sudo apt-get -y dist-upgrade

# install apache 2.5 and php 7.0
exe '--- Install Apache2 ---' \
    sudo apt-get install -y apache2
exe '--- Install Php7.0 ---' \
    sudo apt-get install -y php7.0

# install mysql and give password to installer
exe '--- Setup MySQL Password ---' \
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password 0000"
exe '--- Setup MySQL Password Confirmation ---' \
    sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 0000"
exe '--- Install MySQL ---' \
    sudo apt-get -y install mysql-server

# install php dependencies
exe '--- Install Php Dependencies ---' \
    sudo apt-get install -y php7.0-mysql libapache2-mod-php7.0

# setup php display errors
exe '--- Activate Php Display All Errors ---' \
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
exe '--- Activate Php Display Errors ---' \
    sudo sed -i 's/display_errors = Off/display_errors = On/g' /etc/php/7.0/apache2/php.ini
exe '--- Activate Php Display Startup Errors ---' \
    sudo sed -i 's/display_startup_errors = Off/display_startup_errors = On/g' /etc/php/7.0/apache2/php.ini

# setup hosts file
VHOST=\$(cat <<EOF2
# Le vhost proprement dit : il est compris dans un bloc <VirtualHost>,
# Ces blocs definissent la "portee" de la validite des directives qui y sont definies.
# Le * derriere VirtualHost definit ici que le vhost est valable pour toutes les IP sur lesquelle$

<VirtualHost *:80>

# ServerName definit le nom utilise pour le vhost. Mettez le nom de l'hote du domaine.
#ServerName www.domain.dev

# ServerAlias definit les autres sous-domaines pour lesquels le serveur repondra.
#ServerAlias domain.dev *.domain.dev

# ServerAdmin vous permet de specifier un email a utiliser en cas de probleme, sur une page d'err$
#ServerAdmin administrateur.web@domain.dev

    # DocumentRoot definit le dossier racine dans lequel seront stockes les fichiers du site.
    DocumentRoot "/var/www/html/"

    # Directory definit les options par defaut du repertoire
    <Directory "/var/www/html/">
        # Active les options (pour desactiver '-'):
        # FollowSymLinks permet de suivre les liens symboliques.
        # Indexes autorise le listage de fichiers d'un repertoire qui ne contient pas d'index.
        Options +Indexes +FollowSymLinks +MultiViews
        # AllowOverride permet de surcharger certaines options en utilisant des fichiers .htacces$
        AllowOverride All
        # Droits d'acces (on autorise tout)
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined

</VirtualHost>
EOF2
)
MESSAGE_PREFIX="\b\b\b\b\b\b\b\b\b\b"
echo -e "\$MESSAGE_PREFIX Execute: --- Setup Hosts File ---"
echo "\${VHOST}" > /etc/apache2/sites-available/000-default.conf
echo -e "\$MESSAGE_PREFIX ✔ Success"

# enable mod_rewrite
exe '--- Enable Mod Rewrite ---' \
    sudo a2enmod rewrite

# restart apache
exe '--- Restart Apache ---' \
    sudo service apache2 restart

# verify composer installer SHA-384
MESSAGE_PREFIX="\b\b\b\b\b\b\b\b\b\b"
echo -e "\$MESSAGE_PREFIX Execute: --- Verify Composer Installer SHA-384 ---"
EXPECTED_SIGNATURE=\$(sudo wget -q -O - https://composer.github.io/installer.sig)
sudo php -r "copy('https://getcomposer.org/installer', './composer-setup.php');"
ACTUAL_SIGNATURE=\$(sudo php -r "echo hash_file('SHA384', './composer-setup.php');")
if [ "\$EXPECTED_SIGNATURE" != "\$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    sudo rm ./composer-setup.php
    exit 1
fi
echo -e "\$MESSAGE_PREFIX ✔ Success"

# install composer
exe '--- Install Composer ---' \
    sudo php composer-setup.php --filename=composer --install-dir=/usr/local/bin --quiet

# remove composer setup
exe '--- Remove Composer Setup ---' \
    sudo rm ./composer-setup.php

# update / upgrade
exe '--- Update Packages List ---' \
    sudo apt-get -y update

# clean install
exe '--- Remove apache index.html ---' \
    rm /var/www/html/index.html
exe '--- Remove bootstrap.sh File ---' \
    rm /var/www/html/bootstrap.sh

EOF1
)
echo "${BOOTSTRAP}" > ./${PROJECTFOLDER}/bootstrap.sh

# launch LAMP setup
vagrant up