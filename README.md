# terraform-aws-poc-ha

Terraform module that creates a pair of application server instances and a
HAProxy load balancer in AWS.

The setup should be taken as a proof of concept towards high availability
implementations.

The application servers run Apache and print their hostnames:

```
[centos@ip-10-14-0-11 ~]$ curl localhost
<html>
  <head>
    <title>ip-10-14-1-11.eu-central-1.compute.internal</title>
  </head>
  <body>
    <h2>ip-10-14-1-11.eu-central-1.compute.internal</h2>
  </body>
</html>
[centos@ip-10-14-0-11 ~]$ curl localhost
<html>
  <head>
    <title>ip-10-14-1-12.eu-central-1.compute.internal</title>
  </head>
  <body>
    <h2>ip-10-14-1-12.eu-central-1.compute.internal</h2>
  </body>
</html>
```
