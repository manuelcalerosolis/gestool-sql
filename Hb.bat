cd \fw195\gestool-sql\

taskkill /F /IM gestool.exe

\BCC582\BIN\MAKE -S -fHB.MAK -D__GST__ TARGET=gestool

cd \fw195\gestool-sql\bin\

if "%1"=="" goto NOPASSWORD

   gestool.exe %1 /NOPASSWORD

goto EXIT

:NOPASSWORD
   gestool.exe /NOPASSWORD

:EXIT
   cd \fw195\gestool-sql\