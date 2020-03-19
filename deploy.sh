#!/bin/bash

directory="plugins"
interactive=0
args=()
plugins=(
    "plugin-chemical-properties"
    "plugin-docking"
    "plugin-realtime-scoring"
    "plugin-rmsd"
    "plugin-structure-prep"
    "plugin-vault"
)
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

echo -e "Nanome Plugin Deployer"

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
    echo ""
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
logs=`(cd logs; pwd)`

cd $directory
for plugin in "${plugins[@]}"; do (
    echo -e "\n$plugin"
    if [ ! -d "$plugin" ]; then
        echo -n "  cloning... "
        git clone -q "$github_url$plugin"
        echo "done"
    fi

    cd $plugin
    echo -n "  pulling... "
    git pull -q
    echo "done"
    cd docker
    echo -n "  building... "
    ./build.sh -u 1>> "$logs/$plugin.log"
    echo "done"
    echo -n "  deploying... "
    ./deploy.sh "${args[@]}" 1>> "$logs/$plugin.log"
    echo "done"
); done

echo -e "\ndone"
