cd \fw195\gestool\

taskkill /F /IM servicio.exe

\BCC582\BIN\MAKE -S -fHBServicio.MAK 

cd \fw195\gestool\servicio\

   servicio.exe 

:EXIT
   cd \fw195\gestool\