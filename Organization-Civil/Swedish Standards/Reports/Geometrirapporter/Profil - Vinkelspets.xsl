<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>

    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))" />
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <title lang="en">Simple Vertical Integrity Report</title>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="$xslShowHelp = 'true'">
                        <xsl:call-template name="StyleSheetHelp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="InRoads">
                            <center>
                                <h2 lang="en">Profil</h2>
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
                                <xsl:for-each select="HorizontalAlignment[VerticalAlignment]">
                                    <table class="margin" width="75%">
                                        <thead>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">
                                                    <br/>Spårnamn:
                                                </th>
                                                <td align="left" colspan="2" valign="bottom">
                                                    <xsl:value-of select="@name"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">Beskrivning:</th>
                                                <td align="left" colspan="3">
                                                    <xsl:value-of select="@description"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="right" colspan="2" lang="en">Feature Definition:</th>
                                                <td align="left" colspan="3">
                                                    <xsl:value-of select="@style"/>
                                                </td>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="VerticalAlignment">
                                                <tr>
                                                    <th align="right" colspan="2" lang="en">
                                                        <br/>Profil:
                                                    </th>
                                                    <td align="left" colspan="2" valign="bottom">
                                                        <xsl:value-of select="@name"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th align="right" colspan="2" lang="en">Beskrivning:</th>
                                                    <td align="left" colspan="3">
                                                        <xsl:value-of select="@description"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th align="right" colspan="2" lang="en">Feature Definition:</th>
                                                    <td align="left" colspan="3">
                                                        <xsl:value-of select="@style"/>
                                                    </td>
                                                </tr>
                                                <tr>
													<th lang="en" align="left" class="underline">
                                                        Sektion
                                                    </th>
													<th lang="en" align="left" class="underline">
                                                        Lutning (‰)
                                                    </th>
													<th lang="en" align="left" class="underline">
                                                        Längd
                                                    </th>
                                                </tr>
                                                <xsl:apply-templates select="//VerticalLine | //VerticalCircle"/>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="VerticalLine">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<tr>	
						<td align="left">
							<xsl:value-of select="cif:stationFormat(number(VerticalStart/station/@externalStation), string(VerticalStart/station/@externalStationName))"/>
						</td>
					</tr>
				</xsl:when>
				<xsl:when test="position() = last()">
					<tr>	
						<td align="left">
							<xsl:value-of select="cif:stationFormat(number(VerticalEnd/station/@externalStation), string(VerticalEnd/station/@externalStationName))"/>
						</td>
					</tr>
				</xsl:when>
			</xsl:choose>
    </xsl:template>

    <xsl:template match="VerticalCircle">
		<tr>
			<td></td>
			<td align="left">
				<xsl:value-of select="cif:gradeFormat(number(@startGrade))"/>
			</td>
			<td align="left">
				<xsl:value-of select="substring(cif:distanceFormat(number(PVI/@PVItoPVIHorizontalBack)),2)"/>
			</td>
		</tr>
		<tr>
			<td align="left">
					<xsl:value-of select="cif:stationFormat(number(PVI/station/@externalStation), string(PVI/station/@externalStationName))"/>
			</td>
		</tr>
		<xsl:if test="position() = last() - 1">
			<tr>
				<td></td>
				<td align="left">
						<xsl:value-of select="cif:gradeFormat(number(@endGrade))"/>
				</td>
				<td align="left">
					<xsl:value-of select="cif:distanceFormat(number(PVI/@PVItoPVIHorizontalAhead))"/>
				</td>
			</tr>
		</xsl:if>
    </xsl:template>

    <xsl:template name="StyleSheetHelp">
        <div class="section1">
            <h4 lang="en">Notes</h4>
            <p class="normal1" lang="en">
                You must include at least one Civil vertical geometry element to get results from this report.
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>
