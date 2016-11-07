#!/bin/bash
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
CURRDIR=$(pwd)
apt-get install realpath -y
cd $CURRDIR
echo Restoring...
read -p "Would you like to install Midnight Commander? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install mc -y
fi
read -p "Would you like to install locate? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install locate -y
fi

read -p "Would you like to Update fstab and create mount points? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    echo Updating fstab
    echo "192.168.1.3:/mnt/500gb/ /media/hdd         nfs      defaults,rsize=8192,wsize=8192,nolock  0 0  " >> /etc/fstab
    echo "192.168.1.3:/mnt/WD/ /media/WD        nfs       defaults,rsize=8192,wsize=8192,nolock  0 0   " >> /etc/fstab
    echo "192.168.1.3:/mnt/local/ /media/local        nfs       defaults,rsize=8192,wsize=8192,nolock  0 0   " >> /etc/fstab
    echo "192.168.1.3:/mnt/story/ /media/story        nfs       defaults,rsize=8192,wsize=8192,nolock  0 0   " >> /etc/fstab
    echo "tmpfs    /tmp    tmpfs    defaults,noatime,nosuid,size=64M    0 0" >> /etc/fstab
    echo Creating mount points
    sudo mkdir -p /media/hdd
    sudo mkdir -p /media/WD
    sudo mkdir -p /media/local
    sudo mkdir -p /media/story
    echo Mounting newly created mount points
    sudo mount /media/hdd
    sudo mount /media/WD
    sudo mount /media/local
    sudo mount /media/story
fi
read -p "Would you like to restore entries in config.txt ? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    echo "disable_overscan=1" >> /boot/config.txt
    echo "hdmi_ignore_cec_init=1" >> /boot/config.txt
    echo "hdmi_drive=2" >> /boot/config.txt
    echo "hdmi_group=1" >> /boot/config.txt
    echo "hdmi_mode=4" >> /boot/config.txt
    echo "hdmi_ignore_edid=0xa5000080" >> /boot/config.txt
    echo "decode_MPG2=0xd356fbb0" >> /boot/config.txt
    echo "decode_WVC1=0x41cc9feb" >> /boot/config.txt
fi
read -p "Would you like to install crond? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install cron -y
    
fi
read -p "Would you like to install PNI keymap <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo cp -rf ./files/gen.xml /home/osmc/.kodi/userdata/keymaps/
    
fi
read -p "Would you like to install lcdproc <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install lcdproc -y
    sudo cp -rf ./files/LCDd.conf /etc/
    sudo cp -rf ./files/LCD.xml /home/osmc/.kodi/userdata/
    sudo mkdir -p /lib/arm-linux-gnueabihf/lcdproc
    sudo cp -rf ./files/hd44780.so /usr/lib/arm-linux-gnueabihf/lcdproc/
    sudo chmod 644 /usr/lib/arm-linux-gnueabihf/lcdproc/
    sudo systemctl restart LCDd
fi
read -p "Would you like to install Motion daemon <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install motion -y
    sudo cp -rf ./files/motion.conf /etc/motion/
    sudo cp -rf ./files/motion /etc/default/
    sudo chmod 644 /etc/default/motion
    sudo chmod 777 /var/log/
    #prevent motion autostart
    sudo systemctl disable motion
    sudo systemctl restart motion
fi
read -p "Would you like to install tvheadend daemon <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    read -p "Would you like to add repository to /etc/sources.list <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61
        sudo sh -c 'echo "deb https://dl.bintray.com/djbenson/deb wheezy unstable" >> /etc/apt/sources.list' 
	sudo apt-get install apt-transport-https -y --force-yes 
	sudo apt-get update
    fi
    cp -rf ./files/dvb-demod-m88ds3103.fw /lib/firmware/
    sudo chmod 644 /lib/firmware/dvb-demod-m88ds3103.fw
    sudo apt-get install tvheadend -y
    sudo apt-get install bzip2 -y
    sudo apt-get install zip -y
    read -p "Would you like to restore tvheadend configuration? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
	sudo rm -rfd /home/hts/
        sudo rm -rfd /home/.hts/
	sudo cp -rf ./files/hts.zip /home/
	systemctl stop tvheadend
	sudo cp -rf ./files/tvheadend /etc/default
	cd /home/
	unzip /home/hts.zip
	sudo rm -rfd /home/hts.zip
	cd $CURRDIR
	systemctl restart tvheadend
    fi
    read -p "Would you like to install tvheadend autobackup script? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
	sudo apt-get install cron -y
	sudo cp -rf ./files/updTVH.sh /usr/local/bin/
	chmod 755 /usr/local/bin/updTVH.sh	
	line="0 2 * * 5  /usr/local/bin/updTVH.sh"
	(crontab -u root -l; echo "$line" ) | crontab -u root -
    fi
fi
read -p "Would you like to restore kodi settings? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    systemctl stop mediacenter
    sudo cp -rf ./files/kodi.zip /home/osmc/.kodi
    cd /home/osmc/.kodi/
    unzip -o /home/osmc/.kodi/kodi.zip
    sudo rm -rfd /home/osmc/.kodi/kodi.zip
    cd $CURRDIR
    systemctl start mediacenter
fi
read -p "Would you like to install webserver+php+mysql? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install lighttpd -y
    sudo apt-get install mysql-server -y
    sudo apt-get install php5-common php5-cgi php5 -y
    sudo apt-get install php5-mysql -y
    sudo lighty-enable-mod fastcgi-php -y
    sudo systemctl restart lighttpd -y
    sudo chown www-data:www-data /var/www
    sudo chmod 775 /var/www
    sudo usermod -a -G www-data osmc
    sudo apt-get install phpmyadmin -y
    sudo apt-get install -f -y
fi
read -p "Would you like to install Homey (Home Automation Project)? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    sudo apt-get install git -y
    sudo apt-get install build-essential -y
    sudo apt-get install libusb-1.0-0-dev -y
    cd $CURRDIR
    read -p "Would you like to install mochad? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        wget -O mochad.tgz  http://sourceforge.net/projects/mochad/files/latest/download
        tar xf mochad.tgz
        cd mochad* 
        ./configure 
        make
        make install
        cd $CURRDIR
        sudo cp -rf ./files/mochad.service /lib/systemd/system/
        sudo systemctl enable mochad
        sudo systemctl restart mochad    
    fi
    read -p "Would you like to install wiringpi? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
	cd $CURRDIR
        git clone git://git.drogon.net/wiringPi
	cd wiringPi
	./build
    fi
    read -p "Would you like add SPI and I2C to config.txt <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        echo "dtparam=i2c0=on,i2c1=on,spi=on" >> /boot/config.txt
    fi    
    sudo apt-get install -y python-smbus i2c-tools 
    echo "i2c-dev" >> /etc/modules
    modprobe i2c-dev
    echo Checking connected I2C devices
    sudo i2cdetect -y 1
    read -p "Would you like checkout, install web app, build  and install C app? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
	sudo apt-get install libmysqlclient-dev libmysqld-dev -y
	
	if [ ! -d "./Homey" ]; then
		  # Control will enter here if $DIRECTORY doesn't exist.
	    	  git clone https://github.com/trex2000/Homey
	else
	          cd ./Homey
		  git pull https://github.com/trex2000/Homey
	fi
    fi
    read -p "Would you like to install the web app ? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
        cd $CURRDIR
	sudo cp -rf ./Homey/Webpage/* /var/www/html
	sudo chown -R www-data:www-data /var/www/html
	sudo chmod -R 755 /var/www/html/*.sh   
	sudo cp -rf ./files/config.inc.php /var/www/html/
	sudo mysql -u root --password="l3dyh@wk3" -e "create database homey"; 
	mysql -u root --password="l3dyh@wk3" homey < ./Homey/sql/homey.sql
    fi
    read -p "Would you like compile the C app ? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
	cd $CURRDIR//Homey/Linux\ App\ Source/
	make
	if [ -f homey ];
	then
	     	sudo cp -rf ./homey /usr/local/bin/
		sudo cp -rf $CURRDIR//Homey/Linux\ App\ Source/homey.service /lib/systemd/system/
	else
	     echo "Build went wrong. Binary could not be located. Check build log!"
	fi
    fi
fi
