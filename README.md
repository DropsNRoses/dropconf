# Overview
DropConf is a script which executes several commands automatically, with the right timing between each command. It can be used to configure several drops in a row, or to generate configuration files automatically in a Web server for example. It reads the commands in a local file or in a remote file located with its URL.

See the full documentation on [Drops Developers](http://dropsnroses.github.io/tools.html#dropconf).


# Install
Before using DropConf, you must install CoffeeScript and Noble. You can do this using npm: `$ npm install coffee noble`. Noble also requires the `libbluetooth-dev` package. Then you can run the script.


# Usage
Before running DropConf, make sure to activate Bluetooth on your computer.

You can either give a DropConf file or an url as an argument. The file must respect the DropConf file format (see below). The command must be executed as root if you don't have the permission to access your HCI device.
```
sudo coffee dropconf.coffee --file mydropconf.drop
sudo coffee dropconf.coffee --url http://www.example.com/dropconf/42.drop
```