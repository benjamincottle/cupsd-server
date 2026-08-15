FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cups \
      cups-bsd \
      cups-filters \
      printer-driver-all \
      avahi-daemon \
      dbus \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -G lp,lpadmin -s /bin/bash admin \
 && echo 'admin:admin' | chpasswd \
 && cupsctl --remote-admin --remote-any --share-printers || true \
 && echo 'ServerAlias *' >> /etc/cups/cupsd.conf

EXPOSE 631

CMD ["/usr/sbin/cupsd", "-f"]

