@echo off
if exist "USRDIR_bak" (
	rd /s /q "USRDIR"
	ren "USRDIR_bak" "USRDIR"
)
ccff7unp.exe