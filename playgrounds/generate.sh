#!/usr/bin/env bash

gen_template()
{
    rm -v -rf $1/*
    cp -v -r .templates/$1/* $1/
    cat > $1/reset.sh << EOF
#!/usr/bin/env bash
cd ..
./generate.sh $1
EOF
    chmod +x $1/reset.sh
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

