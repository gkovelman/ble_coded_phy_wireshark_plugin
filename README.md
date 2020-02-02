<h3 align="center">BLE5 Coded PHY Wireshark plugin</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/gkovelman/ble_coded_phy_wireshark_plugin.svg)](https://github.com/gkovelman/ble_coded_phy_wireshark_plugin/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/gkovelman/ble_coded_phy_wireshark_plugin.svg)](https://github.com/gkovelman/ble_coded_phy_wireshark_plugin/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> 
As of Wireshark 3.2.1, there's no support for parsing BLE5 extended advertisemnt. This plugin adds some support to be able to handle extended advertisemnt and coded PHY BLE5 packets.
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

Quick plugin for [Wireshark](https://www.wireshark.org/) to support BLE5 extended advertisement packets.

## 🏁 Getting Started <a name = "getting_started"></a>

See installation and usage.

### Prerequisites

Tested with Wireshark 3.2.1.

### Installing

Close this repository to your favorite Wireshark plugins directory. More info [here](https://www.wireshark.org/docs/wsug_html_chunked/ChPluginFolders.html)

## 🎈 Usage <a name="usage"></a>

Open any BLE5 packet, or if such files are open, reload Lua plugins with Ctrl+Shift+L.
Example projects that provide usable .pcap files: 

  - [nRF Sniffer](https://www.nordicsemi.com/Software-and-tools/Development-Tools/nRF-Sniffer-for-Bluetooth-LE)
  - [Sniffle (for TI CC1352/CC26x2 hardware)](https://github.com/nccgroup/Sniffle)

## ✍️ Authors <a name = "authors"></a>

- [@gkovelman](https://github.com/gkovelman) - Initial work

See also the list of [contributors](https://github.com/kylelobo/The-Documentation-Compendium/contributors) who participated in this project.

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- TODO
