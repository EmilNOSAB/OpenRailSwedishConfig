<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>

    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <title lang="en">Simple Horizontal Integrity Report</title>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="$xslShowHelp = 'true'">
                        <xsl:call-template name="StyleSheetHelp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="InRoads">
                            <center>
                                <h2 lang="en">Väglinje</h2>
                                <p lang="en">
                                    Rapport skapad:&#xa0; <xsl:value-of select="cif:date()"/><br />
                                    Klockan:&#xa0; <xsl:value-of select="cif:time()"/>
                                </p>
                            </center>

                            <xsl:for-each select="GeometryProject">
                                <table class="margin" cellpadding="2" width="90%">
                                    <tbody>
                                        <tr>
                                            <th align="right" lang="en">Projekt:&#xa0; </th>
                                            <td align="left" colspan="2">
                                                <xsl:value-of select="@name"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Beskrivning:&#xa0; </th>
                                            <td align="left" colspan="2">
                                                <xsl:value-of select="@description"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Filnamn:&#xa0; </th>
                                            <td align="left" colspan="2">
                                                <xsl:value-of select="@file"/>
                                            </td>
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

                                <table class="margin" width="95%">
                                    <xsl:for-each select="HorizontalAlignment">
                                        <tbody>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">
                                                    <br />Spårnamn:&#xa0;
                                                </th>
                                                <td align="left" colspan="2" valign="bottom">
                                                    <xsl:value-of select="@name"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">Beskrivning:&#xa0;</th>
                                                <td align="left" colspan="3">
                                                    <xsl:value-of select="@description"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">Feature Definition:&#xa0;</th>
                                                <td align="left" colspan="3">
                                                    <xsl:value-of select="@style"/>
                                                </td>
                                            </tr>
                                            <tr>
												<th lang="en" align="left" class="underline">
													El.Nr
												</th>
                                                <th lang="en" align="left" class="underline">
													Element
												</th>                                                
												<th lang="en" align="right" class="underline">
                                                    Längd
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Radie
                                                </th>
												<th lang="en" align="right" class="underline">
													Start<br/>Sektion
												</th>
                                                <th lang="en" align="right" class="underline">
                                                    Start<br/>N
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Start<br/>E
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Start<br/>Bäring
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Slut<br/>N
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Slut<br/>E
                                                </th>
                                                <th lang="en" align="right" class="underline">
                                                    Slut<br/>Bäring
                                                </th>
                                            </tr>
											<xsl:for-each select="HorizontalElements">
												<xsl:apply-templates select="HorizontalLine | HorizontalCircle | HorizontalSpiral"/>
											</xsl:for-each>
										</tbody>
                                    </xsl:for-each>
                                </table>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="HorizontalLine">
        <tr>
			<td align="left">
				<xsl:value-of select="position()"/>
			</td>
            <td align="left" lang="en">Raklinje</td> 
			<td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td>
            <td align="right"> </td>
			<td align="right" style="white-space:nowrap">
                <xsl:value-of select="cif:stationFormat(number(Start/station/@externalStation), string(Start/station/@externalStationName))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@direction))" />
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@direction))" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="HorizontalCircle">
        <tr>
			<td align="left">
				<xsl:value-of select="position()"/>
			</td>
            <td align="left" lang="en">Cirkulärkurva</td>
			<td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td>
            <xsl:choose>
                <xsl:when test="@rotationDirection = 'ccw'">
                    <td align="right">
                        -<xsl:value-of select="cif:distanceFormat(number(@radius))"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td align="right">
                        +<xsl:value-of select="cif:distanceFormat(number(@radius))"/>
                    </td>
                </xsl:otherwise>
            </xsl:choose>
			<td align="right" style="white-space:nowrap">
                <xsl:value-of select="cif:stationFormat(number(Start/station/@externalStation), string(Start/station/@externalStationName))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@tangentialDirectionStart))" />
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@tangentialDirectionEnd))" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="HorizontalSpiral">
        <tr>
			<td align="left">
				<xsl:value-of select="position()"/>
			</td>
			<td align="left" lang="en">Övergångskurva</td>
            <td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td>
            <td align="right"> </td>
			<td align="right" style="white-space:nowrap">
                <xsl:value-of select="cif:stationFormat(number(Start/station/@externalStation), string(Start/station/@externalStationName))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@tangentialDirectionStart))" />
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(End/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:directionFormat(number(@tangentialDirectionEnd))" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template name="StyleSheetHelp">
        <div class="section1">
            <h4 lang="en">Notes</h4>
            <p class="normal1" lang="en">
                You must select at least one Civil horizontal geometry element to get results from this report.
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>
