#!/bin/bash
set -eux
SCRIPTDIR=$(cd $(dirname $0) && pwd)

# 変数を定義する
myipaddress=$(curl -s ifconfig.me)
usersList=$SCRIPTDIR/userslist # ユーザーリスト

cd ./users

for u in `cat $usersList`; do
    echo create $u resources ...

    # create user folder
    \cp -pr ./template ./${u}

    cd ./${u}

    # ユーザーごとのディレクトリにログを出力する
    touch terraform.log
    tail -f terraform.log &
    exec 3>&1 4>&2
    exec 1>>terraform.log 2>&1

    ls

    # create plan file
    terraform init
    # 制御コードを出力しないために -no-color を付ける
    terraform plan -no-color -out=tfplan -var "resource_group_name=${u}-rg" -var "myipaddress=${myipaddress}"

    # デプロイ開始
    terraform apply -no-color tfplan

    # get info from tf output
    acrName=$(terraform output -raw acr_name)
    aksName=$(terraform output -raw aks_name)

    # connect to aks
    az aks get-credentials --resource-group "${u}-rg" --name ${aksName} --overwrite-existing

    # create scenarios namespace
    kubectl apply -f ../../yamls/namespaces.yaml

    # build image to acr with Dockerfile
    count=0
    until (az acr build --image sample/demoimage --registry "${acrName}.azurecr.io" --file ../../../app/Dockerfile ../../../app) || [ $count -eq 3 ] ; do
        sleep 5
        count=$((++count))
    done

    # build image for scenario02
    count=0
    until (az acr build --image sample/s02image --registry "${acrName}.azurecr.io" --file ../../../scenario02/Dockerfiles/Dockerfile_s02 ../../../app) || [ $count -eq 3 ] ; do
        sleep 5
        count=$((++count))
    done

    exec 1>&3 2>&4

    cd ..
done

# バックグラウンドジョブの tail を終了させる
kill $(jobs -p)
