#!/bin/sh
# Prepares the container, then runs the CMD (cupsd in the foreground).
set -eu

# Fill in any CUPS config files that a mounted /etc/cups is missing, such as
# an empty directory on first run. Existing files are never overwritten, so a
# mounted cupsd.conf, printers.conf and PPDs are left exactly as they are.
cp -a --update=none /usr/share/cupsd-server/etc-cups/. /etc/cups/

# The web admin login is the "admin" user. Its password comes from the
# CUPS_ADMIN_PASSWORD environment variable and is set on every start, so it's
# never baked into the image.
if [ -z "${CUPS_ADMIN_PASSWORD:-}" ]; then
  echo "entrypoint: CUPS_ADMIN_PASSWORD is not set" >&2
  exit 1
fi
printf 'admin:%s\n' "$CUPS_ADMIN_PASSWORD" | chpasswd

# Keep the password out of the environment that cupsd and its filters inherit.
unset CUPS_ADMIN_PASSWORD

exec "$@"
