#!/bin/bash
#run me as root. you trust me don't you?
installfolder="/opt/gnucash/share/gnucash/guile-modules/gnucash/report"
if [ -f $installfolder/balance-linechart.scm ]
 then
 	echo "ruthlessly removing old report"
	rm $installfolder/balance-linechart.scm
fi
if [ -f $installfolder/balance-projection-linechart.scm ]
 then
 	echo "ruthlessly removing old projection report"
	rm $installfolder/balance-projection-linechart.scm
fi
echo "linking to reports"
ln -s $(pwd)/balance-linechart.scm $installfolder/balance-linechart.scm
ln -s $(pwd)/balance-projection-linechart.scm $installfolder/balance-projection-linechart.scm
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
