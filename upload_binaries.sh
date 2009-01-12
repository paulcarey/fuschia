#!/bin/bash

DB_NAME=your_db_name

DESIGN_DOC=localhost:5984/${DB_NAME}/_design%2Ffuschia

JS='Content-Type:application/x-javascript'
HTML='Content-Type:text/html'
SWF='Content-Type:application/x-shockwave-flash'
CSS='Content-Type:text/css'

# Will intentionally fail if a design doc named fuschia already exists
REV=`curl -s -T bin/fuschia_queries.json $DESIGN_DOC | egrep -o '[0-9]+'`
REV=`curl -s -H $JS -T bin/AC_OETags.js ${DESIGN_DOC}/AC_OETags.js?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $HTML -T bin/Fuschia.html ${DESIGN_DOC}/Fuschia.html?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $SWF -T bin/Fuschia.swf ${DESIGN_DOC}/Fuschia.swf?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $CSS -T bin/history/history.css ${DESIGN_DOC}/history/history.css?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $JS -T bin/history/history.js ${DESIGN_DOC}/history/history.js?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $HTML -T bin/history/historyFrame.html ${DESIGN_DOC}/history/historyFrame.html?rev=${REV} | egrep -o '[0-9]+'`
REV=`curl -s -H $SWF -T bin/playerProductInstall.swf ${DESIGN_DOC}/playerProductInstall.swf?rev=${REV} | egrep -o '[0-9]+'`
