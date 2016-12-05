#!/bin/bash
  
# Error log
exec 2> >(tee -a error.log)

# Variable declaration
itscert="no"

#####################
###   Function declaration  ###
#####################

Update_sys()
{  
  apt-get -y update
  apt-get -y upgrade
  echo -e "Mise à jour.......\033[32mDone\033[00m"
  sleep 4
}

Install_dependency()
{  
  apt-get -y install dialog 
  apt-get -y install git
  apt-get -y install unzip
}
  

Install_Apache2()
{
  apt-get -y install apache2
  a2enmod ssl
  a2enmod rewrite
  a2enmod proxy
  a2enmod proxy_http
  a2enmod proxy_html
  a2enmod xml2enc
  a2enmod headers
  a2enmod proxy_wstunnel
  systemctl restart apache2
  echo -e "Installation d'apache2.......\033[32mDone\033[00m"
  sleep 4
}
  
Install_Mysql()
{
  echo "mysql-server mysql-server/root_password password $pass" | sudo debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password $pass" | sudo debconf-set-selections
  apt-get -y install mysql-server
  mysql -u root -p${pass} -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u root -p${pass} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
  mysql -u root -p${pass} -e "FLUSH PRIVILEGES"
  systemctl restart apache2
  echo -e "Installation de MySQL.......\033[32mDone\033[00m"
  sleep 4
}
  
Install_PHP()
{
  apt-get -y install php libapache2-mod-php php-mcrypt php-mysql php-cli
  systemctl restart apache2
  echo -e "Installation de PHP.......\033[32mDone\033[00m"
  sleep 4
}
  
Install_phpmyadmin()
{
  apt-get -y install php-mbstring php-gettext
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
  echo "phpmyadmin phpmyadmin/app-password-confirm password $pass" | sudo debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-pass password $pass" | sudo debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/app-pass password $pass" | sudo debconf-set-selections
  echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
  apt-get -y install phpmyadmin
  phpenmod mcrypt
  phpenmod mbstring
  systemctl restart apache2
  echo -e "Installation de PHPmyadmin.......\033[32mDone\033[00m"
  sleep 4
}
  
Install_mail_server()
{
  # Install dependency
  apt-get -y install php7.0-imap php7.0-curl
  
  # DNS
  dialog --backtitle "Installation du site web de Cairn devices" --title "DNS configuration" \
  --ok-label "Next" --msgbox "
Consider to update your DNS like this :	
$domainName.	0	MX	10 mail.$domainName.		
$domainName.	0	A	ipv4 of your server					
mail.$domainName.	0	AAAA	ipv6 of your server		
mail.$domainName.	0	A	ipv4 of your server
postfixadmin.$domainName.	0	A	ipv4 of your server		
rainloop.$domainName.	0	A	ipv4 of your server		
imap.$domainName.	0	CNAME	$domainName.		
stmp.$domainName.	0	CNAME	$domainName.		
_dmarc.$domainName.	0	TXT	\"v=DMARC1; p=reject; rua=mailto:postmaster@$domainName; ruf=mailto:admin@$domainName; fo=0; adkim=s; aspf=s; pct=100; rf=afrf; sp=reject\"		
$domainName.	600	SPF	\"v=spf1 a mx ptr ip4:ipv4 of your server include:_spf.google.com ~all\"" 20 80	

  # Install Postfix
  apt-get -y install postfix postfix-mysql postfix-policyd-spf-python
  
  # Create database
  mysql -u root -p${pass} -e "CREATE DATABASE postfix;"
  mysql -u root -p${pass} -e "CREATE USER 'postfix'@'localhost' IDENTIFIED BY '$pass';"
  mysql -u root -p${pass} -e "GRANT USAGE ON *.* TO 'postfix'@'localhost';"
  mysql -u root -p${pass} -e "GRANT ALL PRIVILEGES ON postfix.* TO 'postfix'@'localhost';"
  
  # Install Postfixadmin
  wget https://downloads.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-3.0/postfixadmin-3.0.tar.gz
  tar -xzf postfixadmin-3.0.tar.gz
  mv postfixadmin-3.0 /var/www/postfixadmin
  mkdir /var/www/postfixadmin/logs
  rm postfixadmin-3.0.tar.gz
  chown -R www-data:www-data /var/www/postfixadmin
  
  # Configuration of Postfixadmin
  sed -i "25 s/false/true/g" /var/www/postfixadmin/config.inc.php
  pass_MD5=$(echo -n $pass | md5sum | sed 's/  -//g')
  pass_SHA1=$(echo -n $pass_MD5:$pass | sha1sum | sed 's/  -//g')
  sed -i "30 s/changeme/$pass_MD5:$pass_SHA1/g" /var/www/postfixadmin/config.inc.php
  sed -i "87 s/postfixadmin/$pass/g" /var/www/postfixadmin/config.inc.php
  sed -i "120 s/''/'admin@$domainName'/g" /var/www/postfixadmin/config.inc.php
  sed -i "198 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  sed -i "199 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  sed -i "200 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  sed -i "201 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  sed -i "420 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  sed -i "421 s/change-this-to-your.domain.tld/$domainName/g" /var/www/postfixadmin/config.inc.php
  
  # Configuration of Apache2
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/postfixadmin.conf
  echo "ServerAdmin postmaster@$domainName" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "ServerName  postfixadmin.$domainName" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "ServerAlias  postfixadmin.$domainName" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "DocumentRoot /var/www/postfixadmin/" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "php_admin_value open_basedir /var/www/postfixadmin/" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "<Directory /var/www/postfixadmin/>" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "AllowOverride all" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "Order allow,deny" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "allow from all" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "</Directory>" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "ErrorLog /var/www/postfixadmin/logs/error.log" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "CustomLog /var/www/postfixadmin/logs/access.log combined" >> /etc/apache2/sites-available/postfixadmin.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/postfixadmin.conf
  
  a2ensite postfixadmin.conf
  systemctl restart apache2
  
  sed -i "1 s/<?php/<?php\nif (\!isset(\$_SERVER[\"HTTP_HOST\"]))\n{\n    parse_str(\$argv[1], \$_POST);\n}\n\$_SERVER[\'REQUEST_METHOD \']=\'POST\';\n\$_SERVER[\'HTTP_HOST\']=\'$domainName\';/g" /var/www/postfixadmin/setup.php
  
  cd /var/www/postfixadmin/
  
  php -f /var/www/postfixadmin/setup.php "form=createadmin&setup_password=$pass&username=admin@$domainName&password=$pass&password2=$pass"
  
  cd ~
  
  sed -i "2,7d " /var/www/postfixadmin/setup.php
  
  cp /etc/postfix/main.cf /etc/postfix/main.cf.bakup

  # Configuration of main.cf
  echo "smtpd_recipient_restrictions =" > /etc/postfix/main.cf
  echo "        permit_mynetworks," >> /etc/postfix/main.cf
  echo "        permit_sasl_authenticated," >> /etc/postfix/main.cf
  echo "        reject_non_fqdn_recipient," >> /etc/postfix/main.cf
  echo "        reject_unauth_destination," >> /etc/postfix/main.cf
  echo "        reject_unknown_recipient_domain," >> /etc/postfix/main.cf
  echo "        reject_rbl_client zen.spamhaus.org," >> /etc/postfix/main.cf
  echo "        check_policy_service inet:127.0.0.1:10023" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtpd_helo_restrictions =" >> /etc/postfix/main.cf
  echo "        permit_mynetworks," >> /etc/postfix/main.cf
  echo "        permit_sasl_authenticated," >> /etc/postfix/main.cf
  echo "        reject_invalid_helo_hostname," >> /etc/postfix/main.cf
  echo "        reject_non_fqdn_helo_hostname," >> /etc/postfix/main.cf
  echo "        # reject_unknown_helo_hostname" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtpd_client_restrictions =" >> /etc/postfix/main.cf
  echo "        permit_mynetworks," >> /etc/postfix/main.cf
  echo "        permit_inet_interfaces," >> /etc/postfix/main.cf
  echo "        permit_sasl_authenticated," >> /etc/postfix/main.cf
  echo "        # reject_plaintext_session," >> /etc/postfix/main.cf
  echo "        # reject_unauth_pipelining" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtpd_sender_restrictions =" >> /etc/postfix/main.cf
  echo "        reject_non_fqdn_sender," >> /etc/postfix/main.cf
  echo "        reject_unknown_sender_domain" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtp_tls_loglevel = 1" >> /etc/postfix/main.cf
  echo "smtp_tls_note_starttls_offer = yes" >> /etc/postfix/main.cf
  echo "smtp_tls_security_level = may" >> /etc/postfix/main.cf
  echo "smtp_tls_mandatory_ciphers = high" >> /etc/postfix/main.cf
  echo "smtp_tls_CAfile = /etc/letsencrypt/live/$domainName/cert.pem" >> /etc/postfix/main.cf
  echo "smtp_tls_protocols = !SSLv2, !SSLv3, TLSv1, TLSv1.1, TLSv1.2" >> /etc/postfix/main.cf
  echo "smtp_tls_mandatory_protocols = !SSLv2, !SSLv3, TLSv1, TLSv1.1, TLSv1.2" >> /etc/postfix/main.cf
  echo "smtp_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CDC3-SHA, KRB5-DE5, CBC3-SHA" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "# Smtpd INCOMING" >> /etc/postfix/main.cf
  echo "smtpd_tls_loglevel = 1" >> /etc/postfix/main.cf
  echo "smtpd_tls_auth_only = yes" >> /etc/postfix/main.cf
  echo "smtpd_tls_ask_ccert = yes" >> /etc/postfix/main.cf
  echo "smtpd_tls_security_level = may" >> /etc/postfix/main.cf
  echo "smtpd_tls_received_header = yes" >> /etc/postfix/main.cf
  echo "smtpd_tls_mandatory_ciphers = high" >> /etc/postfix/main.cf
  echo "smtpd_tls_protocols = !SSLv2, !SSLv3, TLSv1, TLSv1.1, TLSv1.2" >> /etc/postfix/main.cf
  echo "smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3, TLSv1, TLSv1.1, TLSv1.2" >> /etc/postfix/main.cf
  echo "smtpd_tls_exclude_ciphers = aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CDC3-SHA, KRB5-DE5, CBC3-SHA" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "# Emplacement des certificats" >> /etc/postfix/main.cf
  echo "smtpd_tls_CAfile = \$smtp_tls_CAfile" >> /etc/postfix/main.cf
  echo "smtpd_tls_cert_file = /etc/letsencrypt/live/$domainName/fullchain.pem" >> /etc/postfix/main.cf
  echo "smtpd_tls_key_file = /etc/letsencrypt/live/$domainName/privkey.pem" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "tls_preempt_cipherlist = yes" >> /etc/postfix/main.cf
  echo "tls_random_source = dev:/dev/urandom" >> /etc/postfix/main.cf
  echo "tls_medium_cipherlist = AES128+EECDH:AES128+EDH" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache" >> /etc/postfix/main.cf
  echo "smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache" >> /etc/postfix/main.cf
  echo "lmtp_tls_session_cache_database = btree:\${data_directory}/lmtp_scache" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtpd_sasl_auth_enable = yes" >> /etc/postfix/main.cf
  echo "smtpd_sasl_type = dovecot" >> /etc/postfix/main.cf
  echo "smtpd_sasl_path = private/auth" >> /etc/postfix/main.cf
  echo "smtpd_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
  echo "smtpd_sasl_tls_security_options = \$smtpd_sasl_security_options" >> /etc/postfix/main.cf
  echo "smtpd_sasl_local_domain = \$mydomain" >> /etc/postfix/main.cf
  echo "smtpd_sasl_authenticated_header = yes" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "broken_sasl_auth_clients = yes" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "virtual_uid_maps = static:5000" >> /etc/postfix/main.cf
  echo "virtual_gid_maps = static:5000" >> /etc/postfix/main.cf
  echo "virtual_minimum_uid = 5000" >> /etc/postfix/main.cf
  echo "virtual_mailbox_base = /var/mail" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf" >> /etc/postfix/main.cf
  echo "virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf" >> /etc/postfix/main.cf
  echo "virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "virtual_transport = lmtp:unix:private/dovecot-lmtp" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "smtpd_banner = \$myhostname ESMTP \$mail_name (Debian/GNU)" >> /etc/postfix/main.cf
  echo "biff = no" >> /etc/postfix/main.cf
  echo "append_dot_mydomain = no" >> /etc/postfix/main.cf
  echo "readme_directory = no" >> /etc/postfix/main.cf
  echo "delay_warning_time = 4h" >> /etc/postfix/main.cf
  echo "mailbox_command = procmail -a \"\$EXTENSION\"" >> /etc/postfix/main.cf
  echo "recipient_delimiter = +" >> /etc/postfix/main.cf
  echo "disable_vrfy_command = yes" >> /etc/postfix/main.cf
  echo "message_size_limit = 502400000" >> /etc/postfix/main.cf
  echo "mailbox_size_limit = 1024000000" >> /etc/postfix/main.cf
  echo "smtp_bind_address6 = 2001:41d0:401:3000:0:0:0:37ad" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "inet_interfaces = all" >> /etc/postfix/main.cf
  echo "inet_protocols = ipv4, ipv6" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "myhostname = $domainName" >> /etc/postfix/main.cf
  echo "myorigin = $domainName" >> /etc/postfix/main.cf
  echo "mydestination = localhost localhost.\$mydomain" >> /etc/postfix/main.cf
  echo "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128" >> /etc/postfix/main.cf
  echo "relayhost =" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "alias_maps = hash:/etc/aliases" >> /etc/postfix/main.cf
  echo "alias_database = hash:/etc/aliases" >> /etc/postfix/main.cf
  echo "" >> /etc/postfix/main.cf
  echo "milter_protocol = 6" >> /etc/postfix/main.cf
  echo "milter_default_action = accept" >> /etc/postfix/main.cf
  echo "smtpd_milters = inet:127.0.0.1:8892, inet:127.0.0.1:12345" >> /etc/postfix/main.cf
  echo "non_smtpd_milters = \$smtpd_milters" >> /etc/postfix/main.cf
  
  # Configuration of Postfix in order to interact with MySQL
  echo "hosts = 127.0.0.1" > /etc/postfix/mysql-virtual-mailbox-domains.cf
  echo "user = postfix" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
  echo "password = $pass" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
  echo "dbname = postfix" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
  echo "query = SELECT domain FROM domain WHERE domain='%s' and backupmx = 0 and active = 1" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
  
  echo "hosts = 127.0.0.1" > /etc/postfix/mysql-virtual-mailbox-maps.cf
  echo "user = postfix" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
  echo "password = $pass" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
  echo "dbname = postfix" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
  echo "query = SELECT maildir FROM mailbox WHERE username='%s' AND active = 1" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
  
  echo "hosts = 127.0.0.1" > /etc/postfix/mysql-virtual-alias-maps.cf
  echo "user = postfix" >> /etc/postfix/mysql-virtual-alias-maps.cf
  echo "password = $pass" >> /etc/postfix/mysql-virtual-alias-maps.cf
  echo "dbname = postfix" >> /etc/postfix/mysql-virtual-alias-maps.cf
  echo "query = SELECT goto FROM alias WHERE address='%s' AND active = 1" >> /etc/postfix/mysql-virtual-alias-maps.cf
  
  # Change rights
  chgrp postfix /etc/postfix/mysql-*.cf
  chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf
  
  # Configuration of master.cf
  echo "#" > /etc/postfix/master.cf
  echo "# Postfix master process configuration file.  For details on the format" >> /etc/postfix/master.cf
  echo '# of the file, see the master(5) manual page (command: "man 5 master" or' >> /etc/postfix/master.cf
  echo "# on-line: http://www.postfix.org/master.5.html)." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Do not forget to execute "postfix reload" after editing this file." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ==========================================================================" >> /etc/postfix/master.cf
  echo "# service type  private unpriv  chroot  wakeup  maxproc command + args" >> /etc/postfix/master.cf
  echo "#               (yes)   (yes)   (yes)   (never) (100)" >> /etc/postfix/master.cf
  echo "# ==========================================================================" >> /etc/postfix/master.cf
  echo "#smtp      inet  n       -       -       -       1       postscreen" >> /etc/postfix/master.cf
  echo "#smtpd     pass  -       -       -       -       -       smtpd" >> /etc/postfix/master.cf
  echo "#dnsblog   unix  -       -       -       -       0       dnsblog" >> /etc/postfix/master.cf
  echo "#tlsproxy  unix  -       -       -       -       0       tlsproxy" >> /etc/postfix/master.cf
  echo "" >> /etc/postfix/master.cf
  echo "############" >> /etc/postfix/master.cf
  echo "### SMTP ###" >> /etc/postfix/master.cf
  echo "############" >> /etc/postfix/master.cf
  echo "smtp      inet  n       -       -       -       -       smtpd" >> /etc/postfix/master.cf
  echo "  -o strict_rfc821_envelopes=yes" >> /etc/postfix/master.cf
  echo "  -o smtpd_proxy_options=speed_adjust" >> /etc/postfix/master.cf
  echo "" >> /etc/postfix/master.cf
  echo "##################" >> /etc/postfix/master.cf
  echo "### SUBMISSION ###" >> /etc/postfix/master.cf
  echo "##################" >> /etc/postfix/master.cf
  echo "submission inet n       -       -       -       -       smtpd" >> /etc/postfix/master.cf
  echo "  -o syslog_name=postfix/submission" >> /etc/postfix/master.cf
  echo "  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf
  echo "  -o smtpd_client_restrictions=permit_sasl_authenticated,reject" >> /etc/postfix/master.cf
  echo "  -o smtpd_proxy_options=speed_adjust" >> /etc/postfix/master.cf
  echo "  -o smtpd_enforce_tls=yes" >> /etc/postfix/master.cf
  echo "  -o smtpd_tls_security_level=encrypt" >> /etc/postfix/master.cf
  echo "  -o tls_preempt_cipherlist=yes" >> /etc/postfix/master.cf
  echo "" >> /etc/postfix/master.cf
  echo "#############" >> /etc/postfix/master.cf
  echo "### SMTPS ###" >> /etc/postfix/master.cf
  echo "#############" >> /etc/postfix/master.cf
  echo "#smtps     inet  n       -       -       -       -       smtpd" >> /etc/postfix/master.cf
  echo "#  -o syslog_name=postfix/smtps" >> /etc/postfix/master.cf
  echo "#  -o smtpd_tls_wrappermode=yes" >> /etc/postfix/master.cf
  echo "#  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf
  echo "#  -o smtpd_reject_unlisted_recipient=no" >> /etc/postfix/master.cf
  echo "#  -o smtpd_client_restrictions=\$mua_client_restrictions" >> /etc/postfix/master.cf
  echo "#  -o smtpd_helo_restrictions=\$mua_helo_restrictions" >> /etc/postfix/master.cf
  echo "#  -o smtpd_sender_restrictions=\$mua_sender_restrictions" >> /etc/postfix/master.cf
  echo "#  -o smtpd_recipient_restrictions=" >> /etc/postfix/master.cf
  echo "#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject" >> /etc/postfix/master.cf
  echo "#  -o milter_macro_daemon_name=ORIGINATING" >> /etc/postfix/master.cf
  echo "" >> /etc/postfix/master.cf
  echo "##############" >> /etc/postfix/master.cf
  echo "### AUTRES ###" >> /etc/postfix/master.cf
  echo "##############" >> /etc/postfix/master.cf
  echo "#628       inet  n       -       -       -       -       qmqpd" >> /etc/postfix/master.cf
  echo "pickup    unix  n       -       -       60      1       pickup" >> /etc/postfix/master.cf
  echo "cleanup   unix  n       -       -       -       0       cleanup" >> /etc/postfix/master.cf
  echo "qmgr      unix  n       -       n       300     1       qmgr" >> /etc/postfix/master.cf
  echo "#qmgr     unix  n       -       n       300     1       oqmgr" >> /etc/postfix/master.cf
  echo "tlsmgr    unix  -       -       -       1000?   1       tlsmgr" >> /etc/postfix/master.cf
  echo "rewrite   unix  -       -       -       -       -       trivial-rewrite" >> /etc/postfix/master.cf
  echo "bounce    unix  -       -       -       -       0       bounce" >> /etc/postfix/master.cf
  echo "defer     unix  -       -       -       -       0       bounce" >> /etc/postfix/master.cf
  echo "trace     unix  -       -       -       -       0       bounce" >> /etc/postfix/master.cf
  echo "verify    unix  -       -       -       -       1       verify" >> /etc/postfix/master.cf
  echo "flush     unix  n       -       -       1000?   0       flush" >> /etc/postfix/master.cf
  echo "proxymap  unix  -       -       n       -       -       proxymap" >> /etc/postfix/master.cf
  echo "proxywrite unix -       -       n       -       1       proxymap" >> /etc/postfix/master.cf
  echo "smtp      unix  -       -       -       -       -       smtp" >> /etc/postfix/master.cf
  echo "relay     unix  -       -       -       -       -       smtp" >> /etc/postfix/master.cf
  echo "#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5" >> /etc/postfix/master.cf
  echo "showq     unix  n       -       -       -       -       showq" >> /etc/postfix/master.cf
  echo "error     unix  -       -       -       -       -       error" >> /etc/postfix/master.cf
  echo "retry     unix  -       -       -       -       -       error" >> /etc/postfix/master.cf
  echo "discard   unix  -       -       -       -       -       discard" >> /etc/postfix/master.cf
  echo "local     unix  -       n       n       -       -       local" >> /etc/postfix/master.cf
  echo "virtual   unix  -       n       n       -       -       virtual" >> /etc/postfix/master.cf
  echo "lmtp      unix  -       -       -       -       -       lmtp" >> /etc/postfix/master.cf
  echo "anvil     unix  -       -       -       -       1       anvil" >> /etc/postfix/master.cf
  echo "scache    unix  -       -       -       -       1       scache" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "# Interfaces to non-Postfix software. Be sure to examine the manual" >> /etc/postfix/master.cf
  echo "# pages of the non-Postfix software to find out what options it wants." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Many of the following services use the Postfix pipe(8) delivery" >> /etc/postfix/master.cf
  echo "# agent.  See the pipe(8) man page for information about \${recipient}" >> /etc/postfix/master.cf
  echo "# and other message envelope options." >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# maildrop. See the Postfix MAILDROP_README file for details." >> /etc/postfix/master.cf
  echo "# Also specify in main.cf: maildrop_destination_recipient_limit=1" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "maildrop  unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "  flags=DRhu user=vmail argv=/usr/bin/maildrop -d \${recipient}" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Recent Cyrus versions can use the existing "lmtp" master.cf entry." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Specify in cyrus.conf:" >> /etc/postfix/master.cf
  echo "#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Specify in main.cf one or more of the following:" >> /etc/postfix/master.cf
  echo "#  mailbox_transport = lmtp:inet:localhost" >> /etc/postfix/master.cf
  echo "#  virtual_transport = lmtp:inet:localhost" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Cyrus 2.1.5 (Amos Gouaux)" >> /etc/postfix/master.cf
  echo "# Also specify in main.cf: cyrus_destination_recipient_limit=1" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "#cyrus     unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "#  user=cyrus argv=/cyrus/bin/deliver -e -r \${sender} -m \${extension} \${user}" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "# Old example of delivery via Cyrus." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "#old-cyrus unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m \${extension} \${user}" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# ====================================================================" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# See the Postfix UUCP_README file for configuration details." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "uucp      unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "  flags=Fqhu user=uucp argv=uux -r -n -z -a\$sender - \$nexthop!rmail (\$recipient)" >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "# Other external delivery methods." >> /etc/postfix/master.cf
  echo "#" >> /etc/postfix/master.cf
  echo "ifmail    unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf  
  echo "  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r \$nexthop (\$recipient)" >> /etc/postfix/master.cf
  echo "bsmtp     unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t\$nexthop -f\$sender \$recipient" >> /etc/postfix/master.cf
  echo "scalemail-backend unix  -       n       n       -       2       pipe" >> /etc/postfix/master.cf
  echo "  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store \${nexthop} \${user} ${extension}" >> /etc/postfix/master.cf
  echo "mailman   unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py" >> /etc/postfix/master.cf
  echo "  \${nexthop} \${user}" >> /etc/postfix/master.cf
  echo "dovecot   unix  -       n       n       -       -       pipe" >> /etc/postfix/master.cf
  echo "  flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/dovecot-lda -f \${sender} -d \${recipient}" >> /etc/postfix/master.cf
  echo "" >> /etc/postfix/master.cf
  echo "###########" >> /etc/postfix/master.cf
  echo "### SPF ###" >> /etc/postfix/master.cf
  echo "###########" >> /etc/postfix/master.cf
  echo "policyd-spf    unix    -    n     n    -    0    spawn" >> /etc/postfix/master.cf
  echo "  user=nobody argv=/usr/bin/policyd-spf /etc/postfix-policyd-spf-python/policyd-spf.conf" >> /etc/postfix/master.cf
  
  # Installation of Dovecot
  apt-get -y install dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved
  
  # Configuration of Dovecot
  echo "## Dovecot configuration file" > /etc/dovecot/dovecot.conf
  echo "">> /etc/dovecot/dovecot.conf
  echo "# Enable installed protocols" >> /etc/dovecot/dovecot.conf
  echo "!include_try /usr/share/dovecot/protocols.d/*.protocol" >> /etc/dovecot/dovecot.conf
  echo "protocols = imap lmtp sieve " >> /etc/dovecot/dovecot.conf
  echo "">> /etc/dovecot/dovecot.conf
  echo "# A space separated list of IP or host addresses where to listen in for" >> /etc/dovecot/dovecot.conf
  echo '# connections. "*" listens in all IPv4 interfaces. "[::]" listens in all IPv6' >> /etc/dovecot/dovecot.conf
  echo '# interfaces. Use "*, [::]" for listening both IPv4 and IPv6.' >> /etc/dovecot/dovecot.conf
  echo "listen = *, [::]" >> /etc/dovecot/dovecot.conf
  echo "" >> /etc/dovecot/dovecot.conf
  echo "# Most of the actual configuration gets included below. The filenames are" >> /etc/dovecot/dovecot.conf
  echo "# first sorted by their ASCII value and parsed in that order. The 00-prefixes" >> /etc/dovecot/dovecot.conf
  echo "# in filenames are intended to make it easier to understand the ordering." >> /etc/dovecot/dovecot.conf
  echo "!include conf.d/*.conf" >> /etc/dovecot/dovecot.conf
  echo "" >> /etc/dovecot/dovecot.conf
  echo "# A config file can also tried to be included without giving an error if" >> /etc/dovecot/dovecot.conf
  echo "# it's not found:" >> /etc/dovecot/dovecot.conf
  echo "!include_try local.conf" >> /etc/dovecot/dovecot.conf

  
  echo "##" > /etc/dovecot/conf.d/10-mail.conf
  echo "mail_location = maildir:/var/mail/vhosts/%d/%n/mail" >> /etc/dovecot/conf.d/10-mail.conf
  echo "" >> /etc/dovecot/conf.d/10-mail.conf
  echo "namespace inbox {" >> /etc/dovecot/conf.d/10-mail.conf
  echo "    inbox = yes" >> /etc/dovecot/conf.d/10-mail.conf
  echo "}" >> /etc/dovecot/conf.d/10-mail.conf
  echo "" >> /etc/dovecot/conf.d/10-mail.conf
  echo "mail_uid = 5000" >> /etc/dovecot/conf.d/10-mail.conf
  echo "mail_gid = 5000" >> /etc/dovecot/conf.d/10-mail.conf
  echo "" >> /etc/dovecot/conf.d/10-mail.conf
  echo "first_valid_uid = 5000" >> /etc/dovecot/conf.d/10-mail.conf
  echo "last_valid_uid = 5000" >> /etc/dovecot/conf.d/10-mail.conf
  echo "" >> /etc/dovecot/conf.d/10-mail.conf
  echo "mail_privileged_group = vmail" >> /etc/dovecot/conf.d/10-mail.conf
  
  # Create folder of mail
  mkdir -p /var/mail/vhosts/$domainName
  
  # Create group vmail
  groupadd -g 5000 vmail 
  useradd -g vmail -u 5000 vmail -d /var/mail
  chown -R vmail:vmail /var/mail
  
  # Configuration of dovecot 10-auth.conf
  echo "disable_plaintext_auth = yes" > /etc/dovecot/conf.d/10-auth.conf
  echo "auth_mechanisms = plain login" >> /etc/dovecot/conf.d/10-auth.conf
  echo "!include auth-sql.conf.ext" >> /etc/dovecot/conf.d/10-auth.conf
  
  # Configuration of dovecot auth-sql.conf.ext
  echo "passdb {" > /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "  driver = sql" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "  args = /etc/dovecot/dovecot-sql.conf.ext" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "}" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "userdb {" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "  driver = static" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "  args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n" >> /etc/dovecot/conf.d/auth-sql.conf.ext
  echo "}"  >> /etc/dovecot/conf.d/auth-sql.conf.ext
  
  # Configuration of dovecot-sql.conf.ext
  echo "driver = mysql" > /etc/dovecot/dovecot-sql.conf.ext
  echo "connect = host=127.0.0.1 dbname=postfix user=postfix password=$pass" >> /etc/dovecot/dovecot-sql.conf.ext
  echo "" >> /etc/dovecot/dovecot-sql.conf.ext
  echo "default_pass_scheme = MD5-CRYPT" >> /etc/dovecot/dovecot-sql.conf.ext
  echo "" >> /etc/dovecot/dovecot-sql.conf.ext
  echo "password_query = SELECT password FROM mailbox WHERE username = '%u'" >> /etc/dovecot/dovecot-sql.conf.ext

  # Change permission on /etc/dovecot
  chown -R vmail:dovecot /etc/dovecot
  chmod -R o-rwx /etc/dovecot
  
  # Configuration of 10-master.conf
  echo "service imap-login {" > /etc/dovecot/conf.d/10-master.conf
  echo "  inet_listener imap {" >> /etc/dovecot/conf.d/10-master.conf
  echo "    port = 143" >> /etc/dovecot/conf.d/10-master.conf
  echo "  }" >> /etc/dovecot/conf.d/10-master.conf
  echo "  inet_listener imaps {" >> /etc/dovecot/conf.d/10-master.conf
  echo "    port = 993" >> /etc/dovecot/conf.d/10-master.conf
  echo "    ssl = yes" >> /etc/dovecot/conf.d/10-master.conf
  echo "  }" >> /etc/dovecot/conf.d/10-master.conf
  echo "  service_count = 0" >> /etc/dovecot/conf.d/10-master.conf
  echo "}" >> /etc/dovecot/conf.d/10-master.conf
  echo "" >> /etc/dovecot/conf.d/10-master.conf
  echo "service imap {" >> /etc/dovecot/conf.d/10-master.conf
  echo "}" >> /etc/dovecot/conf.d/10-master.conf
  echo "" >> /etc/dovecot/conf.d/10-master.conf
  echo "service lmtp {" >> /etc/dovecot/conf.d/10-master.conf
  echo "  unix_listener /var/spool/postfix/private/dovecot-lmtp {" >> /etc/dovecot/conf.d/10-master.conf
  echo "      mode = 0600" >> /etc/dovecot/conf.d/10-master.conf
  echo "      user = postfix" >> /etc/dovecot/conf.d/10-master.conf
  echo "      group = postfix" >> /etc/dovecot/conf.d/10-master.conf
  echo "  }" >> /etc/dovecot/conf.d/10-master.conf
  echo "}" >> /etc/dovecot/conf.d/10-master.conf
  echo "" >> /etc/dovecot/conf.d/10-master.conf
  echo "service auth {" >> /etc/dovecot/conf.d/10-master.conf
  echo "  unix_listener /var/spool/postfix/private/auth {" >> /etc/dovecot/conf.d/10-master.conf
  echo "      mode = 0666" >> /etc/dovecot/conf.d/10-master.conf
  echo "      user = postfix" >> /etc/dovecot/conf.d/10-master.conf
  echo "      group = postfix" >> /etc/dovecot/conf.d/10-master.conf
  echo "  }" >> /etc/dovecot/conf.d/10-master.conf
  echo "  unix_listener auth-userdb {" >> /etc/dovecot/conf.d/10-master.conf
  echo "      mode = 0600" >> /etc/dovecot/conf.d/10-master.conf
  echo "      user = vmail" >> /etc/dovecot/conf.d/10-master.conf
  echo "      group = vmail" >> /etc/dovecot/conf.d/10-master.conf
  echo "  }" >> /etc/dovecot/conf.d/10-master.conf
  echo "  user = dovecot" >> /etc/dovecot/conf.d/10-master.conf
  echo "}" >> /etc/dovecot/conf.d/10-master.conf
  echo "" >> /etc/dovecot/conf.d/10-master.conf
  echo "service auth-worker {" >> /etc/dovecot/conf.d/10-master.conf
  echo "  user = vmail" >> /etc/dovecot/conf.d/10-master.conf
  echo "}" >> /etc/dovecot/conf.d/10-master.conf
  
  # Configuration of 10-ssl.conf
  echo "ssl = required" > /etc/dovecot/conf.d/10-ssl.conf
  echo "" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_cert = </etc/letsencrypt/live/$domainName/fullchain.pem" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_key = </etc/letsencrypt/live/$domainName/privkey.pem" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_cipher_list = AES128+EECDH:AES128+EDH" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_prefer_server_ciphers = yes" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_dh_parameters_length = 4096" >> /etc/dovecot/conf.d/10-ssl.conf
  echo "ssl_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1" >> /etc/dovecot/conf.d/10-ssl.conf
  
  # Configuration of sieve
  echo "protocol lmtp {" > /etc/dovecot/conf.d/20-lmtp.conf
  echo "  postmaster_address = postmaster@$domainName" >> /etc/dovecot/conf.d/20-lmtp.conf
  echo "  mail_plugins = \$mail_plugins sieve" >> /etc/dovecot/conf.d/20-lmtp.conf
  echo "}" >> /etc/dovecot/conf.d/20-lmtp.conf
  
  echo "plugin {" > /etc/dovecot/conf.d/90-sieve.conf
  echo "   sieve = ~/.dovecot.sieve" >> /etc/dovecot/conf.d/90-sieve.conf
  echo "   sieve_global_path = /var/lib/dovecot/sieve/default.sieve" >> /etc/dovecot/conf.d/90-sieve.conf
  echo "   sieve_dir = ~/sieve" >> /etc/dovecot/conf.d/90-sieve.conf
  echo "   sieve_global_dir = /var/lib/dovecot/sieve/" >> /etc/dovecot/conf.d/90-sieve.conf
  echo "}" >> /etc/dovecot/conf.d/90-sieve.conf
  
  mkdir -p /var/lib/dovecot/sieve/
  touch /var/lib/dovecot/sieve/default.sieve &&  chown -R vmail:vmail /var/lib/dovecot/sieve/
  
  echo "require \"fileinto\";" > /var/lib/dovecot/sieve/default.sieve
  echo "if header :contains \"X-Spam-Flag\" \"YES\" {" >> /var/lib/dovecot/sieve/default.sieve
  echo "  fileinto \"Spam\";" >> /var/lib/dovecot/sieve/default.sieve
  echo "}" >> /var/lib/dovecot/sieve/default.sieve
  
  postconf -e virtual_transport=dovecot
  postconf -e dovecot_destination_recipient_limit=1

  # Launch Sieve
  sievec /var/lib/dovecot/sieve/default.sieve
  
  # Installation of OpenDKIM
  apt-get -y install opendkim
  
  # Generate public/private key
  mkdir -p /etc/opendkim/
  mv /etc/opendkim.conf /etc/opendkim/
  ln -s /etc/opendkim/opendkim.conf /etc/opendkim.conf
  openssl genrsa -out /etc/opendkim/opendkim.key 1024
  openssl rsa -in /etc/opendkim/opendkim.key -pubout -out /etc/opendkim/opendkim.pub.key
  chmod "u=rw,o=,g=" /etc/opendkim/opendkim.key
  chown opendkim:opendkim /etc/opendkim/opendkim.key
  
  # Configuration of OpenDKIM
  echo "# This is a basic configuration that can easily be adapted to suit a standard" > /etc/opendkim/opendkim.conf
  echo "# installation. For more advanced options, see opendkim.conf(5) and/or" >> /etc/opendkim/opendkim.conf
  echo "# /usr/share/doc/opendkim/examples/opendkim.conf.sample." >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Log to syslog" >> /etc/opendkim/opendkim.conf
  echo "Syslog                  yes" >> /etc/opendkim/opendkim.conf
  echo "SyslogSuccess           yes" >> /etc/opendkim/opendkim.conf
  echo "LogWhy                  yes" >> /etc/opendkim/opendkim.conf
  echo "# Required to use local socket with MTAs that access the socket as a non-" >> /etc/opendkim/opendkim.conf
  echo "# privileged user (e.g. Postfix)" >> /etc/opendkim/opendkim.conf
  echo "UMask                   002" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Sign for example.com with key in /etc/mail/dkim.key using" >> /etc/opendkim/opendkim.conf
  echo "# selector '2007' (e.g. 2007._domainkey.example.com)" >> /etc/opendkim/opendkim.conf
  echo "Domain                  $domainName" >> /etc/opendkim/opendkim.conf
  echo "KeyFile                 /etc/opendkim/opendkim.key" >> /etc/opendkim/opendkim.conf
  echo "Selector                dkim" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Commonly-used options; the commented-out versions show the defaults." >> /etc/opendkim/opendkim.conf
  echo "Canonicalization        simple" >> /etc/opendkim/opendkim.conf
  echo "Mode                    sv" >> /etc/opendkim/opendkim.conf
  echo "#SubDomains             no" >> /etc/opendkim/opendkim.conf
  echo "#ADSPDiscard            no" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "X-Header                yes" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Always oversign From (sign using actual From and a null From to prevent" >> /etc/opendkim/opendkim.conf
  echo "# malicious signatures header fields (From and/or others) between the signer" >> /etc/opendkim/opendkim.conf
  echo "# and the verifier.  From is oversigned by default in the Debian pacakge" >> /etc/opendkim/opendkim.conf
  echo "# because it is often the identity key used by reputation systems and thus" >> /etc/opendkim/opendkim.conf
  echo "# somewhat security sensitive." >> /etc/opendkim/opendkim.conf
  echo "OversignHeaders         From" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# List domains to use for RFC 6541 DKIM Authorized Third-Party Signatures" >> /etc/opendkim/opendkim.conf
  echo "# (ATPS) (experimental)" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "#ATPSDomains            example.com" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "Socket                  inet:12345@localhost" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Our KeyTable and SigningTable" >> /etc/opendkim/opendkim.conf
  echo "KeyTable refile:/etc/opendkim/KeyTable" >> /etc/opendkim/opendkim.conf
  echo "SigningTable refile:/etc/opendkim/SigningTable" >> /etc/opendkim/opendkim.conf
  echo "" >> /etc/opendkim/opendkim.conf
  echo "# Trusted Hosts" >> /etc/opendkim/opendkim.conf
  echo "ExternalIgnoreList /etc/opendkim/TrustedHosts" >> /etc/opendkim/opendkim.conf
  echo "InternalHosts /etc/opendkim/TrustedHosts" >> /etc/opendkim/opendkim.conf
  echo "#ATPSDomains              example.com" >> /etc/opendkim/opendkim.conf
  
  echo "SOCKET=\"inet:12345@localhost\"" >> /etc/default/opendkim
  
  echo "$domainName	$domainName:dkim:/etc/opendkim/opendkim.key" > /etc/opendkim/KeyTable
  
  echo "*@$domainName	$domainName" > /etc/opendkim/SigningTable
  
  echo "127.0.0.1" > /etc/opendkim/TrustedHosts
  echo "localhost" >> /etc/opendkim/TrustedHosts
  echo "$domainName" >> /etc/opendkim/TrustedHosts
  echo "mail.$domainName" >> /etc/opendkim/TrustedHosts
  
  # DNS
  opendkimPubKey=$(sed -n '/-----BEGIN PUBLIC KEY-----/,/-----END PUBLIC KEY-----/{//d;p}' /etc/opendkim/opendkim.pub.key)
  opendkimPubKey=$(echo $opendkimPubKey | sed s/' '/''/g)
  dialog --backtitle "Installation du site web de Cairn devices" --title "DNS configuration" \
  --ok-label "Next" --msgbox "
Consider to update your DNS like this :		
dkim._domainkey.$domainName.	0	DKIM	v=DKIM1; k=rsa; t=y:s; s=email; p=$opendkimPubKey	" 13 70

  # Installation of OpenDMARC
  apt-get -y install opendmarc
  
  # Configuration of OpenDMARC		
  echo "AutoRestart             Yes" > /etc/opendmarc.conf
  echo "AutoRestartRate         10/1h" >> /etc/opendmarc.conf
  echo "UMask                   0002" >> /etc/opendmarc.conf
  echo "Syslog                  true" >> /etc/opendmarc.conf
  echo "" > /etc/opendmarc.conf
  echo "AuthservID              $domainName" >> /etc/opendmarc.conf
  echo "TrustedAuthservIDs      $domainName" >> /etc/opendmarc.conf
  echo "IgnoreHosts             /etc/opendmarc/TrustedHosts" >> /etc/opendmarc.conf
  echo "" > /etc/opendmarc.conf
  echo "RejectFailures          false" >> /etc/opendmarc.conf
  echo "" > /etc/opendmarc.conf
  echo "UserID                  opendmarc:opendmarc" >> /etc/opendmarc.conf
  echo "PidFile                 /var/run/opendmarc.pid" >> /etc/opendmarc.conf
  
  mkdir /etc/opendmarc
  
  echo "127.0.0.1" > /etc/opendmarc/TrustedHosts
  echo "localhost" >> /etc/opendmarc/TrustedHosts
  echo "::1" >> /etc/opendmarc/TrustedHosts
  echo "*@domain.tld" >> /etc/opendmarc/TrustedHosts
  
  echo "# Command-line options specified here will override the contents of" > /etc/default/opendmarc
  echo "# /etc/opendmarc.conf. See opendmarc(8) for a complete list of options." >> /etc/default/opendmarc
  echo "#DAEMON_OPTS=\"\"" >> /etc/default/opendmarc
  echo "#" >> /etc/default/opendmarc
  echo "# Uncomment to specify an alternate socket" >> /etc/default/opendmarc
  echo "# Note that setting this will override any Socket value in opendkim.conf" >> /etc/default/opendmarc
  echo "#SOCKET=\"local:/var/run/opendmarc/opendmarc.sock\" # default" >> /etc/default/opendmarc
  echo "#SOCKET=\"inet:54321\" # listen on all interfaces on port 54321" >> /etc/default/opendmarc
  echo "#SOCKET=\"inet:12345@localhost\" # listen on loopback on port 12345" >> /etc/default/opendmarc
  echo "#SOCKET=\"inet:12345@192.0.2.1\" # listen on 192.0.2.1 on port 12345" >> /etc/default/opendmarc
  echo "SOCKET=\"inet:8892:localhost\"" >> /etc/default/opendmarc

  systemctl restart apache2
  systemctl restart postfix
  systemctl restart dovecot
  systemctl restart opendkim
  systemctl restart opendmarc
  systemctl restart postgrey
}

Install_Rainloop()
{
  # Configuration of rainloop
  mkdir -p /var/www/rainloop/data/_data_/_default_/configs/
  echo "; RainLoop Webmail configuration file" > /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo "; Please don't add custom parameters here, those will be overwritten" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[webmail]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Text displayed as page title' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'title = "RainLoop Webmail du chien vert"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Text displayed on startup' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'loading_description = "RainLoop"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'favicon_url = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Theme used by default' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'theme = "Default"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Allow theme selection on settings screen' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_themes = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_user_background = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Language used by default' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'language = "en"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Admin Panel interface language' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'language_admin = "en"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Allow language selection on settings screen' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_languages_on_settings = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_additional_accounts = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_additional_identities = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';  Number of messages displayed on page by default' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'messages_per_page = 20' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; File size limit (MB) for file upload on compose screen' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; 0 for unlimited.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'attachment_size_limit = 50' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[interface]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'show_attachment_thumbnail = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_native_scrollbars = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[branding]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_logo = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_background = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_desc = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_css = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_powered = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'user_css = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'user_logo = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'user_logo_title = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'user_logo_message = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'user_iframe_message = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'welcome_page_url = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'welcome_page_display = "none"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[contacts]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enable contacts' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enable = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_sharing = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_sync = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'sync_interval = 20' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'type = "mysql"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'pdo_dsn = "mysql:host=127.0.0.1;port=3306;dbname=rainloop"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'pdo_user = "rainloop"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo "pdo_password = \"$pass\"" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'suggestions_limit = 30' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[security]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enable CSRF protection (http://en.wikipedia.org/wiki/Cross-site_request_forgery)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'csrf_protection = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'custom_server_signature = "RainLoop"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'x_frame_options_header = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'openpgp = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Login and password for web admin panel' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'admin_login = "admin"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo "" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Access settings' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_admin_panel = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_two_factor_auth = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'force_two_factor_auth = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'admin_panel_host = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'admin_panel_key = "admin"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'content_security_policy = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'core_install_access_domain = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[ssl]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Require verification of SSL certificate used.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'verify_certificate = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Allow self-signed certificates. Requires verify_certificate.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_self_signed = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Location of certificate Authority file on local filesystem (/etc/ssl/certs/ca-certificates.crt)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'cafile = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; capath must be a correctly hashed certificate directory. (/etc/ssl/certs/)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'capath = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[capa]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'folders = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'composer = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'contacts = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'settings = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'quota = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'help = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'reload = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'search = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'search_adv = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'filters = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'x-templates = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'dangerous_actions = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'message_actions = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'messagelist_actions = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'attachments_actions = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[login]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo "default_domain = \"$domainName\"" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Allow language selection on webmail login screen' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_languages_on_login = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'determine_user_language = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'determine_user_domain = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'welcome_page = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'glass_style = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'hide_submit_button = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'forgot_password_link_url = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'registration_link_url = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; This option allows webmail to remember the logged in user' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; once they closed the browser window.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Values:' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   "DefaultOff" - can be used, disabled by default;' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   "DefaultOn"  - can be used, enabled by default;' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   "Unused"     - cannot be used' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'sign_me_auto = "DefaultOff"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[plugins]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enable plugin support' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enable = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; List of enabled plugins' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enabled_list = "black-list"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[defaults]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Editor mode used by default (Plain, Html, HtmlForced or PlainForced)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'view_editor_type = "Html"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; layout: 0 - no preview, 1 - side preview, 2 - bottom preview' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'view_layout = 1' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'view_use_checkboxes = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'autologout = 30' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'show_images = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'contacts_autosave = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'mail_use_threads = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'mail_reply_same_folder = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[logs]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enable logging' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Logs entire request only if error occured (php requred)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'write_on_error_only = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Logs entire request only if php error occured' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'write_on_php_error_only = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Logs entire request only if request timeout (in seconds) occured.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'write_on_timeout_only = 0' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Required for development purposes only.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Disabling this option is not recommended.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'hide_passwords = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'time_offset = 0' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'session_filter = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Log filename.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; For security reasons, some characters are removed from filename.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Allows for pattern-based folder creation (see examples below).' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Patterns:' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   {date:Y-m-d}  - Replaced by pattern-based date' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';                   Detailed info: http://www.php.net/manual/en/function.date.php' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ";   {user:email}  - Replaced by user's email address" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';                   If user is not logged in, value is set to "unknown"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ";   {user:login}  - Replaced by user's login (the user part of an email)" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';                   If user is not logged in, value is set to "unknown"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ";   {user:domain} - Replaced by user's domain name (the domain part of an email)" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';                   If user is not logged in, value is set to "unknown"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ";   {user:uid}    - Replaced by user's UID regardless of account currently used" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   {user:ip}' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ";   {request:ip}  - Replaced by user's IP address" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Others:' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   {imap:login} {imap:host} {imap:port}' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   {smtp:login} {smtp:host} {smtp:port}' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Examples:' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   filename = "log-{date:Y-m-d}.txt"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   filename = "{date:Y-m-d}/{user:domain}/{user:email}_{user:uid}.log"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo ';   filename = "{user:email}-{date:Y-m-d}.txt"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'filename = "log-{date:Y-m-d}.txt"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enable auth logging in a separate file (for fail2ban)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'auth_logging = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'auth_logging_filename = "fail2ban/auth-{date:Y-m-d}.txt"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'auth_logging_format = "[{date:Y-m-d H:i:s}] Auth failed: ip={request:ip} user={imap:login} host={imap:host} port={imap:port}"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[debug]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Special option required for development purposes' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[social]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Google' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_enable_auth = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_enable_auth_fast = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_enable_drive = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_enable_preview = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_client_id = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_client_secret = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'google_api_key = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Facebook' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fb_enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fb_app_id = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fb_app_secret = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Twitter' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'twitter_enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'twitter_consumer_key = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'twitter_consumer_secret = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Dropbox' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'dropbox_enable = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'dropbox_api_key = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[cache]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; The section controls caching of the entire application.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Enables caching in the system' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'enable = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Additional caching key. If changed, cache is purged' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'index = "v1"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Can be: files, APC, memcache, redis (beta)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_driver = "files"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Additional caching key. If changed, fast cache is purged' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_index = "v1"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Browser-level cache. If enabled, caching is maintainted without using files' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'http = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Caching message UIDs when searching and sorting (threading)' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'server_uids = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[labs]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; Experimental settings. Handle with care.' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '; ' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_mobile_version = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'ignore_folders_subscription = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'check_new_password_strength = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'update_channel = "stable"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_gravatar = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_prefetch = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_smart_html_links = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'cache_system_data = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'date_from_headers = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'autocreate_system_folders = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_message_append = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'disable_iconv_if_mbstring_supported = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'login_fault_delay = 1' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'log_ajax_response_write_limit = 300' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_html_editor_source_button = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_html_editor_biti_buttons = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_ctrl_enter_on_compose = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'try_to_detect_hidden_images = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'hide_dangerous_actions = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_app_debug_js = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_app_debug_css = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_sort = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_force_selection = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_list_subscribe = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_thread = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_move = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_imap_expunge_all_on_delete = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_forwarded_flag = "\$Forwarded"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_read_receipt_flag = "\$ReadReceipt"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_body_text_limit = 555000' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_message_list_fast_simple_search = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_message_list_count_limit_trigger = 0' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_message_list_date_filter = 0' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_message_list_permanent_filter = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_message_all_headers = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_large_thread_limit = 50' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_folder_list_limit = 200' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_show_login_alert = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_use_auth_plain = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_use_auth_cram_md5 = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'smtp_show_server_errors = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'smtp_use_auth_plain = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'smtp_use_auth_cram_md5 = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'sieve_allow_raw_script = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'sieve_utf8_folder_name = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'imap_timeout = 300' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'smtp_timeout = 60' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'sieve_timeout = 10' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'domain_list_limit = 99' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'mail_func_clear_headers = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'mail_func_additional_parameters = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'favicon_status = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'folders_spec_limit = 50' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'owncloud_save_folder = "Attachments"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'owncloud_suggestions = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'curl_proxy = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'curl_proxy_auth = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'in_iframe = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'force_https = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'custom_login_link = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'custom_logout_link = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_external_login = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_external_sso = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'external_sso_key = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'http_client_ip_check_proxy = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_memcache_host = "127.0.0.1"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_memcache_port = 11211' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_redis_host = "127.0.0.1"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'fast_cache_redis_port = 6379' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'use_local_proxy_for_external_images = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'detect_image_exif_orientation = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'cookie_default_path = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'cookie_default_secure = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'replace_env_in_configuration = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'startup_url = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'nice_social_redirect = On' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'strict_html_parser = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'allow_cmd = Off' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'dev_email = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'dev_password = ""' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo '[version]' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  echo 'current = "1.10.4.183"' >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  theDate=$(date)
  echo "saved = \"$thedate\"" >> /var/www/rainloop/data/_data_/_default_/configs/application.ini
  
  # Installation of Rainloop
  wget http://repository.rainloop.net/v2/webmail/rainloop-community-latest.zip
  unzip rainloop-community-latest.zip -d /var/www/rainloop
  rm -rf rainloop-community-latest.zip
  mkdir /var/www/rainloop/logs/
  
  cd /var/www/rainloop
  find . -type d -exec chmod 755 {} \;
  find . -type f -exec chmod 644 {} \;
  chown -R www-data:www-data .
  cd ~

  # Create database
  mysql -u root -p${pass} -e "CREATE DATABASE rainloop;"
  mysql -u root -p${pass} -e "CREATE USER 'rainloop'@'localhost' IDENTIFIED BY '$pass';"
  mysql -u root -p${pass} -e "GRANT USAGE ON *.* TO 'rainloop'@'localhost';"
  mysql -u root -p${pass} -e "GRANT ALL PRIVILEGES ON rainloop.* TO rainloop@localhost IDENTIFIED BY '$pass';"
  
  # Apache2 configuration for Rainloop		
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/rainloop.conf
  echo "ServerAdmin postmaster@$domainName" >> /etc/apache2/sites-available/rainloop.conf
  echo "ServerName rainloop.$domainName" >> /etc/apache2/sites-available/rainloop.conf
  echo "ServerAlias rainloop.$domainName" >> /etc/apache2/sites-available/rainloop.conf
  echo "DocumentRoot /var/www/rainloop/" >> /etc/apache2/sites-available/rainloop.conf
  echo "php_admin_value open_basedir /var/www/rainloop/" >> /etc/apache2/sites-available/rainloop.conf
  echo "<Directory /var/www/rainloop/ >" >> /etc/apache2/sites-available/rainloop.conf
  echo "AllowOverride All" >> /etc/apache2/sites-available/rainloop.conf
  echo "</Directory>" >> /etc/apache2/sites-available/rainloop.conf
  echo "ErrorLog /var/www/rainloop/logs/error.log" >> /etc/apache2/sites-available/rainloop.conf
  echo "CustomLog /var/www/rainloop/logs/access.log combined" >> /etc/apache2/sites-available/rainloop.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/rainloop.conf
  
  a2ensite rainloop.conf
  systemctl restart apache2
  
  echo "<?php" > changeAdminPasswd.php
  echo "" >> changeAdminPasswd.php
  echo "\$_ENV['RAINLOOP_INCLUDE_AS_API'] = true;" >> changeAdminPasswd.php
  echo "include '/var/www/rainloop/index.php';" >> changeAdminPasswd.php
  echo "" >> changeAdminPasswd.php
  echo "\$oConfig = \RainLoop\Api::Config();" >> changeAdminPasswd.php
  echo "\$oConfig->SetPassword('$pass');" >> changeAdminPasswd.php
  echo "echo \$oConfig->Save() ? 'Done' : 'Error';" >> changeAdminPasswd.php
  echo "" >> changeAdminPasswd.php
  echo "?>" >> changeAdminPasswd.php
  
  php -f changeAdminPasswd.php
  
  rm changeAdminPasswd.php

  cd /var/www/rainloop
  find . -type d -exec chmod 755 {} \;
  find . -type f -exec chmod 644 {} \;
  chown -R www-data:www-data .
  cd ~

  systemctl restart apache2
}

Install_Postgrey()
{  
  # Installation of Postgrey
  apt-get -y install postgrey
  
  # Configuration of Postgrey
  echo "# postgrey startup options, created for Debian" > /etc/default/postgrey
  echo "# you may want to set" >> /etc/default/postgrey
  echo "#   --delay=N   how long to greylist, seconds (default: 300)" >> /etc/default/postgrey
  echo "#   --max-age=N delete old entries after N days (default: 35)" >> /etc/default/postgrey
  echo "# see also the postgrey(8) manpage" >> /etc/default/postgrey
  echo "" >> /etc/default/postgrey
  echo "POSTGREY_OPTS=\"--inet=10023\"" >> /etc/default/postgrey
  echo "POSTGREY_TEXT=\"Server overload, try again later\"" >> /etc/default/postgrey
  echo "" >> /etc/default/postgrey
  echo "# the --greylist-text commandline argument can not be easily passed through" >> /etc/default/postgrey
  echo "# POSTGREY_OPTS when it contains spaces.  So, insert your text here:" >> /etc/default/postgrey
  echo "#POSTGREY_TEXT=\"Your customized rejection message here\"" >> /etc/default/postgrey
  
  echo "# google" >> /etc/postgrey/whitelist_clients
  echo "/^.*-out-.*\.google\.com$/" >> /etc/postgrey/whitelist_clients
  echo "/^mail.*\.google\.com$/" >> /etc/postgrey/whitelist_clients
  echo "/^smtpd\d+\.orange\.fr$/" >> /etc/postgrey/whitelist_clients
  
  systemctl restart apache2
  mkdir /var/run/postgrey
  chown postgrey:postgrey /var/run/postgrey
  sed -i 's/PIDFILE= \/var\/run\/$DAEMON_NAME.pid/PIDFILE=\/var\/run\/$DAEMON_NAME\/$DAEMON_NAME.pid/g' /etc/init.d/postgrey
  systemctl stop postgrey
  rm /var/run/postgrey.pid
  systemctl daemon-reload
  systemctl start postgrey
}

Install_WebsiteCD()
{
  wget https://github.com/Gspohu/WebSiteCD/archive/master.zip
  mkdir /var/www/CairnDevices/
  unzip master.zip -d /var/www/CairnDevices/
  rsync -a /var/www/CairnDevices/WebSiteCD-master/ /var/www/CairnDevices/ 
  chmod -R 777 /var/www/CairnDevices
  rm master.zip 
  rm -r /var/www/CairnDevices/WebSiteCD-master/
  echo -e "Installation de du site web de Cairn Devices.......\033[32mFait\033[00m"
  sleep 4
  
  # Configuration apache
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/CairnDevices.conf
  echo "ServerAdmin postmaster@$domainName" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "ServerName  $domainName" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "ServerAlias  $domainName" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "DocumentRoot /var/www/CairnDevices/" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "php_admin_value open_basedir /var/www/CairnDevices/:/usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "<Directory /var/www/CairnDevices/>" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "AllowOverride all" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "Order allow,deny" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "allow from all" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "</Directory>" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "ErrorLog /var/www/CairnDevices/logs/error.log" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "CustomLog /var/www/CairnDevices/logs/access.log combined" >> /etc/apache2/sites-available/CairnDevices.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/CairnDevices.conf
  
  a2ensite CairnDevices
  systemctl restart apache2

  # Creation of CairnDevices user
  USER="CairnDevices"
  echo "Creation of CairnDevices user"
  useradd -p $pass -M -r -U $USER
  echo "Creation of ".${USER}." user" OK
  
  # Ajout de l'acces sécurisé
  echo "CairnDevices" > /var/www/CairnDevices/.htpasswd
  echo $pass >> /var/www/CairnDevices/.htpasswd
  chmod 777 /var/www/CairnDevices/.htpasswd
  
  # Ajout des bases de données
  mysql -u root -p${pass} -e "CREATE DATABASE CairnDevices;"
  mysql -u root -p${pass} -e "GRANT ALL PRIVILEGES ON CairnDevices.* TO CairnDevices@localhost IDENTIFIED BY '$pass';"
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Captcha.sql
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Text_content.sql
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Member.sql
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Projects.sql
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Colors.sql
  mysql -h localhost -p${pass} -u CairnDevices CairnDevices < /var/www/CairnDevices/SQL/Project_types.sql
  
  echo -e "Ajout des bases de données.......\033[32mDone\033[00m"
  sleep 4
}
  

Security_app()
{
  # Enabled UFW
  #  ufw enable

  Mail_adress()
  {
    # Install dependency
    apt-get -y install mailutils

    email=""
    # Ask for email adresse for security report
    while [ "$email" == "" ]      
    do
      dialog --backtitle "Cairngit installation" --title "Email for security reports"\
      --inputbox "/!\\ Should be external of this server /!\\" 7 60 2> $FICHTMP
      email=`cat $FICHTMP`
    done
    hostname=$(hostname)
  }

  Lets_cert()
  {  
    # Configuration letsencrypt cerbot
    apt-get -y install python-letsencrypt-apache
    letsencrypt --apache  --email $email -d $domainName -d rainloop.$domainName  -d postfixadmin.$domainName 
    echo -e "Installation de let's encrypt.......\033[32mDone\033[00m"
    sleep 4
  
    # Redirect all http to https
    sed -i "s/<\/Directory>/<\/Directory>\nRedirect permanent \/ https:\/\/$domainName\//g" /etc/apache2/sites-available/CairnDevices.conf
    sed -i "s/<\/Directory>/<\/Directory>\nRedirect permanent \/ https:\/\/postfixadmin.$domainName\//g" /etc/apache2/sites-available/postfixadmin.conf
    sed -i "s/<\/Directory>/<\/Directory>\nRedirect permanent \/ https:\/\/rainloop.$domainName\//g" /etc/apache2/sites-available/rainloop.conf
  
    # Ajout d'une règle cron pour renouveller automatique le certificat
    crontab -l > /tmp/crontab.tmp 
    echo "* * * 2 * letsencrypt renew" >> /tmp/crontab.tmp
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp

    systemctl restart apache2
    systemctl restart postfix
    systemctl restart dovecot
    systemctl restart opendkim
    systemctl restart opendmarc
    systemctl restart postgrey

    itscert="yes"
  }  


  Check_rootkits()
  {
    apt-get -y install rkhunter chkrootkit lynis

    # Configuration of rkhunter
    rkhunter --propupd

    # Crontab rules for anti rootkit
    crontab -l > /tmp/crontab.tmp
    echo "0 0 * * 0 root rkhunter --update" >> /tmp/crontab.tmp
    echo "0 1 * * 0 root rkhunter --checkall --report-warnings-only | mail -s \"[$hostname on $domainName][RkHunter] Rapport de vérification\" $email" >> /tmp/crontab.tmp

    echo "0 2 * * 0 root chkrootkit -q | mail -s \"[$hostname on $domainName][ChkRootkit] Rapport de vérification\" $email" >> /tmp/crontab.tmp

    echo "0 3 1 * * root lynis --check-update" >> /tmp/crontab.tmp
    echo "0 4 1 * * root lynis --check-all -Q | mail -s \"[$hostname on $domainName][Lynis] Rapport de vérification\" $email" >> /tmp/crontab.tmp
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp
  }

  Install_SNORT()
  {
    interface=$(route | grep default | awk '{print $8}')
  
    apt-get -y install build-essential
  
    apt-get -y install libpcap-dev libpcre3-dev libdumbnet-dev autoconf
  
    mkdir ~/snort_src
  
    cd ~/snort_src/
  
    apt-get -y install bison flex
  
    wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
  
    tar -zxvf daq-2.0.6.tar.gz
  
    cd daq-2.0.6/
  
    ./configure
  
    make
  
    make install
  
    apt-get -y install zlib1g-dev liblzma-dev openssl libssl-dev
  
   cd ~/snort_src/
  
    wget https://www.snort.org/downloads/snort/snort-2.9.8.3.tar.gz
  
    tar -zxvf snort-2.9.8.3.tar.gz
  
    cd snort-2.9.8.3
  
    ./configure --enable-sourcefire
  
    make
  
    make install
  
    ldconfig
  
    ln -s /usr/local/bin/snort /usr/sbin/snort
  
    groupadd snort
  
    useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort
  
    mkdir -p /etc/snort/rules/iplists
  
    mkdir /etc/snort/preproc_rules
  
    mkdir /usr/local/lib/snort_dynamicrules
  
    mkdir /etc/snort/so_rules
  
    mkdir -p /var/log/snort/archived_logs
  
    touch /etc/snort/rules/iplists/black_list.rules
  
    touch /etc/snort/rules/iplists/white_list.rules
  
    touch /etc/snort/rules/local.rules
  
    touch /etc/snort/sid-msg.map
  
    chmod -R 5775 /etc/snort
  
    chmod -R 5775 /var/log/snort
  
    chmod -R 5775 /usr/local/lib/snort_dynamicrules
  
    chown -R snort:snort /etc/snort
  
    chown -R snort:snort /var/log/snort
  
    chown -R snort:snort /usr/local/lib/snort_dynamicrules
  
    cd ~/snort_src/snort-2.9.8.3/etc/
  
    cp *.conf* /etc/snort
  
    cp *.map /etc/snort
  
    cp *.dtd /etc/snort
  
    cd ~/snort_src/snort-2.9.8.3/src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/
  
    cp * /usr/local/lib/snort_dynamicpreprocessor/
  
    sed -i "s/include \$RULE\_PATH/#include \$RULE\_PATH/" /etc/snort/snort.conf
  
    sed -i "55 s/ipvar HOME_NET any/ipvar HOME_NET 192.168.1.0\/22/g" /etc/snort/snort.conf
  sed -i "104 s/var RULE_PATH ..\/rules/var RULE_PATH \/etc\/snort\/rules/g" /etc/snort/snort.conf
  sed -i "105 s/var SO_RULE_PATH ..\/so_rules/var SO_RULE_PATH \/etc\/snort\/so_rules/g" /etc/snort/snort.conf
  sed -i "106 s/var PREPROC_RULE_PATH ..\/preproc_rules/var PREPROC_RULE_PATH \/etc\/snort\/preproc_rules/g" /etc/snort/snort.conf
  sed -i "108 s/var WHITE_LIST_PATH ..\/rules/var WHITE_LIST_PATH \/etc\/snort\/rules\/iplists/g" /etc/snort/snort.conf
  sed -i "109 s/var BLACK_LIST_PATH ..\/rules/var BLACK_LIST_PATH \/etc\/snort\/rules\/iplists/g" /etc/snort/snort.conf
  sed -i "521 s/# output unified2: filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types/output unified2: filename snort.u2, limit 128/g" /etc/snort/snort.conf
  sed -i "545 s/#include \$RULE_PATH\/local.rules/include \$RULE_PATH\/local.rules/g" /etc/snort/snort.conf
  
  cd ~/snort_src/
  
  git clone git://github.com/firnsy/barnyard2.git
  
  cd barnyard2/
  
  autoreconf -fvi -I ./m4
  
  ln -s /usr/include/dumbnet.h /usr/include/dnet.h
  
  ldconfig
  
  ./configure --with-mysql --with-mysql-libraries=/usr/lib/x86_64-linux-gnu
  
  make
  
  make install
  
  cp etc/barnyard2.conf /etc/snort
  
  mkdir /var/log/barnyard2
  
  chown snort.snort /var/log/barnyard2
  
  touch /var/log/snort/barnyard2.waldo
  
  chown snort.snort /var/log/snort/barnyard2.waldo
  
  mysql -u root -p${pass} -e "CREATE DATABASE snort;"
  mysql -u root -p${pass} -e "CREATE USER 'snort'@'localhost' IDENTIFIED BY '$pass';"
  mysql -u root -p${pass} -e "GRANT USAGE ON *.* TO 'snort'@'localhost';"
  mysql -u root -p${pass} -e "GRANT ALL PRIVILEGES ON snort.* TO 'snort'@'localhost';"
  
  echo "output database: log, mysql, user=snort password=$pass dbname=snort host=localhost" >> /etc/snort/barnyard2.conf
  
  chmod o-r /etc/snort/barnyard2.conf
  
  apt-get -y install libcrypt-ssleay-perl liblwp-useragent-determined-perl
  
  cd ~/snort_src/
  
  wget https://github.com/finchy/pulledpork/archive/patch-3.zip
  
  unzip patch-3.zip
  
  cd pulledpork-patch-3
  
  cp pulledpork.pl /usr/local/bin/
  
  chmod +x /usr/local/bin/pulledpork.pl
  
  cp etc/*.conf /etc/snort/
  
  
  dialog --backtitle "Installation du site web de Cairn Devices" --title "Enter your oinkcode"\
  --inputbox "You need to create an account in https://www.snort.org in order to get an Oinkcode. This will allow the script to download the regular rules and documentation." 10 60 2> $FICHTMP
  oinkcode=`cat $FICHTMP`
  
  sed -i "s/<oinkcode>/$oinkcode/g" /etc/snort/pulledpork.conf
  sed -i "29 s/#rule_url=https:\/\/rules.emergingthreats.net\/|emerging.rules.tar.gz|open-nogpl/rule_url=https:\/\/rules.emergingthreats.net\/|emerging.rules.tar.gz|open-nogpl/g" /etc/snort/pulledpork.conf
  sed -i "74 s/rule_path=\/usr\/local\/etc\/snort\/rules\/snort.rules/rule_path=\/etc\/snort\/rules\/snort.rules/g" /etc/snort/pulledpork.conf
  sed -i "89 s/local_rules=_\/usr\/local\/etc\/snort\/rules\/local.rules/local_rules=\/etc\/snort\/rules\/local.rules/g" /etc/snort/pulledpork.conf
  sed -i "92 s/sid_msg=\/usr\/local\/etc\/snort\/sid-msg.map/sid_msg=\/etc\/snort\/sid-msg.map/g" /etc/snort/pulledpork.conf
  sed -i "96 s/sid_msg_version=1/sid_msg_version=2/g" /etc/snort/pulledpork.conf
  sed -i "119 s/config_path=\/usr\/local\/etc\/snort\/snort.conf/config_path=\/etc\/snort\/snort.conf/g" /etc/snort/pulledpork.conf
  sed -i "133 s/distro=FreeBSD-8.1/distro=Ubuntu-12-04/g" /etc/snort/pulledpork.conf
  sed -i "141 s/black_list=\/usr\/local\/etc\/snort\/rules\/iplists\/default.blacklist/black_list=\/etc\/snort\/rules\/iplists\/black_list.rules/g" /etc/snort/pulledpork.conf
  sed -i "150 s/IPRVersion=\/usr\/local\/etc\/snort\/rules\/iplists/IPRVersion=\/etc\/snort\/rules\/iplists/g" /etc/snort/pulledpork.conf
  
  sed -i "539 a\include \$RULE_PATH\/snort.rules" /etc/snort/snort.conf
  
  crontab -l > /tmp/crontab.tmp
  echo "30 02 * * * /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l" >> /tmp/crontab.tmp
  crontab /tmp/crontab.tmp
  rm /tmp/crontab.tmp
  
  echo "[Unit]" > /lib/systemd/system/snort.service
  echo "Description=Snort NIDS Daemon" >> /lib/systemd/system/snort.service
  echo "After=syslog.target network.target" >> /lib/systemd/system/snort.service
  echo "[Service]" >> /lib/systemd/system/snort.service
  echo "Type=simple" >> /lib/systemd/system/snort.service
  echo "ExecStart=/usr/local/bin/snort -q -u snort -g snort -c /etc/snort/snort.conf -i $interface" >> /lib/systemd/system/snort.service
  echo "[Install]" >> /lib/systemd/system/snort.service
  echo "WantedBy=multi-user.target" >> /lib/systemd/system/snort.service
  
  systemctl daemon-reload
  systemctl enable snort
  systemctl start snort
  
  echo "[Unit]" > /lib/systemd/system/barnyard2.service
  echo "Description=Barnyard2 Daemon" >> /lib/systemd/system/barnyard2.service
  echo "After=syslog.target network.target" >> /lib/systemd/system/barnyard2.service
  echo "[Service]" >> /lib/systemd/system/barnyard2.service
  echo "Type=simple" >> /lib/systemd/system/barnyard2.service
  echo "ExecStart=/usr/local/bin/barnyard2 -c /etc/snort/barnyard2.conf -d /var/log/snort -f snort.u2 -q -w /var/log/snort/barnyard2.waldo -g snort -u snort -D -a /var/log/snort/archived_logs" >> /lib/systemd/system/barnyard2.service
  echo "[Install]" >> /lib/systemd/system/barnyard2.service
  echo "WantedBy=multi-user.target" >> /lib/systemd/system/barnyard2.service
  
  systemctl daemon-reload
  systemctl enable barnyard2
  systemctl start barnyard2
  
  apt-get -y install libgdbm-dev libncurses5-dev git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev imagemagick libyaml-dev libxml2-dev libxslt-dev git libssl-dev
  
  echo "gem: --no-rdoc --no-ri" > ~/.gemrc
  
  sh -c "echo gem: --no-rdoc --no-ri > /etc/gemrc"
  
  cd ~/snort_src/
  
  wget http://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz
  
  tar -zxvf ruby-2.3.0.tar.gz
  
  cd ruby-2.3.0/
  
  ./configure
  
  make
  
  make install
  
  gem install wkhtmltopdf
  
  gem install bundler
  
  gem install rails
  
  gem install rake --version=11.1.2
  
  cd ~/snort_src/
  
  git clone git://github.com/Snorby/snorby.git
  
  cp -r snorby/ /var/www/
  
  cd /var/www/snorby/
  
  bundle install
  
  cp /var/www/snorby/config/database.yml.example /var/www/snorby/config/database.yml
  
  cp /var/www/snorby/config/snorby_config.yml.example /var/www/snorby/config/snorby_config.yml
  
  sed -i s/"\/usr\/local\/bin\/wkhtmltopdf"/"\/usr\/bin\/wkhtmltopdf"/g /var/www/snorby/config/snorby_config.yml
  
  bundle exec rake snorby:setup
  
  sed -i s/"do_mysql (~> 0.10.6)"/"do_mysql (0.10.17)"/g /var/www/snorby/Gemfile.lock
  sed -i s/"do_mysql (0.10.6)"/"do_mysql (0.10.17)"/g /var/www/snorby/Gemfile.lock
  
  mysql -u root -p${pass} -e "CREATE DATABASE snorby;"
  mysql -u root -p${pass} -e "CREATE USER 'snorby'@'localhost' IDENTIFIED BY '$pass';"
  mysql -u root -p${pass} -e "GRANT USAGE ON *.* TO 'snorby'@'localhost';"
  mysql -u root -p${pass} -e "GRANT ALL PRIVILEGES ON snorby.* TO 'snorby'@'localhost';"
  
  sed -i s/"password: \".*\""/"password: \"$pass\""/g /var/www/snorby/config/database.yml
  
  apt-get -y install libcurl4-openssl-dev libaprutil1-dev libapr1-dev apache2-dev
  
  gem install passenger
  
  passenger-install-apache2-module
    
  echo "LoadModule passenger_module /usr/local/rvm/gems/ruby-2.3.0/gems/passenger-5.0.26/buildout/apache2/mod_passenger.so" >> /etc/apache2/mods-available/passenger.load
  
  echo "PassengerRoot /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.0.26" >> /etc/apache2/mods-available/passenger.conf
  echo "PassengerDefaultRuby /usr/local/bin/ruby" >> /etc/apache2/mods-available/passenger.conf
  
  a2enmod passenger
  
  systemctl restart apache2
  
  echo "<VirtualHost *:80>" > /etc/apache2/sites-available/001-snorby.conf
  echo "ServerAdmin admin@$domainName" >> /etc/apache2/sites-available/001-snorby.conf
  echo "ServerName snort-ids.$domainName" >> /etc/apache2/sites-available/001-snorby.conf
  echo "DocumentRoot /var/www/snorby/public" >> /etc/apache2/sites-available/001-snorby.conf
  echo '<Directory "/var/www/snorby/public">' >> /etc/apache2/sites-available/001-snorby.conf
  echo "AllowOverride all" >> /etc/apache2/sites-available/001-snorby.conf
  echo "Order deny,allow" >> /etc/apache2/sites-available/001-snorby.conf
  echo "Allow from all" >> /etc/apache2/sites-available/001-snorby.conf
  echo "Options -MultiViews" >> /etc/apache2/sites-available/001-snorby.conf
  echo "</Directory>" >> /etc/apache2/sites-available/001-snorby.conf
  echo "</VirtualHost>" >> /etc/apache2/sites-available/001-snorby.conf
  
  a2ensite 001-snorby.conf
  
  systemctl restart apache2
  
  sed -i "s/output database: log, mysql, user=snort password=********** dbname=snort host=localhost/#output database: log, mysql, user=snort password=********** dbname=snort host=localhost/g" /etc/snort/barnyard2.conf
  echo "output database: log, mysql, user=snorby password=$pass dbname=snorby host=localhost sensor_name=sensor1" >> /etc/snort/barnyard2.conf
  
  systemctl restart barnyard2
  
  echo "[Unit]" > /lib/systemd/system/snorby_worker.service
  echo "Description=Snorby Worker Daemon" >> /lib/systemd/system/snorby_worker.service
  echo "Requires=apache2.service" >> /lib/systemd/system/snorby_worker.service
  echo "After=syslog.target network.target apache2.service" >> /lib/systemd/system/snorby_worker.service
  echo "[Service]" >> /lib/systemd/system/snorby_worker.service
  echo "Type=forking" >> /lib/systemd/system/snorby_worker.service
  echo "WorkingDirectory=/var/www/snorby" >> /lib/systemd/system/snorby_worker.service
  echo "ExecStart=/usr/local/bin/ruby script/delayed_job start" >> /lib/systemd/system/snorby_worker.service
  echo "[Install]" >> /lib/systemd/system/snorby_worker.service
  echo "WantedBy=multi-user.target" >> /lib/systemd/system/snorby_worker.service
  
  systemctl daemon-reload
  systemctl enable snorby_worker
  systemctl start snorby_worker
  
  echo "auto $interface" >> /etc/network/interfaces
  echo "iface $interface inet manual" >> /etc/network/interfaces
  echo "               up ifconfig \$IFACE 0.0.0.0 up" >> /etc/network/interfaces
  echo "               up ip link set \$IFACE promisc on" >> /etc/network/interfaces
  echo "               down ip link set \$IFACE promisc off" >> /etc/network/interfaces
  echo "               down infconfig \$IFACE down" >> /etc/network/interfaces
  echo "" >> /etc/network/interfaces
  echo "post-up ethtool -K $interface gro off" >> /etc/network/interfaces
  echo "post-up ethtool -K $interface lro off" >> /etc/network/interfaces
  
  echo -e "Installation of Snort.......\033[32mDone\033[00m"
  sleep 4
  }

  mail_SSH()
  {
     # Send mail when someone is succefully connected in SSH
    echo "ip=\`echo \$SSH_CONNECTION | cut -d \" \" -f 1\`
hostname=\`hostname\`
Date=\$(date)
echo \"User \$USER just logged in from \$ip at \$Date\" | mail -s \"SSH Login\" $email &" >>  /etc/ssh/sshrc
  }

  Install_modSecurity()
  {
    #Install and configure mod-security
    apt-get -y install libapache2-mod-security2

    systemctl restart apache2

    mv /usr/share/modsecurity-crs/base_rules/modsecurity_crs_21_protocol_anomalies.conf /usr/share/modsecurity-crs/base_rules/modsecurity_crs_21_protocol_anomalies.conf.disable

    mv /usr/share/modsecurity-crs/base_rules/modsecurity_crs_35_bad_robots.conf /usr/share/modsecurity-crs/base_rules/modsecurity_crs_35_bad_robots.conf.disable
  }

  Hide_ApacheVersion()
  {
    echo "ServerSignature Off
ServerTokens Prod
TraceEnable Off
Header unset ETag
Header always unset X-Powered-By
FileETag None" >> /etc/apache2/apache2.conf

    systemctl restart apache2
  }

  Install_Fail2ban()
  {
    apt-get -y install fail2ban

    echo "[ssh-ddos]
enabled  = true
port     = ssh,sftp,$sshport
filter   = sshd-ddos
logpath  = /var/log/auth.log
maxretry = 6

[apache]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-noscript]
enabled  = true
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-badbots]
enabled  = true
port     = http,https
filter   = apache-badbots
logpath  = /var/log/apache*/*error.log
maxretry = 2

[php-url-fopen]
enabled = true
port    = http,https
filter  = php-url-fopen
logpath = /var/log/apache*/*access.log

[ssh]
enabled = true
port = ssh,sftp,$sshport
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 1000

[http-get-post-dos]
enabled = true
port = http,https
filter = http-get-post-dos
logpath = /var/log/apache2/access.log
maxretry = 360
findtime = 120
mail-whois-lines[name=%(__name__)s, dest=%(destemail)s, logpath=%(logpath)s]
bantime = 200

[http-w00t]
enabled = true
filter = http-w00t
logpath = /var/log/apache2/*.log
maxretry = 1

[postfix-sasl]
enabled  = true
port     = smtp,ssmtp
filter   = postfix-sasl
logpath  = /var/log/syslog
maxretry = 3
bantime  = 600" > /etc/fail2ban/jail.local

  # Add filter http-get-post-dos
  echo "[Definition]" > /etc/fail2ban/filter.d/http-get-post-dos.conf
  echo 'failregex = ^<HOST> -.*"(GET|POST).*' >> /etc/fail2ban/filter.d/http-get-post-dos.conf
  echo "ignoreregex =" >> /etc/fail2ban/filter.d/http-get-post-dos.conf

  # Add filter w00t
  echo "[Definition]" > /etc/fail2ban/filter.d/http-w00t.conf
  echo 'failregex = ^<HOST> -.*"(GET|POST).*\/.*w00t.*' >> /etc/fail2ban/filter.d/http-w00t.conf
  echo "ignoreregex =" >> /etc/fail2ban/filter.d/http-w00t.conf

  # Add filter SASL
  echo "[Definition]" > /etc/fail2ban/filter.d/postfix-sasl.conf
  echo "failregex = warning: (.*)\[<HOST>\]: SASL LOGIN authentication failed: authentication failure" >> /etc/fail2ban/filter.d/postfix-sasl.conf
  echo "ignoreregex =" >> /etc/fail2ban/filter.d/postfix-sasl.conf

  # Mail Fail2ban
  echo '# Fail2Ban configuration file
#
# Author: Yannic Arnoux
#         Based on sendmail-buffered written by Cyril Jaquier
#
#

[INCLUDES]

before = sendmail-common.conf

[Definition]

# Option:  actionstart
# Notes.:  command executed once at the start of Fail2Ban.
# Values:  CMD
#
actionstart = printf %%b "Subject: [Fail2Ban] <name>: started on `uname -n`
              From: <sendername> <<sender>>
              To: <dest>\n
              Hi,\n
              The jail <name> has been started successfully.\n
              Regards,\n
              Fail2Ban" | /usr/sbin/sendmail -f <sender> <dest>

# Option:  actionstop
# Notes.:  command executed once at the end of Fail2Ban
# Values:  CMD
#
actionstop = if [ -f <tmpfile> ]; then
                 printf %%b "Subject: [Fail2Ban] Report from `uname -n`
                 From: <sendername> <<sender>>
                 To: <dest>\n
                 Hi,\n
                 These hosts have been banned by Fail2Ban.\n
                 `cat <tmpfile>`
                 \n,Regards,\n
                 Fail2Ban" | /usr/sbin/sendmail -f <sender> <dest>
                 rm <tmpfile>
             fi
             printf %%b "Subject: [Fail2Ban] <name>: stopped  on `uname -n`
             From: Fail2Ban <<sender>>
             To: <dest>\n
             Hi,\n
             The jail <name> has been stopped.\n
             Regards,\n
             Fail2Ban" | /usr/sbin/sendmail -f <sender> <dest>

# Option:  actioncheck
# Notes.:  command executed once before each actionban command
# Values:  CMD
#
actioncheck =

# Option:  actionban
# Notes.:  command executed when banning an IP. Take care that the
#          command is executed with Fail2Ban user rights.
# Tags:    See jail.conf(5) man page
# Values:  CMD
#
actionban = printf %%b "`date`: <name> ban <ip> after <failures> failure(s)\n" >> <tmpfile>
            if [ -f <mailflag> ]; then
                printf %%b "Subject: [Fail2Ban] Report from `uname -n`
                From: <sendername> <<sender>>
                To: <dest>\n
                Hi,\n
                These hosts have been banned by Fail2Ban.\n
                `cat <tmpfile>`
                \n,Regards,\n
                Fail2Ban" | /usr/sbin/sendmail -f <sender> <dest>
                rm <tmpfile>
                rm <mailflag>
            fi

# Option:  actionunban
# Notes.:  command executed when unbanning an IP. Take care that the
#          command is executed with Fail2Ban user rights.
# Tags:    See jail.conf(5) man page
# Values:  CMD
#
actionunban =

[Init]

# Default name of the chain
#
name = default

# Default temporary file
#
tmpfile = /var/run/fail2ban/tmp-mail.txt

# Default flag file
#
mailflag = /var/run/fail2ban/mail.flag' > /etc/fail2ban/action.d/sendmail-cron.conf

  # Ajout d'une règle cron pour mail automatique
  crontab -l > /tmp/crontab.tmp
  echo "@daily touch /var/run/fail2ban/mail.flag" >> /tmp/crontab.tmp
  crontab /tmp/crontab.tmp
  rm /tmp/crontab.tmp

  echo "
[DEFAULT]
destemail = $email" >> /etc/fail2ban/jail.local
  echo 'action_mwlc = %(banaction)s[name=%(__name__)s, port="%(port)s", protocol="%(protocol)s", chain="%(chain)s"]
            %(mta)s-cron[name=%(__name__)s, dest="%(destemail)s", logpath=%(logpath)s, chain="%(chain)s", sendername="%(sendername)s"] action = %(action_mwlc)s' >> /etc/fail2ban/jail.local

  systemctl restart fail2ban
  }

  Change_SSHport()
  {
    sshport=""
    while [ "$sshport" == "" ]      
    do
    dialog --backtitle "Installation du site web de Cairn Devices" --title "Choix d'un port pour la connexion SSH" \
    --inputbox "" 7 60 2> $FICHTMP
    sshport=`cat $FICHTMP`
    test_port=$(netstat -paunt | grep :$sshport\ )
    if [ "$test_port" != "" ]
    then
      echo -e "\033[31m / ! \ Attention ce port semble être utilisé / ! \ \033[0m"
      echo $test_port
      sleep 4
      sshport=""
    fi
    done
    sed -i "5 s/Port 22/Port $sshport/g" /etc/ssh/sshd_config
    dialog --backtitle "Installation du site web de Cairn devices" --title "Changement port SSH" \
  --ok-label "Next" --msgbox "Le port SSH à été changé pour éviter les attaques automatiques. Veuillez en prendre note. \nNouveau port : $sshport   \nPour accéder au serveur en ssh : ssh -p$sshport $USER@$domainName" 9 66
  }

  Install_unattendedupgrades()
  {
    apt-get -y install unattended-upgrades
  }

    DOSDDOSOtherattacks_protection()
    {
    # Install and configure mod-evasive for apache2
    apt-get -y install libapache2-mod-evasive
    mkdir -p /var/lock/mod_evasive
    chown -R apache:apache /var/lock/mod_evasive

    systemctl restart apache2

    # Remove blacklist ip
    0 5 * * * find /var/lock/mod_evasive -mtime +1 -type f -exec rm -f '{}' \; 

    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 2048" >> /etc/sysctl.conf
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf

    sysctl -n -e -q

    #  Secure shared memory
    tmpfs     /run/shm     tmpfs     defaults,noexec,nosuid     0     0

   # Stop IP spoofing
   nospoof on >> /etc/host.conf

    }

  Install_AppArmor()
  {
    apt-get -y install apparmor apparmor-profiles apparmor-utils
  }

  Mail_adress

  dialog --backtitle "Installation of security apps" --title "Choose security apps" \
  --ok-label "Ok" --cancel-label "Quit" \
  --checklist "" 18 77 10 \
  "Rootkits" "Check rootkits with rkhunter, chrootkit, lynis" off \
  "SNORT" "Installattion of SNORT with web interface" off \
  "SSH" "Change SSH port, send email when SSH connexion" off \
  "ModSecurity" "Install apache WAF" off \
  "Apache" "Hide apache signature" off \
  "Fail2ban" "Install fail2ban rules W00t, Dos/DDos, SSH/SASL" off \
  "Unattended Upgrades" "Install Unattended Upgrade" off \
  "Sys protection" "DOS/DDOS protection, martian log, ICMP" off\
  "SSL" "SSL certification, with let's encrypt" off 2> $FICHTMP

  if [ $? = 0 ]
  then
  for i in `cat $FICHTMP`
  do
  case $i in 
  "Rootkits") Check_rootkits ;;
  "SNORT") Install_SNORT ;;
  "SSH")  mail_SSH; Change_SSHport ;;
  "ModSecurity") Install_modSecurity ;;
  "Apache") Hide_ApacheVersion ;;
  "Fail2ban") Install_Fail2ban ;;
  "Unattended Upgrades") Install_unattendedupgrades ;;
  "Sys protection") DOSDDOSOtherattacks_protection ;;
  "SSL") Lets_cert ;;
  esac
  done
  else exit 0
  fi

}

ItsCert()
{
  if [ "$itcert" = "no" ]
  then
    # Install OpenSSL
    apt-get -y install openssl

    # Creation of private key
    cd /etc/ssl/
    openssl genrsa -out mailserver.key 4096

    # Ask for certificat signature
    openssl req -new -key mailserver.key -out mailserver.csr

    # Create certificat
    openssl x509 -req -days 365 -in mailserver.csr -signkey mailserver.key -out mailserver.crt
    cd ~

    # Put certificat in conf file
    sed -i "s/\/etc\/letsencrypt\/live\/$domainName\/cert.pem/\/etc\/ssl\/mailserver.crt/g" /etc/postfix/main.cf
    sed -i "s/\/etc\/letsencrypt\/live\/$domainName\/fullchain.pem/\/etc\/ssl\/mailserver.csr/g" /etc/postfix/main.cf
    sed -i "s/\/etc\/letsencrypt\/live\/$domainName\/privkey.pem/\/etc\/ssl\/mailserver.key/g" /etc/postfix/main.cf
    sed -i "s/\/etc\/letsencrypt\/live\/$domainName\/fullchain.pem/\/etc\/ssl\/mailserver.csr/g" /etc/dovecot/conf.d/10-ssl.conf
    sed -i "s/\/etc\/letsencrypt\/live\/$domainName\/privkey.pem/\/etc\/ssl\/mailserver.key/g" /etc/dovecot/conf.d/10-ssl.conf

    # Ajout d'une règle cron pour renouveller automatique le certificat
    crontab -l > /tmp/crontab.tmp 
    echo "0 0 1 1 * openssl x509 -req -days 365 -in mailserver.csr -signkey mailserver.key -out mailserver.crt" >> /tmp/crontab.tmp
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp

    systemctl restart apache2
    systemctl restart postfix
    systemctl restart dovecot
    systemctl restart opendkim
    systemctl restart opendmarc
    systemctl restart postgrey

    echo -e "Auto cert .............\033[32mDone\033[00m"

  fi
}

Cleanning()
{
  apt-get -y autoremove
  echo -e "Cleaning .............\033[32mDone\033[00m"
  echo "We will now reboot your server"
  sleep 5
  reboot
}

#######################
###   Beginning of the script   ###
#######################

Update_sys
Install_dependency

DIALOG=${DIALOG=dialog}
fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
trap "rm -f $fichtemp" 0 1 2 5 15
$DIALOG --clear --backtitle "Installation du site web de Cairn Devices" --title "Installation du site web de Cairn Devices" \
--menu "Bonjour, choisissez votre type d'installation :" 15 80 5 \
"Dédié" "Installation dédié" \
"Serveur mail" "Installation du serveur mail" 2> $fichtemp
valret=$?
choix=`cat $fichtemp`
case $valret in
0)	echo "'$choix' est votre choix";;
1) 	echo "Appuyé sur Annuler.";;
255) 	echo "Appuyé sur Echap.";;
esac
  
# Password for installation (Mysql, etc)
touch /tmp/dialogtmp && FICHTMP=/tmp/dialogtmp
trap "rm -f $FICHTMP" 0 1 2 3 5 15
  
passnohash="0"
repassnohash="1"
while [ "$passnohash" != "$repassnohash" ]      
do
dialog --backtitle "Installation du site web de Cairn Devices" --title "Choose the password for the installation" \
--insecure --passwordbox "" 7 60 2> $FICHTMP
passnohash=`cat $FICHTMP`
  
dialog --backtitle "Installation du site web de Cairn Devices" --title "Retype the password for the installation" \
--insecure --passwordbox "" 7 60 2> $FICHTMP
repassnohash=`cat $FICHTMP`
done
  
pass=$(echo -n $passnohash | sha256sum | sed 's/  -//g')
passnohash="0"
  
domainName=""
# Ask for domain name
while [ "$domainName" == "" ]      
do
dialog --backtitle "Installation du site web de Cairn Devices" --title "Domain name" \
--inputbox "" 7 60 2> $FICHTMP
domainName=`cat $FICHTMP`
done
  
if [ "$choix" = "Dédié" ]
then
  Install_Apache2
  Install_Mysql
  Install_PHP
  Install_phpmyadmin
  Install_mail_server
  Install_Rainloop
  Install_Postgrey
  Install_WebsiteCD
  Security_app
  ItsCert
  Cleanning
elif [ "$choix" = "Serveur mail" ]
then
  Install_Apache2
  Install_Mysql
  Install_PHP
  Install_phpmyadmin
  Install_mail_server
  Install_Rainloop
  Install_Postgrey
  ItsCert
  Cleanning
fi