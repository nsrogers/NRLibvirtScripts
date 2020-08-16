# NRLibvirtScripts
Set of scripts for graphics and usb passthrough device for Windows Guest.
Goal is to make windows vm offload as much as possible into the host linux. Avoiding the issues plaguing emulation of hardware as much as possible via shim devices (virtio) and other solution that allow the host linux to mix inputs, sound and video directly allowing seamless windows and linux switching and cohabitation on one desktop.

Main pain points the scripts here address:
I have two of the same exact graphics card and most ways to direct one device to X11 and one to vfio/libvirt does not apply. Thus I use the vfio* script on amdgpu load to instead hardcode one pci bdf address to vfio and one to amdgpu. This does also require specifing device in Xorg.conf for it to use.

Added 2 quick scripts that will dynamically parse out current mouse and keyboard and send them to first running guest. I built a tiny macro keyboard so I can use that keypad to trigger keyboard shortcuts sending whole keyboard over and back when run.

My X470 tiachi motherboard was a pain, passthrough only works on versions < 2.0 and versions > 3.90 due to a bug in AGESA 0.7.0 or so, finally fixed in AGESA 1.0.0.4 Patch B. But my 2700X fails to fully power cycle on these newer bios, but the other fixes are worth it.
added kernel boot options, amd_iommu=on

Other features that are used but have no scripts because they just worked:
Sound passthrough working with scream https://github.com/duncanthrax/scream had to use unicast

Looking glass to pass throuh a gpu frame buffer.

spice display as keyboard and mouse passthough when not gaming, and via the softkvm scripts to usb passthough when latency is important, but always viewed via looking glass.

Other Resources:
Found this doc on a way to move devices in and out of windows without an extra macro keypad by telling libvirt to detach via a serial connection. Very cool.
https://rokups.github.io/#!pages/kvm-hid.md
Needed this to run looking_glass_host as admin.
https://superuser.com/questions/929225/how-to-run-a-program-as-an-administrator-at-startup-on-windows-10



TODO and minor nits:
mouse side buttons do not work in spice mapping, there is support but need to check mapping.
Without capturing mouse via scrolllock the mouse can lose tracking and cannot reach full screen area until moved into windows and back
setup my iscsi drive
copy paste between desktops via spice (BOTH WAYS?)
hold backspace does not translate via spice


Hardware:
Tiachi x470 pro ac with 2700X,
2 AMD 580 evga gpus
