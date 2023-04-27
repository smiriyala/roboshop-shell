source common.sh

##root password must be given whilest executing this service in mysql spot instnace.
mysql_root_password=$1
if[-z "${mysql_root_password}"]; then
    echo -e "\e[31mMissing Mysql root password argument-RoboShop@1\e[0m"
    exit 1
fi

print_head "disable MySQL 8 version"
dnf module disable mysql -y &>>${log_file}
status_check $?

print_head "copy MySQL repo file"
cp ${code_dir}/configs/mysql.repo /etc/yum.repos.d/mysql.repo &>>${log_file}
status_check $?

print_head "Install Start MySQL Service"
yum install mysql-community-server -y &>>${log_file}
status_check $?

print_head "Enable MySQL Service"
systemctl enable mysqld &>>${log_file}
status_check $?

print_head "Start MySQL Service"
systemctl start mysqld  &>>${log_file}
status_check $?

print_head "change default password only when it doesnt set earlier"
echo show database | mysql -uroot -p${mysql_root_password} &>>${log_file}
if[$? -ne 0];then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>${log_file}
fi
status_check $?

print_head "Check new password set correctly"
mysql -uroot -p${mysql_root_password} &>>${log_file}
status_check $?