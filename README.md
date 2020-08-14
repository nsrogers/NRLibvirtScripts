# NRLibvirtScripts
Set of scripts for graphics and usb passthrough device for Wndows Guest.

Main pain points the scripts address:
I have two of the same exact graphics card and most ways to direct one device to X11 and one to vfio/libvirt does not apply. Thus I use the vfio* script on amdgpu is loaded to instead hardcode one pci bdf address to vfio and one to amdgpu. This does also require specifing device in Xorg.conf for it to use.

Added 2 quick scripts that will dynamically parse out current mouse and keyboard and send them to first running guest. I built a tiny macro keyboard so I can use that keypad to trigger keyboard shortcuts sending whole keyboard over and back when run.

TODO:
Sound passthrough work in progress probably with https://github.com/duncanthrax/scream, but current solution is spice display.
Get Looking glass working again. Will post startup scripts when ready.
