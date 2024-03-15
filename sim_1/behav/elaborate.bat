@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto db1ce6de82244cad814a52f6461237bf -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip -L xpm --snapshot simulation_behav xil_defaultlib.simulation -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
