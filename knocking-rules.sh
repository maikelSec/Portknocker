# Run the script with four agruments each a port number
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
# -F flushes all the chains. Chains can't be deleted unless they are empty
iptables -F
# -X Delets all the non-builtin chains in the table
iptables -X
# -Z Zero's the packet and byte counters in all chains
iptables -Z

# Adding the additional chains that will be required
iptables -N WALL
iptables -N KNOCK1
iptables -N KNOCK2
iptables -N KNOCK3
iptables -N KNOCK4
iptables -N PASSED

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Rules to accept traffic for localhost, web server 
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -j WALL

#First GATE
iptables -A KNOCK1 -p tcp --dport $1 -m recent --name AUTH1 --set -j DROP
iptables -A KNOCK1 -j DROP

#Second GATE
iptables -A KNOCK2 -m recent --name AUTH1 --remove
iptables -A KNOCK2 -p tcp --dport $2 -m recent --name AUTH2 --set -j DROP
iptables -A KNOCK2 -j KNOCK1

#Third GATE
iptables -A KNOCK3 -m recent --name AUTH2 --remove
iptables -A KNOCK3 -p tcp --dport $3 -m recent --name AUTH3 --set -j DROP
iptables -A KNOCK3 -j KNOCK1

#Fourth GATE
iptables -A KNOCK4 -m recent --name AUTH3 --remove
iptables -A KNOCK4 -p tcp --dport $4 -m recent --name AUTH4 --set -j DROP
iptables -A KNOCK4 -j KNOCK1

iptables -A PASSED -m recent --name AUTH4 --remove
iptables -A PASSED -p tcp --dport 22 -j ACCEPT
iptables -A PASSED -j KNOCK1

iptables -A WALL -m recent --rcheck --seconds 60 --name AUTH4 -j PASSED
iptables -A WALL -m recent --rcheck --seconds 60 --name AUTH3 -j KNOCK4
iptables -A WALL -m recent --rcheck --seconds 20 --name AUTH2 -j KNOCK3
iptables -A WALL -m recent --rcheck --seconds 20 --name AUTH1 -j KNOCK2
iptables -A WALL -j KNOCK1

#Keeps rules implemented even after reboot
apt-get install iptables-persistent
service iptables-persistent start
