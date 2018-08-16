Basic firewall script using iptables for Debian
=================================================

this is personalized post-installation script for setting up basic firewall template using iptables for Debian.

Usage
-----
````
cd $(mktemp -d)
wget https://github.com/danielkubat/iptables/archive/master.zip
unzip master.zip && cd iptables-master
bash iptables.sh
````
