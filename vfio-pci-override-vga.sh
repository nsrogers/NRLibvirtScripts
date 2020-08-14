#!/bin/sh

# https://gist.github.com/comjf/c6c96703d77e3ff5cb3dbc309d86d5cf

host_gpu="0d:00.0"
host_gpu_audio="0d:00.1"

guest_gpu="0e:00.0"
guest_gpu_audio="0e:00.1"


# Get pci-id/vendor-id/device-id guest GPU
guest_gpu_vendor=$(cat /sys/bus/pci/devices/0000:$guest_gpu/vendor)
guest_gpu_device=$(cat /sys/bus/pci/devices/0000:$guest_gpu/device)
# guest_gpu_audio=$(echo $guest_gpu | sed -e 's/\.0$/.1/')
# guest_gpu_audio_vendor=$(cat /sys/bus/pci/devices/0000:$guest_gpu_audio/vendor)
# guest_gpu_audio_device=$(cat /sys/bus/pci/devices/0000:$guest_gpu_audio/device)

# Get pci-id/vendor-id/device-id guest USB
#usb_pci=$(lspci | grep "VL805" | head -1 | awk '{print $1;}')
# usb_pci_vendor=$(cat /sys/bus/pci/devices/0000:$usb_pci/vendor)
# usb_pci_device=$(cat /sys/bus/pci/devices/0000:$usb_pci/device)

# Get pci-id/vendor-id/device-id guest NIC
# nic_pci=$(lspci | grep "I218-V" | head -1 | awk '{print $1;}')
# nic_pci_vendor=$(cat /sys/bus/pci/devices/0000:$nic_pci/vendor)
# nic_pci_device=$(cat /sys/bus/pci/devices/0000:$nic_pci/device)

# Set real driver for host GPU/GPU-audio
echo amdgpu        > /sys/bus/pci/devices/0000:$host_gpu/driver_override
echo snd-hda-intel > /sys/bus/pci/devices/0000:$host_gpu_audio/driver_override

# Set vfio-pci driver for guest GPU/GPU-audio/USB/NIC
echo vfio-pci      > /sys/bus/pci/devices/0000:$guest_gpu/driver_override
echo vfio-pci      > /sys/bus/pci/devices/0000:$guest_gpu_audio/driver_override
#echo vfio-pci      > /sys/bus/pci/devices/0000:$usb_pci/driver_override
# echo vfio-pci      > /sys/bus/pci/devices/0000:$nic_pci/driver_override

# Load vfio-pci kernel module

modprobe -i vfio-pci

# Set GPU/GPU-audio/USB/NIC vfio-pci id
#echo $guest_gpu_vendor $guest_gpu_device             > /sys/bus/pci/drivers/vfio-pci/new_id
#echo $guest_gpu_audio_vendor $guest_gpu_audio_device > /sys/bus/pci/drivers/vfio-pci/new_id
# echo $usb_pci_vendor $usb_pci_device                 > /sys/bus/pci/drivers/vfio-pci/new_id
# echo $nic_pci_vendor $nic_pci_device                 > /sys/bus/pci/drivers/vfio-pci/new_id

# Unbind GPU/GPU-audio/USB/NIC real driver
echo 0000:$guest_gpu       > /sys/bus/pci/devices/0000:$guest_gpu/driver/unbind
echo 0000:$guest_gpu_audio > /sys/bus/pci/devices/0000:$guest_gpu_audio/driver/unbin
#echo 0000:$usb_pci         > /sys/bus/pci/devices/0000:$usb_pci/driver/unbind
# echo 0000:$nic_pci         > /sys/bus/pci/devices/0000:$nic_pci/driver/unbind
modprobe -i amdgpu
modprobe -i snd_hda_intel

# Bind GPU/GPU-audio/USB/NIC to vfio-pci
echo 0000:$guest_gpu       > /sys/bus/pci/drivers/vfio-pci/bind
echo 0000:$guest_gpu_audio > /sys/bus/pci/drivers/vfio-pci/bind
#echo 0000:$usb_pci         > /sys/bus/pci/drivers/vfio-pci/bind
# echo 0000:$nic_pci         > /sys/bus/pci/drivers/vfio-pci/bind

# Load nvidia kernel module
echo 1 > /sys/module/kvm/parameters/ignore_msrs
