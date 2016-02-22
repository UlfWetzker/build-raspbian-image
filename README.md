build-raspbian-image
====================
Builds a minimal [Raspbian](http://raspbian.org/) Jessie image. Based on: https://github.com/niklasf/build-raspbian-image

Login: `root`  
Password: `raspberry`

Only a basic Debian with standard networking utilities.

**:exclamation: Careful: As an exception dropbear is pre-installed and
will allow root login with the default password.** Host keys are generated on
first boot.


Dependencies
------------

 Run `./install.sh`

Usage
-----

Run `./bootstrap.sh` (probably root required for loopback device management)
to create a fresh raspbian-yyyy-mm-dd.img in the current directory.

Writing the image to an SD card
-------------------------------

`dd if=raspbian-yyyy-mm-dd.img of=/dev/mmcblk0 bs=1M && sync`

Recommended packages
--------------------

 * Install `console-common` to select a keyboard layout.

 * Install `ntp` to automatically synchronize the clock over the network.
   Without a synchronized clock there may be problems when checking validity
   and expiration dates of SSL certificates.  Also `dpkg-reconfigure tzdata`
   to select a time zone.

 * Install `locales`. Also `dpkg-reconfigure locales` and select at least one
   UTF-8 locale to generate.

 * Install `iptables` for firewall configuration. Sample
   `/etc/network/iptables`:

   ```
   *filter
   :INPUT DROP [23:2584]
   :FORWARD ACCEPT [0:0]
   :OUTPUT ACCEPT [1161:105847]
   -A INPUT -i lo -j ACCEPT
   -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
   -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
   -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
   -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
   COMMIT
   ```

   Append `pre-up iptables-restore < /etc/network/iptables` to
   `/etc/network/interfaces`.

 * `fail2ban` to ban IPs trying too many wrong SSH passwords for some time.
   Works without any configuration.

 * `needrestart`, telling you which services to restart after package upgrades.

 * Install `apt-cron` to automatically look for package updates. Regularly
   updates the package lists (but does not install anything) if installed
   without any reconfiguration.

 * Install `avahi-daemon` to broadcast the device address to the local network
   using Zeroconf / Bonjour.

Resize the root partition to the SD card
----------------------------------------

The default image is effectly about 200MB but actually comes with a 2GB root
parition. Its likely the the SD card is much bigger.

 1. Boot. Login. `fdisk /dev/mmcblk0p1`. Delete the partition.
    Create a new primary ext4 parition.

 2. Reboot.

 3. Login. `resize2fs /dev/mmcblk0p1`.

Optimize for heavy RAM usage
----------------------------

### Add a swapfile

 1. Allocate a continuous file:

    `dd if=/dev/zero of=/var/swapfile bs=1M count=512`

 2. Create a swap file in there: `mkswap /var/swapfile`

 3. Append the following line to `/etc/fstab` to activate it on future boots:

    `/var/swapfile none swap sw 0 0`

 4. `swapon /var/swapfile` to activate it right now. `swapon -s` to show
     statistics.

### Relinquish ramdisks

Remove `tmpfs /tmp tmpfs defaults,size=100M 0 0` from `/etc/fstab`. It makes
no sense to have a ramdisk only to swap it to disk anyway.

Optimize for SD card life
-------------------------

Make sure you limit writes to your SD card. `/tmp` is already mounted as
tmpfs (see `/etc/fstab`). If you do not need logs across reboots you could also
mount `/var/log` as tmpfs.
