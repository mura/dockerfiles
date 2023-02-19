#!/bin/bash
busybox crond -b -L /proc/self/fd/2
exit $?
