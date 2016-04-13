tmp=temp_crontab
trap "rm -f $tmp; exit 1" 0 1 2 3 13 15
SED_CMD="/.*periodic_internet_speed_test/cronscript.*/d"
crontab -l | sed $SED_CMD > $tmp
crontab < $tmp
rm -f $tmp
trap 0
