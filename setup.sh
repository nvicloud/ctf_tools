#!/bin/bash

# =====================================================================================================
#
#
# Date: 2022-10-24
# Version: 1.4
#
# $(date +'%Y_%b_%d_%H:%M:%S')_
# =====================================================================================================

clear

# TryHackMe Additional Updates
thm_package(){
apt-get update && apt install -y python3-pip  
rm -rf /opt/impacket && git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket  
python3 /opt/impacket/setup.py install 
gem install evil-winrm
}


# Install default apps.
software_install() {
#docker pull rustscan/rustscan:2.0.0 &> /dev/null
#alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:2.0.0'
mv audit_tools/apps/* /usr/bin/ &> /dev/null
cd /usr/bin
wget https://github.com/OJ/gobuster/releases/download/v3.1.0/gobuster-linux-amd64.7z &> /dev/null
wget https://go.dev/dl/go1.19.4.linux-amd64.tar.gz &> /dev/null
rm -f /usr/bin/gobuster && 7z e gobuster-linux-amd64.7z &> /dev/null && chmod +x /usr/bin/gobuster &> /dev/null
rm -rf /usr/bin/go && tar -C /usr/bin -xzf go1.*linux-amd64.tar.gz &> /dev/null
export PATH=$PATH:/usr/bin/go/bin
cd - &> /dev/null
systemctl start postgresql &> /dev/null && msfdb init &> /dev/null
}

# View installation results.
software_results() {
echo "Current Directory $(pwd)"
echo "PostgreSQL Status -" $(systemctl status postgresql | grep -E 'Active')
echo "Go Version -" $(go version)
#echo "Checking for Hash-Identifier"
#which hash-identifier
#echo $(whatweb --version)
echo $(openvpn --version | grep -Eo '^OpenVPN.{0,7}')
echo "Gobuster" $(gobuster version)
}

# Remove installed software packages and folder(s).
clean_up() {
	# mv audit_tools/web_shells/ audit_tools/win audit_tools/lin/ audit_tools/wordlists/ .
	rm -fr /usr/bin/gobuster-linux-amd64.7z /usr/bin/gobuster-linux-amd64/
	rm -f /usr/bin/go1.19.linux-amd64.tar.gz
	mv audit_tools/* .
	mkdir lin ; mv lin.tar.bz2 lin/
	mkdir win ; mv win.tar.bz2 win/
	rm -rf audit_tools/
}

proxy_func() {
PROXY_CONFIG=/etc/proxychains.conf
        if [[ -f "$PROXY_CONFIG" ]]
        then
            echo "Configuration updated to $PROXY_CONFIG."
            sed -i -e 's/socks4/#socks4/g' /etc/proxychains.conf
	    echo -e "socks5 127.0.0.1 1080\n\nhttp 127.0.0.1:8080 \nhttps 127.0.0.1:8080" >> /etc/proxychains.conf
	    sed -i -e 's/#quiet_mode/quiet_mode/g' /etc/proxychains.conf
        else 
            echo "$PROXY_CONFIG may not exist. Please confirm"
        fi
}

tput cup 3 12; echo "Installation Type"
tput cup 4 12; echo "================="
tput cup 6 9; echo "1 - TryHackMe"
tput cup 7 9; echo "2 - ProvingGrounds"
tput cup 8 9; echo "3 - HackTheBox"
tput cup 9 9; echo "Q - Other "
tput cup 10 9;
tput cup 10 19;
read choice || continue
case $choice in
        "1")
                software_install
                cd ~/Desktop && ln -s /usr/share/wordlists/rockyou.txt rockyou.txt
                software_results
		proxy_func
		thm_package
                clean_up
                ;;
        "2")
                software_install
                gunzip /usr/share/wordlists/rockyou.txt.gz;
                cd /home/kali/Desktop && ln -s /usr/share/wordlists/rockyou.txt rockyou.txt
                software_results
		proxy_func
                clean_up
                ;;
        "3")
                software_install
                cd /home/htb-*/Desktop && ln -s /usr/share/wordlists/rockyou.txt rockyou.txt
                software_results
		proxy_func
                clean_up
                ;;
        [QqEe])
                software_install
                software_results
		proxy_func
                clean_up
                exit ;;
*) tput cup 14 4; echo "Invalid Code"; read choice ;;
esac
