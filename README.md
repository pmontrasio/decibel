# Beacon

nvm use v5.7.0
iex -S mix phoenix.server
KV.Registry.create(KV.Registry, "channels")
KV.Registry.create(KV.Registry, "addresses")
{:ok, _} = Arp.Table.start_link()
{:ok, ma} = MacAddress.start_link(self())
Decibel.display

From another device:

http://192.168.1.xxx:4000

# To gain some extra memory on the Raspberry

Disable/enable the desktop
http://ask.xmodulo.com/disable-desktop-gui-raspberry-pi.html

    sudo raspi-config

Use the arrows to move to 3. Boot options. Press ENTER.
Select the option and use TAB to move to OK. Then ENTER.
The TAB to Finish, press ENTER.

# WiFi adapters with monitor mode

The internal WiFi adapter of the Raspberry Pi 3 doesn't have monitor mode.

https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=49432

These work with Kali Linux, but they are not certified to work with the Raspberry
http://www.wirelesshack.org/top-kali-linux-compatible-usb-adapters-dongles-2015.html

The good chips apparently are

* Atheros AR9271
* Ralink RT3070
* Ralink RT3572
* Realtek 8187L (Wireless G adapters)

https://github.com/raspberrypi/linux/issues/369
It seems that the driver for the rtl8192cu works now.

# Setup monitor mode

    sudo apt-get install tshark

We add a virtual card to wlan0 and set it to monitor mode

    sudo iw dev wlan0 interface add mon0 type monitor
    iw dev

The output should be something like this

    phy#0
    	Interface mon0
    		ifindex 12
    		type monitor  <--- the new mon0 is in monitor mode
    	Interface wlan0
    		ifindex 3
    		type managed  <---- the original wlan 0 is still managed

    sudo iw mon0 info
    sudo ifconfig mon0 up
    sudo tshark -i mon0 -f 'broadcast' -T fields -e frame.time_epoch -e wlan.sa \
       -e radiotap.dbm_antsignal -e wlan.fc.type -e wlan.fc.subtype
    sudo ifconfig mon0 down
    sudo iw dev mon0 del

Interesting fields:

* radiotap.db_antsignal
* radiotap.db_txattenuation
* radiotap.dbm_antnoise
* radiotap.dbm_antsignal # sullo zbook è l'unico valorizzato
* radiotap.txattenuation
* radiotap.txpower

Notice that tshark in Raspbian is old

    $ tshark -v
    TShark 1.6.7

It should be enough though.

    wifi on
    sudo iw dev wlan0 interface add mon0 type monitor
    sudo ifconfig mon0 up
    sudo tshark -i mon0 -f 'broadcast' -T fields -e frame.time_epoch -e wlan.sa  \
       -e radiotap.dbm_antsignal 2> /dev/null | ./bin/average.rb
    sudo ifconfig mon0 down
    sudo iw dev mon0 del
    wifi off


    cat test/2-secs | ruby/average.rb | sort

    wifi on
    sudo tshark -i mon0 -f 'broadcast' -T fields  -e frame.time_epoch -e wlan.sa \
       -e radiotap.dbm_antsignal 2> /dev/null | ruby/average.rb
    wifi off

## References

https://www.wireshark.org/docs/dfref/
http://www.radiotap.org/defined-fields/all

http://blog.onfido.com/using-cpus-elixir-on-raspberry-pi2/
https://github.com/elixir-lang/elixir/releases/


https://en.wikipedia.org/wiki/Monitor_mode

Monitor mode is one of the seven modes that 802.11 wireless cards can operate in: Master (acting as an access point), Managed (client, also known as station), Ad hoc, Mesh, Repeater, Promiscuous, and Monitor mode.

You can use it to listen to all packets but you're not connected to an access point so you can't decrypt them.

https://en.wikipedia.org/wiki/Promiscuous_mode

You connect to an access point then you can do packet sniffing. Getting somebody else's packets exposes to the attacks directed to that other guy.

http://www.radio-electronics.com/info/wireless/wi-fi/80211-channels-number-frequencies-bandwidth.php



# TODO

1) Implement channel hopping, to detect packets on all channels.

    sudo ifconfig wlan1 down
    sudo iwconfig wlan1 mode Monitor
    sudo ifconfig wlan1 up
    sudo iwconfig wlan1 channel 1 # It doesn't work all the times
    iwlist wlan1 channel | grep "Current Frequency"
    sudo iwconfig wlan1 channel 2 # Starting with 2 always works.
    iwlist wlan1 channel | grep "Current Frequency"
    sudo iwconfig wlan1 channel 3
    iwlist wlan1 channel | grep "Current Frequency"

    sudo iwconfig wlan1 channel 8; iwlist wlan1 channel | grep "Current Frequency"
    sudo tshark -i wlan1 -f 'broadcast' -T fields -e frame.time_epoch -e wlan.sa  \
       -e radiotap.dbm_antsignal 2> /dev/null| ruby average.rb 30

Add -e radiotap.channel.freq if you feel like

    sudo tshark -i wlan1 -f 'broadcast' -T fields -e frame.time_epoch -e wlan.sa \
       -e radiotap.dbm_antsignal 2> /dev/null

    sudo tshark -i wlan1 -f 'broadcast' -T fields -e radiotap.channel.freq \
       -e frame.time_epoch -e wlan.sa  -e radiotap.dbm_antsignal 2> /dev/null

    sudo ifconfig wlan1 down
    sudo iwconfig wlan1 mode Managed
    sudo ifconfig wlan1 up

You don't need to kill the wpa_supplicant process, but if you have to here's how to do it

    sudo kill $(cat /run/wpa_supplicant.wlan1.pid)

    sudo /sbin/wpa_supplicant -s -B -P /run/wpa_supplicant.wlan1.pid -i wlan1 \
       -D nl80211,wext -c /etc/wpa_supplicant/wpa_supplicant.conf


# On the ZBook

Enable the wireless network from the network manager and

    sudo ifconfig wlan0 down

but it keeps going back up

    sudo wpa_cli -i wlan0 terminate

doesn't stop it.

Disabling wireless with

    sudo iwconfig wlan0 mode Monitor
    sudo ifconfig wlan0 up
    SIOCSIFFLAGS: Operation not possible due to RF-kill

but

    rfkill unblock wlan0
    sudo ifconfig wlan0 up

works. Now

    sudo iwconfig wlan0 channel 2
    iwlist wlan0 channel | grep "Current Frequency"

works.

This is the basic channel hopping script

    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
      sudo iwconfig wlan0 channel $i
      tshark -i wlan0 -f 'broadcast' -T fields -e frame.time_epoch -e wlan.sa \
        -e radiotap.dbm_antsignal -e wlan.fc.type -e wlan.fc.subtype
    done

To shut it down

    sudo ifconfig wlan0 down
    sudo iwconfig wlan0 mode Managed
    sudo ifconfig wlan0 up

Often the network card never gets an IP address again.

To avoid sudo you can use the capabilities

    sudo setcap 'CAP_NET_ADMIN+eip' /sbin/iwconfig
    sudo setcap 'CAP_NET_ADMIN+eip' /sbin/ifconfig

Restore the original status with

    sudo setcap -r /sbin/iwconfig
    sudo setcap -r /sbin/ifconfig

# Misc

Google for _wifi dbm meter_
