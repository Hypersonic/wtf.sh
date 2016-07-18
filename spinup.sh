#!/usr/bin/env bash

cp -R /opt/wtf.sh /tmp/wtf_runtime;
chown -R www /tmp/wtf_runtime
su www -c "/tmp/wtf_runtime/wtf.sh/wtf.sh 8080";
