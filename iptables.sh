#!/bin/bash
# documentation: https://wiki.debian.org/iptables

# flush old rules
iptables -F
iptables -t nat -F

# flush any user-defined tables
iptables -X

# set secure default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# drop invalid
iptables -A INPUT -m state --state INVALID -j DROP

# drop invalid SYN packets
iptables -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# drop incomming XMAS packets
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# drop incomming NULL packets
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# drop packets with incomming fragments
iptables -A INPUT -f -j DROP

# accept loopback, reject access to localhost from all but loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT

# accept established and related traffic
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# allows SSH connections
#iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
#iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# block incomming ICMP pings
# destination-unreachable(3), source-quench(4) and time-exceeded(11) are required
iptables -A INPUT -p icmp -m icmp --icmp-type 3 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 4 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 11 -j ACCEPT

# for ping and traceroute you want echo-request(8) and echo-reply(0) enabled
iptables -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# reject all other ICMP types
iptables -A INPUT -p icmp -j REJECT

# log iptables denied calls (access via 'dmesg' command)
#iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# reject anything not allowed above
iptables -A INPUT -j REJECT
iptables -A FORWARD -j REJECT

# save rules to master file
iptables-save > /etc/iptables.up.rules

# apply rules at reboot
cat > /etc/network/if-pre-up.d/iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.up.rules
EOF

# make iptables rules script executable
chmod +x /etc/network/if-pre-up.d/iptables
