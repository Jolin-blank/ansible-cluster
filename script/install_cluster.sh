#!/bin/bash 
file_dir=/root/ansible-cluster/
set_jvmargs(){
if [ $memory == 4G ];then
 sed  -i '/runbroker.sh/s/-Xms4g -Xmx4g -Xmn2g/-Xms2g -Xmx2g -Xmn1g/'  $file_dir/yaml/install_rocketmq.yml 
else
 echo "make sure your dest machine memory >=8g"
fi
}
judge_run(){
if [ $mode == "root" ];then
ansible-playbook -i  $file_dir/$2.host  $file_dir/yaml/$1  -k
elif [ $mode == "prtg" ];then  
ansible-playbook -i  $file_dir/$2.host  $file_dir/yaml/$1   -u  prtg  -k -b    --become-method=su  -K
else
ansible-playbook -i  $file_dir/$2.host  $file_dir/yaml/$1   -u  prtg   -b   --become-method=su  -K
fi
}
gen_password(){
 python $file_dir/files/pwd
}
usage(){
 echo "Please enter as prompted"
}
install_rocketmq()
{
read -p 'please input rocketmq-cluster ip : ' rocketmq_ip1
read -p 'please input rocketmq-cluster ip : ' rocketmq_ip2
read -p 'please input rocketmq-cluster ip : ' rocketmq_ip3
cat <<EOF > $file_dir/rocketmq.host
[rocketmq-cluster]
$rocketmq_ip1
$rocketmq_ip2
$rocketmq_ip3
EOF
cat <<EOF > $file_dir/vars/rocketmq_var.yml
ROCKETMQIP1: $rocketmq_ip1
ROCKETMQIP2: $rocketmq_ip2 
ROCKETMQIP3: $rocketmq_ip3
EOF
read -p 'please input rocketmq-console ip : ' rocketmq_console_ip
cat <<EOF >> $file_dir/rocketmq.host
[rocketmq-console]
$rocketmq_console_ip
EOF
read -p 'dest machine memory : ' memory
set_jvmargs
judge_run  $1  rocketmq
}
install_3redis()
{
read -p 'please input redis-cluster ip : ' redis_ip1
read -p 'please input redis-cluster ip : ' redis_ip2
read -p 'please input redis-cluster ip : ' redis_ip3
cat <<EOF > $file_dir/3redis.host
[redis-cluster]
$redis_ip1
$redis_ip2
$redis_ip3
EOF
cat <<EOF > $file_dir/vars/redis3_var.yml
REDIS1: $redis_ip1
REDIS2: $redis_ip2
REDIS3: $redis_ip3
PORT1: 7000
PORT2: 7001
PASSWORD: $(gen_password)
EOF
read -p 'please input create redis ip :' createredis_ip
cat <<EOF >> $file_dir/3redis.host
[redis-create]
$createredis_ip
EOF
judge_run  $1  3redis
}
install_redis(){
read -p 'please input redis-cluster ip : ' redis_ip1
read -p 'please input redis-cluster ip : ' redis_ip2
read -p 'please input redis-cluster ip : ' redis_ip3
read -p 'please input redis-cluster ip : ' redis_ip4
read -p 'please input redis-cluster ip : ' redis_ip5
read -p 'please input redis-cluster ip : ' redis_ip6
cat <<EOF > $file_dir/redis.host
[redis-cluster]
$redis_ip1
$redis_ip2
$redis_ip3
$redis_ip4
$redis_ip5
$redis_ip6
EOF

cat <<EOF > $file_dir/vars/redis_var.yml
REDIS1: $redis_ip1
REDIS2: $redis_ip2
REDIS3: $redis_ip3
REDIS4: $redis_ip4
REDIS5: $redis_ip5
REDIS6: $redis_ip6
PORT: 7000
PASSWORD: $(gen_password)
EOF

read -p 'please input create redis ip :' createredis_ip
cat <<EOF >> $file_dir/redis.host
[redis-create]
$createredis_ip
EOF
judge_run  $1  redis
}
install_zookeeper(){
read -p 'please input zookeeper-cluster ip : ' zookeeper_ip1
read -p 'please input zookeeper-cluster ip : ' zookeeper_ip2
read -p 'please input zookeeper-cluster ip : ' zookeeper_ip3
cat <<EOF > $file_dir/zookeeper.host
[zookeeper-cluster]
$zookeeper_ip1
$zookeeper_ip2
$zookeeper_ip3
EOF
cat <<EOF > $file_dir/vars/zookeeper_var.yml
ZOOKEEPER_IP1: $zookeeper_ip1
ZOOKEEPER_IP2: $zookeeper_ip2
ZOOKEEPER_IP3: $zookeeper_ip3
EOF
judge_run  $1   zookeeper
}
operate(){
if [ $state == "install" ];then
  install_$1  install_$1.yml 
elif [ $state == "remove" ];then
  judge_run   remove_$1.yml   $1
else
    usage
fi
}
read -p 'user mode : '  mode
read -p 'please input cluster you want to opreate(rocketmq|3redis|redis|zookeeper) : ' cluster
read -p 'install  or  remove : ' state
case $cluster in
      zookeeper) 
          operate zookeeper
           ;;
      3redis)
          operate 3redis
           ;;
       redis)
          operate  redis
           ;;
      rocketmq)
          operate rocketmq
           ;;
      *)
          usage
esac
sed  -i '/runbroker.sh/s/-Xms2g -Xmx2g -Xmn1g/-Xms4g -Xmx4g -Xmn2g/'  $file_dir/yaml/install_rocketmq.yml 

