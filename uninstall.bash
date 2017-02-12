tmp=temp_crontab
trap "rm -f $tmp; exit 1" 0 1 2 3 13 15
SED_CMD='/periodic_internet_speed_test_logger/d'
crontab -l | sed $SED_CMD > $tmp
crontab < $tmp
rm -f $tmp
trap 0

WWW_PATH="/var/www/html"
if [ -L $WWW_PATH/index.html ] ; then
    sudo rm -f $WWW_PATH/index.html
fi
if [ -f $WWW_PATH/old_index.html ] ; then
    sudo mv $WWW_PATH/old_index.html $WWW_PATH/index.html
fi
sudo rm -f $WWW_PATH/internet_speed_test_data.csv
sudo rm -f $WWW_PATH/plotly-2017-02-12.min.js
