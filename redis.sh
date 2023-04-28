source common.sh


print_head "Redis Repo download" 
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${log_file}
status_check $?

print_head "Redis Repo enabling"
dnf module enable redis:remi-6.2 -y &>>${log_file}
status_check $?

print_head "Redis installation" 
yum install redis -y &>>${log_file}
status_check $?

print_head "Update redis listener address" 
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis.conf &>>${log_file}
status_check $?

print_head "Update redis listener address"
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/redis/redis.conf &>>${log_file}
status_check $?
#You can edit file by using vim /etc/redis.conf & vim /etc/redis/redis.conf

print_head "enable redis"
systemctl enable redis &>>${log_file}
status_check $?

print_head "Start Redis service" 
systemctl restart redis &>>${log_file}
status_check $?