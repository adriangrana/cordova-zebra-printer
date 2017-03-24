---
title: cordova-zebra-printer
description: Plugin for use zebra printer by bluetooth
---
<!--
# license: Licensed to the Apache Software Foundation (ASF) under one
#         or more contributor license agreements.  See the NOTICE file
#         distributed with this work for additional information
#         regarding copyright ownership.  The ASF licenses this file
#         to you under the Apache License, Version 2.0 (the
#         "License"); you may not use this file except in compliance
#         with the License.  You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#         Unless required by applicable law or agreed to in writing,
#         software distributed under the License is distributed on an
#         "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#         KIND, either express or implied.  See the License for the
#         specific language governing permissions and limitations
#         under the License.
-->


# cordova-zebra-printer

This plugin allow a  scan and print in zebra printer devices.

Report issues with this plugin on the [cordova-zebra-printer issue tracker](https://github.com/adriangrana/cordova-zebra-printer/issues)


## Installation

    cordova plugin add https://github.com/adriangrana/cordova-zebra-printer.git

## Properties

- zebra.scan
- zebra.write

## zebra.scan

The `zebra.scan` returns an array of the name of the printer and it serial number.

### Supported Platforms

- iOS

### Quick Example

```js
   zebra.scan(function success(devices){
      devices.forEach(function(device){
          console.log(device.name+":"+device.serialNumber);
      });
    },
    function fail(error){
      alert(error);
    })
```
## zebra.write

The `zebra.write` allow connect and print in zebra printer device.

### Supported Platforms

- iOS

### Quick Example

```js
    var serialNumber="XXQLJ144902148";
    var data  = "! 0 200 200 406 1\r\nON-FEED IGNORE\r\nBOX 20 20 380 380 8\r\nT 0 6 137 177 TEST\r\nPRINT\r\n";;
    zebra.write(serialNumber,data,function success(info){
      console.log(info);
    },
    function fail(error){
      console.log(error);
    })
```



