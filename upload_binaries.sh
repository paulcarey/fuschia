#!/bin/bash

set -u

DB_NAME=$1

DESIGN_DOC=localhost:5984/${DB_NAME}/_design%2Ffuschia

JS='Content-Type:application/x-javascript'
HTML='Content-Type:text/html'
SWF='Content-Type:application/x-shockwave-flash'
CSS='Content-Type:text/css'

RES=`curl -s $DESIGN_DOC | grep not_found`
if [ $? != 0 ]; then
  echo "${DESIGN_DOC} exists!"
  echo It must be deleted before running this script
  exit 1
fi

REV=`curl -s -T bin/fuschia_queries.json $DESIGN_DOC | egrep -o '[0-9]+'`
REV=`curl -s -H $JS -T bin/AC_OETags.js ${DESIGN_DOC}/AC_OETags.js?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $HTML -T bin/Fuschia.html ${DESIGN_DOC}/Fuschia.html?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $SWF -T bin/Fuschia.swf ${DESIGN_DOC}/Fuschia.swf?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $CSS -T bin/history/history.css ${DESIGN_DOC}/history/history.css?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $JS -T bin/history/history.js ${DESIGN_DOC}/history/history.js?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $HTML -T bin/history/historyFrame.html ${DESIGN_DOC}/history/historyFrame.html?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $SWF -T bin/playerProductInstall.swf ${DESIGN_DOC}/playerProductInstall.swf?rev=${REV} | egrep -o '[0-9]+'`
