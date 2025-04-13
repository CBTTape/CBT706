<?xml version="1.0" encoding="utf-8"?>
<!--
    Line Chart Transformer 1.1.36
    Copyright (C) 2004-2005 Andrew J. Armstrong

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	Author:
	Andrew J. Armstrong <andrew_armstrong(at)unwired.com.au>
-->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- Hideous Hack:
         When using: Adobe SVG Viewer plugin 3 (or the pre-release 6) to view SVG in Internet Explorer
         And:        You want to serve out the SVG created by lineChart.xsl from a web server
         Then:       You should invoke the xslt transformation processor with a user-defined
                     parameter called "protocol" set to "http:" ...the colon is required.
         This will:  Prefix any referenced resource URLs (for example, image file names) with "http:"
         Example:    java org.apache.xalan.xslt.Process -in file.xml -xsl lineChart.xsl -out file.svg -param protocol http:
         Fixes:      Adobe SVG Viewer not handling relative URLs properly.
    -->
    <xsl:param name="protocol"/>

    <xsl:output method="xml"
        version="1.0"
        encoding="utf-8"
        doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
        indent="yes"
        />

    <xsl:template name="getValueOrDefault">
        <xsl:param name="path"/>
        <xsl:param name="default" select="0"/>
        <xsl:choose>
            <xsl:when test="normalize-space($path) != ''">
                <xsl:value-of select="normalize-space($path)"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$default"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getNonZeroNumber">
        <xsl:param name="n"/>
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="string(number($n)) = 'NaN' or $n = 0"><xsl:value-of select="$default"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:variable name="inset" select="5"/>                                     <!-- Gap size when a gap is needed -->
    <xsl:variable name="defaultMarginSize" select="10"/>                        <!-- Size of the margin around the entire chart -->
    <xsl:variable name="defaultChartTitleHeight" select="40"/>                  <!-- Height of the chart title area -->
    <xsl:variable name="defaultChartTitleFontSize" select="40"/>                <!-- Height of the font within the chart title area -->
    <xsl:variable name="defaultTitleHeight" select="20"/>                       <!-- Height of the axis title area -->
    <xsl:variable name="defaultTitleFontSize" select="20"/>                     <!-- Height of the font within the axis title area -->
    <xsl:variable name="defaultLabelHeight" select="20"/>                       <!-- Height of the label area -->
    <xsl:variable name="defaultLabelFontSize" select="16"/>                     <!-- Height of the font within the label area -->
    <xsl:variable name="defaultLabelRotation" select="0"/>                      <!-- Label rotation in degrees (positive is clockwise) -->
    <xsl:variable name="defaultLegendEntryHeight" select="12"/>                 <!-- Height of a legend entry -->
    <xsl:variable name="defaultLegendEntryWidth" select="$chartWidth div 5"/>   <!-- Width of a legend entry -->

    <xsl:variable name="debugOpacity">0.15</xsl:variable>
    <xsl:variable name="debugStyle">stroke-opacity:<xsl:value-of select="$debugOpacity"/>;fill-opacity:<xsl:value-of select="$debugOpacity"/></xsl:variable>

    <xsl:variable name="chartHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/height/text()"/>
            <xsl:with-param name="default" select="600"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="chartWidth">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/width/text()"/>
            <xsl:with-param name="default" select="800"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="chartMargin">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/margin/text()"/>
            <xsl:with-param name="default" select="$defaultMarginSize"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="chartTitleHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/title/height/text()"/>
            <xsl:with-param name="default" select="$defaultChartTitleHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="chartTitleFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/title/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultChartTitleFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northTitleHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/north/title/height/text()"/>
            <xsl:with-param name="default" select="$defaultTitleHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northTitleFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/north/title/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultTitleFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northLabelHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/north/label/height/text()"/>
            <xsl:with-param name="default" select="$defaultLabelHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northLabelFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/north/label/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultLabelFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northLabelRotation">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/north/label/rotation/text()"/>
            <xsl:with-param name="default" select="$defaultLabelRotation"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="northHeight" select="$chartMargin + $chartTitleHeight + $northTitleHeight + $northLabelHeight + $inset"/>


    <xsl:variable name="southLabelHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/label/height/text()"/>
            <xsl:with-param name="default" select="$defaultLabelHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southLabelFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/label/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultLabelFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southLabelRotation">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/label/rotation/text()"/>
            <xsl:with-param name="default" select="$defaultLabelRotation"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southTitleHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/title/height/text()"/>
            <xsl:with-param name="default" select="$defaultTitleHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southTitleFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/title/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultTitleFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southLegendHeight">
        <xsl:variable name="legendRows" select="1 + floor((count(/chart/series) - 1) div $southLegendColumns)"/>
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/legend/height/text()"/>
            <xsl:with-param name="default" select="$legendRows * $defaultLegendEntryHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southLegendColumns">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/south/legend/columns/text()"/>
            <xsl:with-param name="default" select="4"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="southLegendDisplayHeight">
        <xsl:choose>
            <xsl:when test="//layout/south/legend">
                <xsl:value-of select="$southLegendHeight"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="southHeight" select="$chartMargin + $southLegendDisplayHeight + $inset + $southTitleHeight + $southLabelHeight + $inset"/>

    <xsl:variable name="eastLabelWidth">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/label/width/text()"/>
            <xsl:with-param name="default" select="50"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLabelHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/label/height/text()"/>
            <xsl:with-param name="default" select="$defaultLabelHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLabelFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/label/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultLabelFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLabelRotation">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/label/rotation/text()"/>
            <xsl:with-param name="default" select="$defaultLabelRotation"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastTitleHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/title/height/text()"/>
            <xsl:with-param name="default" select="$defaultTitleHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastTitleFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/title/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultTitleFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLegendEntryWidth">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/legend/width/text()"/>
            <xsl:with-param name="default" select="$eastLegendColumns * $defaultLegendEntryWidth"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLegendColumns">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/east/legend/columns/text()"/>
            <xsl:with-param name="default" select="1"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="eastLegendDisplayWidth">
        <xsl:choose>
            <xsl:when test="//layout/east/legend">
                <xsl:value-of select="$eastLegendEntryWidth"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="eastWidth" select="$inset + $eastLabelWidth + $eastTitleHeight + $inset + $eastLegendDisplayWidth + $chartMargin"/>

    <xsl:variable name="westTitleHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/title/height/text()"/>
            <xsl:with-param name="default" select="$defaultTitleHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westTitleFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/title/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultTitleFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westLabelWidth">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/label/width/text()"/>
            <xsl:with-param name="default" select="50"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westLabelHeight">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/label/height/text()"/>
            <xsl:with-param name="default" select="$defaultLabelHeight"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westLabelFontSize">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/label/fontsize/text()"/>
            <xsl:with-param name="default" select="$defaultLabelFontSize"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westLabelRotation">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/layout/west/label/rotation/text()"/>
            <xsl:with-param name="default" select="$defaultLabelRotation"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="westWidth" select="$chartMargin + $westTitleHeight + $westLabelWidth + $inset"/>

    <xsl:variable name="gridlineMajorX">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x/gridline/major/text()"/>
            <xsl:with-param name="default" select="'true'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="gridlineMajorY">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y/gridline/major/text()"/>
            <xsl:with-param name="default" select="'true'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="gridlineMinorX">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x/gridline/minor/text()"/>
            <xsl:with-param name="default" select="'false'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="gridlineMinorY">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y/gridline/minor/text()"/>
            <xsl:with-param name="default" select="'false'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="intervalMajorX">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x/interval/major/text()"/>
            <xsl:with-param name="default" select="$defaultIntervalMajorX"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="defaultIntervalMajorX">
        <xsl:call-template name="getInterval">
            <xsl:with-param name="min" select="$minX"/>
            <xsl:with-param name="max" select="$maxX"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="intervalMajorX2">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x2/interval/major/text()"/>
            <xsl:with-param name="default" select="$defaultIntervalMajorX2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="defaultIntervalMajorX2">
        <xsl:call-template name="getInterval">
            <xsl:with-param name="min" select="$minX2"/>
            <xsl:with-param name="max" select="$maxX2"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="intervalMajorY">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y/interval/major/text()"/>
            <xsl:with-param name="default" select="$defaultIntervalMajorY"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="defaultIntervalMajorY">
        <xsl:call-template name="getInterval">
            <xsl:with-param name="min" select="$minY"/>
            <xsl:with-param name="max" select="$maxY"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="intervalMajorY2">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y2/interval/major/text()"/>
            <xsl:with-param name="default" select="$defaultIntervalMajorY2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="defaultIntervalMajorY2">
        <xsl:call-template name="getInterval">
            <xsl:with-param name="min" select="$minY2"/>
            <xsl:with-param name="max" select="$maxY2"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="intervalMinorX">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x/interval/minor/text()"/>
            <xsl:with-param name="default" select="$intervalMajorX div 2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="intervalMinorX2">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/x2/interval/minor/text()"/>
            <xsl:with-param name="default" select="$intervalMajorX2 div 2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="intervalMinorY">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y/interval/minor/text()"/>
            <xsl:with-param name="default" select="$intervalMajorY div 2"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="intervalMinorY2">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/axis/y2/interval/minor/text()"/>
            <xsl:with-param name="default" select="$intervalMajorY2 div 2"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="seriesHueInitial">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/hue/initial/text()"/>
            <xsl:with-param name="default" select="250"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesHueStep">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/hue/step/text()"/>
            <xsl:with-param name="default" select="47"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="seriesSaturationMin">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/saturation/min/text()"/>
            <xsl:with-param name="default" select="0.6"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesSaturationMax">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/saturation/max/text()"/>
            <xsl:with-param name="default" select="1.0"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesSaturationLevels">
        <xsl:call-template name="getNonZeroNumber">
            <xsl:with-param name="n" select="/chart/style/series/saturation/levels/text()"/>
            <xsl:with-param name="default" select="5"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesSaturationStep">
        <xsl:choose>
            <xsl:when test="$seriesSaturationLevels > 1">
                <xsl:value-of select="($seriesSaturationMax - $seriesSaturationMin) div ($seriesSaturationLevels - 1)"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="seriesBrightnessMin">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/brightness/min/text()"/>
            <xsl:with-param name="default" select="0.4"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesBrightnessMax">
        <xsl:call-template name="getValueOrDefault">
            <xsl:with-param name="path" select="/chart/style/series/brightness/max/text()"/>
            <xsl:with-param name="default" select="1.0"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesBrightnessLevels">
        <xsl:call-template name="getNonZeroNumber">
            <xsl:with-param name="n" select="/chart/style/series/brightness/levels/text()"/>
            <xsl:with-param name="default" select="5"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="seriesBrightnessStep">
        <xsl:choose>
            <xsl:when test="$seriesBrightnessLevels > 1">
                <xsl:value-of select="($seriesBrightnessMax - $seriesBrightnessMin) div ($seriesBrightnessLevels - 1)"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>




    <xsl:variable name="formatLabelX">
        <xsl:choose>
            <xsl:when test="/chart/style/label/x/format/text()">
                <xsl:value-of select="/chart/style/label/x/format/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="interval" select="$intervalMajorX"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="formatLabelX2">
        <xsl:choose>
            <xsl:when test="/chart/style/label/x2/format/text()">
                <xsl:value-of select="/chart/style/label/x2/format/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="interval" select="$intervalMajorX2"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="formatLabelY">
        <xsl:choose>
            <xsl:when test="/chart/style/label/y/format/text()">
                <xsl:value-of select="/chart/style/label/y/format/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="interval" select="$intervalMajorY"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="formatLabelY2">
        <xsl:choose>
            <xsl:when test="/chart/style/label/y2/format/text()">
                <xsl:value-of select="/chart/style/label/y2/format/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="getFormat">
                    <xsl:with-param name="interval" select="$intervalMajorY2"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:variable name="plotareaHeight" select="$chartHeight - $northHeight - $southHeight"/>
    <xsl:variable name="plotareaWidth" select="$chartWidth  - $westWidth - $eastWidth"/>




    <xsl:variable name="minY">
        <xsl:choose>
            <xsl:when test="/chart/axis/y/range/min">
                <xsl:value-of select="/chart/axis/y/range/min/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/chart/series/datum[string(number(@y)) != 'NaN']">
                    <xsl:sort order="ascending" data-type="number" select="@y"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@y"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="maxY">
        <xsl:choose>
            <xsl:when test="/chart/axis/y/range/max">
                <xsl:value-of select="/chart/axis/y/range/max/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/chart/series/datum[string(number(@y)) != 'NaN']">
                    <xsl:sort order="descending" data-type="number" select="@y"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@y"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rangeMinY">
        <xsl:value-of select="floor($minY div $intervalMajorY) * $intervalMajorY"/>
    </xsl:variable>

    <xsl:variable name="rangeMaxY">
        <xsl:value-of select="ceiling($maxY div $intervalMajorY) * $intervalMajorY"/>
    </xsl:variable>

    <xsl:variable name="rangeY">
        <xsl:value-of select="$rangeMaxY - $rangeMinY"/>
    </xsl:variable>




    <xsl:variable name="minY2">
        <xsl:choose>
            <xsl:when test="/chart/axis/y2/range/min">
                <xsl:value-of select="/chart/axis/y2/range/min/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/chart/series/datum[string(number(@y2)) != 'NaN']">
                    <xsl:sort order="ascending" data-type="number" select="@y2"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@y2"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="maxY2">
        <xsl:choose>
            <xsl:when test="/chart/axis/y2/range/max">
                <xsl:value-of select="/chart/axis/y2/range/max/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/chart/series/datum[string(number(@y2)) != 'NaN']">
                    <xsl:sort order="descending" data-type="number" select="@y2"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@y2"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rangeMinY2">
        <xsl:value-of select="floor($minY2 div $intervalMajorY2) * $intervalMajorY2"/>
    </xsl:variable>

    <xsl:variable name="rangeMaxY2">
        <xsl:value-of select="ceiling($maxY2 div $intervalMajorY2) * $intervalMajorY2"/>
    </xsl:variable>

    <xsl:variable name="rangeY2">
        <xsl:value-of select="$rangeMaxY2 - $rangeMinY2"/>
    </xsl:variable>




    <xsl:variable name="minX">
        <xsl:choose>
            <!-- If the user has supplied a minimum X value, then use it -->
            <xsl:when test="string(number(/chart/axis/x/range/min/text())) != 'NaN'">
                <xsl:value-of select="/chart/axis/x/range/min/text()"/>
            </xsl:when>
            <!-- Otherwise, it gets complicated... -->
            <xsl:otherwise>
                <!-- Get the minimum x (=NaN if there is a missing x)-->
                <xsl:variable name="min">
                    <xsl:for-each select="/chart/series/datum">
                        <xsl:sort order="ascending" data-type="number" select="@x"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <!-- Get the minimum (specified) x (=NaN if all x values are omitted) -->
                <xsl:variable name="minSpecified">
                    <xsl:for-each select="/chart/series/datum[string(number(@x)) != 'NaN']">
                        <xsl:sort order="ascending" data-type="number" select="@x"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <!-- If all X values are omitted, then return 0 as the minimum X value -->
                    <xsl:when test="string(number($minSpecified)) = 'NaN'">0</xsl:when>
                    <!-- If any X value is omitted, then return min(0,$min) as the minimum X value -->
                    <xsl:when test="string(number($min)) = 'NaN'">
                        <xsl:choose>
                            <xsl:when test="$minSpecified &lt; 0">
                                <xsl:value-of select="$minSpecified"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- If no X values are omitted, then return the minimum specified X value -->
                    <xsl:otherwise>
                        <xsl:value-of select="$min"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="maxX">
        <xsl:choose>
            <!-- If the user has supplied a maximum X value, then use it -->
            <xsl:when test="string(number(/chart/axis/x/range/max/text())) != 'NaN'">
                <xsl:value-of select="/chart/axis/x/range/max/text()"/>
            </xsl:when>
            <!-- Otherwise, use the maximum (specified) X value in the series data -->
            <xsl:otherwise>
                <xsl:variable name="max">
                    <xsl:for-each select="/chart/series/datum[string(number(@x)) != 'NaN']">
                        <xsl:sort order="descending" data-type="number" select="@x"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <!-- If all X values are omitted, then use the maximum number of datum points in any one data series (less 1) -->
                    <xsl:when test="string(number($max)) = 'NaN'">
                        <xsl:value-of select="$maxDatumCount - 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$max"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rangeMinX">
        <xsl:value-of select="floor($minX div $intervalMajorX) * $intervalMajorX"/>
    </xsl:variable>

    <xsl:variable name="rangeMaxX">
        <xsl:value-of select="ceiling($maxX div $intervalMajorX) * $intervalMajorX"/>
    </xsl:variable>

    <xsl:variable name="rangeX">
        <xsl:value-of select="$rangeMaxX - $rangeMinX"/>
    </xsl:variable>




    <xsl:variable name="minX2">
        <xsl:choose>
            <!-- If the user has supplied a minimum X2 value, then use it -->
            <xsl:when test="string(number(/chart/axis/x2/range/min/text())) != 'NaN'">
                <xsl:value-of select="/chart/axis/x2/range/min/text()"/>
            </xsl:when>
            <!-- Otherwise, it gets complicated... -->
            <xsl:otherwise>
                <!-- Get the minimum x2 (=NaN if there is a missing x2)-->
                <xsl:variable name="min">
                    <xsl:for-each select="/chart/series/datum">
                        <xsl:sort order="ascending" data-type="number" select="@x2"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x2"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <!-- Get the minimum (specified) x2 (=NaN if all x2 values are omitted) -->
                <xsl:variable name="minSpecified">
                    <xsl:for-each select="/chart/series/datum[string(number(@x2)) != 'NaN']">
                        <xsl:sort order="ascending" data-type="number" select="@x2"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x2"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <!-- If all X2 values are omitted, then return 0 as the minimum X2 value -->
                    <xsl:when test="string(number($minSpecified)) = 'NaN'">0</xsl:when>
                    <!-- If any X2 value is omitted, then return min(0,$min) as the minimum X2 value -->
                    <xsl:when test="string(number($min)) = 'NaN'">
                        <xsl:choose>
                            <xsl:when test="$minSpecified &lt; 0">
                                <xsl:value-of select="$minSpecified"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- If no X2 values are omitted, then return the minimum specified X2 value -->
                    <xsl:otherwise>
                        <xsl:value-of select="$min"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="maxX2">
        <xsl:choose>
            <!-- If the user has supplied a maximum X2 value, then use it -->
            <xsl:when test="string(number(/chart/axis/x2/range/max/text())) != 'NaN'">
                <xsl:value-of select="/chart/axis/x2/range/max/text()"/>
            </xsl:when>
            <!-- Otherwise, use the maximum (specified) X2 value in the series data -->
            <xsl:otherwise>
                <xsl:variable name="max">
                    <xsl:for-each select="/chart/series/datum[string(number(@x2)) != 'NaN']">
                        <xsl:sort order="descending" data-type="number" select="@x2"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="@x2"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <!-- If all X2 values are omitted, then use the maximum number of datum points in any one data series -->
                    <xsl:when test="string(number($max)) = 'NaN'">
                        <xsl:value-of select="$maxDatumCount - 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$max"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rangeMinX2">
        <xsl:value-of select="floor($minX2 div $intervalMajorX2) * $intervalMajorX2"/>
    </xsl:variable>

    <xsl:variable name="rangeMaxX2">
        <xsl:value-of select="ceiling($maxX2 div $intervalMajorX2) * $intervalMajorX2"/>
    </xsl:variable>

    <xsl:variable name="rangeX2">
        <xsl:value-of select="$rangeMaxX2 - $rangeMinX2"/>
    </xsl:variable>



    <xsl:variable name="maxDatumCount">
        <xsl:choose>
            <xsl:when test="/chart/series">
                <xsl:for-each select="/chart/series">
                    <xsl:sort order="descending" data-type="number" select="count(datum)"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="count(datum)"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="scaleY">
        <xsl:value-of select="$plotareaHeight div $rangeY"/>
    </xsl:variable>

    <xsl:variable name="scaleY2">
        <xsl:value-of select="$plotareaHeight div $rangeY2"/>
    </xsl:variable>

    <xsl:variable name="scaleX">
        <xsl:value-of select="$plotareaWidth div $rangeX"/>
    </xsl:variable>

    <xsl:variable name="scaleX2">
        <xsl:value-of select="$plotareaWidth div $rangeX2"/>
    </xsl:variable>

    <xsl:template name="getInterval">
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:variable name="range" select="$max - $min"/>
        <xsl:choose>
            <xsl:when test="$range &gt;= 1">
                <xsl:variable name="len" select="string-length(floor($range))"/>
                <xsl:variable name="int" select="substring('10000000000000000000000',1,$len)"/>
                <xsl:variable name="intervals" select="floor($range div $int)"/>
                <!-- Try to keep the number of intervals between 2 and 20 -->
                <xsl:choose>
                    <xsl:when test="$intervals = 1">    <!--only one interval: not good-->
                        <xsl:value-of select="$int div 10"/>
                    </xsl:when>
                    <xsl:when test="$intervals &lt;= 20">
                        <xsl:value-of select="$int"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$int * 10"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise> <!-- range is fractional -->
                <xsl:variable name="nx" select="translate($range,'123456789','XXXXXXXXX')"/>
                <xsl:variable name="int" select="concat(substring-before($nx,'X'),'1')"/>
                <xsl:variable name="intervals" select="floor($range div $int)"/>
                <!-- Try to keep the number of intervals between 2 and 20 -->
                <xsl:choose>
                    <xsl:when test="$intervals = 1">    <!--only one interval: not good-->
                        <xsl:value-of select="$int div 10"/>
                    </xsl:when>
                    <xsl:when test="$intervals &lt;= 20">
                        <xsl:value-of select="$int"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$int * 10"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFormat">
        <xsl:param name="interval"/>
        <xsl:choose>
            <xsl:when test="$interval &gt;= 1">#0</xsl:when>
            <xsl:otherwise> <!-- 0.nnnnn -->
                <xsl:variable name="f" select="substring('0.00000000000000000000',1,string-length($interval))"/>
                <xsl:value-of select="$f"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="/">
        <svg xmlns:svg="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            viewBox="0 0 {$chartWidth} {$chartHeight}"
            width="{$chartWidth}"
            height="{$chartHeight}">

            <xsl:if test="/chart/@debug = 'true'">
                <xsl:comment>

                      chartHeight=<xsl:value-of select="$chartHeight"/>
                       chartWidth=<xsl:value-of select="$chartWidth"/>
                      chartMargin=<xsl:value-of select="$chartMargin"/>

                   plotareaHeight=<xsl:value-of select="$plotareaHeight"/>
                    plotareaWidth=<xsl:value-of select="$plotareaWidth"/>

                 chartTitleHeight=<xsl:value-of select="$chartTitleHeight"/>
                 northTitleHeight=<xsl:value-of select="$northTitleHeight"/>
                 northLabelHeight=<xsl:value-of select="$northLabelHeight"/>
                      northHeight=<xsl:value-of select="$northHeight"/>

                 southLabelHeight=<xsl:value-of select="$southLabelHeight"/>
                 southTitleHeight=<xsl:value-of select="$southTitleHeight"/>
                      southHeight=<xsl:value-of select="$southHeight"/>

                   eastLabelWidth=<xsl:value-of select="$eastLabelWidth"/>
                  eastLabelHeight=<xsl:value-of select="$eastLabelHeight"/>
                  eastTitleHeight=<xsl:value-of select="$eastTitleHeight"/>
                        eastWidth=<xsl:value-of select="$eastWidth"/>

                  westTitleHeight=<xsl:value-of select="$westTitleHeight"/>
                   westLabelWidth=<xsl:value-of select="$westLabelWidth"/>
                  westLabelHeight=<xsl:value-of select="$westLabelHeight"/>
                        westWidth=<xsl:value-of select="$westWidth"/>

                   gridlineMajorX=<xsl:value-of select="$gridlineMajorX"/>
                   gridlineMajorY=<xsl:value-of select="$gridlineMajorY"/>
                   gridlineMinorX=<xsl:value-of select="$gridlineMinorX"/>
                   gridlineMinorY=<xsl:value-of select="$gridlineMinorY"/>

                   intervalMajorX=<xsl:value-of select="$intervalMajorX"/>
                   intervalMajorY=<xsl:value-of select="$intervalMajorY"/>
                  intervalMajorX2=<xsl:value-of select="$intervalMajorX2"/>
                  intervalMajorY2=<xsl:value-of select="$intervalMajorY2"/>
                   intervalMinorX=<xsl:value-of select="$intervalMinorX"/>
                   intervalMinorY=<xsl:value-of select="$intervalMinorY"/>
                  intervalMinorX2=<xsl:value-of select="$intervalMinorX2"/>
                  intervalMinorY2=<xsl:value-of select="$intervalMinorY2"/>

                             minX=<xsl:value-of select="$minX"/>
                             maxX=<xsl:value-of select="$maxX"/>
                        rangeMinX=<xsl:value-of select="$rangeMinX"/>
                        rangeMaxX=<xsl:value-of select="$rangeMaxX"/>
                           rangeX=<xsl:value-of select="$rangeX"/>
                           scaleX=<xsl:value-of select="$scaleX"/>

                            minX2=<xsl:value-of select="$minX2"/>
                            maxX2=<xsl:value-of select="$maxX2"/>
                       rangeMinX2=<xsl:value-of select="$rangeMinX2"/>
                       rangeMaxX2=<xsl:value-of select="$rangeMaxX2"/>
                          rangeX2=<xsl:value-of select="$rangeX2"/>
                          scaleX2=<xsl:value-of select="$scaleX2"/>

                             minY=<xsl:value-of select="$minY"/>
                             maxY=<xsl:value-of select="$maxY"/>
                        rangeMinY=<xsl:value-of select="$rangeMinY"/>
                        rangeMaxY=<xsl:value-of select="$rangeMaxY"/>
                           rangeY=<xsl:value-of select="$rangeY"/>
                           scaleY=<xsl:value-of select="$scaleY"/>

                            minY2=<xsl:value-of select="$minY2"/>
                            maxY2=<xsl:value-of select="$maxY2"/>
                       rangeMinY2=<xsl:value-of select="$rangeMinY2"/>
                       rangeMaxY2=<xsl:value-of select="$rangeMaxY2"/>
                          rangeY2=<xsl:value-of select="$rangeY2"/>
                          scaleY2=<xsl:value-of select="$scaleY2"/>

                       hueInitial=<xsl:value-of select="$seriesHueInitial"/>
                          hueStep=<xsl:value-of select="$seriesHueStep"/>
                    saturationMin=<xsl:value-of select="$seriesSaturationMin"/>
                    saturationMax=<xsl:value-of select="$seriesSaturationMax"/>
                 saturationLevels=<xsl:value-of select="$seriesSaturationLevels"/>
                   saturationStep=<xsl:value-of select="$seriesSaturationStep"/>
                    brightnessMin=<xsl:value-of select="$seriesBrightnessMin"/>
                    brightnessMax=<xsl:value-of select="$seriesBrightnessMax"/>
                 brightnessLevels=<xsl:value-of select="$seriesBrightnessLevels"/>
                   brightnessStep=<xsl:value-of select="$seriesBrightnessStep"/>
                    <xsl:text> </xsl:text>
                </xsl:comment>
            </xsl:if>


            <style type="text/css">
                <xsl:text disable-output-escaping="yes">
&lt;![CDATA[</xsl:text>
        .debug          {fill:none;stroke-width:0.5;stroke-opacity:1;stroke:green;}
        .debugText      {font-family:Arial;font-weight:bold;text-anchor:middle;fill:black;stroke:none;}
        .grid           {fill:none;stroke-width:2;stroke:#fafafa;<xsl:value-of select="normalize-space(/chart/style/grid/text())"/>;}
        .gridVert       {<xsl:value-of select="normalize-space(/chart/style/grid/vertical/text())"/>;}
        .gridVertMajor  {<xsl:value-of select="normalize-space(/chart/style/grid/vertical/major/text())"/>;}
        .gridVertMinor  {stroke-width:1;stroke-dasharray:1;<xsl:value-of select="normalize-space(/chart/style/grid/vertical/minor/text())"/>;}
        .gridHorz       {<xsl:value-of select="normalize-space(/chart/style/grid/horizontal/text())"/>;}
        .gridHorzMajor  {<xsl:value-of select="normalize-space(/chart/style/grid/horizontal/major/text())"/>;}
        .gridHorzMinor  {stroke-width:1;stroke-dasharray:1;<xsl:value-of select="normalize-space(/chart/style/grid/horizontal/minor/text())"/>;}
        .ref            {stroke:blue;stroke-width:1;stroke-dasharray:1,2;<xsl:value-of select="normalize-space(/chart/style/reference/text())"/>;}
        .refVert        {<xsl:value-of select="normalize-space(/chart/style/reference/vertical/text())"/>;}
        .refHorz        {<xsl:value-of select="normalize-space(/chart/style/reference/horizontal/text())"/>;}
        .label          {stroke:none;fill:black;font-size:<xsl:value-of select="$defaultLabelFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/label/text())"/>;}
        .labelX         {text-anchor:middle;font-size:<xsl:value-of select="$southLabelFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/label/x/text())"/>;}
        .labelY         {text-anchor:end;font-size:<xsl:value-of select="$westLabelFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/label/y/text())"/>;}
        .labelX2        {text-anchor:middle;font-size:<xsl:value-of select="$northLabelFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/label/x2/text())"/>;}
        .labelY2        {text-anchor:start;font-size:<xsl:value-of select="$eastLabelFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/label/y2/text())"/>;}
        .title          {text-anchor:middle;fill:gold;stroke:goldenrod;font-size:<xsl:value-of select="$chartTitleFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/title/text())"/>;}
        .titleX         {text-anchor:middle;fill:black;font-size:<xsl:value-of select="$southTitleFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/title/x/text())"/>;}
        .titleX2        {text-anchor:middle;fill:black;font-size:<xsl:value-of select="$northTitleFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/title/x2/text())"/>;}
        .titleY         {text-anchor:middle;fill:black;font-size:<xsl:value-of select="$westTitleFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/title/y/text())"/>;}
        .titleY2        {text-anchor:middle;fill:black;font-size:<xsl:value-of select="$eastTitleFontSize"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/title/y2/text())"/>;}
        .plotarea       {<xsl:choose>
                            <xsl:when test="/chart/style/plotarea/gradient">
                                <xsl:text>fill:url(#backgroundGradient);</xsl:text>
                            </xsl:when>
                            <xsl:when test="/chart/style/plotarea/color">
                                <xsl:text>fill:</xsl:text><xsl:value-of select="normalize-space(/chart/style/plotarea/color/text())"/>
                                <xsl:text>;fill-opacity:</xsl:text><xsl:value-of select="/chart/style/plotarea/color/@opacity"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>fill:white</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>;}</xsl:text>
        .plotareaBorder {fill:none;stroke:gray;stroke-width:3;<xsl:value-of select="normalize-space(/chart/style/plotarea/border/text())"/>
                        <xsl:text>;</xsl:text><xsl:if test="/chart/@debug = 'true'"><xsl:value-of select="$debugStyle"/></xsl:if>;}
        .legend         {stroke:none;fill:black;font-size:<xsl:value-of select="$defaultLegendEntryHeight"/>;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/legend/text())"/>
                        <xsl:text>;</xsl:text><xsl:if test="/chart/@debug = 'true'"><xsl:value-of select="$debugStyle"/></xsl:if>;}
        .annotation     {fill:gold;stroke:black;fill-opacity:0.2;stroke-opacity:0.2;font-size:10px;<xsl:value-of select="normalize-space(/chart/style/annotation/marker/text())"/>
                        <xsl:text>;</xsl:text><xsl:if test="/chart/@debug = 'true'"><xsl:value-of select="$debugStyle"/></xsl:if>;}
        .annotationText {fill:black;fill-opacity:0.7;stroke:none;<xsl:value-of select="normalize-space(/chart/style/text())"/>;<xsl:value-of select="normalize-space(/chart/style/annotation/text/text())"/>;text-anchor:middle
                        <xsl:text>;</xsl:text><xsl:if test="/chart/@debug = 'true'"><xsl:value-of select="$debugStyle"/></xsl:if>;}
        .series         {fill:none;stroke-width:5;stroke-opacity:0.5;stroke-linejoin:round;stroke-linecap:round;<xsl:value-of select="normalize-space(/chart/style/series/text())"/>
                        <xsl:text>;</xsl:text><xsl:if test="/chart/@debug = 'true'"><xsl:value-of select="$debugStyle"/></xsl:if>;}
    <xsl:apply-templates select="chart/series" mode="css-style-sheet"/>
<xsl:text disable-output-escaping="yes">]]&gt;
</xsl:text>
            </style>
            <defs>
                <xsl:if test="/chart/style/plotarea/gradient">
                    <xsl:element name="linearGradient">
                        <xsl:attribute name="id">backgroundGradient</xsl:attribute>
                        <xsl:attribute name="x1">0%</xsl:attribute>
                        <xsl:attribute name="y1">0%</xsl:attribute>
                        <xsl:attribute name="x2">0%</xsl:attribute>
                        <xsl:attribute name="y2">100%</xsl:attribute>
                        <xsl:copy-of select="/chart/style/plotarea/gradient/@*"/> <!-- user can specify spreadMethod here, for example -->
                        <xsl:choose>
                            <xsl:when test="/chart/style/plotarea/gradient/*">
                                <xsl:apply-templates select="/chart/style/plotarea/gradient/color" mode="getStops"/>
                            </xsl:when>
                            <xsl:otherwise> <!--default gradient-->
                                <stop offset="25%" style="stop-color:skyblue;stop-opacity:0.2;"/>
                                <stop offset="75%" style="stop-color:mediumturquoise;stop-opacity:0.5;"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:if>
                <filter id="shadowFilter" height="100" width="100">
                    <feGaussianBlur result="blur" stdDeviation="4" in="SourceAlpha"/>
                    <feOffset result="offsetBlur" dy="4" dx="4" in="blur"/>
                    <feSpecularLighting result="specular" lighting-color="#bbbbbb" specularExponent="20" specularConstant=".75" surfaceScale="5" in="blur">
                        <fePointLight z="20000" y="-10000" x="-5000"/>
                    </feSpecularLighting>
                    <feComposite result="specular" operator="in" in2="SourceAlpha" in="specular"/>
                    <feComposite result="shiney" k4="0" k3="1" k2="1" k1="0" operator="arithmetic" in2="specular" in="SourceGraphic"/>
                    <feMerge>
                        <feMergeNode in="offsetBlur"/>
                        <feMergeNode in="shiney"/>
                    </feMerge>
                </filter>
                <filter id="invertedShadowFilter" height="100" width="100">
                    <feGaussianBlur result="blur" stdDeviation="4" in="SourceAlpha"/>
                    <feOffset result="offsetBlur" dy="-4" dx="4" in="blur"/>
                    <feSpecularLighting result="specular" lighting-color="#bbbbbb" specularExponent="20" specularConstant=".75" surfaceScale="5" in="blur">
                        <fePointLight z="20000" y="-10000" x="-5000"/>
                    </feSpecularLighting>
                    <feComposite result="specular" operator="in" in2="SourceAlpha" in="specular"/>
                    <feComposite result="shiney" k4="0" k3="1" k2="1" k1="0" operator="arithmetic" in2="specular" in="SourceGraphic"/>
                    <feMerge>
                        <feMergeNode in="offsetBlur"/>
                        <feMergeNode in="shiney"/>
                    </feMerge>
                </filter>
            </defs>

            <xsl:element name="g">
                <xsl:attribute name="transform">
                    <xsl:text>matrix(1 0 0 -1 </xsl:text>
                    <xsl:value-of select="$westWidth"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$northHeight + $plotareaHeight"/>
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:if test="/chart/@debug = 'true'">
                    <xsl:attribute name="style">
                        <xsl:value-of select="$debugStyle"/>
                    </xsl:attribute>
                </xsl:if>

            <!-- Translate to plot area and invert the y-axis for ease of drawing (i.e. so that 'up' is now positive)... -->
<!--            <g transform="matrix(1 0 0 -1 {$westWidth} {$northHeight + $plotareaHeight})" style="stroke-opacity:{$chartOpacity};fill-opacity:{$chartOpacity}">-->
                <xsl:if test="//layout/south/legend">
                    <xsl:comment>South Legend</xsl:comment>
                    <xsl:call-template name="drawLegend">
                        <xsl:with-param name="legendOriginX" select="0"/>
                        <xsl:with-param name="legendOriginY" select="-$southLabelHeight - $southTitleHeight - $inset"/>
                        <xsl:with-param name="legendWidth" select="$plotareaWidth"/>
                        <xsl:with-param name="legendHeight" select="$southLegendHeight"/>
                        <xsl:with-param name="legendColumns" select="$southLegendColumns"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:if test="//layout/east/legend">
                    <xsl:comment>East Legend</xsl:comment>
                    <xsl:call-template name="drawLegend">
                        <xsl:with-param name="legendOriginX" select="$plotareaWidth  + $inset + $eastLabelWidth + $eastTitleHeight + $inset"/>
                        <xsl:with-param name="legendOriginY" select="$plotareaHeight"/>
                        <xsl:with-param name="legendWidth" select="$eastLegendEntryWidth"/>
                        <xsl:with-param name="legendHeight" select="$plotareaHeight"/>
                        <xsl:with-param name="legendColumns" select="$eastLegendColumns"/>
                    </xsl:call-template>
                </xsl:if>
                <g class="label">
                    <xsl:if test="string(number($rangeMinX)) != 'NaN'">
                        <g class="labelX" transform="matrix(1 0 0 -1 0 {-$southLabelHeight div 2 - $southLabelFontSize div 2})">
                            <xsl:comment>X-axis Labels</xsl:comment>
                            <xsl:call-template name="drawLabelOnXAxis">
                                <xsl:with-param name="at">
                                    <xsl:value-of select="$rangeMinX"/>
                                </xsl:with-param>
                                <xsl:with-param name="by">
                                    <xsl:value-of select="$intervalMajorX"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </g>
                    </xsl:if>
                    <!-- Text on the chart needs to be inverted (again) so that it appears right-side-up... -->
                    <xsl:if test="string(number($rangeMinY)) != 'NaN'">
                        <g class="labelY" transform="matrix(1 0 0 -1 {-$inset} {-($rangeMinY * $scaleY)})">
                            <xsl:comment>Y-axis Labels</xsl:comment>
                            <xsl:call-template name="drawLabelOnYAxis">
                                <xsl:with-param name="at">
                                    <xsl:value-of select="$rangeMinY"/>
                                </xsl:with-param>
                                <xsl:with-param name="by">
                                    <xsl:value-of select="$intervalMajorY"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </g>
                    </xsl:if>
                    <xsl:if test="/chart/layout/north/label and string(number($rangeMinX2)) != 'NaN'">
                        <g class="labelX2" transform="matrix(1 0 0 -1 0 {$plotareaHeight + $inset + $northLabelHeight div 2 - $northLabelFontSize div 4})">
                            <xsl:comment>X2-axis Labels</xsl:comment>
                            <xsl:call-template name="drawLabelOnX2Axis">
                                <xsl:with-param name="at">
                                    <xsl:value-of select="$rangeMinX2"/>
                                </xsl:with-param>
                                <xsl:with-param name="by">
                                    <xsl:value-of select="$intervalMajorX2"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </g>
                    </xsl:if>
                    <xsl:if test="string(number($rangeMinY2)) != 'NaN'">
                        <g class="labelY2" transform="matrix(1 0 0 -1 {$plotareaWidth + $inset} {-($rangeMinY2 * $scaleY2)})">
                            <xsl:comment>Y2-axis Labels</xsl:comment>
                            <xsl:call-template name="drawLabelOnY2Axis">
                                <xsl:with-param name="at">
                                    <xsl:value-of select="$rangeMinY2"/>
                                </xsl:with-param>
                                <xsl:with-param name="by">
                                    <xsl:value-of select="$intervalMajorY2"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </g>
                    </xsl:if>
                </g>
                <g class="title" transform="matrix(1 0 0 -1 {-$westWidth} {$plotareaHeight + $inset + $northLabelHeight + $northTitleHeight + $chartTitleHeight div 2 - $chartTitleFontSize div 4})" filter="url(#shadowFilter)">
                    <xsl:comment>Chart Title</xsl:comment>
                    <xsl:element name="text">
                        <xsl:attribute name="x">
                            <xsl:value-of select="$chartWidth * 0.5"/>
                        </xsl:attribute>
                        <xsl:attribute name="y">0</xsl:attribute>
                        <xsl:value-of select="/chart/title/text()"/>
                    </xsl:element>
                </g>
                <xsl:if test="/chart/axis/x/title">
                    <g class="titleX" transform="matrix(1 0 0 -1 0 {-$inset - $southLabelHeight - $southTitleHeight div 2 - $southTitleFontSize div 4})">
                        <xsl:comment>X-axis Title</xsl:comment>
                        <xsl:element name="text">
                            <xsl:attribute name="x">
                                <xsl:value-of select="$plotareaWidth * 0.5"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">0</xsl:attribute>
                            <xsl:value-of select="/chart/axis/x/title/text()"/>
                        </xsl:element>
                    </g>
                </xsl:if>
                <xsl:if test="/chart/axis/y/title">
                    <g class="titleY" transform="matrix(1 0 0 -1 {-$inset - $westLabelWidth - $westTitleHeight div 2 + $westTitleFontSize div 4} 0), rotate(-90 0 {-$plotareaHeight * 0.5})">
                        <xsl:comment>Y-axis Title</xsl:comment>
                        <xsl:element name="text">
                            <xsl:attribute name="x">0</xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="-$plotareaHeight * 0.5"/>
                            </xsl:attribute>
                            <xsl:value-of select="/chart/axis/y/title/text()"/>
                        </xsl:element>
                    </g>
                </xsl:if>
                <xsl:if test="/chart/axis/x2/title">
                    <g class="titleX2" transform="matrix(1 0 0 -1 0 {$plotareaHeight + $inset + $northLabelHeight + $northTitleHeight div 2 - $northTitleFontSize div 4})">
                        <xsl:comment>X2-axis Title</xsl:comment>
                        <xsl:element name="text">
                            <xsl:attribute name="x">
                                <xsl:value-of select="$plotareaWidth * 0.5"/>
                            </xsl:attribute>
                            <xsl:attribute name="y">0</xsl:attribute>
                            <xsl:value-of select="/chart/axis/x2/title/text()"/>
                        </xsl:element>
                    </g>
                </xsl:if>
                <xsl:if test="/chart/axis/y2/title">
                    <g class="titleY2" transform="matrix(1 0 0 -1 {$plotareaWidth + $inset + $eastLabelWidth + $eastTitleHeight div 2 + $eastTitleFontSize div 4} 0), rotate(-90 0 {-$plotareaHeight * 0.5})">
                        <xsl:comment>Y2-axis Title</xsl:comment>
                        <xsl:element name="text">
                            <xsl:attribute name="x">0</xsl:attribute>
                            <xsl:attribute name="y">
                                <xsl:value-of select="-$plotareaHeight * 0.5"/>
                            </xsl:attribute>
                            <xsl:value-of select="/chart/axis/y2/title/text()"/>
                        </xsl:element>
                    </g>
                </xsl:if>
                <!-- Graphical markup remains inverted and is clipped to the plot area... -->
                <clipPath id="clipPlotarea">
                    <rect height="{$plotareaHeight}" width="{$plotareaWidth}" y="0" x="0" />
                </clipPath>
                <g  clip-path="url(#clipPlotarea)">
                    <g class="plotarea" transform="matrix(1 0 0 -1 0 {$plotareaHeight})">
                        <xsl:comment>Plot area background</xsl:comment>
                        <!-- First draw the background color or gradient... -->
                        <rect height="{$plotareaHeight}" width="{$plotareaWidth}" y="0" x="0" />
                        <!-- Then optionally place one or more pictures over it... -->
                        <xsl:if test="/chart/style/plotarea/picture">
                            <xsl:apply-templates select="/chart/style/plotarea/picture"/>
                        </xsl:if>
                    </g>
                    <g class="grid">
                        <xsl:comment>Grid Lines</xsl:comment>
                        <!-- Grid lines -->
                        <g class="gridVert">
                            <xsl:if test="$gridlineMajorX = 'true'">
                                <g class="gridVertMajor">
                                    <xsl:comment>Major Vertical Grid Lines</xsl:comment>
                                    <xsl:call-template name="drawVerticalGridLine">
                                        <xsl:with-param name="at">
                                            <xsl:value-of select="$rangeMinX"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="by">
                                            <xsl:value-of select="$intervalMajorX"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </g>
                            </xsl:if>
                            <xsl:if test="$gridlineMinorX = 'true'">
                                <g class="gridVertMinor">
                                    <xsl:comment>Minor Vertical Grid Lines</xsl:comment>
                                    <xsl:call-template name="drawVerticalGridLine">
                                        <xsl:with-param name="at">
                                            <xsl:value-of select="$rangeMinX"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="by">
                                            <xsl:value-of select="$intervalMinorX"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </g>
                            </xsl:if>
                        </g>
                        <xsl:choose>
                            <xsl:when test="string(number($rangeMinY)) != 'NaN'">
                                <g class="gridHorz">
                                    <xsl:if test="$gridlineMajorY = 'true'">
                                        <g class="gridHorzMajor">
                                            <xsl:comment>Major Horizontal Grid Lines</xsl:comment>
                                            <xsl:call-template name="drawHorizontalGridLine">
                                                <xsl:with-param name="at">
                                                    <xsl:value-of select="$rangeMinY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="by">
                                                    <xsl:value-of select="$intervalMajorY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="min">
                                                    <xsl:value-of select="$rangeMinY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="max">
                                                    <xsl:value-of select="$rangeMaxY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="scale">
                                                    <xsl:value-of select="$scaleY"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </g>
                                    </xsl:if>
                                    <xsl:if test="$gridlineMinorY = 'true'">
                                        <g class="gridHorzMinor">
                                            <xsl:comment>Minor Horizontal Grid Lines</xsl:comment>
                                            <xsl:call-template name="drawHorizontalGridLine">
                                                <xsl:with-param name="at">
                                                    <xsl:value-of select="$rangeMinY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="by">
                                                    <xsl:value-of select="$intervalMinorY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="min">
                                                    <xsl:value-of select="$rangeMinY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="max">
                                                    <xsl:value-of select="$rangeMaxY"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="scale">
                                                    <xsl:value-of select="$scaleY"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </g>
                                    </xsl:if>
                                </g>
                            </xsl:when>
                            <xsl:when test="string(number($rangeMinY2)) != 'NaN'">
                                <g class="gridHorz">
                                    <xsl:if test="$gridlineMajorY = 'true'">
                                        <g class="gridHorzMajor">
                                            <xsl:comment>Major Horizontal Grid Lines (Y2)</xsl:comment>
                                            <xsl:call-template name="drawHorizontalGridLine">
                                                <xsl:with-param name="at">
                                                    <xsl:value-of select="$rangeMinY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="by">
                                                    <xsl:value-of select="$intervalMajorY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="min">
                                                    <xsl:value-of select="$rangeMinY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="max">
                                                    <xsl:value-of select="$rangeMaxY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="scale">
                                                    <xsl:value-of select="$scaleY2"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </g>
                                    </xsl:if>
                                    <xsl:if test="$gridlineMinorY = 'true'">
                                        <g class="gridHorzMinor">
                                            <xsl:comment>Minor Horizontal Grid Lines (Y2)</xsl:comment>
                                            <xsl:call-template name="drawHorizontalGridLine">
                                                <xsl:with-param name="at">
                                                    <xsl:value-of select="$rangeMinY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="by">
                                                    <xsl:value-of select="$intervalMinorY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="min">
                                                    <xsl:value-of select="$rangeMinY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="max">
                                                    <xsl:value-of select="$rangeMaxY2"/>
                                                </xsl:with-param>
                                                <xsl:with-param name="scale">
                                                    <xsl:value-of select="$scaleY2"/>
                                                </xsl:with-param>
                                            </xsl:call-template>
                                        </g>
                                    </xsl:if>
                                </g>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </g>
                    <!-- There can be any number of horizontal or vertical 'reference' lines. These are just
                        lines drawn at the specified places on the x- or y- axis to guide the eye.
                     -->
                    <xsl:if test="//reference">
                        <g class="ref">
                            <xsl:if test="/chart/axis/x/reference or /chart/axis/x2/reference">
                                <g class="refVert">
                                    <xsl:comment>Vertical Reference Lines</xsl:comment>
                                    <xsl:if test="/chart/axis/x/reference">
                                        <xsl:comment>x-axis</xsl:comment>
                                        <xsl:apply-templates select="/chart/axis/x/reference" mode="reference"/>
                                    </xsl:if>
                                    <xsl:if test="/chart/axis/x2/reference">
                                        <xsl:comment>x2-axis</xsl:comment>
                                        <xsl:apply-templates select="/chart/axis/x2/reference" mode="reference"/>
                                    </xsl:if>
                                </g>
                            </xsl:if>
                            <xsl:if test="/chart/axis/y/reference or /chart/axis/y2/reference">
                                <g class="refHorz">
                                    <xsl:comment>Horizontal Reference Lines</xsl:comment>
                                    <xsl:if test="/chart/axis/y/reference">
                                        <xsl:comment>y-axis</xsl:comment>
                                        <xsl:apply-templates select="/chart/axis/y/reference" mode="reference"/>
                                    </xsl:if>
                                    <xsl:if test="/chart/axis/y2/reference">
                                        <xsl:comment>y2-axis</xsl:comment>
                                        <xsl:apply-templates select="/chart/axis/y2/reference" mode="reference"/>
                                    </xsl:if>
                                </g>
                            </xsl:if>
                        </g>
                    </xsl:if>
                    <!-- Plot the data (so this is where it all happens!) -->
                    <g class="series" filter="url(#invertedShadowFilter)">
                        <xsl:comment>Data series</xsl:comment>
                        <xsl:apply-templates select="chart/series"/>
                    </g>
                    <!-- Plot area border -->
                    <g class="plotareaBorder" transform="matrix(1 0 0 -1 0 {$plotareaHeight})">
                        <xsl:comment>Plot area border</xsl:comment>
                        <xsl:element name="rect">
                            <xsl:attribute name="x">0</xsl:attribute>
                            <xsl:attribute name="y">0</xsl:attribute>
                            <xsl:attribute name="width"><xsl:value-of select="$plotareaWidth"/></xsl:attribute>
                            <xsl:attribute name="height"><xsl:value-of select="$plotareaHeight"/></xsl:attribute>
                        </xsl:element>
                    </g>
                </g>
                <!-- Annotations are small pieces of text attached to a particular datum -->
                <g class="annotation" transform="matrix(1 0 0 -1 0 0)">
                    <xsl:comment>Annotations</xsl:comment>
                    <xsl:apply-templates select="chart/series" mode="annotations"/>
                </g>

            </xsl:element>

            <!-- Debug outlines -->
            <xsl:if test="/chart/@debug = 'true'">
                <xsl:comment>Debug outlines</xsl:comment>
                <g class="debug">
                    <xsl:comment>Chart area</xsl:comment>
                    <rect style="stroke:red" x="0" y="1" width="{$chartWidth - 1}" height="{$chartHeight - 2}" />
                    <g class="debugText">
                        <text x="{$chartWidth - $chartMargin}" y="{$chartHeight - $chartMargin}" style="text-anchor:end">
                            <xsl:text>Chart (</xsl:text>
                            <xsl:value-of select="$chartWidth"/>
                            <xsl:text> x </xsl:text>
                            <xsl:value-of select="$chartHeight"/>
                            <xsl:text>)</xsl:text>
                        </text>
                    </g>
                    <xsl:comment>Plot area</xsl:comment>
                    <g transform="translate({$westWidth},{$northHeight})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'Plot Area'"/>
                            <xsl:with-param name="style" select="'stroke:red'"/>
                            <xsl:with-param name="w" select="$plotareaWidth"/>
                            <xsl:with-param name="h" select="$plotareaHeight"/>
                        </xsl:call-template>
                    </g>
                    <xsl:comment>North area</xsl:comment>
                    <g transform="translate({$chartMargin},{$chartMargin})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'Chart Title'"/>
                            <xsl:with-param name="style" select="'stroke:green'"/>
                            <xsl:with-param name="w" select="$chartWidth - 2 * $chartMargin"/>
                            <xsl:with-param name="h" select="$chartTitleHeight"/>
                            <xsl:with-param name="fontsize" select="$chartTitleFontSize"/>
                        </xsl:call-template>
                    </g>
                    <g transform="translate({$westWidth},{$chartMargin + $chartTitleHeight})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'North Title'"/>
                            <xsl:with-param name="style" select="'stroke:red'"/>
                            <xsl:with-param name="w" select="$plotareaWidth"/>
                            <xsl:with-param name="h" select="$northTitleHeight"/>
                            <xsl:with-param name="fontsize" select="$northTitleFontSize"/>
                        </xsl:call-template>
                        <g transform="translate(0,{$northTitleHeight})">
                            <xsl:call-template name="drawAreaOutline">
                                <xsl:with-param name="area" select="'North Label'"/>
                                <xsl:with-param name="style" select="'stroke:green'"/>
                                <xsl:with-param name="w" select="$plotareaWidth"/>
                                <xsl:with-param name="h" select="$northLabelHeight"/>
                                <xsl:with-param name="fontsize" select="$northLabelFontSize"/>
                            </xsl:call-template>
                        </g>
                    </g>
                    <xsl:comment>West area</xsl:comment>
                    <g transform="translate({$chartMargin},{$northHeight})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'West Title'"/>
                            <xsl:with-param name="style" select="'stroke:red'"/>
                            <xsl:with-param name="w" select="$westTitleHeight"/>
                            <xsl:with-param name="h" select="$plotareaHeight"/>
                            <xsl:with-param name="fontsize" select="$westTitleFontSize"/>
                            <xsl:with-param name="rotate" select="-90"/>
                        </xsl:call-template>
                        <g transform="translate({$westTitleHeight})">
                            <xsl:call-template name="drawAreaOutline">
                                <xsl:with-param name="area" select="'West Label'"/>
                                <xsl:with-param name="style" select="'stroke:green'"/>
                                <xsl:with-param name="w" select="$westLabelWidth"/>
                                <xsl:with-param name="h" select="$plotareaHeight"/>
                                <xsl:with-param name="fontsize" select="$westLabelFontSize"/>
                                <xsl:with-param name="rotate" select="-90"/>
                            </xsl:call-template>
                        </g>
                    </g>
                    <xsl:comment>South area</xsl:comment>
                    <g transform="translate({$westWidth},{$northHeight + $plotareaHeight + $inset})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'South Label'"/>
                            <xsl:with-param name="style" select="'stroke:green'"/>
                            <xsl:with-param name="w" select="$plotareaWidth"/>
                            <xsl:with-param name="h" select="$southLabelHeight"/>
                            <xsl:with-param name="fontsize" select="$southLabelFontSize"/>
                        </xsl:call-template>
                        <g transform="translate(0,{$southLabelHeight})">
                            <xsl:call-template name="drawAreaOutline">
                                <xsl:with-param name="area" select="'South Title'"/>
                                <xsl:with-param name="style" select="'stroke:red'"/>
                                <xsl:with-param name="w" select="$plotareaWidth"/>
                                <xsl:with-param name="h" select="$southTitleHeight"/>
                                <xsl:with-param name="fontsize" select="$southTitleFontSize"/>
                            </xsl:call-template>
                            <xsl:if test="//layout/south/legend">
                                <g transform="translate(0,{$southTitleHeight + $inset})">
                                    <xsl:call-template name="drawAreaOutline">
                                        <xsl:with-param name="area" select="'South Legend'"/>
                                        <xsl:with-param name="style" select="'stroke:green'"/>
                                        <xsl:with-param name="w" select="$plotareaWidth"/>
                                        <xsl:with-param name="h" select="$southLegendDisplayHeight"/>
                                        <xsl:with-param name="fontsize" select="$defaultLegendEntryHeight"/>
                                    </xsl:call-template>
                                </g>
                            </xsl:if>
                        </g>
                    </g>
                    <xsl:comment>East area</xsl:comment>
                    <g transform="translate({$westWidth + $plotareaWidth + $inset},{$northHeight})">
                        <xsl:call-template name="drawAreaOutline">
                            <xsl:with-param name="area" select="'East Label'"/>
                            <xsl:with-param name="style" select="'stroke:green'"/>
                            <xsl:with-param name="w" select="$eastLabelWidth"/>
                            <xsl:with-param name="h" select="$plotareaHeight"/>
                            <xsl:with-param name="fontsize" select="$eastLabelFontSize"/>
                            <xsl:with-param name="rotate" select="-90"/>
                        </xsl:call-template>
                        <g transform="translate({$eastLabelWidth})">
                            <xsl:call-template name="drawAreaOutline">
                                <xsl:with-param name="area" select="'East Title'"/>
                                <xsl:with-param name="style" select="'stroke:red'"/>
                                <xsl:with-param name="w" select="$eastTitleHeight"/>
                                <xsl:with-param name="h" select="$plotareaHeight"/>
                                <xsl:with-param name="fontsize" select="$eastTitleFontSize"/>
                                <xsl:with-param name="rotate" select="-90"/>
                            </xsl:call-template>
                            <xsl:if test="//layout/east/legend">
                                <g transform="translate({$eastTitleHeight + $inset})">
                                    <xsl:call-template name="drawAreaOutline">
                                        <xsl:with-param name="area" select="'East Legend'"/>
                                        <xsl:with-param name="style" select="'stroke:green'"/>
                                        <xsl:with-param name="w" select="$eastLegendDisplayWidth"/>
                                        <xsl:with-param name="h" select="$plotareaHeight"/>
                                        <xsl:with-param name="fontsize" select="$defaultLegendEntryHeight"/>
                                        <xsl:with-param name="rotate" select="-90"/>
                                    </xsl:call-template>
                                </g>
                            </xsl:if>
                        </g>
                    </g>
                </g>
            </xsl:if>
        </svg>
    </xsl:template>

    <xsl:template name="drawAreaOutline">
        <xsl:param name="area"/>
        <xsl:param name="style"/>
        <xsl:param name="w"/>
        <xsl:param name="h"/>
        <xsl:param name="fontsize"/>
        <xsl:param name="rotate" select="0"/>
        <rect style="{$style}" x="0" y="0" width="{$w}" height="{$h}" />
        <xsl:variable name="cx" select="$w div 2"/>
        <xsl:variable name="cy" select="$h div 2"/>
        <text class="debugText" x="{$cx}" y="{$cy + 5}" transform="rotate({$rotate},{$cx},{$cy})">
            <xsl:value-of select="$area"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$w"/>
            <xsl:text> x </xsl:text>
            <xsl:value-of select="$h"/>
            <xsl:text>)</xsl:text>
            <xsl:if test="$fontsize">
                <xsl:text> Fontsize=</xsl:text>
                <xsl:value-of select="$fontsize"/>
            </xsl:if>
        </text>
    </xsl:template>

    <!-- Handle the placement and scaling of any background image(s) -->
    <xsl:template match="/chart/style/plotarea/picture">
        <xsl:variable name="location">
            <xsl:call-template name="getValueOrDefault">
                <xsl:with-param name="path" select="@location"/>
                <xsl:with-param name="default" select="'stretch'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="filterName" select="concat('pictureFilter',position())"/>
        <xsl:element name="image" xmlns:xlink="http://www.w3.org/1999/xlink">
            <xsl:attribute name="xlink:href">
                <xsl:value-of select="$protocol"/>
                <xsl:value-of select="normalize-space(text())"/>
            </xsl:attribute>
            <xsl:if test="@opacity or $location = 'tile' or /chart/@debug = 'true'">
                <xsl:attribute name="filter">url(#<xsl:value-of select="$filterName"/>)</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="preserveAspectRatio">none</xsl:attribute>
            <xsl:attribute name="x">
                <xsl:choose>
                    <xsl:when test="$location = 'stretch' or $location = 'tile'">0</xsl:when> <!-- ignore @width -->
                    <xsl:when test="@width">
                        <xsl:choose>
                            <xsl:when test="$location = 'left' or $location = 'topleft' or $location = 'bottomleft'">0</xsl:when>
                            <xsl:when test="$location = 'center' or $location = 'centre' or $location = 'top' or $location = 'bottom'">
                                <xsl:value-of select="($plotareaWidth - @width) div 2"/>
                            </xsl:when>
                            <xsl:when test="$location = 'right' or $location = 'topright' or $location = 'bottomright'">
                                <xsl:value-of select="$plotareaWidth - @width"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$location = 'left' or $location = 'topleft' or $location = 'bottomleft'">0</xsl:when>
                            <xsl:when test="$location = 'center' or $location = 'centre' or $location = 'top' or $location = 'bottom'">
                                <xsl:value-of select="($plotareaWidth - $intervalMajorX * $scaleX) div 2"/>
                            </xsl:when>
                            <xsl:when test="$location = 'right' or $location = 'topright' or $location = 'bottomright'">
                                <xsl:value-of select="$plotareaWidth - $intervalMajorX * $scaleX"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="y">
                <xsl:choose>
                    <xsl:when test="$location = 'stretch' or $location = 'tile'">0</xsl:when> <!-- ignore @height -->
                    <xsl:when test="@height">
                        <xsl:choose>
                            <xsl:when test="$location = 'top' or $location = 'topleft' or $location = 'topright'">0</xsl:when>
                            <xsl:when test="$location = 'center' or $location = 'centre' or $location = 'left' or $location = 'right'">
                                <xsl:value-of select="($plotareaHeight - @height) div 2"/>
                            </xsl:when>
                            <xsl:when test="$location = 'bottom' or $location = 'bottomleft' or $location = 'bottomright'">
                                <xsl:value-of select="$plotareaHeight - @height"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$location = 'top' or $location = 'topleft' or $location = 'topright'">0</xsl:when>
                            <xsl:when test="$location = 'center' or $location = 'centre' or $location = 'left' or $location = 'right'">
                                <xsl:value-of select="($plotareaHeight - $intervalMajorY * $scaleY) div 2"/>
                            </xsl:when>
                            <xsl:when test="$location = 'bottom' or $location = 'bottomleft' or $location = 'bottomright'">
                                <xsl:value-of select="$plotareaHeight - $intervalMajorY * $scaleY"/>
                            </xsl:when>
                            <xsl:otherwise>0</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="width">
                <xsl:choose>
                    <xsl:when test="$location = 'stretch'">
                        <xsl:value-of select="$plotareaWidth"/>
                    </xsl:when>
                    <xsl:when test="@width">
                        <xsl:value-of select="@width"/>
                    </xsl:when>
                    <xsl:when test="$location = 'tile'">
                        <xsl:value-of select="$intervalMajorX * $scaleX"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$intervalMajorX * $scaleX"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="height">
                <xsl:choose>
                    <xsl:when test="$location = 'stretch'">
                        <xsl:value-of select="$plotareaHeight"/>
                    </xsl:when>
                    <xsl:when test="@height">
                        <xsl:value-of select="@height"/>
                    </xsl:when>
                    <xsl:when test="$location = 'tile'">
                        <xsl:value-of select="$intervalMajorY * $scaleY"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$intervalMajorY * $scaleY"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="@opacity or $location = 'tile' or /chart/@debug = 'true'">
                <!-- Define a filter to tile or fade the background image... -->
                <xsl:variable name="tileareaWidth" >
                    <xsl:choose>
                        <xsl:when test="@width">
                            <xsl:value-of select="format-number($plotareaWidth div @width * 100,'#0.##')"/>
                        </xsl:when>
                        <xsl:when test="$location = 'tile'">
                            <xsl:value-of select="format-number($plotareaWidth div ($intervalMajorX * $scaleX) * 100,'#0.##')"/>
                        </xsl:when>
                        <xsl:otherwise>100</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="tileareaHeight" >
                    <xsl:choose>
                        <xsl:when test="@height">
                            <xsl:value-of select="format-number($plotareaHeight div @height * 100,'#0.##')"/>
                        </xsl:when>
                        <xsl:when test="$location = 'tile'">
                            <xsl:value-of select="format-number($plotareaHeight div ($intervalMajorY * $scaleY) * 100,'#0.##')"/>
                        </xsl:when>
                        <xsl:otherwise>100</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <filter primitiveUnits="objectBoundingBox" filterUnits="objectBoundingBox"
                    x="0" y="0" width="{$tileareaWidth}%" height="{$tileareaHeight}%" id="{$filterName}">
                    <xsl:if test="$location = 'tile'">
                        <feOffset x="0" y="0" width="100%" height="100%"/>
                        <feTile />
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="/chart/@debug = 'true'">
                            <feComponentTransfer>
                                <feFuncA type="linear" slope="{$debugOpacity}" intercept="0"/>
                            </feComponentTransfer>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="@opacity">
                                <feComponentTransfer>
                                    <feFuncA type="linear" slope="{@opacity}" intercept="0"/>
                                </feComponentTransfer>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </filter>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="chart/style/plotarea/gradient/color" mode="getStops">
        <!-- IN:    <color offset="25%" opacity="0.4">skyblue</color>                   -->
        <!-- OUT:   <stop offset="25%" style="stop-color:skyblue;stop-opacity:0.4;"/>   -->
        <xsl:element name="stop">
            <xsl:copy-of select="@offset"/>
            <xsl:attribute name="style">
                <xsl:text>stop-color:</xsl:text>
                <xsl:value-of select="normalize-space(text())"/>
                <xsl:if test="@opacity">
                    <xsl:text>;stop-opacity:</xsl:text>
                    <xsl:value-of select="@opacity"/>
                </xsl:if>
                <xsl:text>;</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="chart/series">
        <!-- If the series has not been explicitly hidden by the "visible='false'" attribute then draw it... -->
        <xsl:if test="not(@visible) or @visible != 'false'">
            <xsl:variable name="pos" select="position()"/>
            <xsl:element name="g">
                <xsl:attribute name="class">series<xsl:value-of select="$pos"/></xsl:attribute>
                <xsl:element name="title">
                    <xsl:choose>
                        <xsl:when test="title">
                            <xsl:value-of select="title/text()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Series </xsl:text><xsl:value-of select="$pos"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:element name="path">
                    <xsl:attribute name="d">
                        <xsl:for-each select="datum">
                            <xsl:choose>
                                <xsl:when test="string(number(@y)) = 'NaN' and string(number(@y2)) = 'NaN'">
                                    <!-- Missing y (or y2) value, so leave a break in this line -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="cmd">
                                        <xsl:choose>
                                            <xsl:when test="(@y  and string(number(preceding-sibling::datum[1]/@y))  = 'NaN')
                                                         or (@y2 and string(number(preceding-sibling::datum[1]/@y2)) = 'NaN')">
                                                <xsl:text>M</xsl:text> <!-- Move to absolute co-ordinate -->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>L</xsl:text> <!-- Line to absolute co-ordinate -->
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="x">
                                        <xsl:choose>
                                            <!-- When both x and x2 attributes are omitted, use datum position - 1 on the x-axis -->
                                            <xsl:when test="string(number(@x)) = 'NaN' and string(number(@x2)) = 'NaN'">
                                                <xsl:value-of select="format-number((position() - 1 - $rangeMinX) * $scaleX,'#0.##')"/>
                                            </xsl:when>
                                            <!-- When x is specified, use it on the x-axis -->
                                            <xsl:when test="@x">
                                                <xsl:value-of select="format-number((@x - $rangeMinX) * $scaleX,'#0.##')"/>
                                            </xsl:when>
                                            <!-- Otherwise, x2 is specified, so use it on the x2-axis -->
                                            <xsl:otherwise>
                                                <xsl:value-of select="format-number((@x2 - $rangeMinX2) * $scaleX2,'#0.##')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="y">
                                        <xsl:choose>
                                            <xsl:when test="@y">
                                                <xsl:value-of select="format-number((@y - $rangeMinY) * $scaleY,'#0.##')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="format-number((@y2 - $rangeMinY2) * $scaleY2,'#0.##')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <!-- Emit a MoveTo(x,y) or a LineTo(x,y) command -->
                                    <xsl:value-of select="$cmd"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$x"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$y"/>
                                    <xsl:text> </xsl:text>
                                    <!-- If the last command was MoveTo and the next datum is missing then draw a dot -->
                                    <xsl:if test="($cmd = 'M')
                                                 and ((@y  and string(number(following-sibling::datum[1]/@y))  = 'NaN')
                                                 or   (@y2 and string(number(following-sibling::datum[1]/@y2)) = 'NaN'))">
                                        <xsl:text>L </xsl:text> <!-- Draw a Line to the place we just moved to! -->
                                        <xsl:value-of select="$x"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$y"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="chart/series" mode="annotations">
        <xsl:for-each select="datum">
            <xsl:if test="text() and (@y or @y2)">
                <xsl:variable name="x">
                    <xsl:choose>
                        <xsl:when test="string(number(@x)) = 'NaN' and string(number(@x2)) = 'NaN'">
                            <xsl:value-of select="format-number((position() - 1 - $rangeMinX) * $scaleX,'#0.##')"/>
                        </xsl:when>
                        <xsl:when test="@x">
                            <xsl:value-of select="format-number((@x - $rangeMinX) * $scaleX,'#0.##')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="format-number((@x2 - $rangeMinX2) * $scaleX2,'#0.##')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="y">
                    <xsl:choose>
                        <xsl:when test="@y">
                            <xsl:value-of select="format-number((@y - $rangeMinY) * $scaleY,'#0.##')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="format-number((@y2 - $rangeMinY2) * $scaleY2,'#0.##')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="radius" select="$chartWidth div 100"/>
                <circle cx="{$x}" cy="{-$y}" r="{$radius}" />
                <text x="{$x}" y="{-$y - $radius - $inset}" class="annotationText"><xsl:value-of select="normalize-space(text())"/></text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="chart/series" mode="css-style-sheet">
        <xsl:variable name="pos" select="position() - 1"/>
        <xsl:variable name="h" select="($seriesHueInitial + $pos * $seriesHueStep) mod 360"/>
        <xsl:variable name="s" select="$seriesSaturationMin + $seriesSaturationStep * (($seriesSaturationLevels - 1) - ($pos mod $seriesSaturationLevels))"/>
        <xsl:variable name="v" select="$seriesBrightnessMin + $seriesBrightnessStep * (($seriesBrightnessLevels - 1) - ($pos mod $seriesBrightnessLevels))"/>
        <xsl:variable name="rgb">
            <xsl:call-template name="hsv2rgb">
                    <xsl:with-param name="h" select="$h"/>
                    <xsl:with-param name="s" select="$s"/>
                    <xsl:with-param name="v" select="$v"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:text>    .series</xsl:text><xsl:value-of select="position()"/>
        <xsl:text>        {stroke:</xsl:text><xsl:value-of select="normalize-space($rgb)"/>;<xsl:value-of select="@style"/>}
    </xsl:template>

    <!-- HSV to RGB converter (to compute default series colors) -->
    <xsl:template name="hsv2rgb">
        <xsl:param name="h" select="0"/>
        <xsl:param name="s" select="0"/>
        <xsl:param name="v" select="0"/>
        <xsl:choose>
            <xsl:when test="$s = 0">
                <xsl:text>rgb(</xsl:text><xsl:value-of select="100 * $v"/>%,<xsl:value-of select="100 * $v"/>%,<xsl:value-of select="100 * $v"/><xsl:text>%)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="sextant" select="floor($h div 60)"/>
                <xsl:variable name="f" select="$h div 60 - $sextant"/>
                <xsl:variable name="p" select="100 * $v * (1 - $s)"/>
                <xsl:variable name="q" select="100 * $v * (1 - $s * $f)"/>
                <xsl:variable name="t" select="100 * $v * (1 - $s * (1 - $f))"/>
                <xsl:variable name="u" select="100 * $v"/>
                <xsl:choose>
                    <xsl:when test="$sextant = 0">
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($u,'#0.##')"/>%,<xsl:value-of select="format-number($t,'#0.##')"/>%,<xsl:value-of select="format-number($p,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$sextant = 1">
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($q,'#0.##')"/>%,<xsl:value-of select="format-number($u,'#0.##')"/>%,<xsl:value-of select="format-number($p,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$sextant = 2">
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($p,'#0.##')"/>%,<xsl:value-of select="format-number($u,'#0.##')"/>%,<xsl:value-of select="format-number($t,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$sextant = 3">
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($p,'#0.##')"/>%,<xsl:value-of select="format-number($q,'#0.##')"/>%,<xsl:value-of select="format-number($u,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:when>
                    <xsl:when test="$sextant = 4">
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($t,'#0.##')"/>%,<xsl:value-of select="format-number($p,'#0.##')"/>%,<xsl:value-of select="format-number($u,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise> <!-- $sextant = 5 -->
                        <xsl:text>rgb(</xsl:text><xsl:value-of select="format-number($u,'#0.##')"/>%,<xsl:value-of select="format-number($p,'#0.##')"/>%,<xsl:value-of select="format-number($q,'#0.##')"/><xsl:text>%)</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="drawLegend">
        <xsl:param name="legendOriginX"/>
        <xsl:param name="legendOriginY"/>
        <xsl:param name="legendWidth"/>
        <xsl:param name="legendHeight"/>
        <xsl:param name="legendColumns" select="1"/>
        <xsl:variable name="columns">
            <xsl:call-template name="getValueOrDefault">
                <xsl:with-param name="path" select="$legendColumns"/>
                <xsl:with-param name="default" select="1"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="legendEntryHeight" select="$defaultLabelHeight"/>
        <xsl:variable name="legendEntryWidth" select="$legendWidth div $columns"/>
        <xsl:variable name="legendLineWidth" select="$legendEntryWidth div 5"/>

        <g class="series" transform="matrix(1 0 0 -1 {$legendOriginX} {$legendOriginY})">
            <xsl:for-each select="chart/series">
                <xsl:if test="not(@visible) or @visible != 'false'">
                    <xsl:variable name="row" select="floor((position() - 1) div $columns)"/>
                    <xsl:variable name="col" select="(position() - 1) - ($row * $columns)"/>
                    <xsl:variable name="x" select="$col * $legendEntryWidth"/>
                    <xsl:variable name="y" select="$row * $legendEntryHeight + $inset"/>
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:variable name="clip" select="concat('clip',$pos,'.',$legendOriginX,',',$legendOriginY)"/>
                    <xsl:element name="line">
                        <xsl:attribute name="class">series<xsl:value-of select="$pos"/>
                        </xsl:attribute>
                        <xsl:attribute name="x1">
                            <xsl:value-of select="$x"/>
                        </xsl:attribute>
                        <xsl:attribute name="y1">
                            <xsl:value-of select="$y + $legendEntryHeight div 2"/>
                        </xsl:attribute>
                        <xsl:attribute name="x2">
                            <xsl:value-of select="$x + $legendLineWidth"/>
                        </xsl:attribute>
                        <xsl:attribute name="y2">
                            <xsl:value-of select="$y + $legendEntryHeight div 2"/>
                        </xsl:attribute>
                    </xsl:element>
                    <clipPath id="{$clip}">
                        <rect height="{$legendEntryHeight + $inset * 2}" width="{$legendEntryWidth - $inset}" y="{$y - $inset}" x="{$x}"/>
                    </clipPath>
                    <text clip-path="url(#{$clip})" class="legend" x="{$x + $legendLineWidth + $inset}" y="{$y + 2 * $legendEntryHeight div 3}">
                        <xsl:choose>
                            <xsl:when test="title">
                                <xsl:value-of select="title/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Series </xsl:text><xsl:value-of select="$pos"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </text>
                </xsl:if>
            </xsl:for-each>
        </g>
    </xsl:template>

    <xsl:template match="//x/reference" mode="reference">
        <xsl:variable name="here" select="format-number((@at  - $rangeMinX) * $scaleX,'#0.##')"/>
        <xsl:element name="line">
            <xsl:attribute name="x1"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y1">0</xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="$plotareaHeight"/></xsl:attribute>
            <xsl:copy-of select="@style"/>
            <xsl:element name="title">
                <xsl:value-of select="@at"/>
                <xsl:if test="text()">
                    <xsl:text> = </xsl:text>
                    <xsl:value-of select="normalize-space(text())"/>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="//y/reference" mode="reference">
        <xsl:variable name="here" select="format-number((@at  - $rangeMinY) * $scaleY,'#0.##')"/>
        <xsl:element name="line">
            <xsl:attribute name="x1">0</xsl:attribute>
            <xsl:attribute name="y1"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="$plotareaWidth"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:copy-of select="@style"/>
            <xsl:element name="title">
                <xsl:value-of select="@at"/>
                <xsl:if test="text()">
                    <xsl:text> = </xsl:text>
                    <xsl:value-of select="normalize-space(text())"/>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="//x2/reference" mode="reference">
        <xsl:variable name="here" select="format-number((@at  - $rangeMinX2) * $scaleX2,'#0.##')"/>
        <xsl:element name="line">
            <xsl:attribute name="x1"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y1">0</xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="$plotareaHeight"/></xsl:attribute>
            <xsl:copy-of select="@style"/>
            <xsl:element name="title">
                <xsl:value-of select="@at"/>
                <xsl:if test="text()">
                    <xsl:text> = </xsl:text>
                    <xsl:value-of select="normalize-space(text())"/>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="//y2/reference" mode="reference">
        <xsl:variable name="here" select="format-number((@at  - $rangeMinY2) * $scaleY2,'#0.##')"/>
        <xsl:element name="line">
            <xsl:attribute name="x1">0</xsl:attribute>
            <xsl:attribute name="y1"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="$plotareaWidth"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:copy-of select="@style"/>
            <xsl:element name="title">
                <xsl:value-of select="@at"/>
                <xsl:if test="text()">
                    <xsl:text> = </xsl:text>
                    <xsl:value-of select="normalize-space(text())"/>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="drawVerticalGridLine">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:variable name="here" select="format-number(($at - $rangeMinX) * $scaleX,'#0.##')"/>
        <xsl:element name="line">
            <xsl:attribute name="x1"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y1">0</xsl:attribute>
            <xsl:attribute name="x2"><xsl:value-of select="$here"/></xsl:attribute>
            <xsl:attribute name="y2"><xsl:value-of select="$plotareaHeight"/></xsl:attribute>
        </xsl:element>
        <xsl:if test="$at &lt; $rangeMaxX">
            <xsl:call-template name="drawVerticalGridLine">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="drawLabelOnXAxis">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:element name="g">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="format-number(($at - $rangeMinX) * $scaleX,'#0.###')"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="$southLabelRotation != 0">
                    <xsl:text> rotate(</xsl:text>
                    <xsl:value-of select="$southLabelRotation"/>
                    <xsl:text>,0,</xsl:text>
                    <xsl:value-of select="-$southLabelFontSize div 4"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="/chart/axis/x/label">   <!-- use the next specified label -->
                        <xsl:value-of select="/chart/axis/x/label[position() = floor(($at - $rangeMinX) div $intervalMajorX) + 1]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>                         <!-- generate a numeric label -->
                        <xsl:value-of select="format-number($at,$formatLabelX)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
        <xsl:if test="format-number($at,$formatLabelX) &lt; $rangeMaxX">
            <xsl:call-template name="drawLabelOnXAxis">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="drawLabelOnX2Axis">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:element name="g">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="format-number(($at - $rangeMinX2) * $scaleX2,'#0.###')"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="$northLabelRotation != 0">
                    <xsl:text> rotate(</xsl:text>
                    <xsl:value-of select="$northLabelRotation"/>
                    <xsl:text>,0,</xsl:text>
                    <xsl:value-of select="-$northLabelFontSize div 4"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:element name="text">
                <xsl:choose>
                    <xsl:when test="/chart/axis/x2/label">   <!-- use the next specified label -->
                        <xsl:value-of select="/chart/axis/x2/label[position() = floor(($at - $rangeMinX2) div $intervalMajorX2) + 1]/text()"/>
                    </xsl:when>
                    <xsl:otherwise>                          <!-- generate a numeric label -->
                        <xsl:value-of select="format-number($at,$formatLabelX2)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:element>
        <xsl:if test="format-number($at,$formatLabelX2) &lt; $rangeMaxX2">
            <xsl:call-template name="drawLabelOnX2Axis">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="drawHorizontalGridLine">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:param name="scale"/>
        <xsl:element name="line">
            <xsl:attribute name="x1">0</xsl:attribute>
            <xsl:attribute name="y1">
                <xsl:value-of select="format-number(($at - $min) * $scale,'#0.##')"/>
            </xsl:attribute>
            <xsl:attribute name="x2">
                <xsl:value-of select="$plotareaWidth"/>
            </xsl:attribute>
            <xsl:attribute name="y2">
                <xsl:value-of select="format-number(($at - $min) * $scale,'#0.##')"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:if test="$at &lt; $max">
            <xsl:call-template name="drawHorizontalGridLine">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
                <xsl:with-param name="min">
                    <xsl:value-of select="$min"/>
                </xsl:with-param>
                <xsl:with-param name="max">
                    <xsl:value-of select="$max"/>
                </xsl:with-param>
                <xsl:with-param name="scale">
                    <xsl:value-of select="$scale"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="drawLabelOnYAxis">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:element name="g">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="-$inset"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="format-number(-$at * $scaleY,'#0.###')"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="$westLabelRotation != 0">
                    <xsl:text> rotate(</xsl:text>
                    <xsl:value-of select="$westLabelRotation"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:element name="text">
                <xsl:value-of select="format-number($at,$formatLabelY)"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="format-number($at,$formatLabelY) &lt; $rangeMaxY">
            <xsl:call-template name="drawLabelOnYAxis">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="drawLabelOnY2Axis">
        <xsl:param name="at"/>
        <xsl:param name="by"/>
        <xsl:element name="g">
            <xsl:attribute name="transform">
                <xsl:text>translate(</xsl:text>
                <xsl:value-of select="$inset"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="format-number(-$at * $scaleY2,'#0.###')"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="$eastLabelRotation != 0">
                    <xsl:text> rotate(</xsl:text>
                    <xsl:value-of select="$eastLabelRotation"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:element name="text">
                <xsl:value-of select="format-number($at,$formatLabelY2)"/>
            </xsl:element>
        </xsl:element>
        <xsl:if test="format-number($at,$formatLabelY2) &lt; $rangeMaxY2">
            <xsl:call-template name="drawLabelOnY2Axis">
                <xsl:with-param name="at">
                    <xsl:value-of select="$at + $by"/>
                </xsl:with-param>
                <xsl:with-param name="by">
                    <xsl:value-of select="$by"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>