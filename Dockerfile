FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y nginx libnginx-mod-http-auth-pam fcgiwrap spawn-fcgi krb5-kdc krb5-admin-server libpam-krb5

RUN echo "[libdefaults]\n    default_realm = FPTU.LOCAL\n\n[realms]\n    FPTU.LOCAL = {\n        kdc = localhost\n        admin_server = localhost\n    }" > /etc/krb5.conf

RUN echo "auth sufficient pam_krb5.so use_first_pass\naccount sufficient pam_krb5.so" > /etc/pam.d/nginx-krb5

RUN echo '#!/bin/bash\n\
printf "123456\\n123456\\n" | kdb5_util create -s\n\
krb5kdc && kadmind\n\
kadmin.local -q "addprinc -pw 123 testuser"\n\
spawn-fcgi -s /var/run/fcgiwrap.socket -f /usr/sbin/fcgiwrap\n\
chmod 777 /var/run/fcgiwrap.socket\n\
nginx -g "daemon off;"' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
