@echo XC16++ symlink creation script
@echo Note that you still have to copy the other .exe files manually!

@rem Change to same this directory as this file
@cd %0\..

@if not exist ".\xc16-gcc.exe" (
	echo FATAL ERROR: This is NOT the right directory to run this script.
	echo Put this script in XC16's bin directory -NOT bin\bin-
	echo  e.g. "C:\Program Files (x86)\Microchip\xc16\v1.23\bin"
	echo and run it again.
	goto:done
)

@set success=1
@if %success% equ 1 call:createcopy "xc16-gcc.exe" "xc16-g++.exe"
@if %success% equ 1 call:createcopy "xc16-cc1.exe" "xc16-cc1plus.exe"

cd bin
@if %errorlevel% neq 0 (
	echo FATAL ERROR: Failed to change to bin\bin subdirectory
	goto:done
)

@if %success% equ 1 call:createcopy "coff-pa.exe" "coff-paplus.exe"
@if %success% equ 1 call:createcopy "elf-pa.exe" "elf-paplus.exe"

@if %success% equ 1 echo SUCCESS: All files have been created successfully

:done
@if "%1"=="nopause" goto:eof
@pause
@goto:eof

:createcopy
copy "%~1" "%~2"
@if %errorlevel% equ 0 goto:eof
@echo FATAL ERROR: File copy failed, please check your permissions
@echo (this script must be run as Administrator)
@set success=0
@goto:eof
