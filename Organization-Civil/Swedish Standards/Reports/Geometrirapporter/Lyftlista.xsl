<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>

    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <title lang="en">Vertical Regression Points Review Report</title>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="$xslShowHelp = 'true'">
                        <xsl:call-template name="StyleSheetHelp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="InRoads">
                            <center>
                                <h2 lang="en">Lyftlista</h2>
                                <p lang="en">
                                    Rapport skapad:&#xa0; <xsl:value-of select="cif:date()"/><br/>
                                    Klockan:&#xa0; <xsl:value-of select="cif:time()"/>
                                </p>
                            </center>

                            <xsl:for-each select="GeometryProject">
                                <table class="margin" cellpadding="2" width="90%">
                                    <tbody>
                                        <tr>
                                            <th align="right" lang="en">Projekt:&#xa0; </th>
                                            <td align="left" colspan="2"><xsl:value-of select="@name"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Beskrivning:&#xa0; </th>
                                            <td align="left" colspan="2"><xsl:value-of select="@description"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Filnamn:&#xa0; </th>
                                            <td align="left" colspan="2"><xsl:value-of select="@file"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Fil senast sparad:&#xa0; </th>
                                            <td align="left" colspan="2">
                                                <xsl:value-of select="concat(@lastRevisedBy, '  ', @lastRevisedDate)"/> (MM-DD-ÅÅÅÅ)
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en" style="font-size: 80%">&#xa0; </th>                                            
                                            <td align="right" lang="en" style="font-size: 80%">
                                                <strong>Obs:&#xa0;</strong>Alla enheter i denna rapport är i
                                                <xsl:if test="//@linearUnits = 'Imperial'">fot</xsl:if>
                                                <xsl:if test="//@linearUnits = 'Metric'">meter</xsl:if>
                                                om inte annat anges.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <hr/>

                                <xsl:for-each select="HorizontalAlignment">
                                <table class="margin" width="90%">
                                    <thead>
                                        <tr>
                                            <th align="right" colspan="1" lang="en">Spårnamn:&#xa0; </th>
                                            <td align="left" colspan="1"><xsl:value-of select="@name"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" colspan="1" lang="en">Beskrivning:&#xa0; </th>
                                            <td align="left" colspan="1"><xsl:value-of select="@description"/></td>
                                        </tr>
                                    </thead>
                                    <xsl:for-each select="VerticalAlignment">
                                        <tbody>
                                            <tr><td colspan="6">&#xa0;</td></tr>
                                            <tr>
                                                <th align="right" colspan="1" lang="en">Profil:&#xa0; </th>
                                                <td align="left" colspan="1"><xsl:value-of select="@name"/></td>
                                            </tr>
                                            <tr>
                                                <th align="right" colspan="1" lang="en">Beskrivning:&#xa0; </th>
                                                <td align="left" colspan="1"><xsl:value-of select="@description"/></td>
                                            </tr>
                                            <tr><td colspan="9">&#xa0;</td></tr>
                                            <xsl:for-each select="RegressionPoints">
                                                <tr>
                                                    <th class="underline" lang="en" align="left">Punktindex</th>
                                                    <th class="underline" lang="en" align="right">Sektion</th>
													<!--<th class="underline" lang="en" align="right">Punkt<br/>N</th>
                                                    <th class="underline" lang="en" align="right">Punkt<br/>E</th>-->
                                                    <th class="underline" lang="en" align="right">Punkt<br/>Höjd</th>
                                                    <!--<th class="underline" lang="en" align="right">Tangential Gradient</th>
                                                    <th class="underline" lang="en" align="center">Point Type</th>-->
                                                    <th class="underline" lang="en" align="right">Spår<br/>Höjd</th>
                                                    <th class="underline" lang="en" align="right">Lyft</th>
                                                </tr>
                                                <xsl:for-each select="RegressionPoint">
                                                    <tr>
                                                        <td align="left">
                                                            <xsl:value-of select="@index"/>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:value-of select="cif:stationFormat(number(GeometryPoint/station/@externalStation), string(GeometryPoint/station/@externalStationName))"/>
                                                        </td>
														<!--<td align="right">
                                                            <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@northing))"/>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@easting))"/>
                                                        </td>-->
                                                        <td align="right">
                                                            <xsl:value-of select="cif:ordinateFormat(number(@elevation))"/>
                                                        </td>
                                                        <!--<td align="right">
                                                            <xsl:value-of select="cif:gradeFormat(number(@slope))"/>
                                                        </td>
                                                        <td align="center">
                                                            <xsl:value-of select="GeometryPoint/@type"/>
                                                        </td>-->
                                                        <td align="right">
                                                            <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@elevation))"/>
                                                        </td>
                                                        <td align="right">
                                                            <xsl:value-of select="cif:distanceFormat(number(@lift))"/>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </tbody>
                                    </xsl:for-each>
                                </table>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="StyleSheetHelp">
        <p class="normal1" lang="en">
            This report has no additional notes.
        </p>
    </xsl:template>
</xsl:stylesheet>
