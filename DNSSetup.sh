#!/bin/bash

apk update
apk add bind
rc-update add named default

cat << EOF > /etc/bind/named.conf
options {
        directory "/var/bind";

        allow-recursion {
                127.0.0.1/32;
                192.168.40.0/24;
        };

        forwarders {
                1.1.1.1;
                8.8.8.8;
        };

        listen-on { 127.0.0.1; 192.168.40.2; };
        listen-on-v6 { none; };

        pid-file "/var/run/named/named.pid";

        allow-transfer { none; };

        dnssec-validation auto;
        recursion yes;
        dump-file "/var/cache/bind/named_dump.db";
};
EOF

rc-service named start
