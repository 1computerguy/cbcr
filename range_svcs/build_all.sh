#!/bin/bash

count=1
for dir in */
do
    build_dir=$dir
    if [ $count -ne 1 ]
    then
        build_dir="../"$dir
    fi

    cd $build_dir
    ./build_all.sh
    let count=$count+1
done