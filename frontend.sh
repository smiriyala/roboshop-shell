source common.sh

print_head "Installing Nginx"
yum install nginx -y &>>${log_file}
echo $? # this give status of last command in numeric
status_check $?
# if[$? -eq 0]; then
#     echo SUCCESS
# else
#     echo FAILURE
# fi


print_head "Removing Default Nginx html content"
rm -rf /usr/share/nginx/html/* &>>{log_file}
status_check $?

print_head "Downloading frontend package"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>{log_file}
status_check $?

print_head "Extracting frontend package"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>{log_file}
status_check $?

print_head "Copying frontend config file to nginx"
cp ${code_dir}/configs/ignix-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>{log_file}
status_check $?

print_head "Enable Nginx"
systemctl enable nginx &>>{log_file}
status_check $?

print_head "Start nginx"
systemctl start nginx &>>{log_file}
status_check $?