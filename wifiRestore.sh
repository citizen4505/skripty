#!/bin/bash
read ifce;
ip link set wlp1s0 down;
iw wlp1s0 set type managed;
ip link set wlp1s0 up;

