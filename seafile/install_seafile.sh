#!/bin/bash
################ 一键安装Seafile脚本 ##################
#Author:夕阳DIY
#Update:2018-10-18
#######################   END   #######################

#防火墙放行端口
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 8000 -j ACCEPT
		iptables -I INPUT -p tcp --dport 8082 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=8000/tcp --permanent
		firewall-cmd --zone=public --add-port=8082/tcp --permanent
		firewall-cmd --reload
	fi
}

#安装seafile函数
function install_sea() {
	cd /home/Seafile
	#下载安装包7.0.5 64bit
	wget http://seafile-downloads.oss-cn-shanghai.aliyuncs.com/seafile-server_7.0.5_x86-64.tar.gz
	#解压
	tar -zxvf seafile-server_7.0.5_x86-64.tar.gz
	mkdir installed
	rm -rf seafile-server*.tar.gz
	mv seafile-server-7* seafile-server
	#安装依赖环境
	yum -y install python-setuptools python-imaging python-ldap MySQL-python python-memcached python-urllib3
	#进行安装
	cd seafile-server && ./setup-seafile.sh
	
	#启动服务
	./seafile.sh start &&  ./seahub.sh start
	#防火墙放行端口
	chk_firewall
	#开机启动
	echo "/home/Seafile/seafile-server/seafile.sh start" >> /etc/rc.d/rc.local
	echo "/home/Seafile/seafile-server/seahub.sh start" >> /etc/rc.d/rc.local
	chmod u+x /etc/rc.d/rc.local
	#获取IP
	osip=$(curl https://api.ip.sb/ip)
	echo "------------------------------------------------------"
	echo "安装完成。请访问：http://${osip}:8000"
	echo "------------------------------------------------------"
}

echo "##########	Seafile一键安装脚本	##########"

echo "1.安装Seafile"
echo "2.卸载Seafile"
echo "3.退出"
declare -i stype
read -p "请输入选项:" stype

if [ "$stype" == 1 ]
	then
		#检查目录是否存在
		if [ -e "/home/Seafile" ]
			then
			echo "目录存在，请检查是否已经安装。"
			exit
		else
			echo "目录不存在，创建目录..."
			mkdir -p /home/Seafile
			#执行安装函数
			install_sea
		fi
	elif [ "$stype" == 2 ]
		then
			/home/Seafile/seafile-server/seafile.sh stop
			/home/Seafile/seafile-server/seahub.sh stop
			rm -rf /home/Seafile
			rm -rf /tmp/seahub_cache/*
			echo '卸载完成.'
			exit
	elif [ "$stype" == 3 ]
		then
			exit
	else
		echo "参数错误！"
	fi	
