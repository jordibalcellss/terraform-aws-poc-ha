#!/bin/bash
yum install haproxy -q -y
cat << EOF > /etc/haproxy/haproxy.cfg
global
  log 127.0.0.1 local2
  chroot /var/lib/haproxy
  pidfile /var/run/haproxy.pid
  maxconn 4000
  user haproxy
  group haproxy
  daemon

defaults
  mode http
  log global
  option httplog
  option dontlognull
  option http-server-close
  option forwardfor except 127.0.0.0/8
  option redispatch
  retries 3
  timeout http-request 10s
  timeout queue 1m
  timeout connect 10s
  timeout client 1m
  timeout server 1m
  timeout http-keep-alive 10s
  timeout check 10s
  maxconn 3000

frontend haproxy_in
  bind *:80
  default_backend haproxy_in

backend haproxy_in
  mode http
  balance roundrobin
  server app-server-1 10.14.1.11:80 check
  server app-server-2 10.14.1.12:80 check
EOF
systemctl enable haproxy -q
systemctl start haproxy
