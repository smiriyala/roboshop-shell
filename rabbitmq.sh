#wrapping password, rather than passing in code we need to pass as argument while execution
if [ -z "${roboshop_app_password}" ];then
    each -e "\e[31mMissing RabbitMQ user password argument\e[0m"
    exit 1
fi


print_head "Configure YUM Repos from the script provided by vendor"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${log_file}
status_check $?

print_head "Install ErLang"
yum install erlang -y &>>${log_file}
status_check $?

print_head "Configure YUM Repos for RabbitMQ."
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${log_file}
status_check $?

print_head "Install RabbitMQ"
yum install rabbitmq-server -y &>>${log_file}
status_check $?

print_head "Start RabbitMQ Service"
systemctl enable rabbitmq-server &>>${log_file}
status_check $?

print_head "Starting rabbitmq server"
systemctl start rabbitmq-server &>>${log_file}
status_check $?

print_head "default username / password as guest/guest Hence, we need to create one user for the application"
#chekcing list of users exists in rabbitmq using rabbitmgctl list_users commond using sudo
rabbitmqctl list_users | grep roboshop &>>${log_file}
if [ $? -ne 0 ];then
 rabbitmqctl add_user roboshop ${roboshop_app_password} &>>${log_file}
fi
status_check $?

print_head "set permission for the user created"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check $?