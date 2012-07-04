# The script is used for delete job which out of time.
# @author doxie@ebay.com   
# @version 1.0

#!bin/bash

RETEN=2592000 

DATE=`date +%F`

EDATE=`date +%s`

touch /var/tmp/${DATE}_deletedjobs.txt

chmod 777 /var/tmp/${DATE}_deletedjobs.txt

grep disabled /var/lib/jenkins/jobs/*/config.xml | \

sed -e 's|/var/lib/jenkins/jobs/||g' | \

awk -F/ '{print $1}' | \

grep -i ^TC | \

grep -i -E "main$|caboose$" | \

grep -v -i Template > /var/tmp/${DATE}_deletedjobs.txt

DISABLED=`cat /var/tmp/${DATE}_deletedjobs.txt`

for JOB in ${DISABLED}

do

LASTBLD=`stat -c %Y /var/lib/jenkins/jobs/${JOB}/builds`

let LASTBLD+=${RETEN}

if [ ${LASTBLD} -lt ${EDATE} ]

then

/usr/bin/wget -q -o /dev/null --auth-no-challenge --http-user=admin --http-password=admin --post-data='' http://`hostname`:8080/job/${JOB}/doDelete

fi

done

rm -f /var/tmp/${DATE}_deletedjobs.txt
