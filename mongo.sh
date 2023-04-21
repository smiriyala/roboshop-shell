source common.sh


print_head "MongoDB repo file copying"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}

print_head "MongoDB installation started"
yum install mongodb-org -y &>>${log_file}

print_head "update mongodb listener address"
sed -i -e 's/127.0.0.1/0.0.0.0' /etc/mongod.conf &>>${log_file}

print_head "enable mongodb"
systemctl enable mongod &>>${log_file}

print_head "ReStarted Mongodb"
systemctl restart mongod &>>${log_file}

#systemctl restart mongod