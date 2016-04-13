#!/usr/bin/env python

import time
import os.path
import sys

text = os.popen("speedtest-cli --simple").read()[:-1]
with open("sample.txt", "w") as my_file:
    my_file.write(text)
lines = text.split("\n")
data = [time.strftime("%c")]
for line in lines:
    split_line = line.split(" ")
    data.append(split_line[1])

def write_data(file_handle, data):
    file_handle.write(data[0] + ", " + data[1] + ", " + data[2] + ", " + data[3] + "\n")

filename = "speed_test_data.csv"
if (not os.path.isfile(filename)):
    with open(filename, "w") as my_file:
        my_file.write("Date And Time, Ping (ms), Download (Mbit/s), Upload (Mbit/s)\n")
        write_data(my_file, data)
else:
    with open(filename, "a") as my_file:
        write_data(my_file, data)

