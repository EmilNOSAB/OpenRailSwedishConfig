<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>

    <!--Turnout Report-->
    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))" />
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <!--Title displayed in browser Title Bar-->
                <title lang="en">Turnout Report</title>
            </head>
            <body>
                <xsl:choose>
                    <xsl:when test="$xslShowHelp = 'true'">
                        <xsl:call-template name="StyleSheetHelp"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="InRoads">
                            <center>
                                <!--Report Title-->
                                <h2 lang="en">Växelberäkning</h2>
                                <p lang="en">
                                    Rapport skapad:&#xa0; <xsl:value-of select="cif:date()"/><br />
                                    Klockan:&#xa0; <xsl:value-of select="cif:time()"/>
                                </p>
                            </center>
                            
                            <!--Project Data-->
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
                                <hr />
                                <xsl:for-each select="Turnout">
                                    <table class="margin" cellpadding="2" cellspacing="1" width="90%">
                                        <thead>
                                            <colgroup span="6">
                                                <col width="20%"/>
                                                <col width="16%"/>
                                                <col width="16%"/>
                                                <col width="16%"/>
                                                <col width="16%"/>
                                                <col width="16%"/>
                                            </colgroup>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td align="left" colspan="6" lang="en"><strong>Växel:&#xa0; </strong>
                                                    <xsl:value-of select="@name"/>
                                                    <xsl:text> - </xsl:text>
                                                    <xsl:value-of select="@description"/>
                                                    <!--(<xsl:value-of select="@style"/>)-->
                                                </td>
                                            </tr>
                                            <tr>
												<td align="left" colspan="6" lang="en">
													<i>Placering</i>:													
														<xsl:choose>
															<xsl:when test="@placement = 'ByPoint0'">
																MKP,
															</xsl:when>
															<xsl:when test="@placement = 'ByPoint1'">
																FSK,
															</xsl:when>
															<xsl:when test="@placement = 'ByPoint2'">
																BKS 1,
															</xsl:when>
															<xsl:when test="@placement = 'ByPoint3'">
																BKS 2,
															</xsl:when>
															<xsl:when test="@placement = 'ByPoint4'">
																BKS 3,
															</xsl:when>
															<xsl:when test="@placement = 'ByPoint5'">
																BKS 4,
															</xsl:when>
															<xsl:otherwise/>
														</xsl:choose>
													<i>Riktning</i>:
														<xsl:choose>
															<xsl:when test="@hand = 'ToTheLeft'">
																Vänster,
															</xsl:when>
															<xsl:when test="@hand = 'ToTheRight'">
																Höger,
															</xsl:when>
															<xsl:otherwise/>
														</xsl:choose>
													<i>Orientering</i>:
														<xsl:choose>
															<xsl:when test="@orientation = 'Leading'">
																Framåt,
															</xsl:when>
															<xsl:when test="@orientation = 'Trailing'">
																Bakåt,
															</xsl:when>
															<xsl:otherwise/>
														</xsl:choose>
													<i>Stamspår</i>:
													<xsl:value-of select="TurnoutPoint/@mainlineAlignment"/>
                                              </td>
                                            </tr>
											<tr>
												<th align="left"  lang="en">Element</th>
												<th align="left" lang="en">Radie</th>
												<th align="right" lang="en">Längd</th>
												<th align="right" lang="en">Start N</th>
												<th align="right" lang="en">Start E</th>
												<th align="right" lang="en">Start Z</th>
											</tr>
                                          <xsl:apply-templates />
                                        </tbody>
                                    </table>
                                    <hr />
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    
    <!-- Turnout Horizontal Line Data -->
    <xsl:template match="HorizontalLine">
        <!--<xsl:if test="position() = 10 or position() = 20 or preceding-sibling::*[1][name() = 'TurnoutPoint']">
            <tr>
                <th align="left"  lang="en">Element</th>
				<th align="right" lang="en">Radie</th>
				<th align="right" lang="en">Längd</th>
                <th align="right" lang="en">Start N</th>
                <th align="right" lang="en">Start E</th>
                <th align="right" lang="en">Start Z</th>
            </tr>
        </xsl:if>-->
        <tr>
            <td align="left" lang="en">Raklinje</td>
			<td align="right"></td>
			<td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td>   
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
			<td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@elevation))"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- Turnout Horizontal Circle Data -->
    <xsl:template match="HorizontalCircle">
        <!--<xsl:if test="position() = 10 or position() = 20 or preceding-sibling::*[1][name() = 'TurnoutPoint']">
            <tr>
                <th align="left"  lang="en">Element</th>
				<th align="right" lang="en">Radie</th>
                <th align="right" lang="en">Längd</th>
                <th align="right" lang="en">Start N</th>
                <th align="right" lang="en">Start E</th>
                <th align="right" lang="en">Start Z</th>
            </tr>
        </xsl:if>-->
        <tr>
            <td align="left" lang="en">Cirkulärkurva</td>
            <td align="left">
                <xsl:value-of select="cif:distanceFormat(number(@radius))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td>  
			<td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
			<td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@elevation))"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- Turnout Horizontal Spiral Data -->
    <xsl:template match="HorizontalSpiral">
        <!--<xsl:if test="position() = 10 or position() = 20 or preceding-sibling::*[1][name() = 'TurnoutPoint']">
            <tr>
                <th align="left"  lang="en">Element</th>
				<th align="right" lang="en">Radie</th>
                <th align="right" lang="en">Längd</th>
                <th align="right" lang="en">Start N</th>
                <th align="right" lang="en">Start E</th>
                <th align="right" lang="en">Start Z</th>
            </tr>
        </xsl:if>-->
        <tr>
            <td align="left" lang="en">Övergångskurva</td>
			<td align="left">
                <xsl:value-of select="cif:distanceFormat(number(@startRadius))"/> - <xsl:value-of select="cif:distanceFormat(number(@endRadius))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:distanceFormat(number(@length))"/>
            </td> 
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@easting))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(Start/@elevation))"/>
            </td>
        </tr>
    </xsl:template>
    
    <!-- Turnout Points -->
    <xsl:template match="TurnoutPoint">
        <xsl:if test="preceding-sibling::*[1][name() != 'TurnoutPoint']">
            <tr>
                <td></td>
            </tr>
            <tr>
                <th align="left"  lang="en">Växelpunkt</th>
				<th align="left"  lang="en">Sektion (Stamspår)</th>
                <th align="right" lang="en">Avstånd (Stamspår)</th>
                <th align="right" lang="en">N</th>
                <th align="right" lang="en">E</th>
                <!--<th align="right" lang="en">Radie</th>-->
                <th align="right" lang="en">Z</th>
            </tr>
        </xsl:if>
        <tr>
            <td align="left">
			<xsl:choose>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P0'">
					MKP
				</xsl:when>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P1'">
					FSK
				</xsl:when>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P2'">
					BKS 1
				</xsl:when>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P3'">
					BKS 2
				</xsl:when>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P4'">
					BKS 3
				</xsl:when>
				<xsl:when test="GeometryPoint/@name = 'Branch1 P5'">
					BKS 4
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			</td>
			<td align="left" style="white-space:nowrap">
                <xsl:value-of select="cif:stationFormat(number(GeometryPoint/Station/@externalStation), string(GeometryPoint/Station/@externalStationName))"/>
            </td>
			<td align="right">
                <xsl:value-of select="cif:distanceFormat(number(GeometryPoint/@offset))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@northing))"/>
            </td>
            <td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@easting))"/>
            </td>
            <!--<td align="right">
                <xsl:value-of select="cif:distanceFormat(number(GeometryPoint/@radius))"/>
            </td>-->  
			<td align="right">
                <xsl:value-of select="cif:ordinateFormat(number(GeometryPoint/@elevation))"/>
            </td> 
            <td />
        </tr>
    </xsl:template>

    <xsl:template name="StyleSheetHelp">
        <p class="normal1" lang="en">
            This report has no additional notes.
        </p>
    </xsl:template>
</xsl:stylesheet>
