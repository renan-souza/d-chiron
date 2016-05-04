#!/usr/bin/python

import sys, time
from subprocess import call
while 1:
	line = sys.stdin.readline()
	if not line:
		break
	
	#print("printing in python", line.rstrip())
	if len(line.split(",")) > 6:
		time.sleep(int(line.split(",")[5].rstrip())/1000.0)
	#print cmd
