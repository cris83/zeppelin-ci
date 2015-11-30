#!/bin/bash

echo "init>"
./buildstep.sh init ./log 10 

echo "log>"
./buildstep.sh log t.bs "test"
./buildstep.sh log t.bs "test ok ok ok ok ok ok ok ok ok ok ok ok ok ok ok ok"

echo "waitfor>"
./buildstep.sh waitfor t.bs "ok ok ok 12345"
