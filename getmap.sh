#!/bin/sh

set -Ceuo pipefail

now=$(LANG=C date +%s)
reftime=$(expr \( $now / 3600 - 1 \) / 6 \* 6 \* 3600 )
set $(LANG=C TZ=UTC+0 date --date="@${reftime}" +"%Y %m %d %H")
yy=$1
mm=$2
dd=$3
hh=$4

pubdir=/nwp/p3
test -d $pubdir

cd $(dirname $0)
source venv/bin/activate

rm -f surface.png upper.png

bn=sfcplot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${bn}.png
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png}
ln -f ${png} surface.png
mv ${png} ${pubdir}

bn=p500plot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${bn}.png
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png}
ln -f ${png} upper.png
mv ${png} ${pubdir}

export XPOST_TITLE="${yy}${mm}${dd}T${hh}Z 地上・高層実況"
venv/bin/python3 post.py

find ${pubdir} -name '*.png' -ctime +7 -print0 | xargs -0 -n 100 rm -f
