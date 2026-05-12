#!/bin/sh

set -Ceuo pipefail

now=$(LANG=C date +%s)
reftime=$(expr \( $now / 3600 - 1 \) / 6 \* 6 \* 3600 )
set $(LANG=C TZ=UTC+0 date --date="@${reftime}" +"%Y %m %d %H")
yy=$1
mm=$2
dd=$3
hh=$4

cd $(dirname $0)
source venv/bin/activate

rm -f surface.png upper.png

bn=sfcplot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${bn}.png
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png}
ln -f ${png} surface.png
mv ${png} /var/www/html/2026

bn=p500plot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${bn}.png
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png}
ln -f ${png} upper.png
mv ${png} /var/www/html/2026

export XPOST_TITLE="${yy}${mm}${dd}T${hh}Z 地上・高層実況"
venv/bin/python3 post.py
