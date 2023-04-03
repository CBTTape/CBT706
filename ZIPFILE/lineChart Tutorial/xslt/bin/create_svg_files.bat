set JAVA=%JAVA_HOME%\bin\java.exe
set XSLT=org.apache.xalan.xslt.Process
set STYLESHEET=../src/lineChart.xsl
set INDIR=../src
set OUTDIR=../html/svg

%JAVA% %XSLT% -in %INDIR%/tut000.xml -xsl %STYLESHEET% -out %OUTDIR%/tut000.svg
%JAVA% %XSLT% -in %INDIR%/tut001.xml -xsl %STYLESHEET% -out %OUTDIR%/tut001.svg
%JAVA% %XSLT% -in %INDIR%/tut002.xml -xsl %STYLESHEET% -out %OUTDIR%/tut002.svg
%JAVA% %XSLT% -in %INDIR%/tut003.xml -xsl %STYLESHEET% -out %OUTDIR%/tut003.svg
%JAVA% %XSLT% -in %INDIR%/tut004.xml -xsl %STYLESHEET% -out %OUTDIR%/tut004.svg
%JAVA% %XSLT% -in %INDIR%/tut005.xml -xsl %STYLESHEET% -out %OUTDIR%/tut005.svg
%JAVA% %XSLT% -in %INDIR%/tut006.xml -xsl %STYLESHEET% -out %OUTDIR%/tut006.svg
%JAVA% %XSLT% -in %INDIR%/tut007.xml -xsl %STYLESHEET% -out %OUTDIR%/tut007.svg
%JAVA% %XSLT% -in %INDIR%/tut008.xml -xsl %STYLESHEET% -out %OUTDIR%/tut008.svg
%JAVA% %XSLT% -in %INDIR%/tut009.xml -xsl %STYLESHEET% -out %OUTDIR%/tut009.svg
%JAVA% %XSLT% -in %INDIR%/tut010.xml -xsl %STYLESHEET% -out %OUTDIR%/tut010.svg
%JAVA% %XSLT% -in %INDIR%/tut011.xml -xsl %STYLESHEET% -out %OUTDIR%/tut011.svg
%JAVA% %XSLT% -in %INDIR%/tut012.xml -xsl %STYLESHEET% -out %OUTDIR%/tut012.svg
%JAVA% %XSLT% -in %INDIR%/tut013.xml -xsl %STYLESHEET% -out %OUTDIR%/tut013.svg
%JAVA% %XSLT% -in %INDIR%/tut014.xml -xsl %STYLESHEET% -out %OUTDIR%/tut014.svg
%JAVA% %XSLT% -in %INDIR%/tut015.xml -xsl %STYLESHEET% -out %OUTDIR%/tut015.svg
%JAVA% %XSLT% -in %INDIR%/tut016.xml -xsl %STYLESHEET% -out %OUTDIR%/tut016.svg

