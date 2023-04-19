echo -e "\e[35mInstalling Nginx\e[0m"
yum install nginx -y 

echo -e "\e[35mRemoving Default Nginx html content\e[0m"
rm -rf /usr/share/nginx/html/*

echo -e "\e[35mDownloading frontend package\e[0m"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip 

echo -e "\e[35mExtracting frontend package\e[0m"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip

echo -e "\e[35mEnable Nginx\e[0m"
systemctl enable nginx 
echo -e "\e[35mStart nginx\e[0m"
systemctl start nginx