#!/bin/bash

count=1
for dir in */
do
    build_dir=$dir
    if [ $count == 1 ]
    then
        build_dir="../"$dir
    fi

    cd $build_dir
    ./build.sh
    let count=$count+1
done