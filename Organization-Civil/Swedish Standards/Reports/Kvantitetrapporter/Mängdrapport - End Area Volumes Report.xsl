<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
    <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
    <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>
    <xsl:param name="xslConvertToCY" select="cif:xslConvertToCY"/>
    
    <!-- Variable to hold cubic factor -->
    <xsl:variable name="cubicFactor">
        <xsl:choose>
            <xsl:when test="//@linearUnits = 'Imperial'">
                <xsl:choose>
                    <xsl:when test="$xslConvertToCY = 1">27</xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Variable to hold unit cost factor  - TFS#945838-->
    <xsl:variable name="unitCostFactor">
        <xsl:choose>
            <xsl:when test="//@linearUnits = 'Imperial'">
                <xsl:choose>
                    <xsl:when test="$xslConvertToCY = 1">1</xsl:when>
                    <xsl:otherwise>27</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Volumes Report -->
    <xsl:template match="/">
        <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
                <!-- Title displayed in browser Title Bar -->
                <title lang="en">Volumes Report</title>
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
                                <h2 lang="en">Mängdrapport - End Area Volumes Report</h2>
                                <p lang="en">
                                    Rapport skapad: <xsl:value-of select="cif:date()"/><br/>
                                    Klockan: <xsl:value-of select="cif:time()"/>
                                </p>
                            </center>
                            <!-- Cross Section Set Data -->
                            <xsl:for-each select="CrossSectionSet">
                                <table class="margin" cellpadding="2" width="90%">
                                    <tbody>
                                        <tr>
                                            <th align="right" lang="en">Tvärsektioner:</th>
                                            <td align="left" colspan="2"><xsl:value-of select="@setName"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en">Spårnamn:</th>
                                            <td align="left" colspan="2"><xsl:value-of select="@alignmentName"/></td>
                                        </tr>
                                        <tr>
                                            <th align="right" lang="en" style="font-size: 80%"></th>
                                            <td align="right" lang="en" style="font-size: 80%">
                                                <strong>Obs: </strong>Alla enheter i denna rapport är i
                                                <xsl:if test="//@linearUnits = 'Imperial'">fot</xsl:if>
                                                <xsl:if test="//@linearUnits = 'Metric'">meter</xsl:if>
                                                om inte annat anges.
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <hr/>
                                <!-- Volume Data -->
                                <table class="margin" width="90%"> <!-- border="solid 0.1mm black" -->
                                    <xsl:for-each select="CrossSectionStations">
                                        <thead style="display:table-header-group">
                                            <xsl:for-each select="CrossSectionStation">
												<xsl:if test="position() = last()">
													<xsl:for-each select="StationVolume">
														<tr>
															<th class="underline" lang="en" align="left" valign="bottom">Station</th>
															<xsl:apply-templates mode="first"/>
														</tr>
													</xsl:for-each>
												</xsl:if>                                                                         
											</xsl:for-each>
                                        </thead>
                                        <xsl:for-each select="CrossSectionStation">
                                            <tbody>
                                                <xsl:apply-templates/>
                                            </tbody>
                                            <tfoot style="display:table-footer-group">
                                                <xsl:if test="position() = last()">
                                                    <xsl:for-each select="StationVolume">
                                                        <tr><td colspan="100"><hr/></td></tr>
                                                        <th align="left">Summa:</th>
                                                        <xsl:apply-templates mode="final"/>
                                                        <!--<tr>
                                                            <th colspan="7" align="right">
                                                                Uppskattad kostnad:                                                           
                                                            </th>
                                                            <th  align="right">
                                                                <xsl:value-of select="cif:formatNumber(number(//@totalCost), 2)"/>
                                                            </th>
                                                        </tr>-->
                                                        
                                                    </xsl:for-each>
                                                </xsl:if>
                                            </tfoot>
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
	<xsl:template match="Material" mode="first">
		<th class="underline" lang="en" valign="bottom">
			<xsl:choose>
				<xsl:when test="contains(@name, '\')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="materialName" select="@name" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(@name, 'Volumes_Cut')">						
						Skärning						
				</xsl:when>
				<xsl:when test="contains(@name, 'Volumes_Fill')">						
						Fyllning					
				</xsl:when>
				<xsl:otherwise>						 
						<xsl:value-of select="@name"/>						
				 </xsl:otherwise>
			</xsl:choose>
			<br/>Area:
		</th>
        <th class="underline" lang="en" valign="bottom">
			<xsl:choose>
				<xsl:when test="contains(@name, '\')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="materialName" select="@name" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(@name, 'Volumes_Cut')">						
						Skärning					
				</xsl:when>
				<xsl:when test="contains(@name, 'Volumes_Fill')">						
						Fyllning					
				</xsl:when>
				<xsl:otherwise>						 
						<xsl:value-of select="@name"/>						
				 </xsl:otherwise>
			</xsl:choose> 
			<br/>Volym:
		</th>
    </xsl:template>
    <xsl:template match="StationVolume">
		<th align="left" nowrap="nowrap">
			<xsl:value-of select="cif:stationFormat(number(../Station/@externalStation), string(../Station/@externalStationName))"/>
		</th>
        <xsl:apply-templates mode="normalParent"/>
        <!--<tr><td>&#xa0;</td></tr>-->
    </xsl:template>
    <xsl:template match="Material" mode="normalParent">
		<!--<td align="right" colspan="1">
			<xsl:choose>
				<xsl:when test="contains(@name, '\')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="materialName" select="@name" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(@name, 'Cut Volume')">						
						Skärning:&#xa0;						
				</xsl:when>
				<xsl:when test="contains(@name, 'Fill Volume')">						
						Fyllning:&#xa0;						
				</xsl:when>
				<xsl:otherwise>						 
						<xsl:value-of select="@name"/>:&#xa0; 						
				 </xsl:otherwise>
			</xsl:choose>
		</td>-->
		<xsl:choose>
			<xsl:when test="@area != 0.0">
				<td align="center">
					<xsl:value-of select="cif:areaFormat(number(@area))"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				 <td></td>
			 </xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@volume != 0.0">
				<td align="center">
					<xsl:value-of select="cif:cubicFormat(number(@volume div $cubicFactor))"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				 <td></td>
			 </xsl:otherwise>
		</xsl:choose>
		<!--<xsl:choose>
			<xsl:when test="@length != 0.0">
				<td align="right">
					<xsl:value-of select="cif:distanceFormat(number(@length))"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				 <td>&#xa0;</td>
			 </xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@linearArea != 0.0">
				<td align="right">
					<xsl:value-of select="cif:areaFormat(number(@linearArea))"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				 <td>&#xa0;</td>
			 </xsl:otherwise>
		</xsl:choose>
		<td align="right">
			<xsl:choose>
				<xsl:when test="@volume != 0.0">
					<xsl:value-of select="cif:formatNumber(number(@unitCost div $unitCostFactor), 2)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="cif:formatNumber(number(@unitCost), 2)"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
		<td align="right">
			<xsl:value-of select="cif:cubicFormat(number((@volume div $cubicFactor div $unitCostFactor + @linearArea) * @unitCost), 2)"/>
		</td>-->
    </xsl:template>
    <xsl:template match="Material" mode="final">
		<!--<td align="right" colspan="1">
			<xsl:choose>
				<xsl:when test="contains(@name, '\')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="materialName" select="@name" />
						<xsl:with-param name="delimiter" select="'\'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="contains(@name, 'Cut Volume')">						
						Skärning:&#xa0;						
				</xsl:when>
				<xsl:when test="contains(@name, 'Fill Volume')">						
						Fyllning:&#xa0;						
				</xsl:when>
				<xsl:otherwise>						 
						<xsl:value-of select="@name"/>:&#xa0; 						
				 </xsl:otherwise>
			</xsl:choose>
		</td>-->
		<xsl:choose>
			<xsl:when test="@cumulativeVolume != 0.0">
				<td></td>
				<td align="center">
					<xsl:value-of select="cif:cubicFormat(number(@cumulativeVolume div $cubicFactor), 2)"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="2"></td>
			</xsl:otherwise>
		</xsl:choose>
		<!--<xsl:choose>
			<xsl:when test="@cumulativeArea != 0.0">
				<td colspan="1" align="right">
					<xsl:value-of select="cif:cubicFormat(number(@cumulativeArea))"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td colspan="1">&#xa0;</td>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="@cumulativeVolume != 0.0">
				<td align="right">
					<xsl:value-of select="cif:formatNumber(number(@unitCost div $unitCostFactor), 2)"/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td align="right">
					<xsl:value-of select="cif:formatNumber(number(@unitCost), 2)"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>
		<td align="right">
			<xsl:value-of select="cif:cubicFormat(number((@cumulativeArea + @cumulativeVolume div $cubicFactor div $unitCostFactor) * @unitCost), 2)"/>
		</td>-->
    </xsl:template>
    <xsl:template name="StyleSheetHelp">
        <div class="section1">
            <h4 lang="en">Notes</h4>
            <p class="normal1" lang="en">
                You must click the <em>Report </em> button from within <em>Component Quantities</em> to generate a report from this
                command.  Alternately, you can open this report from the Civil Report Browser if another Component Quantities report has already been generated.
            </p>
        </div>
    </xsl:template>
	<!-- Code created with help of Stack Overflow Question: https://stackoverflow.com/questions/9078779/  
		Questioner: https://stackoverflow.com/users/494143/lysergic-acid
		Responder: https://stackoverflow.com/users/14419/mads-hansen -->
	<xsl:template name="substring-after-last">
		<xsl:param name="materialName" />
		<xsl:param name="delimiter" />
		<xsl:choose>
			<xsl:when test="contains($materialName, $delimiter)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="materialName" select="substring-after($materialName, $delimiter)" />
					<xsl:with-param name="delimiter" select="$delimiter" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$materialName" />:&#xa0; 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>