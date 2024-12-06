# udev-rules-utils - udev utilites to manipulate and maintain the 70-persistent-net.rules file

# WARNING!!!

Do not use this on antything other that a test/throwaway system.

Also do not use it on systems with more than one network interface.

It is "hacky" to say the least!!!

## What is this all about?

Different Linux distributions and different hardware mean that the names
that the operating system assigns to NIC cards are usually different
between systems.

By editing the file `/etc/udev/rules.d/70-persistent-net.rules` with
specially formatted lines an additional name can be given to a specific
interface.

The result of this is that you could add an interface name such as `eth0`
to a NIC. Having all the interfaces have the same name across all systems
not only looks "tidier" but it can make automation tasks a little easier.

An example entry in `/etc/udev/rules.d/70-persistent-net.rules` might
look like:

```
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="bc:24:11:72:46:46", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="ens18", NAME="eth0"
```

This great. However, because this entry line has the MAC address of
the NIC in it we have a niggly problem when the system is a virtual
machine and it gets cloned. Most hypervisors when they clone a system
will assign a different MAC address to the NICs on the clone. That way if
both the clone and original machine are powered on and connected to the
same network segment they won't have duplicate MAC addresses. Duplicate
MAC addresses are bad and make diagnosing network issues even harder
than usual.

This is good practice but a side effect is that if you are adding new alias
names via the `70-persistent-net.rules` file when cloning you
need to remember to update the file with the new MAC address assigned
to the cloned virtual machine.

To help with this issue the `eth0.sh` script is called by the
oneshot service defined in the `eth0.service` file and creates the
`/etc/udev/rules.d/70-persistent-net.rules` with just one line to rename
the NIC using the correct MAC address. So after cloning there is no need
to update the `70-persistent-net.rules` file - it gets automatically
updated - nice!

Note after cloning and powering up the clone you need to login to the
virtual machine on the console and reboot it. Until it gets a full reboot
after cloning the card doesn't get renamed. I will leave it as an exercise
for the reader to work out why this happens. If you can come up with a
workaround to make this reboot unnecessary then please let me know.

## Quick start

Make sure you are on a systemd based Linux system with just one network
interface card (NIC).

The following is the output of the command `ip addr` a system with just
one NIC:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens18: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether bc:24:11:15:7d:58 brd ff:ff:ff:ff:ff:ff
    altname enp0s18
    inet 192.168.1.45/24 brd 192.168.1.255 scope global noprefixroute ens18
       valid_lft forever preferred_lft forever
    inet6 fe80::be24:11ff:fe15:7d58/64 scope link
       valid_lft forever preferred_lft forever
```

Edit the `eth0.service` file and locate the line which reads:

```
ExecStart=/usr/local/bin/eth0.sh ens18 eth0
```

Change `ens18` to be the current name of the single NIC.

If required change `eth0` to the new name you want to use when configuring
the NIC.

Save the changes to the `eth0.service` file.

Run the `Install.sh` script as follows:

```
sudo ./Install.sh
```

Reboot the server.

Log back in.

Run the command `ip addr` - the output should now be similar to:

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether bc:24:11:72:46:46 brd ff:ff:ff:ff:ff:ff
    altname enp0s18
    altname ens18
    inet 192.168.1.46/24 brd 192.168.1.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::be24:11ff:fe72:4646/64 scope link
       valid_lft forever preferred_lft forever
```

That is the NIC now using the new name of `eth0`.

## More on cloning

As mentioned above if the script is installed on a virtual machine and
the machine is cloned then when the clone is booted up the NIC will
revert to the old name. Simply reboot the clone and this time the NIC
will have renamed.

----------------
End of README.md
