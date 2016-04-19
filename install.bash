#!/usr/bin/env bash

SPEEDTEST_CLI_DIR="$(dirname $(which speedtest-cli))"
if [ "$SPEEDTEST_CLI_DIR" == "" ]
  then
    echo cannot find speedtest-cli in PATH
    return
fi
PYTHON_DIR=="$(dirname $(which python))"
if [ "$PYTHON_DIR" == "" ]
  then
    echo cannot find python in PATH
    return
fi

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

INSTALL_DIR=$SCRIPTPATH/cron_install
mkdir -p $INSTALL_DIR
LOG_DIR=$SCRIPTPATH/data
mkdir -p $LOG_DIR
CRONSCRIPT_FILENAME=$INSTALL_DIR/cronscript.bash
cronscript=$CRONSCRIPT_FILENAME
cat <<EOF > $cronscript
export PATH=\$PATH:$SPEEDTEST_CLI_DIR:$PYTHON_DIR
python $SCRIPTPATH/src/internet_speed_test_logger.py --log_dir="$LOG_DIR"
EOF
chmod u+x $cronscript

tmp=temp_crontab
trap "rm -f $tmp; exit 1" 0 1 2 3 13 15
SED_CMD="/.*"$(basename $CRONSCRIPT_FILENAME)"/d"
crontab -l | sed $SED_CMD > $tmp
echo "0 * * * * $cronscript" >> $tmp
crontab < $tmp
rm -f $tmp
trap 0

sudo apt-get update
sudo apt-get install apache2
if [ -f /var/www/index.html -a ! -L /var/www/index.html ] ; then
    sudo mv /var/www/index.html /var/www/old_index.html
fi
sudo rm -f /var/www/index.html
sudo ln -s $SCRIPTPATH/index.html /var/www/index.html
sudo rm -f /var/www/internet_speed_test_data.csv
sudo ln -s $SCRIPTPATH/data/internet_speed_test_data.csv /var/www/internet_speed_test_data.csv
sudo rm -f /var/www/plotly-2016-04-19.min.js
sudo ln -s $SCRIPTPATH/plotly-2016-04-19.min.js /var/www/plotly-2016-04-19.min.js

