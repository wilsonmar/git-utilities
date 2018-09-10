#!/bin/bash
# This is from https://github.com/wilsonmar/git-utilities/gitlab-on-pie3.sh
# by WilsonMar@gmail.com
# Described in https://wilsonmar.github.io/gitlab-on-pie3.md

# This script installs GitLab CE on a Raspberry Pi 3 (64-bit) Stretch version,
# so you can store stuff for less than $50 (less than a year of GitHub subscription)
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/git-utilities/master/gitlab-on-pi3.sh)"

# https://about.gitlab.com/installation/#raspberry-pi-2
# https://x-team.com/blog/alternatives-to-github-including-github/
# https://hackernoon.com/create-your-own-git-server-using-raspberry-pi-and-gitlab-f64475901a66
# https://howtoraspberrypi.com/private-git-raspberry-gitlab/  9 March 2018
# https://github.com/scaleway/image-builder
# use the Docker's building system and convert it at the end to a disk image that will boot on real servers without Docker.

# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md

#Raspbian armhf AFAIK is not binary compatible with debian armhf, unless omnibus packages ship all binary stuff (e.g. therubyracer) statically linked (or only depend on binary stuff present in jessie repository).
# Raspbian armhf == armv6zk -mfpu=vfpv2
# Debian   armhf == armv7l  -mfpu=vfpv3

echo "1.1 install and configure the necessary dependencies."
sudo apt-get install -y curl openssh-server ca-certificates apt-transport-https

echo "1.2 install postfix. To send emails from your GitLab server select ‘Internet Site’ during setup."
sudo apt-get install -y postfix
   # TODO: Manually set SMTP to local - See https://pimylifeup.com/raspberry-pi-gitlab/

echo "1.3 add GPG keys to update GitLab server."
curl https://packages.gitlab.com/gpg.key | sudo apt-key add -

echo "2. Install Gitlab CE"
sudo curl -sS https://packages.gitlab.com/install/repositories/gitlab/raspberry-pi2/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce

echo "cat /etc/gitlab/gitlab.rb"
sudo nano /etc/gitlab/gitlab.rb
# external_url 'http://localhost:9999'
# nginx['listen_port'] = 9999
# nginx['listen_https'] = false
# unicorn['port'] = 7777
# QUESTION: What's the unicorn port for?
	read -rsp $'Press any key after deleting ...\n' -n 1 key

echo "3. Start gitlab-ctl"
sudo gitlab-ctl reconfigure

echo "4.1 Get the IP of your raspberry pi using ifconfig command."
ifconfig

echo "4.2 On your first visit, you’ll be redirected to a password reset screen"

echo "5. Log in with your username (root by default) and the password you set in the previous step."
# You will have the home page of your GitLab server, where all your future projects will be listed."

echo "6. Start all GitLab components"
sudo gitlab-ctl start

echo "6.1 Restart all GitLab components"
sudo gitlab-ctl restart

echo "6.2 Stop all GitLab components"
sudo gitlab-ctl stop

echo "6.3 Tail GitLab logs"
sudo gitlab-ctl tail

# https://stackoverflow.com/questions/849308/pull-push-from-multiple-remote-locations