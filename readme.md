Corectl App for macOS 
========================

**Corectl App** is a macOS Status bar App which works like a wrapper around the [corectl](https://github.com/TheNewNormal/corectl) command line tool `corectld` to control the server runtime process. 

**Note:** `Corectl App` only controls `corectld` server daemon, and is very, very, light on macOS system resources, when running and when idle. Also if there are no VMs running `corectld` server daemon is not using much resources too.


[corectl](https://github.com/TheNewNormal/corectl) allows to run CoreOS VMs on macOS using [xhyve](https://github.com/mist64/xhyve) which uses native macOS Hypervisor framework. Using native macOS Hypervisor framework eliminates of needs to use Virtual Box and other similar software to run your CoreOS VMs.

![Corectl_APP](corectl_app.png "Corectl_APP")


How to install Corectl App for macOS
----------

**Requirements**
 -----------
  - **macOS 10.10.3** Yosemite or later 
  - Mac 2010 or later for this to work.


####Download:
* Download `corectl_app.dmg` from the [Releases Page](https://github.com/TheNewNormal/corectl.app/releases)

###Install:

Open the downloaded `DMG` file and drag the App to /Applications, and start the `Corectl` from there.

You will be asked for your Mac user password, which will used to start `corectld` server as `root` is needed for the network to work. The password will be safely stored in your macOS `keychain`.

How it works
------------
When you start `Corectl` app, you will find a small icon with the CoreOS logo with X (X means [xhyve](https://github.com/mist64/xhyve)) in the Status Bar.
Under menu you will be able:

- To see that Server is running
- Shows Server version
- Shows Active VMs
- Restart the server
- Check and download `corectl` new version
- Fetch latest CoreOS ISO images, which will be stored under `~/.coreos` folder and can be shared between all VMs.

### have fun!

## Projects using **Corectl.App/corectl**

- [TheNewNormal](http://github.com/TheNewNormal) org projects:

  - **[CoreOS VM for macOS](https://github.com/TheNewNormal/coreos-osx)** (to be ported soon to use the latest corectl v0.7)
  - **[Kubernetes Solo Cluster for macOS](https://github.com/TheNewNormal/kube-solo-osx)** (to be ported soon to use the latest corectl v0.7)
  - **[Multi node Kubernetes Cluster for macOS](https://github.com/TheNewNormal/kube-cluster-osx)** (to be ported soon to use the latest corectl v0.7)

## Contributing

**Corectl App** is an [open source](http://opensource.org/osd) project release under
the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0),
hence contributions and suggestions are gladly welcomed! 
