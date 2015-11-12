# Cider-CI Integration-Tests

Part of [Cider-CI](https://github.com/cider-ci/cider-ci).

Reverse Proxy
-------------

### Debian Ubuntu

Install _Apache2_ and _X-Sendfile_ from the system repositories.

Copy `cider-ci/templates/httpd.conf` to `reverse-proxy/conf/httpd.conf` and set
the templated values.

    LD_LIBRARY_PATH=/usr/lib/apache2/modules/ /usr/sbin/apache2 -d reverse-proxy/ -f conf/httpd.conf -e info -DFOREGROUND


### Mac OS

Install `Apache2` via MacPorts and compile and install X-Sendfile according to
<https://tn123.org/mod_xsendfile/>.

Link or copy (if you need to adjust values) to `reverse-proxy/conf/httpd.conf`
from `reverse-proxy/conf/httpd_example.conf`.

    LD_LIBRARY_PATH=/opt/local/apache2/modules/ /opt/local/apache2/bin/apachectl -d reverse-proxy -e info -DFOREGROUND

### General

We have seen issues of randomly terminating reverse proxies. Those can be
bypassed by starting the proxy within an infinite loop:

    while true; do LD_LIBRARY_PATH=/opt/local/apache2/modules/ /opt/local/apache2/bin/apachectl -d reverse-proxy -e info -DFOREGROUND; done


## Copyright and License

Copyright (C) 2015 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
Public licensed yet to be determined.
