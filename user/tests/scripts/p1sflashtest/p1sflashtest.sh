#!/bin/bash

# P1 external 1MB sFlash test
#
# 4KB quick test
# ./p1flashtest quick
#
# 1MB - 1 byte long test
# ./p1flashtest

QUICK_OPTION=$1

# puts device in dfu mode
dfu()
{
  local d=`dfu-util -l | grep d00`;
  if [ -z "$d" ]; then
    local x=`compgen -f -- "/dev/tty.usbmodem"`;
    if [ -z "$x" ]; then
      echo "No USB device found";
    else
      eval $(stty -f $x 14400);
    fi
  else
    echo "already in DFU mode!";
  fi
}

# kicks device out of dfu mode, no matter which device it is (except for Core,
# this can be easily modified later if desired. Grep for Core VID and use 0x08020000.
# Any -d x:y seems to work)
dfuq()
{
	dfu-util -d 2b04:d008 -a 0 -s 0x080A0000:leave -D /dev/null
}

pass() {
  echo "8888888b.     d8888  .d8888b.   .d8888b."
  echo "888   Y88b   d88888 d88P  Y88b d88P  Y88b"
  echo "888    888  d88P888 Y88b.      Y88b."
  echo "888   d88P d88P 888  \"Y888b.    \"Y888b."
  echo "8888888P\" d88P  888     \"Y88b.     \"Y88b."
  echo "888      d88P   888       \"888       \"888"
  echo "888     d8888888888 Y88b  d88P Y88b  d88P"
  echo "888    d88P     888  \"Y8888P\"   \"Y8888P\""
}
fail() {
  echo "8888888888     d8888 8888888 888      888"
  echo "888           d88888   888   888      888"
  echo "888          d88P888   888   888      888"
  echo "8888888     d88P 888   888   888      888"
  echo "888        d88P  888   888   888      888"
  echo "888       d88P   888   888   888      Y8P"
  echo "888      d8888888888   888   888       \" "
  echo "888     d88P     888 8888888 88888888 888"
}

main()
{
	if [[ "$QUICK_OPTION" == "quick" ]]; then
		size=4096;
	else
		size=1048575;
	fi
	cd /Users/brett/Downloads/binaries
	dfu
	sleep 1
	rm random1mb*
	dd if=/dev/urandom of=random1mb1.bin count=$size bs=1
	dfu-util -d 2b04:d008 -a 2 -s 1:$size -D random1mb1.bin
	sleep 1
	dfu-util -d 2b04:d008 -a 2 -s 1:$size -U random1mb2.bin
	diff random1mb1.bin random1mb2.bin > compare1 2>&1
	value1=$(<compare1)
	#echo "$value1"
	if [ "$value1" == "" ]; then
		pass
	else
		fail
	fi
	dfuq
}

main