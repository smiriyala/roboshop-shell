code_dir=$(pwd)
log_file=/tmp/roboshop.log
rm -f $(log_file)

print_head(){
    echo -e "\e[35m${1}\e[0m"
}

status_check(){
    if [$1 -eq 0]; then
        echo SUCCESS
    else
        echo FAILURE
        echo "Read log file for more information - ${log_file}"
        exit 1
    fi
}

db_schema_setup(){
    if["${schema_type}" == "mongo"];then
        print_head "copy mongodb repo file"
        cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
        status_check $?


        print_head "Intall mongodb client"
        yum install mongodb-org-shell -y &>>${log_file}
        status_check $?

        print_head "Load schema of ${component} component"
        mongo --host mongodb-dev.devopsforyou.online </app/schema/${component}.js &>>${log_file}
        status_check $?
    elif["${schema_type}"=="mysql"];then
        
        print_head "Installing Mysql"
        yum install mysql -y &>>${log_file}
        status_check $?

        print_head "Load schema of ${component} component"
        mysql -h mysql-dev.devopsforyou.online -uroot -p${mysql_root_password} < /app/schema/${component}.sql &>>${log_file}
        status_check $?
    if
    
}

app_prereq_setup(){

    print_head "create roboshop ${component}"
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
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
    status_check $?
    cd /app 


    print_head "extracting app content"
    unzip /tmp/${component}.zip &>>${log_file}
    status_check $?
}

systemd_setup(){

    print_head "copy config service to systemD service"
    cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
    status_check $?

    #payment service need a password roboshop123, which is wrapping in systemd without status checking, 
    #hence other service wont impact due to ROBOSHOP_USER_PASSWORD keyword which is only exits in payment service
    sed -i -e "s/ROBOSHOP_USER_PASSWORD/${roboshop_app_password}/" /etc/systemd/system/${component}.service &>>${log_file}


    print_head "Reload SystemD"
    systemctl daemon-reload &>>${log_file}
    status_check $?

    print_head "enable ${component} service"
    systemctl enable ${component} &>>${log_file}
    status_check $?

    print_head "Restart ${component} service"
    systemctl restart ${component} &>>${log_file}
}

nodeJs(){

    print_head "Configure NodeJs Repo"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
    status_check $?

    print_head "Install Nodejs"
    yum install nodejs -y &>>${log_file}
    status_check $?

    app_prereq_setup

    print_head "install nodeJs Dependents"
    npm install &>>${log_file}
    status_check $?

    systemd_setup

    db_schema_setup
}

java_shipping(){

    print_head "Installing Maven"
    yum install maven -y &>>${log_file}
    status_check $?

    #prereq function
    app_prereq_setup

    print_head "Donwload Dependencies & Packages"
    mvn clean package &>>${log_file}
    mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
    status_check $?

    #setup schema function
    db_schema_setup

    #systemd setup function
    systemd_setup
}

python_payment(){

    print_head "Installing python"
    yum install python36 gcc python3-devel -y &>>${log_file}
    status_check $?

    #prereq function
    app_prereq_setup

    print_head "Donwload Dependencies & Packages"
    pip3.6 install -r requirements.txt &>>${log_file}
    status_check $?

    #systemd setup function
    systemd_setup
}

golang_dispatch(){

    print_head "Installing golang"
    yum install golang -y &>>${log_file}
    status_check $?

    #prereq function
    app_prereq_setup

    print_head "Donwload Dependencies & Packages"
    go mod init dispatch &>>${log_file}
    go get &>>${log_file}
    go build &>>${log_file}
    status_check $?

    #systemd setup function
    systemd_setup
}