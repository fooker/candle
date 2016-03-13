candle
======

The candle is a generic lightnig controller based on the ESP-8266 chip.

Nowadays, the lightning in a room comprises a lot of different light sources
like static direct and indirect main lights, LED stribes and panels, RGB
spotlights, etc. Most of these devices are controllable by some kind of control
protocol or network reaching from a simple relay to a DMX bus. The candle adapts
all these protocols and provides unified access to all the light sources via
WiFi.


Hardware
--------

The main component is the ESP-8266 chip which provides WiFi access and the main
processing unit. In addition to this chip, a variety of baseboards are used to
provide power and adapts the physical connection to an implemented protocol.


Software
--------

The ESP-8266 is running the controller software based on NodeMCU. The controller
connects to a preconfigured WiFi network and registers itself as a MQTT client.

The MQTT connection is used to publish details about the controller and can be
used to configure the controller and controll the attached lightning fixture(s).

