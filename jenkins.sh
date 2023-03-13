#!/usr/bin/sudo bash

user="jenkins"
#PASSWORD=cnl8989
hosts=$(cat server.txt)


if id -u $user >/dev/null 2>&1;
    then
      echo "The user $user already exists"
      echo "$user ALL=(ALL)       NOPASSWD:       ALL" | sudo tee --append  /etc/sudoers
      sudo mkdir /var/lib/jenkins/.ssh
      sudo touch /var/lib/jenkins/.ssh/id_rsa &&  sudo chmod 700 /var/lib/jenkins/.ssh/id_rsa
      cp -R /home/ubuntu/lala.pem /var/lib/jenkins/.ssh/id_rsa
      sudo touch /var/lib/jenkins/.ssh/known_hosts
      sudo chown -R $user:$user /var/lib/jenkins/.ssh/
      sudo apt-get install ansible -y > /dev/null 2>&1 &
    else
      echo " The user $user does not exist"
fi

for host in $hosts;
do
  ssh -t -t -i lala.pem -o StrictHostKeyChecking=no ubuntu@$host 'bash -s' << EOF
    sudo useradd -m -d /var/lib/jenkins -s /bin/bash $user
#    sudo echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$user"
    sudo echo "$user ALL=(ALL)       NOPASSWD:       ALL" | sudo tee --append  /etc/sudoers
    sudo echo "user $user created in $host"
    sudo mkdir /var/lib/jenkins/.ssh
    sudo chmod 700 /var/lib/jenkins/.ssh
    sudo touch /var/lib/jenkins/.ssh/authorized_keys
    sudo chmod 600 /var/lib/jenkins/.ssh/authorized_keys
    sudo chown -R $user:$user /var/lib/jenkins/.ssh
    sudo cp -R /home/ubuntu/.ssh/authorized_keys /var/lib/jenkins/.ssh/authorized_keys
    exit
EOF
done
