#!/bin/sh

set -Ceuo pipefail

now=$(LANG=C date +%s)
reftime=$(expr \( $now / 3600 - 1 \) / 6 \* 6 \* 3600 )
set $(LANG=C TZ=UTC+0 date --date="@${reftime}" +"%Y %m %d %H")
yy=$1
mm=$2
dd=$3
hh=$4

pubdir=/nwp/u3
test -d $pubdir

cd $(dirname $0)
source venv/bin/activate

rm -f surface.png upper.png

bn=sfcplot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${pubdir}/${bn}.png
rm -f ${png}
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png} > /dev/null
export SFC_FILE=$png

bn=p500plot${yy}-${mm}-${dd}T${hh}Z

url=https://toyoda-eizi.net/nwp/p2/${yy}-${mm}-${dd}T${hh}Z-plot/${bn}.html
png=${pubdir}/${bn}.png
rm -f ${png}
npx playwright screenshot --wait-for-timeout=3000 ${url} ${png} > /dev/null
export P500_FILE=$png

export XPOST_TITLE="${yy}${mm}${dd}T${hh}Z 地上・高層実況"
TWURL=$(venv/bin/python3 post.py)
mail -r news -s "xpostmap $XPOST_TITLE" news <<MAIL
posted - $TWURL
MAIL

find ${pubdir} -name '*.png' -ctime +7 -print0 | xargs -0 -n 100 rm -f
