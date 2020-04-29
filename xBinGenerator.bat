ECHO OFF
cls
echo ***********************************************************
echo 		 	BINARY IMG GENERATOR
Echo ***********************************************************
echo.
echo ------------------------------------------------------------------------
del 1Loader.bin
del 2Object.bin
echo Old Files Deleted!

taskkill -f -im notepad++.exe
echo Notepad++ Closed!
echo ------------------------------------------------------------------------

echo.

echo ------------------------------------------------------------------------

nasm Loader1.asm -f bin -o 1Loader.bin
echo File "Loader" compiled!

nasm Object.asm -f bin -o 2Object.bin
echo File "Object" compiled!
echo.

echo Starting FergoRaw
FergoRaw
echo.

echo Starting RufusPortable
RufusPortable\RufusPortable
echo.

echo ------------------------------------------------------------------------
set /p resp=Deseja reiniciar o computador?(Y/N):
if %resp% == 'Y' goto Reiniciar
if %resp% == 'N' goto sair

::Reiniciar
 shutdown -r -t 0

::sair