#! /bin/bash


function clone_app_repository() {
    printf "***************************************************\n\t\tFetching App \n***************************************************\n"
    # Clone and access project directory
    echo ======== Cloning and accessing project directory ========
    if [[ -d /opt/subscription-api ]]; then
        sudo rm -rf /opt/subscription-api
        git clone -b dev https://github.com/vivek22117/rsvp-subscription-api.git /opt/subscription-api
        cd /opt/subscription-api/backend/
    else
        git clone -b dev https://github.com/vivek22117/rsvp-subscription-api.git /subscription-api
        cd /opt/subscription-api/backend/
    fi
}


function setup_app() {
    printf "***************************************************\nInstalling App dependencies and Env Variables \n***************************************************\n"
    setup_env
    # Install required packages
    echo ======= Installing required packages ========
    pip3 install -r requirements.txt

}

# Create and Export required environment variable
function setup_env() {
    printf "***************************************************\n\t\tSetting up Venv \n***************************************************\n"
    # Install virtualenv
    echo ======= Installing virtualenv =======
    pip3 install virtualenv

    # Create virtual environment and activate it
    echo ======== Creating and activating virtual env =======
    virtualenv venv
    source ./venv/bin/activate


    echo ======= Exporting the necessary environment variables ========
    sudo cat > ~/.env << EOF
    export APP_CONFIG="production"
    export FLASK_APP=run.py
    export IS_RUNNING_LOCAL="true"
EOF
    echo ======= Exporting the necessary environment variables ========
    source ~/.env
}

# Add a launch script
function create_launch_script () {
    printf "***************************************************\n\t\tCreating a Launch script \n***************************************************\n"

    sudo cat > /home/ec2-user/launch.sh <<EOF
    #!/bin/bash
    cd /opt/subscription-api/backend/
    source ~/.env
    source ./venv/bin/activate
    python3 run.py > api_log.txt 2>&1 &
EOF
    sudo chmod 744 /home/ec2-user/launch.sh
    echo ====== Ensuring script is executable =======
    ls -la /home/ec2-user/launch.sh
}

function configure_startup_service () {
    printf "***************************************************\n\t\tConfiguring startup service \n***************************************************\n"

    sudo bash -c 'cat > /etc/systemd/system/flask-rest.service <<EOF
    [Unit]
    Description=flask-rest startup service
    After=network.target

    [Service]
    User=ec2-user
    ExecStart=/bin/bash /home/ec2-user/launch.sh

    [Install]
    WantedBy=multi-user.target
EOF'

    sudo chmod 664 /etc/systemd/system/flask-rest.service
    sudo systemctl daemon-reload
    sudo systemctl enable flask-rest.service
    sudo systemctl start flask-rest.service
    sudo systemctl status flask-rest
}

# Serve the web app through gunicorn
function launch_app() {
    printf "***************************************************\n\t\tServing the App \n***************************************************\n"
    sudo bash /home/ec2-user/launch.sh
}

######################################################################
########################      RUNTIME       ##########################
######################################################################

clone_app_repository
install_ssl_cert
setup_app
create_launch_script
configure_startup_service
launch_app