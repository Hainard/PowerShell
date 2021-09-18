SET DirName=ПУТЬ_КУДА_СОХРАНЯЕМ_АРХИВЫ
FOR /f "tokens=1-7 delims=/-:., " %%a IN ("%DATE: =0% %TIME: =0%") do (
    SET NewBkDir=%DirName%\%%c.%%b.%%a_%%d.%%e.%%f.%%g
)
IF NOT EXIST "%NewBkDir%" (
    MD "%NewBkDir%"
)
SET SrcData=ПУТЬ_ПАПКЕ_С_ДАННЫМИ
SET ArcName=%NewBkDir%\backup.rar

"C:\Program Files\WinRAR\Rar.exe" a -m5 -ep1 -ri1 -dh "%ArcName%" "%SrcData%"