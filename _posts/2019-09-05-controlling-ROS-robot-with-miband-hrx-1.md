---
layout: post
title:  "Controlling ROS Turtlebot3 with Miband - Part I"
date:   2019-09-01
excerpt: "Reading raw accelerometer data from a Xiaomi Miband and controllling a ROS simulation bot with it"
comments: true
image: "/images/controlling-ROS-robot-with-miband-hrx-1-img01.png"
image1: "/images/controlling-ROS-robot-with-miband-hrx-1-img02.png"
image2: "/images/controlling-ROS-robot-with-miband-hrx-1-img03.gif"
categories: [BLE, ROS]
tags: [MiBand, BLE, ROS]
---


I wanted to control my Turtlebot3 gazebo simulations using the Xiaomi MiBand HRX. MiBand uses Bluetooth Low Energy to communicate. The major challenge was understanding the undocumented services and characteristics. Fortunately, there are several python libraries that are written for other MiBand models. So, I didn't have to start from scratch!

Still, the challenge of finding the right services & values remained. I started by forking [this](https://github.com/creotiv/MiBand2) wonderful library which used bluepy. I was only interested in the accelerometer data.

Check out the ROS interfacing example [here](https://github.com/4lhc/ROS/tree/master/learning_ws/src/x1_miband_control).


So, let's begin by identifying the MAC address of the MiBand!

### 1. BLE - connecting and reading data
An excellent place to learn about BLE GATT Services and Characteristics would be [here](https://www.oreilly.com/library/view/getting-started-with/9781491900550/ch04.html).
#### Scan for available devices
```sh
sudo hcitool lescan
```


The following commands were helpful in identification of services and characteristics specific to HRX bands. Xiaomi doesn't provide user descriptions for the services and characteristics, which makes it harder. There are plenty of reverse engineered solutions for MiBand2 & 3 which are extremely [helpful](#sources--references).

#### List services
```sh
gatttool -b <MAC-ADDRESS> -t random --primary
```

#### List characteristics
```sh
gatttool -b <MAC-ADDRESS> -t random --characteristics
```


#### Auth and notifications
- Authentication is same as MiBand2
- Services & Characteristics of interest (names are arbitrary)

    - ``SERVICE_MIBAND1 : "0000fee1-0000-1000-8000-00805f9b34fb"``
        - ``CHARACTERISTIC_SENSOR_CONTROL : "00000001-0000-3512-2118-0009af100700"``
        - ``CHARACTERISTIC_SENSOR_MEASURE : "00000002-0000-3512-2118-0009af100700"``

- To receive accelerometer notification
    - Write without response ``0x010119`` to service ``0000fee1-0000-1000-8000-00805f9b34fb`` characeteristic ``00000001-0000-3512-2118-0009af100700``
    - Write without response ``0x02`` to service ``0000fee1-0000-1000-8000-00805f9b34fb`` characeteristic ``00000001-0000-3512-2118-0009af100700``
    - Write ``0x0100`` to notification descriptor to enable notification

### 2. Processing Accelerometer Data

After successfully reading the raw accelerometer data, the next step would be to make sense of it.

#### Parsing
Data received in packets of byte size ``20``, ``14`` or ``8``.

Sample: ``0x0100 0500 8200 0b00 0400 8000 0b00 0300 8100 0b00``


|0100  | 0500  | 8200  | 0b00 | 0400  | 8000  | 0b00  | 0300  | 8100  | 0b00   |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| -  | signed x  |signed y   | signed z  |  signed x |  signed y | signed z  | signed x  | signed y  |  signed z |

#### Calculating Roll and Pitch
In the absence of linear acceleration, the accelerometer output is a measurement of the rotated
gravitational field vector and can be used to determine the accelerometer pitch and roll orientation
angles.
<!--<p align="center">-->
<div class="box">
{% raw %}
  $$tan\phi_{xyz} = \left ( \frac{G_{py}} {G_{pz}} \right )$$

  $$tan\theta_{xyz} = \left ( \frac{-G_{px}} {\sqrt{G_{py}^{2} + G_{pz}^{2}}} \right )$$
 {% endraw %}
 </div>
<!--</p>-->

## Plot

<div class="image main">
<img src="{{page.image2 | absolute_url}}" width="1200">
</div>



## Sources & References
1) [Base lib provided by Leo Soares](https://github.com/leojrfs/miband2)

2) [Volodymyr Shymanskyy](https://github.com/vshymanskyy/miband2-python-test)

3) [Freeyourgadget Team](https://github.com/Freeyourgadget/Gadgetbridge/tree/master/app/src/main/java/nodomain/freeyourgadget/gadgetbridge/service/devices/huami/miband2)

4) [ragcsalo's Comment](https://github.com/Freeyourgadget/Gadgetbridge/issues/63#issuecomment-493740447)

5) [Xiaomi band protocol analyze](http://changy-.github.io/articles/xiao-mi-band-protocol-analyze.html)

6) [Tilt Sensing Using 3-Axis Accelerometer](https://www.nxp.com/docs/en/application-note/AN3461.pdf)

7) [creotiv donate link](https://github.com/creotiv/MiBand2#donate)

