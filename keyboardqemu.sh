#!/bin/bash

# exit when any command fails
set -e

# For attach Best Attempt to find the main Keyboard if env not set.
if [ "$1" = "attach" ]; then
  command="attach-device"
  if ! [[ -v SOFT_KVM_KEYBOARD ]]; then
  keyboard=$(grep -E '\<(Bus|Name)' /proc/bus/input/devices |
	# This term works for me, ignoring other devs and matching
        # all the keyboards I tested
	grep "USB Keyboard" --no-group-separator -B 1 |
	awk '!a[$0]++' |
	grep Bus | sed 's/.*Vendor=//g' |
	sed 's/ Product=/:/g' |
	sed 's/ .*//g' |
	head -n 1)
  else
  keyboard=$SOFT_KVM_KEYBOARD
  fi
elif [ "$1" = "detach" ]; then
  command="detach-device"
  keyboard=$(cat /tmp/curr_kvm_keyboard)
else
  echo add option attach or detach
  exit 1
fi


#TODO handle empty or badly provided keyboard

Vendor=$(echo $keyboard | awk -F':' '{print $1}')
Product=$(echo $keyboard | awk -F':' '{print $2}')

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
echo $command keyboard = $keyboard to $VM with $CONF;
virsh -c qemu:///system $command $VM --file $CONF --current
if [ "$1" = "attach" ]; then
  echo "$keyboard" > /tmp/curr_kvm_keyboard
elif [ "$1" = "detach" ]; then
  rm /tmp/curr_kvm_keyboard
fi
else
echo no vm found
fi
rm -f $CONF

