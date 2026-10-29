<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:cif="cif">
  <xsl:param name="xslShowHelp" select="cif:xslShowHelp"/>
  <xsl:param name="xslResourceDirectory" select="cif:xslResourceDirectory"/>
  <xsl:template match="/">
    <xsl:variable name="gridOut" select="cif:SetGridOut(number(InRoads/@outputGridScaleFactor))" />
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="{$xslResourceDirectory}/engtheme.css"/>
        <title lang="en">Station Offset Report</title>
      </head>
      <body>
        <xsl:choose>
          <xsl:when test="$xslShowHelp = 'true'">
            <xsl:call-template name="StyleSheetHelp"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="InRoads">
              <center>
                <h2 lang="en">Hinderberäkning</h2>
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
                      <th align="right" lang="en">Spårnamn:</th>
                      <td align="left" colspan="2">
                        <xsl:value-of select="HorizontalAlignment/@name"/>
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
                        <xsl:value-of select="concat(@lastRevisedBy, '  ', @lastRevisedDate)"/>
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

                <!-- From Custom Point Station Offset Elevation Feature command -->
                <xsl:for-each select="HorizontalAlignment[OffsetPoint]">
                  <table cellspacing="4" width="100%">
                    <thead style="display:table-header-group">
                      <tr>
                        <th class="underline" lang="en" align="left">Punktnamn</th>
                        <th class="underline" lang="en" align="left">Sektion</th>
                        <th class="underline" lang="en" align="left">Sidoavstånd</th>
                        <th class="underline" lang="en" align="left">N</th>
                        <th class="underline" lang="en" align="left">E</th>
                        <th class="underline" lang="en" align="left">Z</th>
                        <th class="underline" lang="en" align="left">Feature</th>
                      </tr>
                    </thead>
                    <tbody>
                        <xsl:for-each select="OffsetPoint/GeometryPointProperties">
                          <tr>
                            <td align="left">
                              <xsl:value-of select="@PointName"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="cif:stationFormat(number(station/@externalStation),string(station/@externalStationName))"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="cif:distanceFormat(number(@offset))"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="cif:ordinateFormat(number(@northing))"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="cif:ordinateFormat(number(@easting))"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="cif:ordinateFormat(number(@elevation))"/>
                            </td>
                            <td align="left">
                              <xsl:value-of select="@FeatureName"/>
                            </td>
                          </tr>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </xsl:for-each>

                <!--From Alignment Station Offset command -->
                <xsl:for-each select="HorizontalAlignment[StationOffsetPoints]">
                  <table cellspacing="4" width="100%">

                    <tbody>
                      <xsl:for-each select="StationOffsetPoints/StationOffsetPoint">
                        <tr>
                          <xsl:if test="not(@offsetAlignmentName = preceding-sibling::*/@offsetAlignmentName)">
                            <tr>
                              <th class="underline" lang="en" align="left">
                                Baseline Alignment
                                <br>
                                  (<xsl:value-of select="../../../HorizontalAlignment/@name"/>)
                                </br>
                                <br />
                                Point Type
                              </th>
                              <th class="underline" lang="en" align="left">
                                Offset Alignment
                                <br>
                                  (<xsl:value-of select="@offsetAlignmentName"/>)
                                </br>
                                <br />
                                Point Name
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Baseline Alignment<br />Station
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Baseline Alignment<br />Offset
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Offset Alignment<br />Northing
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Offset Alignment<br />Easting
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Offset Alignment<br />Elevation
                              </th>
                              <th class="underline" lang="en" align="left">
                                <br />
                                Offset Alignment<br />Feature
                              </th>
                            </tr>
                          </xsl:if>
                          <td align="left">
                            <xsl:value-of select="centerLinePoint/point/@type"/>
                          </td>
                          <td align="left">
                            <xsl:value-of select="offsetPoint/@name"/>
                          </td>
                          <td align="left">
                            <xsl:value-of select="cif:stationFormat(number(centerLinePoint/point/station/@externalStation),string(centerLinePoint/point/station/@externalStationName))"/>
                          </td>
                          <td align="left">
                            <xsl:value-of select="cif:distanceFormat(number(@firstOffset))"/>
                          </td>
                          <td align="left">
                            <xsl:value-of select="cif:ordinateFormat(number(offsetPoint/@northing))"/>
                          </td>
                          <td align="left">
                            <xsl:value-of select="cif:ordinateFormat(number(offsetPoint/@easting))"/>
                          </td>
                          <td align="left">
                            <xsl:if test="offsetPoint/@elevation">
                              <xsl:value-of select="cif:ordinateFormat(number(offsetPoint/@elevation))"/>
                            </xsl:if>
                          </td>
                          <td align="left">
                            <xsl:value-of select="@FeatureName"/>
                          </td>
                        </tr>
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

  <xsl:template name="StyleSheetHelp">
    <p class="normal1" lang="en">
      This report has no additional notes.
    </p>
  </xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios/>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->