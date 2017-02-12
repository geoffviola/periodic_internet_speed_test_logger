#!/usr/bin/env bash

if [ "$(which speedtest-cli)" == "" ]
  then
    echo "\
Cannot find speedtest-cli in PATH.
Try sudo apt install speedtest-cli"
    exit 1
fi
if [ "$(which python3)" == "" ]
  then
    echo "\
Cannot find python3 in PATH.
The min version is 3.5.
Try sudo apt install python3"
    exit 1
fi
PYTHON3_MINOR_VER=$(python3 --version | cut -d " " -f 2 | cut -d "." -f 2)
if [ "$PYTHON3_MINOR_VER" -lt "5" ]
  then
    echo "\
The minimum version of python allowed is 3.5
Try
  https://github.com/python/cpython.git
  cd cpython
  ./configure
  make
  sudo apt-get install libffi-dev
  sudo make install
  sudo unlink /usr/bin/python3
  sudo ln -s /usr/local/bin/python3.7 /usr/bin/python3"
    exit 1
fi
if [ "$(which apache2)" == "" ]
  then
    echo "\
Cannot find apach2 in PATH.
Try sudo apt install apache2"
    exit 1
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
#!/usr/bin/env bash

SPEEDTEST_CLI_DIR="$(dirname $(which speedtest-cli))"
PYTHON_DIR=="$(dirname $(which python3))"
export PATH=\$PATH:$SPEEDTEST_CLI_DIR:$PYTHON_DIR
$SCRIPTPATH/src/internet_speed_test_logger.py --log_dir="$LOG_DIR"
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

WWW_PATH="/var/www/html"
if [ -f $WWW_PATH/index.html -a ! -L $WWW_PATH/index.html ] ; then
    sudo mv $WWW_PATH/index.html $WWW_PATH/old_index.html
fi
sudo rm -f $WWW_PATH/index.html
sudo ln -s $SCRIPTPATH/index.html $WWW_PATH/index.html
sudo rm -f $WWW_PATH/internet_speed_test_data.csv
sudo ln -s $SCRIPTPATH/data/internet_speed_test_data.csv $WWW_PATH/internet_speed_test_data.csv
sudo rm -f $WWW_PATH/plotly-2017-02-12.min.js
sudo ln -s $SCRIPTPATH/plotly-2017-02-12.min.js $WWW_PATH/plotly-2017-02-12.min.js

