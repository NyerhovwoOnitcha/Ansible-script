#!/usr/bin/sudo bash

user="ansible"

#PASSWORD=cnl8989
hosts=$(cat server.txt)


if id -u $user >/dev/null 2>&1;
    then
      echo "The user $user already exists"
    else
      useradd -m -s /bin/bash $user
#      echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$user"
      echo "$user ALL=(ALL)       NOPASSWD:       ALL" | sudo tee --append  /etc/sudoers
      sudo mkdir /home/$user/.ssh
      sudo touch /home/$user/.ssh/id_rsa &&  sudo chmod 700 /home/$user/.ssh/id_rsa
      cp -R /home/ubuntu/lala.pem /home/$user/.ssh/id_rsa
      sudo touch /home/$user/known_hosts

      sudo apt-get install ansible -y > /dev/null 2>&1 &
      sleep 2
      sudo mkdir /home/$user/dev
      sudo touch /home/$user/dev/ansible.cfg
      sudo echo -e "[defaults] \ninventory=hosts \nremote_user=ansible \nhost_key_checking = false \n[privilege_escalation] \nbecome=True \nbecome_method=sudo \nbecome_user=root \nbecome_ask_pass=False" >> /home/$user/dev/ansible.cfg
      sudo touch /home/$user/dev/hosts
      sudo cp -R /home/ubuntu/server.txt  /home/$user/dev/hosts
      sudo chown -R $user:$user /home/$user/
fi

for host in $hosts;
do
  ssh -t -t -i lala.pem -o StrictHostKeyChecking=no ubuntu@$host 'bash -s' << EOF
    sudo useradd -m -s /bin/bash $user
#    sudo echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$user"
    sudo echo "$user ALL=(ALL)       NOPASSWD:       ALL" | sudo tee --append  /etc/sudoers
    sudo echo "user created in $host"
    sudo mkdir /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo touch /home/$user/.ssh/authorized_keys
    sudo chmod 600 /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user/.ssh
    sudo cp -R /home/ubuntu/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
    exit
EOF
done
