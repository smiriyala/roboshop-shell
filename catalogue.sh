source common.sh

print_head "Configure NodeJs Repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
status_check $?

print_head "Install Nodejs"
yum install nodejs -y &>>${log_file}
status_check $?

print_head "create roboshop user"
id roboshop &>>${log_file}
if [$? -ne 0]; then
    useradd roboshop &>>${log_file}
fi
status_check $?

print_head "create app directory"
if [! -d /app]; then
    mkdir /app &>>${log_file}
fi
status_check $?

print_head "remove old log content"
rm -rf /app/* &>>${log_file}
status_check $?

print_head "download app content"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log_file}
status_check $?
cd /app 


print_head "extracting app content"
unzip /tmp/catalogue.zip &>>${log_file}
status_check $?

print_head "install nodeJs Dependents"
npm install &>>${log_file}
status_check $?

print_head "copy config service to systemD service"
cp ${code_dir}/configs/catalogue.service /etc/systemd/system/catalogue.service &>>${log_file}
status_check $?

print_head "Reload SystemD"
systemctl daemon-reload &>>${log_file}
status_check $?

print_head "enable catalogue service"
systemctl enable catalogue &>>${log_file}
status_check $?

print_head "Restart catalogue service"
systemctl restart catalogue &>>${log_file}

print_head "copy mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?


print_head "Intall mongodb client"
yum install mongodb-org-shell -y &>>${log_file}
status_check $?

print_head "Load Schema"
mongo --host mongodb-dev.devopsforyou.online </app/schema/catalogue.js &>>${log_file}
status_check $?