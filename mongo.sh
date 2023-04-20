echo -e "\e[35mMongoDB repo file copying\e[0m"
cp configs/mongodb.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[35mMongoDB installation started\e[0m"
yum install mongodb-org -y 
systemctl enable mongod 
systemctl start mongod 
systemctl restart mongod