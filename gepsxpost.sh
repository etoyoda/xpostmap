#!/bin/sh

set -Ceuo pipefail

now=$(LANG=C date +%s)
reftime=$(expr \( $now / 3600 - 6 \) / 12 \* 12 \* 3600 )
set $(LANG=C TZ=UTC+0 date --date="@${reftime}" +"%Y %m %d %H")
yy=$1
mm=$2
dd=$3
hh=$4

pubdir=/nwp/u3
test -d $pubdir

cd $(dirname $0)
source venv/bin/activate

bn=tytrack${yy}-${mm}-${dd}T${hh}Z

url=https://www.jma.go.jp/bosai/numericmap/data/nwpmap/GEPS_tytrack.pdf
png=${pubdir}/${bn}.png
rm -f ${png}
wget -q -O${png}.pdf "${url}"
set $(md5sum ${png}.pdf)
cursum=$1
prevsum=dummy
if [ -f ${pubdir}/tytrack.md5 ]; then
  read prevsum < ${pubdir}/tytrack.md5
fi
if [[ "$cursum" = "$prevsum" ]]; then
  : md5 unchanged - skip this time
  exit 0
else
  echo $cursum > ${pubdir}/tytrack.md5
fi
convert -density 300 ${png}.pdf ${png}
rm -f ${png}.pdf
export P500_FILE=$png

bn=tyfcst${yy}-${mm}-${dd}T${hh}Z

url='https://www.jma.go.jp/bosai/map.html#contents=typhoon&typhoon=all'
png=${pubdir}/${bn}.png
rm -f ${png}
npx playwright screenshot --wait-for-timeout=3000 "${url}" ${png} > /dev/null
export SFC_FILE=$png

export XPOST_TITLE="${yy}${mm}${dd}T${hh}Z typhoon"
TWURL=$(venv/bin/python3 post.py)
mail -r news -s "xpostmap $XPOST_TITLE" news <<MAIL
posted - $TWURL
MAIL

