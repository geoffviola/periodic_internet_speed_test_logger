tmp=temp_crontab
trap "rm -f $tmp; exit 1" 0 1 2 3 13 15
SED_CMD="/.*periodic_internet_speed_test/cronscript.*/d"
crontab -l | sed $SED_CMD > $tmp
crontab < $tmp
rm -f $tmp
trap 0

sudo rm -f /var/www/index.html
if [ -f /var/www/old_index.html ] ; then
    sudo mv /var/www/old_index.html /var/www/index.html
fi
sudo rm -f /var/www/internet_speed_test_data.csv
sudo rm -f /var/www/plotly-2016-04-19.min.js

