#!/bin/bash
#run me as root. you trust me don't you?
installfolder="/opt/gnucash/share/gnucash/guile-modules/gnucash/report"
echo "removing reports"
rm $installfolder/balance-linechart.scm
rm $installfolder/balance-projection-linechart.scm
echo "restoring standard report list from backup"
cp $installfolder/standard-reports.scm.orig $installfolder/standard-reports.scm
echo "removing standard report list backup"
rm $installfolder/standard-reports.scm.orig
echo "done"

