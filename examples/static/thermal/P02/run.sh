#!/bin/sh
export PATH=../../../../hecmw1/bin:$PATH
FISTR=../../../../fistr1/bin/fistr1
cp hecmw_ctrl.dat.heat hecmw_ctrl.dat
hecmw_part1
mpirun -np 2 $FISTR || echo HEAT - 0 FAILED
if [ -f 0.log ]; then cp 0.log heat-0.log; fi
cp hecmw_ctrl.dat.heat.ref1 hecmw_ctrl.dat
mpirun -np 2 $FISTR || echo HEAT - 1 FAILED
if [ -f 0.log ]; then cp 0.log heat-1.log; fi
cp hecmw_ctrl.dat.static hecmw_ctrl.dat
hecmw_part1
mpirun -np 2 $FISTR || echo STATIC - 0 FAILED
if [ -f 0.log ]; then tail -31 0.log > static-00.log; fi
cp hecmw_ctrl.dat.static.ref01 hecmw_ctrl.dat
mpirun -np 2 $FISTR || echo STATIC - 01 FAILED
if [ -f 0.log ]; then tail -31 0.log > static-01.log; fi
cp hecmw_ctrl.dat.static.ref02 hecmw_ctrl.dat
mpirun -np 2 $FISTR || echo STATIC - 02 FAILED
if [ -f 0.log ]; then tail -31 0.log > static-02.log; fi
cp hecmw_ctrl.dat.static.ref11 hecmw_ctrl.dat
mpirun -np 2 $FISTR || echo STATIC - 11 FAILED
if [ -f 0.log ]; then tail -31 0.log > static-11.log; fi
cp hecmw_ctrl.dat.static.ref12 hecmw_ctrl.dat
mpirun -np 2 $FISTR || echo STATIC - 12 FAILED
if [ -f 0.log ]; then tail -31 0.log > static-12.log; fi
