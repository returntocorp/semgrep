#!/bin/bash

sudo apt-get update && sudo apt-get install -y --no-install-recommends make m4 perl wget swi-prolog mercurial pkg-config build-essential
sudo apt-get install -y zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libbz2-dev
# Install Python 3.7
sudo wget https://www.python.org/ftp/python/3.7.7/Python-3.7.7.tar.xz
sudo tar xvf Python-3.7.7.tar.xz
cd Python-3.7.7
sudo ./configure --enable-shared
sudo make altinstall
sudo ldconfig /usr/local/lib
python3.7 --version
which python3.7
/usr/local/bin/python3.7 -c "import bz2; print(bz2.__doc__)"
sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo -H python3.7 get-pip.py
pip3 --version
ldd --version
echo "Pls help me make this at least 3.7"

# Install git 2.18
sudo apt-get install -y --no-install-recommends libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential autoconf
cd /usr/src/
sudo wget https://github.com/git/git/archive/v2.18.0.tar.gz -O git.tar.gz
sudo tar -xf git.tar.gz
cd git-*
sudo make prefix=/usr/local all;
sudo make prefix=/usr/local install;
git --version
sudo chmod -R 777 . /github
opam switch --root /home/opam/.opam 4.07;
