# CBT706
Converted to GitHub via [cbt2git](https://github.com/wizardofzos/cbt2git)

This is still a work in progress. GitHub repos will be deleted and created during this period...

```
//***FILE 706 is from Andrew Armstrong and contains a marvelous     *   FILE 706
//*           system to convert your mainframe performance data     *   FILE 706
//*           to SVG (Scalable Vector Graphics) format and display  *   FILE 706
//*           it anywhere in your network, on other platforms.      *   FILE 706
//*                                                                 *   FILE 706
//*           email:  andrew_armstrong@unwired.com.au               *   FILE 706
//*                                                                 *   FILE 706
//*   A description of this contribution follows:                   *   FILE 706
//*                                                                 *   FILE 706
//*     I have a new CBT tape contribution to make...               *   FILE 706
//*                                                                 *   FILE 706
//*     Some time ago (maybe a year or so) someone on IBM-MAIN      *   FILE 706
//*     asked about how to publish mainframe performance graphs     *   FILE 706
//*     on their intranet.  I suggested somehow creating a          *   FILE 706
//*     Scalable Vector Graphics (SVG) file and serving it out      *   FILE 706
//*     directly from your mainframe web server - that way an       *   FILE 706
//*     intranet web server could have a page that just linked      *   FILE 706
//*     to the mainframe web server's SVG file.  The 'somehow'      *   FILE 706
//*     was the bit I didn't have available at the time...          *   FILE 706
//*                                                                 *   FILE 706
//*     Well, I've finally put something together that may be       *   FILE 706
//*     of use to other people (and not just mainframers either     *   FILE 706
//*     because you can run it on a PC or even Linux).              *   FILE 706
//*                                                                 *   FILE 706
//*     Basically the idea is to pull your performance data         *   FILE 706
//*     from wherever (SMF say), using whatever (Rexx,              *   FILE 706
//*     Assembler, it doesn't matter) and create an XML file        *   FILE 706
//*     (which is just text) containing the line chart data.        *   FILE 706
//*     Then you run my contribution (an XSL stylesheet) to         *   FILE 706
//*     transform the XML file into an SVG file which describes     *   FILE 706
//*     the line chart in terms of lines, colors and text.  The     *   FILE 706
//*     SVG file can be served out directly by your mainframe       *   FILE 706
//*     web server so that all the user needs is a browser to       *   FILE 706
//*     view the graphics.  SVG is good for this because            *   FILE 706
//*     complicated graphs don't take up much space - so            *   FILE 706
//*     transmission to the end-user is quick - and the actual      *   FILE 706
//*     rendering of the graphic is done on the user's PC.          *   FILE 706
//*     Also, the images are scalable (at the PC), so no image      *   FILE 706
//*     quality is lost.  Modern software like Microsoft Visio      *   FILE 706
//*     understands the SVG format.                                 *   FILE 706
//*                                                                 *   FILE 706
//*     Alternatively, the SVG file can be converted to an          *   FILE 706
//*     image file (PNG, JPEG or TIFF) and published in the         *   FILE 706
//*     usual way.  The user may have to put up with longer         *   FILE 706
//*     download times and poor print quality though.               *   FILE 706
//*                                                                 *   FILE 706
//*     I have included in the xmit file all the Java JAR files     *   FILE 706
//*     necessary to do the processing, but as a result the         *   FILE 706
//*     xmit file is quite large (8.5 MB) and does not compress     *   FILE 706
//*     well (7.5 MB zipped).                                       *   FILE 706
//*                                                                 *   FILE 706
//*     Oh...and the xmit file is of a RECFM=VB PDS, so the         *   FILE 706
//*     xmitmanager won't be able to be used to extract the         *   FILE 706
//*     files (I've tried but I get garbage).  The only way is      *   FILE 706
//*     to upload the xmit file and let TSO RECEIVE extract the     *   FILE 706
//*     files.                                                      *   FILE 706
//*                                                                 *   FILE 706
//*     - - - - - - - - - - - - - - - - - - - - - - - - - - - -     *   FILE 706
//*                                                                 *   FILE 706
//*     I've uploaded version 1.1 of file706.                       *   FILE 706
//*                                                                 *   FILE 706
//*     This version:                                               *   FILE 706
//*     1. Adds support for rotated labels on line charts           *   FILE 706
//*     2. Upgrades the included Batik jar file to version 1.5.1    *   FILE 706
//*        (was using 1.5.1rc2)                                     *   FILE 706
//*     3. Renames the ZIPFILE member to ZIPDOCS                    *   FILE 706
//*     4. Has Improved html documentation and tutorial stored      *   FILE 706
//*        in ZIPDOCS.                                              *   FILE 706
//*                                                                 *   FILE 706
//*     Cheers,                                                     *   FILE 706
//*     Andrew Armstrong.                                           *   FILE 706
//*                                                                 *   FILE 706
```
