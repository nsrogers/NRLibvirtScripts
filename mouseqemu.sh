#!/bin/bash
# Author robotcanadia@gmail.com
# License MIT 2.0

# Script Run via keyboard shortcut, that will send mouse to and from libvirt guest.
# Setup a small macro keypad

# exit when any command fails
set -e

# For attach Best Attempt to find the main Mouse if env not set.
if [ "$1" = "attach" ]; then
  command="attach-device"
  if ! [[ -v SOFT_KVM_MOUSE ]]; then
  mouse=$(grep -E '\<(Bus|Name)' /proc/bus/input/devices |
	# TODO UGLY, razer keyword works but really need better way to detect mice
	grep "Razer" --no-group-separator -B 1 |
	awk '!a[$0]++' |
	grep Bus | sed 's/.*Vendor=//g' |
	sed 's/ Product=/:/g' |
	sed 's/ .*//g' |
	head -n 1)
  else
  mouse=$SOFT_KVM_MOUSE
  fi
elif [ "$1" = "detach" ]; then
  command="detach-device"
  mouse=$(cat /tmp/curr_kvm_mouse)
else
  echo add option attach or detach
  exit 1
fi


#TODO handle empty or badly provided mouse

Vendor=$(echo $mouse | awk -F':' '{print $1}')
Product=$(echo $mouse | awk -F':' '{print $2}')

#Libvirt wants a xml of the device to add.
CONF=$(mktemp)
cat > $CONF << EOFcat
<hostdev mode='subsystem' type='usb'>
<source>
<vendor id='0x$Vendor'/>
<product id='0x$Product'/>
</source>
</hostdev>
EOFcat

#TODO support filtering out one of multiple vms, right now first vm always
VM=$(virsh -c qemu:///system list | awk '/running/{print $2;exit}')

if ! [ -z "$VM" ]; then
echo $command mouse = $mouse to $VM with $CONF;
virsh -c qemu:///system $command $VM --file $CONF --current
if [ "$1" = "attach" ]; then
  echo "$mouse" > /tmp/curr_kvm_mouse
elif [ "$1" = "detach" ]; then
  rm /tmp/curr_kvm_mouse
fi
else
echo no vm found
fi
rm -f $CONF

