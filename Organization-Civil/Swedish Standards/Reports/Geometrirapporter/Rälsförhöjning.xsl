<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>
    <!-- Cant Application Report -->
    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <!-- Title displayed in browser Title Bar -->
                <title lang="en">Cant Application Report</title>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="$xslShowHelp = 'true'">
                        <xsl:call-template name="StyleSheetHelp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="InRoads">
                            <center>
                                <!-- Report Title -->
                                <h2 lang="en">Rälsförhöjning</h2>
                                <p lang="en">
                                    Rapport skapad:&#xa0; <xsl:value-of select="cif:date()"/><br/>
                                    Klockan:&#xa0; <xsl:value-of select="cif:time()"/>
                                </p>
                            </center>
                            <!-- Project Data -->
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
                                <hr />
                                <!-- Horizontal Alignment Data -->
                                <table cellpadding="1" width="100%">
                                    <xsl:for-each select="HorizontalAlignment[*/CantAlignment]">
                                        <tr>
                                            <th align="right" lang="en" width="20%"><br/>Spårnamn:&#xa0; </th>
                                            <td align="left" valign="bottom" width="80%"><xsl:value-of select="@name"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en" style="white-space:nowrap;">Beskrivning:&#xa0; </th>
                                            <td align="left"><xsl:value-of select="@description"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Feature Definition:&#xa0; </th>
                                            <td align="left"><xsl:value-of select="@style"/></td>
                                        </tr>
                                        <xsl:for-each select="Superelevation/CantAlignment">
                                            <tr>
                                                <th align="right" lang="en"><br/>Rälsförhöjning:&#xa0; </th>
                                                <td align="left" valign="bottom"><xsl:value-of select="@name"/></td>
                                            </tr>
                                            <tr>
                                                <th align="right" lang="en">Beskrivning:&#xa0; </th>
                                                <td align="left"><xsl:value-of select="@description"/></td>
                                            </tr>
                                            <tr>
                                                <td colspan="12">
                                                    <table width="100%">
                                                        <xsl:if test="//@linearUnits = 'Imperial'">
                                                            <tr>
                                                                <!--<th class="underline" lang="en" valign="bottom">Type</th>-->
                                                                <th class="underline" lang="en" valign="bottom">Sektion</th>
                                                                <th class="underline" lang="en" valign="bottom">Hastighet<br/>(mph)</th>
                                                                <th class="underline" lang="en" valign="bottom">Radie</th>
                                                                <th class="underline" lang="en" valign="bottom">Element</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Teoretisk<br/>(in)</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Anordnad<br/>(in)</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Brist<br/>(in)</th>
                                                                <th class="underline" lang="en" valign="bottom">Okompenserad<br/>Sidoacceleration<br/>(ft/s*s)</th>
                                                                <th class="underline" lang="en" valign="bottom" style="color: red;">Applied<br/>Rate of<br/>Change<br/>(in/s)</th>
                                                                <th class="underline" lang="en" valign="bottom" style="color: red;">Deficiency<br/>Rate of<br/>Change<br/>(in/s)</th>
                                                                <th class="underline" lang="en" valign="bottom">Ramptal</th>
                                                            </tr>
                                                        </xsl:if>
                                                        <xsl:if test="//@linearUnits = 'Metric'">
                                                            <tr>
                                                                <!--<th class="underline" lang="en" valign="bottom">Type</th>-->
                                                                <th class="underline" lang="en" valign="bottom">Sektion</th>
                                                                <th class="underline" lang="en" valign="bottom">Hastighet<br/>(km/h)</th>
                                                                <th class="underline" lang="en" valign="bottom">Radie</th>
                                                                <th class="underline" lang="en" valign="bottom">Element</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Teoretisk<br />(mm)</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Anordnad<br/>(mm)</th>
                                                                <th class="underline" lang="en" valign="bottom">Rälsförhöjning<br/>Brist<br/>(mm)</th>
                                                                <th class="underline" lang="en" valign="bottom">Okompenserad<br/>Sidoacceleration<br/>(m/s*s)</th>
                                                                <th class="underline" lang="en" valign="bottom">qa<br/>(h/km)</th>
                                                                <th class="underline" lang="en" valign="bottom">qb<br/>(h/km)</th>
                                                                <th class="underline" lang="en" valign="bottom">Ramptal<br/>(mm/mm)</th>
                                                            </tr>
                                                        </xsl:if>
                                                        <!-- Cant Data -->
                                                        <xsl:for-each select="Cant">
                                                            <tr>
                                                                <!--<td align="left"><xsl:value-of select="Start/@type"/></td>-->
                                                                <td align="right" style="white-space:nowrap;">
                                                                    <xsl:value-of select="cif:stationFormat(number(Start/station/@externalStation), string(Start/station/@externalStationName))"/>
                                                                </td>
                                                                <td align="right">
                                                                    <xsl:value-of select="cif:formatNumber(number(@designSpeed), 0)"/>
                                                                </td>
                                                                <td align="right">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			<xsl:value-of select="cif:distanceFormat(number(@radius), 1)"/>
																			<!--<xsl:choose>
																				<xsl:when test="preceding-sibling::Cant[1]/@radius = '∞' and following-sibling::Cant[1]/@radius != '∞'">
																					<xsl:value-of select="preceding-sibling::Cant[1]/@radius"/> - 
																					<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@radius, 1)"/>
																				</xsl:when>
																				<xsl:when test="preceding-sibling::Cant[1]/@radius != '∞' and following-sibling::Cant[1]/@radius = '∞'">
																					<xsl:value-of select="cif:formatNumber(preceding-sibling::Cant[1]/@radius, 1)"/> - 
																					<xsl:value-of select="following-sibling::Cant[1]/@radius"/>
																				</xsl:when>
																				<xsl:otherwise>
																					<xsl:value-of select="cif:formatNumber(preceding-sibling::Cant[1]/@radius, 1)"/> - 
																					<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@radius, 1)"/>
																				</xsl:otherwise>
																			</xsl:choose>-->																	
																		</xsl:when>
																		<xsl:when test="@transitionType = 'Circular'">
																			<xsl:value-of select="cif:distanceFormat(number(@radius), 1)"/>
																		</xsl:when>
																		<xsl:otherwise/>
																	</xsl:choose>
                                                                </td>
                                                                <td align="right">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Linear'">
																			Raklinje
																		</xsl:when>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			Övergångskurva
																		</xsl:when>
																		<xsl:when test="@transitionType = 'Circular'">
																			Cirkulärkurva
																		</xsl:when>
																		<xsl:otherwise/>
																	</xsl:choose>
																</td>
                                                                <td align="center">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			<xsl:value-of select="cif:formatNumber(number(@equilibriumCant), 1)"/><!-- -
																			<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@equilibriumCant, 1)"/>-->
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:value-of select="cif:formatNumber(number(@equilibriumCant), 1)"/>
																		</xsl:otherwise>
																	</xsl:choose>
                                                                </td>
                                                                <td align="center">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			<xsl:value-of select="cif:formatNumber(number(@appliedCant), 1)"/><!-- -
																			<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@appliedCant, 1)"/>-->
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:value-of select="cif:formatNumber(number(@appliedCant), 1)"/>
																		</xsl:otherwise>
																	</xsl:choose>
                                                                </td>
                                                                <td align="center">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			<xsl:value-of select="cif:formatNumber(number(@cantDeficiency), 1)"/><!-- -
																			<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@cantDeficiency, 1)"/>-->
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:value-of select="cif:formatNumber(number(@cantDeficiency), 1)"/>
																		</xsl:otherwise>
																	</xsl:choose>
                                                                </td>
                                                                <td align="center">
																	<xsl:choose>
																		<xsl:when test="@transitionType = 'Clothoid'">
																			<xsl:value-of select="cif:formatNumber(number(@nonLateralAcceleration), 2)"/><!-- -
																			<xsl:value-of select="cif:formatNumber(following-sibling::Cant[1]/@nonLateralAcceleration, 2)"/>-->
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:value-of select="cif:formatNumber(number(@nonLateralAcceleration), 2)"/>
																		</xsl:otherwise>
																	</xsl:choose>
                                                                </td>
                                                                <td align="center">
                                                                    <xsl:if test="@appliedCantRateOfChange != 0">
																		<xsl:value-of select="cif:formatNumber(number(1000 div (@appliedCantRateOfChange * 3.6)), 1)"/>
																	</xsl:if>
                                                                </td>
                                                                <td align="center">
																	<xsl:if test="@cantDeficiencyRateOfChange != 0">
																		<xsl:value-of select="cif:formatNumber(number(1000 div (@cantDeficiencyRateOfChange *3.6)), 1)"/>
																	</xsl:if>
                                                                </td>
                                                                <td align="center">
																	<xsl:if test="@appliedGradient != 0">
																		<xsl:value-of select="cif:formatNumber(number(@appliedGradient), 0)"/>
																	</xsl:if>
                                                                </td>
                                                            </tr>
                                                        </xsl:for-each>
                                                        <tr><td colspan="12">&#xa0;</td></tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </table>
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
