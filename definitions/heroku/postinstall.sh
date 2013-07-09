# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get -y install git-core vim curl lxc s3cmd

apt-get install -y --force-yes language-pack-en
apt-get install -y --force-yes coreutils tar build-essential autoconf
apt-get install -y --force-yes libxslt-dev libxml2-dev libglib2.0-dev \
    libbz2-dev libreadline5-dev zlib1g-dev libevent-dev libssl-dev libpq-dev \
    libncurses5-dev libcurl4-openssl-dev libjpeg-dev libmysqlclient-dev
apt-get install -y --force-yes daemontools
apt-get install -y --force-yes curl netcat-openbsd telnet
apt-get install -y --force-yes iputils-tracepath bind9-host dnsutils socat
apt-get install -y --force-yes ed bison
apt-get install -y --force-yes openssh-client openssh-server
apt-get install -y --force-yes imagemagick libmagick9-dev
apt-get install -y --force-yes ia32-libs
apt-get install -y --force-yes openjdk-6-jdk openjdk-6-jre-headless

apt-get install -y --force-yes syslinux

apt-get install -y --force-yes --no-install-recommends language-pack-aa \
    language-pack-af language-pack-am language-pack-an language-pack-ar \
    language-pack-as language-pack-ast language-pack-az language-pack-be \
    language-pack-ber language-pack-bg language-pack-bn language-pack-bo \
    language-pack-br language-pack-bs language-pack-ca language-pack-crh \
    language-pack-cs language-pack-csb language-pack-cy language-pack-da \
    language-pack-de language-pack-dv language-pack-dz language-pack-el \
    language-pack-en language-pack-eo language-pack-es language-pack-et \
    language-pack-eu language-pack-fa language-pack-fi language-pack-fil \
    language-pack-fo language-pack-fr language-pack-fur language-pack-fy \
    language-pack-ga language-pack-gd language-pack-gl language-pack-gu \
    language-pack-ha language-pack-he language-pack-hi language-pack-hne \
    language-pack-hr language-pack-hsb language-pack-ht language-pack-hu \
    language-pack-hy language-pack-ia language-pack-id language-pack-ig \
    language-pack-is language-pack-it language-pack-iu language-pack-ja \
    language-pack-ka language-pack-kk language-pack-km language-pack-kn \
    language-pack-ko language-pack-ks language-pack-ku language-pack-kw \
    language-pack-ky language-pack-la language-pack-lg language-pack-li \
    language-pack-lo language-pack-lt language-pack-lv language-pack-mai \
    language-pack-mg language-pack-mi language-pack-mk language-pack-ml \
    language-pack-mn language-pack-mr language-pack-ms language-pack-mt \
    language-pack-nan language-pack-nb language-pack-nds language-pack-ne \
    language-pack-nl language-pack-nn language-pack-nr language-pack-nso \
    language-pack-oc language-pack-om language-pack-or language-pack-pa \
    language-pack-pap language-pack-pl language-pack-pt language-pack-ro \
    language-pack-ru language-pack-rw language-pack-sa language-pack-sc \
    language-pack-sd language-pack-se language-pack-shs language-pack-si \
    language-pack-sk language-pack-sl language-pack-so language-pack-sq \
    language-pack-sr language-pack-ss language-pack-st language-pack-sv \
    language-pack-ta language-pack-te language-pack-tg language-pack-th \
    language-pack-ti language-pack-tk language-pack-tl language-pack-tlh \
    language-pack-tn language-pack-tr language-pack-ts language-pack-tt \
    language-pack-ug language-pack-uk language-pack-ur language-pack-uz \
    language-pack-ve language-pack-vi language-pack-wa language-pack-wo \
    language-pack-xh language-pack-yi language-pack-yo language-pack-zh \
    language-pack-zh-hans language-pack-zh-hant language-pack-zu

# pull in a newer libpq
echo "deb http://apt.postgresql.org/pub/repos/apt/ lucid-pgdg main" >> /etc/apt/sources.list

cat > /etc/apt/preferences <<EOF
Package: *
Pin: release a=lucid-pgdg
Pin-Priority: -10
EOF

curl -o /tmp/postgres.asc http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc
if [ "$(sha256sum /tmp/postgres.asc)" = \
    "fbdb6c565cd95957b645197686587f7735149383a3d5e1291b6830e6730e672f" ]; then
    apt-key add /tmp/postgres.asc
fi

apt-get update
apt-get install -y --force-yes -t lucid-pgdg libpq5 libpq-dev

# Apt-install python tools and libraries
# libpq-dev lets us compile psycopg for Postgres
apt-get -y install python-setuptools python-dev libpq-dev pep8

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Install Ruby from source in /opt so that users of Vagrant
# can install their own Rubies using packages or however.
wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.bz2
tar jxf ruby-2.0.0-p247.tar.bz2
cd ruby-2.0.0-p247
./configure --prefix=/opt/ruby
make
make install
cd ..
rm -rf ruby-2.0.0-p247*
chown -R root:admin /opt/ruby
chmod -R g+w /opt/ruby

# Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc
/opt/ruby/bin/gem install bundler --no-ri --no-rdoc

# Add the Puppet group so Puppet runs without issue
groupadd puppet

# Install Foreman
/opt/ruby/bin/gem install foreman --no-ri --no-rdoc

# Install pip, virtualenv, and virtualenvwrapper
easy_install pip
pip install virtualenv
pip install virtualenvwrapper

# Add a basic virtualenvwrapper config to .bashrc
echo "export WORKON_HOME=/home/vagrant/.virtualenvs" >> /home/vagrant/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.bashrc

# Install PostgreSQL 9.2.4
wget http://ftp.postgresql.org/pub/source/v9.2.4/postgresql-9.2.4.tar.bz2
tar jxf postgresql-9.2.4.tar.bz2
cd postgresql-9.2.4
./configure --prefix=/usr
make world
make install
cd ..
rm -rf postgresql-9.2.4*

# Initialize postgres DB
useradd -p postgres postgres
mkdir -p /var/pgsql/data
chown postgres /var/pgsql/data
su -c "/usr/bin/initdb -D /var/pgsql/data --locale=en_US.UTF-8 --encoding=UNICODE" postgres
mkdir /var/pgsql/data/log
chown postgres /var/pgsql/data/log

# Add 'vagrant' role
su -c 'createuser vagrant -s' postgres

# Start postgres
su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres

# Start postgres at boot
sed -i -e 's/exit 0//g' /etc/rc.local
echo "su -c '/usr/bin/pg_ctl start -l /var/pgsql/data/log/logfile -D /var/pgsql/data' postgres" >> /etc/rc.local

# Install NodeJs for a JavaScript runtime
git clone https://github.com/joyent/node.git
cd node
git checkout v0.4.7
./configure --prefix=/usr
make
make install
cd ..
rm -rf node*

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /home/vagrant
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Install Heroku toolbelt
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

# Install some libraries
apt-get -y install libxml2-dev libxslt-dev curl libcurl4-openssl-dev
apt-get -y install imagemagick libmagickcore-dev libmagickwand-dev
apt-get clean

# Set locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
exit
