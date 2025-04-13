set JAVA=%JAVA_HOME%\bin\java.exe
set RASTERIZER=d:\java\batik-1.5.1\batik-rasterizer.jar
set INDIR=..\html\svg
set OUTDIR=..\html\images

for %%i in (%INDIR%\*.svg) do %JAVA% -Djava.awt.headless=true -jar %RASTERIZER% -w 400 -h 300 -d %OUTDIR% %%i

@rem Use the following if the above 'for' command fails...
@rem cd %INDIR%
@rem pwd
@rem %JAVA% -Djava.awt.headless=true -jar %RASTERIZER% -w 400 -h 300 -d %OUTDIR% tut000.svg tut001.svg tut002.svg tut003.svg tut004.svg tut005.svg tut006.svg
@rem %JAVA% -Djava.awt.headless=true -jar %RASTERIZER% -w 400 -h 300 -d %OUTDIR% tut007.svg tut008.svg tut009.svg tut010.svg tut011.svg tut012.svg tut013.svg
@rem %JAVA% -Djava.awt.headless=true -jar %RASTERIZER% -w 400 -h 300 -d %OUTDIR% tut014.svg tut015.svg tut016.svg

pause
