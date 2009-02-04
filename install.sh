#!/bin/bash
#run me as root. you trust me don't you?
installfolder="/opt/gnucash/share/gnucash/guile-modules/gnucash/report"
if [ -f $installfolder/balance-linechart.scm ]
 then
 	echo "ruthlessly removing old report"
	rm $installfolder/balance-linechart.scm
fi
echo "linking to report"
ln -s $(pwd)/balance-linechart.scm $installfolder/balance-linechart.scm
#check if already patched
match="$(grep balance-linechart $installfolder/standard-reports.scm | wc -l)"
if [ $match -eq 0 ]
	then
		cp $installfolder/standard-reports.scm $installfolder/standard-reports.scm.orig
		patch $installfolder/standard-reports.scm standard-reports.scm.patch
else
	echo "standard report list already patched"
fi
echo "done"
