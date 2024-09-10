#!/bin/bash
###### Test to see if a particular process is running using grep.  Returns 1 if yes, 0 if no.
###### If no process is specified, returns 0.

### This script is intended to gather and format the TARPN Node Metadata for the Copernicus mapping application.
### Don Rotolo N2IRZ
###
### Version History
### 10SEP2024  Initial Attempt
###


check_process() {
  #  echo "$ts: checking $1"
  [ "$1" = "" ]  && return 0
  [ `pgrep -nf $1` ] && return 1 || return 0
}

TEMP_PARSE_FILE3="/tmp/tarpn/metaget_parsing3.txt";
TEMP_PARSE_FILE2="/tmp/tarpn/metaget_parsing2.txt";
TEMP_PARSE_FILE="/tmp/tarpn/metaget_parsing.txt";
PORTCALLRELATEFILEPREFIX="/tmp/tarpn/portcallrelate"

# Gets Lat Lon from 'node.ini'
   grep --text -e "=TARPN" /usr/local/sbin/tarpn | cut -d= -f2 | head -n1
   echo -n "lat/lon coordinates: "
   grep --text latlon /home/pi/node.ini | cut -d: -f2

# Gets TARPN Updates URL from 'source_url.txt'
   echo -n "TARPN Updates URL:   "
   if [ -f /usr/local/sbin/source_url.txt ];
   then
       cat /usr/local/sbin/source_url.txt
   else
       echo "NONE FOUND!"
   fi


   grep --text "BACKGROUND:" /usr/local/etc/background.ini > $TEMP_PARSE_FILE2

# Gets Linux OS Uptime (time of day, uptime in days & hours/min, # of users, load averages) from OS
   echo -n  "Linux UPTIME:       "
   uptime

# Gets Node start time stamp from <somewhere>
   echo -ne "Node started:        "
   cat /usr/local/etc/node_start_time.txt

# Gets status of Node Background Service setting (Grep for ??)
   if grep --text -q ":ON" $TEMP_PARSE_FILE2; then
      echo "Node background Service is (AUTO)"
   else
      echo "Node background Service STOPPED"
   fi

# Gets when the Raspberry Pi was last reset (YYYY-MM-DD HH:MM:SS)
   echo -n "Raspberry PI Reset:  "
   uptime -s

# Shows Tarpn Home status (is running, is set to start)
   echo -n  "TARPN HOME:          "
   check_process "tarpn_home.pyc"
   if [ $? -ge 1 ]; then
      echo -n "is running             "
   else
      echo -n "is NOT running         "
   fi

   if grep --text -q "BACKGROUND:ON" /usr/local/etc/home.ini; then
      echo " TARPN HOME is set to START"
      check_process "tarpn_home.pyc"
      if [ $? -ge 1 ]; then                                ## check if BPQ node is running
          if grep --text -q ":ON" $TEMP_PARSE_FILE2; then         ## But is BPQ-node-service in background enabled?
             sleep 0                                       ## BPQ background is running
          else
             echo "Note: BPQ node background needs to be running for TARPN-HOME to start"
             echo "      Type      tarpn service start "
          fi
      fi
   else
      echo "TARPN HOME is not enabled."
   fi

   echo -n "TARPN-HOME build-utc:"
   TZ=utc ls -l /usr/local/sbin/home_web_app/about.html | cut -c27-39
   echo -n "TARPN-HOME install:  "
   cat /usr/local/sbin/home_web_app/dateinstalled.txt

   echo -ne "Rasberry PI Hardware:"
   cat /usr/local/etc/hardware.txt | cut -d\< -f1
   echo -n  "OS version:          "
   cat /etc/*-release | grep --text PRETTY | cut -b 14- | cut -d\" -f1
   echo -n "Ethernet MAC:        "
   if [ -f /sys/class/net/eth0/address ];
   then
      cat /sys/class/net/eth0/address > $TEMP_PARSE_FILE
   else
      cat /sys/class/net/en*/address > $TEMP_PARSE_FILE
   fi
   vcgencmd measure_temp >> $TEMP_PARSE_FILE
   sed ':a;N;$!ba;s/\n/   CPU /g' $TEMP_PARSE_FILE > $TEMP_PARSE_FILE2
   if [ -f /usr/local/sbin/tarpn_start1dl_starttime.txt ];
   then
      echo -n "@@@" >> $TEMP_PARSE_FILE2
      cat /usr/local/sbin/tarpn_start1dl_starttime.txt >> $TEMP_PARSE_FILE2
      sed ':a;N;$!ba;s/\n/ /g' $TEMP_PARSE_FILE2 > $TEMP_PARSE_FILE
      sed 's/@@@/  SDcard=/g' $TEMP_PARSE_FILE > $TEMP_PARSE_FILE2
      cat $TEMP_PARSE_FILE2
      rm -r $TEMP_PARSE_FILE
      rm -r $TEMP_PARSE_FILE2
   else
      cat $TEMP_PARSE_FILE2
      rm -r $TEMP_PARSE_FILE
      rm -r $TEMP_PARSE_FILE2
   fi
ls -l /usr/local/sbin/*.flag > $TEMP_PARSE_FILE3
   echo -n "TARPN Installed:     "
   grep --text tarpn_start1dl.flag $TEMP_PARSE_FILE3 | cut -b27-39
   echo -n "tarpn updateapps:    "
   if [ -f /usr/local/sbin/last_update_apps_start.flag ];
   then
       grep --text last_update_apps_start.flag $TEMP_PARSE_FILE3 | cut -b27-39
   else
       echo "NEVER"
   fi
   echo -n "tarpn update:        "
   if [ -f /usr/local/etc/update_last_completed.txt ];
   then
       cat /usr/local/etc/update_last_completed.txt
   else
       echo "NEVER"
   fi

   if [ -e $PORTCALLRELATEFILEPREFIX1.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX1.dat
      cat $PORTCALLRELATEFILEPREFIX1.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX2.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX2.dat
      cat $PORTCALLRELATEFILEPREFIX2.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX3.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX3.dat
      cat $PORTCALLRELATEFILEPREFIX3.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX4.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX4.dat
      cat $PORTCALLRELATEFILEPREFIX4.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX5.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX5.dat
      cat $PORTCALLRELATEFILEPREFIX5.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX6.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX6.dat
      cat $PORTCALLRELATEFILEPREFIX6.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX7.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX7.dat
      cat $PORTCALLRELATEFILEPREFIX7.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX8.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX8.dat
      cat $PORTCALLRELATEFILEPREFIX8.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX9.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX9.dat
      cat $PORTCALLRELATEFILEPREFIX9.dat
   fi
   if [ -e $PORTCALLRELATEFILEPREFIX10.dat ];
   then
      ls -l $PORTCALLRELATEFILEPREFIX10.dat
      cat $PORTCALLRELATEFILEPREFIX10.dat
   fi


   rm $TEMP_PARSE_FILE3
   echo
      ####  Date  Time Port AsnNghbr FWver  Board Switch  Baud Modu  FEC   TXD
      ####  06-10 00:14 p1  KA2DEW-3   3.01  A3    0001  >9600 GFSK  IL2P<  21
      ####  06-10 00:14 p2  KN4ORB-2   3.01  A3    0111  >1200 AFSK  IL2P<  120
      ####  06-10 00:14 p3  K4RGN-2    3.01  A3    0101  >2400 DAPSK IL2P<  120
      ####  06-10 00:14 p4  KM4EP-2    3.01  A4r1  0001  >9600 GFSK  IL2P<  20
      ####  06-10 00:14 p5  N3LTV-2    3.01  A3    0001  >9600 GFSK  IL2P<  16
   _number_of_tnc_lines=$(ls -l /tmp/tarpn/port_*status.dat | wc -l)
   ___one=1;
   if [ $_number_of_tnc_lines -gt $___one ];
   then
      echo "Date  Time Port AsnNghbr FWver  Board Switch  Baud Modu  FEC   TXD"
      cat /tmp/tarpn/port_*_ninotnc_status.dat
   else
      echo "TINFO would report the status of in-use NinoTNCs in this place but"
      echo "no NinoTNCs at this node have fully associated with a neighbor."
      echo "Come back in 15 minutes."
   fi
   echo
   echo -n "disk-size  used  avail  used-percent  = "
   df -h | head -2 | tail -1  | cut -b17-100
   echo -n "Undervoltage Events found in Log file = "
   grep --text -a Under-voltage /var/log/syslog | wc -l
   echo -n "My IP address is "
   #this is what I had in the nov2020test distribution from 2020 until April 14, 2021 ##  hostname -I | cut -d' ' -f1
   hostname -I
   echo -n "Router info:"
   ip r | grep --text default


echo " "
echo " "
echo " "
   sleep 2
