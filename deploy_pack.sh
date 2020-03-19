#!/bin/bash

directory="plugins"
interactive=0
args=()
plugins=("plugin-vault" "plugin-realtime-scoring" "plugin-rmsd" "plugin-chemical-properties" "plugin-docking" "plugin-molecular-dynamics")
github_url="https://github.com/nanome-ai/"

usage() {
    cat <<EOM

$0 [options]

    -i or --interactive
        Start interactive mode

    -a <address> or --address <address>
        NTS address plugins connect to

    -p <port> or --port <port>
        NTS port plugins connect to

    -d <directory> or --directory <directory>
        Directory containing plugins

EOM
}

if [ $# -eq 0 ]; then
    interactive=1
fi

while [ $# -gt 0 ]; do
    case $1 in
        -i | --interactive )
            shift
            interactive=1
            break
            ;;
        -a | --address )
            shift
            args+=("-a" $1)
            ;;
        -p | --port )
            shift
            args+=("-p" $1)
            ;;
        -d | --directory )
            shift
            directory=$1
            ;;
        -h | --help )
            usage
            exit
            ;;
        * )
            usage
            exit 1
    esac
    shift
done

if [ $interactive == 1 ]; then
    args=()
    read -p "Plugin directory?  (plugins): " directory
    directory=${directory:-"plugins"}
    read -p "NTS address?     (127.0.0.1): " address
    address=${address:-"127.0.0.1"}
    args+=("-a" $address)
    read -p "NTS port?             (8888): " port
    if [ -n "$port" ]; then
        args+=("-p" $port)
    fi
fi

if [ ! -d "$directory" ]; then
    mkdir -p $directory
fi

mkdir -p logs
cd logs
ld=`pwd`
cd ..

cd $directory
for plugin in "${plugins[@]}"; do
    if [ ! -d "$plugin" ]; then
        echo "cloning $plugin..."
        git clone -q "$github_url$plugin"
    fi
done

for plugin in plugin-*; do (
    cd $plugin
    echo "pulling $plugin..."
    git pull -q
    cd docker
    echo "building $plugin..."
    ./build.sh 1>> "$ld/$plugin.log"
    echo "deploying $plugin..."
    ./deploy.sh "${args[@]}" 1>> "$ld/$plugin.log"
); done

echo "done"
echo "logs: $ld"
