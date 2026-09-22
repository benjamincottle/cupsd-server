FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

# Only what the Brother HL-2130 needs, using its "Brother HL-2030 Foomatic/hl1250"
# driver: foomatic-db-compressed-ppds has the PPD, cups-filters has foomatic-rip,
# and ghostscript has the hl1250 device. For another printer, add its driver
# package here.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      cups \
      cups-filters \
      foomatic-db-compressed-ppds \
      ghostscript \
 && rm -rf /var/lib/apt/lists/*

# The web admin login. lpadmin is CUPS's admin group (@SYSTEM in cupsd.conf).
# It has no password in the image: entrypoint.sh sets one on every start.
RUN useradd --no-create-home --groups lpadmin --shell /usr/sbin/nologin admin

COPY cupsd.conf /etc/cups/cupsd.conf

# A pristine copy of /etc/cups, which entrypoint.sh uses to fill in any files a
# mounted /etc/cups is missing.
RUN mkdir -p /usr/share/cupsd-server \
 && cp -a /etc/cups /usr/share/cupsd-server/etc-cups

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 631

# lpstat -r exits 0 even when the scheduler is down, so check what it prints.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["sh", "-c", "lpstat -r | grep -q 'scheduler is running'"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/sbin/cupsd", "-f"]
