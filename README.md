# TinyDragon0


A box that captures broadcast wifi traffic, prints it to an onboard screen and converts the raw packet data to sound.

It's a very scaled down and simplified version of the installation [Here Be Dragons](), that translated cyber attacks on honeypot servers setup around the globe into sound.

This box is a way for us humans to sense the invisible wireless signals that make up our local networked digital ecosystem by bringing it into our field of perception. It's meant to be experienced much like the roar of the ocean, as something to become familiar with, a texture that is at first incomprehensible, but after some time, we can begin to intuit meaning and significance from its ebbs and flows.

## Installation
* [Installing Kali Linux on a Pi Zero W](https://dantheiotman.com/2017/10/06/installing-kali-linux-on-a-pi-zero-w/)
* [Set Up Kali Linux on the New $10 Raspberry Pi Zero W ](https://null-byte.wonderhowto.com/how-to/set-up-kali-linux-new-10-raspberry-pi-zero-w-0176819/)
* [Enable Monitor Mode & Packet Injection on the Raspberry Pi](https://null-byte.wonderhowto.com/how-to/enable-monitor-mode-packet-injection-raspberry-pi-0189378/)
* [Raspberry Pi Zero W WiFi Hacking Gadget](https://medium.com/@THESMASHY/raspberry-pi-zero-w-wifi-hacking-gadget-63e3fa1c3c8d)

### Hardware:

#### Parts:

* Raspberry Pi Zero W (CanaKit)
* USB hub (minimum 2x ports)
* Kuman 3.5" TFT touch display
* 1/8" sereo jack with switch
* 2.5" 4ohm 3W speaker
* Adafruit Audio Bonnet

#### Setup: Adafruit Audio Bonnet

1. Solder terminals to bonnet
1. Solder wires to speaker
1. Solder wires to left and right non-switched side of 1/8" jack
1. Solder speaker wires to left channel on switched side of 1/8" jack
1. Secure left and right jack wires into respective terminal blocks on bonnet

#### Setup Raspberry Pi Zero:

1. Download and flash the "Raspberry Pi OS (32-bit) Lite" image from [Raspberry Pi OS](https://www.raspberrypi.org/downloads/raspberry-pi-os/) onto a micro SD card using [balenaEtcher](https://www.balena.io/etcher/).
1. Remove and reinsert card to remount.
1. Open a terminal and `cd` to the `/boot/` volume.
1. add a file `ssh`
1. create a `wpa_supplicant.conf` file and populate it with:

```
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
ssid="WIFI_SSID"
scan_ssid=1
psk="WIFI_PASSWORD"
key_mgmt=WPA-PSK
}
```

1. edit `config.txt` to enable gadget mode overlay by adding a new line: `dtoverlay=dwc2`
1. edit `cmdline.txt` to include `modules-load=dwc2,g_ether` after `rootwait`
1. Unmount card, insert into Pi Zero, power up and connect to your host machine via USB.
1. ping `raspberrypi.local`
1. if successful, login: `ssh pi@raspberrypi.local`
1. create user `tinydragon`: `sudo useradd tinydragon -m`
1. create group `tinydragon and wheel`: `sudo groupadd tinydragon wheel`
1. add `tinydragon` to groups: `sudo usermod -a -G wheel,tindydragon`
1. Run `sudo visudo` and modify:

```
%sudo   ALL = (ALL) NOPASSWD: ALL
%wheel  ALL=(ALL:ALL) ALL
```

1. Set password for `tinydragon`: `sudo passwd tinydragon`
1. Run `sudo nano /etc/hostname` and replace `raspberrypi` with `tinydragon0`
1. Run `sudo nano /etc/hosts` and replace `raspberrypi` with `tinydragon0`

1. reboot: `sudo reboot -h now`
1. login in using `ssh tinydragon@tinydragon0.local`
1. remove to user `pi`: `sudo userdel -r pi`

1. permanently boot to console: `sudo systemctl set-default multi-user.target`, `graphical.target` for GUI
1. `sudo apt-get update && sudo apt-get upgrade -y`
1. `wget -O re4son-kernel_current.tar.xz https://re4son-kernel.com/download/re4son-kernel-current/ && tar -xJf re4son-kernel_current.tar.xz`
1. `cd re4son-kernel_*`
1. `sudo ./install.sh`, Y to all
1. log back in and run: `iw phy phy0 info`

```
...
Supported interface modes:
		 * IBSS
		 * managed
		 * AP
		 * monitor
		 * P2P-client
		 * P2P-GO
		 * P2P-device
...
``` 

1. `sudo apt-get update && sudo apt-get install git tcpdump aircrack-ng -y`
1. `sudo systemctl disable wpa_supplicant`
1. add `airmon-ng start wlan0` to `/etc/rc.local`
1. `reboot`
1. From host machine, ssh possible over USB, `wlan0` is set to monitor mode on boot.

#### Restoring WiFi Internet Connection

Assumes you've already configured to connect to a WiFi network by editing `wpa_supplicant.conf`.

1. Bring down the monitor interface: `sudo airmon-ng stop wlan0mon`
1. Restart WiFi networking services: `sudo systemctl restart wpa_supplicant.service networking.service`
1. Bring up the WiFi interface: `sudo ip link set wlan0 up` and wait a minute
1. Check IP assignment: `ifconfig wlan0`
1. Test internet connection: `ping google.com -c 3`
1. Do your downloading. On reboot, everything will be returned to "normal".

#### Kuman MHS35 Display

1. `git clone https://github.com/goodtft/LCD-show.git`
1. `chmod -R 755 LCD-show`
1. `cd LCD-show/`
1. `sudo ./MHS35-show`
1. `sudo apt-get --fix-broken install`

#### TinyDragon0 Software

1. `sudo apt-get update && sudo apt-get update -y && sudo apt-get install xinit`
1. `sudo xinit +hm -fullscreen +j -k8 +mb -fa monaco -fs 8 -fg white -bg black -e /bin/sh -c 'ls -R /' -- -nocursor
`

Requirements:

* python3
* pyaudio

Install pyaudio on Debian systems using:

```
$ sudo apt-get update && sudo apt-get install python3-pyaudio portaudio19-dev
$ git clone https://github.com/phillipdavidstearns/packet2audio.git
```

Create a symlink for handy command line usage:

```
$ sudo ln -s /path/to/packet2audio/packet2audio.py /usr/local/bin/packet2audio
```

Run with:

```
$ packet2audio -i <iface_name>
```

## Usage

Simple, but it must be run as root (with `sudo`):

```
usage: packet2audio [-h] [-a] [-s] -i INTERFACE [-c CHUNK_SIZE]
                    [-r SAMPLE_RATE] [-w WIDTH] [-t TIMEOUT] [-p]

optional arguments:
  -h, --help            show this help message and exit
  -a, --audio-blocking  non-blocking by default
  -s, --socket-blocking
                        non-blocking by default
  -i INTERFACE, --interface INTERFACE
                        [if0[,if1]]
  -c CHUNK_SIZE, --chunk-size CHUNK_SIZE
                        chunk size in frames
  -r SAMPLE_RATE, --sample-rate SAMPLE_RATE
                        frames per second
  -w WIDTH, --width WIDTH
                        bytes per sample
  -t TIMEOUT, --timeout TIMEOUT
                        socket timeout in seconds
  -p, --print-packet    print packet to console
```

### Examples:

Listen to WiFi traffic: 

```
sudo packet2audio -i wlan0
```

Listen on more than one interface: 

```
sudo packet2audio -i wlan0,eth0
```

Enable blocking with `-a` for audio and `-s` for socket:

```
sudo packet2audio -i wlan0,eth0 -a -s
```

Print the data written to the audio buffer with `-p` (hint: doesn't make sense to use without a monitor):

```
sudo packet2audio -i wlan0 -p
```

## Credits

by Phillip David Stearns 2019

Code cobbled together from examples at:

* [How to Write a Simple Packet Sniffer](http://www.bitforestinfo.com/2017/01/how-to-write-simple-packet-sniffer.html)
* [Wire Callback Examples](https://people.csail.mit.edu/hubert/pyaudio/#wire-callback-example)
* [Capturing SIGINT in Python](https://stackoverflow.com/questions/1112343/how-do-i-capture-sigint-in-python#1112350)

A nice link illuminating protocol codes in linux:

* [Linux Protocol Codes](https://github.com/torvalds/linux/blob/ead751507de86d90fa250431e9990a8b881f713c/include/uapi/linux/if_ether.h)
