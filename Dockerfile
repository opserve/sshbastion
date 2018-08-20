FROM alpine
LABEL maintainer="Aleksey @soar Smyrnov http://soar.name"

ARG bastion_username
ENV bastion_username=${bastion_username:-jumper}

ARG bastion_homedir
ENV bastion_homedir=${bastion_homedir:-/home/${bastion_username}/}

RUN apk add --no-cache openssh \
 && adduser -D -s /sbin/nologin -h ${bastion_homedir} ${bastion_username} \
 && passwd -u ${bastion_username} \
 && mkdir -p /var/chroot/sbin \
 && cp /sbin/nologin /var/chroot/sbin/nologin

COPY ./rootfs/run.sh /

COPY rootfs /

COPY homefs ${bastion_homedir}/
RUN chown -R ${bastion_username}:${bastion_username} ${bastion_homedir} \
 && chmod -R u=rwX,og=rX ${bastion_homedir}/.ssh \
 && chmod u=rw,og=r ${bastion_homedir}/.ssh/authorized_keys || true

ONBUILD COPY homefs ${bastion_homedir}/
ONBUILD RUN chown -R ${bastion_username}:${bastion_username} ${bastion_homedir} \
         && chmod -R u=rwX,og=rX ${bastion_homedir}/.ssh \
         && chmod u=rw,og=r ${bastion_homedir}/.ssh/authorized_keys

ENTRYPOINT ["/run.sh"]
EXPOSE 10022/tcp
