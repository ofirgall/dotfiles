#!/usr/bin/env bash

gen_template()
{
    rm -v -rf $1
    cp -v -r .templates/$1 $1
}

gen_all()
{
    for template in $(ls .templates); do
        gen_template $template
    done
}

if [ $# -eq 0 ]; then
    gen_all
else
    gen_template $1
fi

