wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add - 
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' 
apt-get update

sudo apt remove jenkins

sudo apt install openjdk-11-jdk

sudo apt install jenkins