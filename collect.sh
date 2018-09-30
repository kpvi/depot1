#!/bin/bash
export PATH=$PATH
export file=/tmp/sample.out

##the below condition checks if email is supplied along with script. if not it displays an error###

if [ $# -ne 1 ]
then
	echo "Usage: $0 Email is required to run the script!."
	exit 1
fi

echo "System configuration captured at `date +"%d %A %b %Y %T"`" >/tmp/sample.out
echo "================================================================">>/tmp/sample.out

 line()
        {
        echo "================================================================" >>/tmp/sample.out
        }

echo "system hostname: `hostname`" >>$file
echo "system FQDN: `hostname -f`" >>$file
line

printf "Installed Operating system:\n`cat /etc/redhat-release`\n">>$file;
line
#The installed processors counts represents number of cores per systems
printf  "Installed processors `cat /proc/cpuinfo |awk '/processor/ {print$0}'|wc -l` | `cat /proc/cpuinfo |awk '/model name/ {print$0}'|sed "1d"`\n">>$file
line
printf "Installed Memory/Swap in the system in Giga bit.\n`free -g |awk '/Mem|Swap/ {print $1,$2}'`\n" >>$file
line

#Configured File system in the system is converted into two components. 1 with NFS , 2 without NFS
printf "File system configured in system\n" >>$file
echo "`df -Th|head -1`">>$file
echo    "`df -Th |awk '/xfs|devtmpfs|ext3|ext4|tmpfs/ {print $0}'`" >>$file
line

printf "NFS configured in the system\n" >>$file
echo "`df -Th|head -1`">>$file
echo    "`df -Th |awk '/nfs/ {print $0}'`">>$file;line
#capturing ip and gateways. this will be revisited to avoid loops back ip and other unwanted IPs
printf "IP address and Gateway of the host:-\n" >>$file
#ip addr show `cat /proc/net/dev|awk '/eno|eth/ {print$0}'|  cut -d':' -f1` >>$file
ip addr show >>$file
printf "Gateway:-\n`netstat -rn|sed "1d"`\n" >>$file
line
printf "Java version installed:-\n">>$file
java -version &>>$file;line
printf "C++ bundle installed\n `rpm -qa gcc | xargs rpm -qi |awk '/Name|Version|Architecture|Source RPM|Summary/ {print $0}'`\n">>$file;line
#printf "C++ bundle installed\n">>$file
#gcc -v &>>$file
#oracle configuration
printf "Oracle version and database details\n" >>$file
#su - ormerck -c "echo $ORAHOME" >>$file
ps -ef |grep -i pmon|grep -v grep >>$file
line
#removing the exported variable/s
unset file
#emailing the captured information to the Admin
cat /tmp/sample.out|mailx -s "configuration of `hostname`" $1
#removing the captured file
rm -rf /tmp/sample.out
