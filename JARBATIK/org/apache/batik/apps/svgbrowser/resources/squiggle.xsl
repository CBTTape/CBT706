<?xml version="1.0" standalone="no"?>
<!-- ========================================================================= -->
<!-- Copyright (C) The Apache Software Foundation. All rights reserved.        -->
<!--                                                                           -->
<!-- This software is published under the terms of the Apache Software License -->
<!-- version 1.1, a copy of which has been included with this distribution in  -->
<!-- the LICENSE file.                                                         -->
<!-- ========================================================================= -->

<!-- ========================================================================= -->
<!-- This simple XSL stylesheet is used to automatically generate the splash   -->
<!-- screen for the documentation and the Squiggle browser. See the 'splash'   -->
<!-- target in build.xml.                                                      -->
<!--                                                                           -->
<!-- @author vincent.hardy@eng.sun.com                                         -->
<!-- @version $Id: squiggle.xsl,v 1.1 2002/06/05 14:38:26 vhardy Exp $      -->
<!-- ========================================================================= -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
                              xmlns:xlink="http://www.w3.org/1999/xlink"
                              xmlns:xalan="http://xml.apache.org/xalan" 
                              exclude-result-prefixes="xalan">

        <xsl:param name="version" >currentVersion</xsl:param>
        <xsl:param name="revisionType" >beta</xsl:param>
        <xsl:param name="revisionNumber" >3</xsl:param>
	<xsl:output method="xml" indent="yes" media-type="image/svg"/> 

    <xsl:template match="/" >

<svg id="body" width="492" height="150" viewBox="0 0 492 150">
<title>Batik URL card for JavaOne 2001</title>

    <defs>
        <g id="card">
            <rect x="-246" y="-75" width="492" height="150" />
        </g>

        <radialGradient id="backgroundGradient" r=".7" cx="0.5">
            <stop offset="0" stop-color="white" />
            <stop offset=".5" stop-color="rgb(124, 65, 239)" />
            <stop offset="1" stop-color="black" />
        </radialGradient>

        <pattern id="stripes" patternUnits="userSpaceOnUse" x="0" y="0" width="50" height="4">
            <rect width="50" height="2" fill="black" fill-opacity=".2" />
        </pattern>

        <filter id="dropShadow" primitiveUnits="objectBoundingBox" x="-.2" y="-.2" width="1.4" height="1.4">
            <feGaussianBlur in="SourceAlpha" stdDeviation="2" x="-.2" y="-.2" width="1.4" height="1.4"/> 
            <feOffset dx="3" dy="3" />
            <feComponentTransfer result="shadow">
               <feFuncA type="linear" slope="1" intercept="0" />
            </feComponentTransfer>
            <feMerge>
                <feMergeNode />
                <feMergeNode in="SourceGraphic" />
            </feMerge>
        </filter>

    </defs>
    <g id="content" transform="translate(246,75)" filter2="url(#dropShadow)">

        <g id="top">
            <use xlink:href="#card" fill="url(#backgroundGradient)" />
            <use xlink:href="#card" fill="url(#stripes)" />

            <use xlink:href="#Batik_Squiggle" x="20" y="20"
                 transform="translate(-242, -110.5) scale(2.3)" filter="url(#dropShadow)"/>

            <g id="topText" font-family="'20th Century Font', 'Futura XBlk BT'" font-size="75" text-anchor="middle" 
               fill="white" filter="url(#dropShadow)">
                <text y=".15em"><tspan font-size="95">squiggle</tspan></text>
                <text font-size="17" y="2.7em"><tspan>Built with the Batik SVG toolkit</tspan><tspan dy="1em" x="0">http://xml.apache.org/batik</tspan></text>
                <text transform="translate(241, 65)" y="0" text-anchor="end" font-size="16" fill="red"><xsl:value-of select="$version" />
                <xsl:if test="$revisionType != 'revisionType'">
                    <xsl:value-of select="substring-after($revisionType, 'revisionType')" /><xsl:text> </xsl:text><xsl:value-of select="substring-after($revisionNumber, 'revisionNumber')"/>
                </xsl:if>
                </text>
            </g>

    
        </g>
    
    </g>

    <defs>
        <g id="Batik_Squiggle">  
            <!-- The squiggle is defined as approx 54x57 units @ 0,0 -->
            <path id="Batik_Squiggle_Blue" style="fill:#6666FF;" 
                  d="M7,22c2.783-3.428,5.975-5.999,9.896-8.025c-1.157-1.682-2.313-3.363-3.47-5.045c-3.529,8.583-9.506,15.878-12.988,24.507c-1.424,3.528,1.087,7.368,4.788,4.606c4.628-3.453,9.209-6.988,12.807-11.548
                     c-1.737-1.683-3.474-3.367-5.21-5.05c-1.203,2.039-2.795,3.63-4.451,5.306c1.724,1.675,3.448,3.35,5.171,5.025c1.737-2.343,4.278-3.896,6.66-5.5c-1.726-1.112-3.452-2.225-5.177-3.337c-0.412,1.82-1.716,3.448-2.165,5.333c-0.819,3.436,2.431,5.561,5.228,3.37
                     c1.089-0.853,2.121-1.741,3.154-2.66c0.27-0.24,2.352-2.781,1.087-1.242c-1.901,0.256-3.802,0.513-5.703,0.769c-0.442-1.809-0.591-2.103-0.447-0.882c0.061,0.692,0.135,1.383,0.222,2.073c0.547,4.68,6.211-1.189,6.884-2.75c0.811-1.877,1.806-4.181,0.519-6.087
                     c-1.083-1.603-3.412-1.174-4.709-0.111c-1.155,0.947-2.154,2.039-3.312,2.981c1.743,1.123,3.485,2.247,5.228,3.37c0.401-1.833,1.678-3.476,2.114-5.365c0.839-3.633-2.323-5.241-5.177-3.337c-4.064,2.711-7.516,5.554-10.458,9.476
                     c-3.299,4.397,0.973,9.229,5.171,5.025c2.33-2.333,4.55-4.69,6.248-7.532c2.625-4.394-1.298-9.954-5.21-5.05c-3.095,3.878-6.791,6.867-10.729,9.847c1.596,1.536,3.192,3.071,4.788,4.606c3.412-8.649,9.323-16.011,12.686-24.702
                     c0.948-2.451,0.194-7.002-3.47-5.045c-5.309,2.836-9.933,6.46-13.639,11.23c-1.319,1.697-3.073,4.564-1.681,6.745c1.318,2.063,4.239,0.358,5.343-1.001z"/>

            <path id="Batik_Squiggle_Red" style="fill:#FF0000;" 
                  d="M36,13c1.095-1.054,2.151-1.838,3.493-2.567c-0.949-2.375-1.897-4.749-2.846-7.124c-1.96,3.858-3.554,8.012-5.898,11.658c-1.202,1.87-1.95,4.149-1.307,6.371c0.461,1.592,2.045,2.92,3.719,1.958
                     c2.792-1.606,5.072-3.694,7.356-5.946c-1.631-1.296-3.263-2.592-4.895-3.888c0.423-2.181-0.838,1.04-1.041,1.472c-0.595,1.267-0.875,2.5-1.14,3.864c-0.396,2.038,1.298,6.281,4.05,4.513c3.503-2.25,7.211-4.155,10.708-6.416c-0.86-2.792-1.721-5.585-2.582-8.377
                     c-2.26,3.495-4.161,7.205-6.419,10.698c-1.166,1.803-3.031,9.546,1.622,8.659c2.694-0.513,5.223-2.283,7.228-4.094c-1.4-2.216-2.8-4.432-4.2-6.648c-1.777,2.892-3.42,4.527-4.006,8.079c-0.355,2.152,1.243,6.147,4.078,4.521c2.237-1.284,4.184-2.972,6.395-4.286
                     c2.267-1.346,3.457-4.071,3.249-6.675c-0.157-1.958-1.758-4.435-4.029-3.175c-2.268,1.258-4.202,2.985-6.443,4.271c1.359,1.507,2.719,3.014,4.078,4.521c-0.546,1.443-0.411,1.566,0.405,0.371c0.791-0.92,1.374-1.96,2.007-2.989
                     c1.776-2.889-0.048-10.398-4.2-6.648c-0.903,0.816-2.232,2.09-3.469,2.326c0.541,2.886,1.081,5.772,1.622,8.659c2.26-3.495,4.161-7.205,6.419-10.698c1.215-1.88,1.976-4.14,1.287-6.376c-0.469-1.523-2.212-3.072-3.869-2.001
                     c-3.493,2.259-7.202,4.153-10.688,6.422c1.35,1.504,2.7,3.008,4.05,4.513c-0.386,2.161,0.771-1.038,0.976-1.492c0.577-1.276,0.878-2.497,1.123-3.869c0.493-2.755-2.1-6.696-4.895-3.888c-1.704,1.712-3.375,3.525-5.479,4.751c0.804,2.776,1.608,5.553,2.413,8.329
                     c2.776-4.455,4.699-9.286,6.938-14.016c0.902-1.905,1.375-9.486-2.846-7.124c-1.896,1.062-3.539,2.305-5.063,3.851c-1.783,1.808-2.738,4.762-2.12,7.262c0.545,2.203,2.574,2.816,4.221,1.232z"/>
            <path id="Batik_Squiggle_Green" style="fill:#33CC33;" 
                  d="M24,44c0.783-0.504,1.606-0.938,2.469-1.301c-1.583-1.209-3.166-2.419-4.748-3.628c-2.467,3.958-3.438,8.551-5.454,12.714c-2.352,4.856,3.013,5.929,6.132,3.061c3.375-3.103,7.41-5.351,10.752-8.495
                     c-2.078-1.06-4.155-2.12-6.233-3.18c-1.059,2.217-1.887,4.529-3.542,6.382c-3.302,3.697,0.169,7.709,4.344,5.127c4.005-2.478,8.331-4.002,11.861-7.246c-2.243-0.696-4.485-1.393-6.728-2.089c-0.215,1.156-1.024,2.195-1.661,3.168
                     c-3.016,4.607,3.391,6.075,6.246,3.195c2.925-2.951,5.072-5.702,6.501-9.646c1.441-3.978-3.187-4.057-5.543-2.891c-1.383,0.685-2.487,1.158-4.03,1.306c1.048,1.237,2.097,2.475,3.145,3.712c0.125-0.477,1.471-1.594,1.964-2.097
                     c2.829-2.878,1.002-6.963-3.061-5.589c-2.886,0.976-5.777,1.933-8.535,3.236c0.28,2.457,0.561,4.913,0.841,7.369c0.352-0.233,0.71-0.457,1.068-0.681c0.451-0.278,0.911-0.541,1.379-0.791c-0.923,0.3-0.715,0.262,0.625-0.115c2.553-0.935,4.935-3.57,5.073-6.385
                     c0.154-3.138-3.764-2.988-5.619-1.686c-2.035,1.429-3.433,2.693-4.696,4.823c0.983-0.965,1.966-1.93,2.949-2.895c-0.115,0.083-0.23,0.167-0.345,0.25c-1.448,1.045-2.816,2.212-3.498,3.921c-0.501,1.257-0.279,3.353,1.588,3.168
                     c1.579-0.156,3.114-0.367,4.511-1.194c-0.039,0.023,3.256-2.522,1.495-1.309c-1.873-0.562-3.745-1.124-5.618-1.687c0.139-0.474,0.279-0.949,0.418-1.423c1.762-1.264,3.523-2.527,5.285-3.791c-2.419,0.446-4.606,1.661-6.651,2.991
                     c-1.733,1.126-3.506,2.876-3.606,5.088c-0.11,2.417,2.563,3.155,4.448,2.281c2.775-1.286,5.681-2.224,8.582-3.182c-0.685-2.2-1.37-4.401-2.055-6.601c-2.17,2.169-4.635,4.408-5.459,7.474c-0.627,2.334,0.756,3.929,3.145,3.712c3.196-0.29,5.958-1.573,8.806-2.973
                     c-1.848-0.963-3.695-1.927-5.543-2.891c-0.48,1.318-1.07,2.204-2.055,3.192c2.082,1.065,4.164,2.13,6.246,3.195c1.067-1.622,2.254-3.462,2.616-5.39c0.854-4.542-4.149-4.445-6.728-2.089c-2.762,2.523-6.394,3.631-9.534,5.592c1.448,1.709,2.896,3.418,4.344,5.127
                     c2.271-2.566,3.568-5.538,5.016-8.597c2.284-4.825-3.085-6.168-6.233-3.18c-3.328,3.158-7.349,5.426-10.644,8.623c2.044,1.02,4.088,2.041,6.132,3.061c1.928-4.203,2.889-8.988,5.245-12.96c2.417-4.074-1.607-5.273-4.748-3.628
                     c-3.403,1.783-6.204,3.945-8.23,7.255c-0.98,1.601-1.226,4.278,1.271,4.468c2.564,0.195,5.004-1.875,6.301-3.884z"/>
        </g> <!-- End Batik_Squiggle -->

        <font-face font-family="20th Century Font" font-weight="normal" font-style="normal">
            <font-face-src>
                    <font-face-uri xlink:href="http://nagoya.apache.org/batik_1.1/svgfonts/20thfont.svg#fontDef"/>
            </font-face-src>     
        </font-face>

    </defs>
</svg>

    </xsl:template>
</xsl:stylesheet>
