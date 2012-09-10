<?xml version="1.0" encoding="UTF-8"?>
<!--
/*
 *    Copyright 2011-2012 Terradue srl
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
-->
<xsl:stylesheet version="2.0" 
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:atom="http://www.w3.org/2005/Atom" 
      xmlns:dc="http://purl.org/dc/elements/1.1/" 
      xmlns:georss="http://www.georss.org/georss" 
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns:owc="http://www.opengis.net/owc"
      xmlns:owc_wms="http://www.opengis.net/owc/wms"
>
<xsl:output method="text"/>

<xsl:template match="atom:feed">
{
	"lang" : "<xsl:value-of select="@xml:lang"/>",
	"title" : "<xsl:value-of select="atom:title"/>",
	"id" : "<xsl:value-of select="atom:id"/>,
	"subtitle" : {
		<xsl:apply-template select="atom:subtitle"/>
		},
	"entries" : [<xsl:for-each select="atom:entry">
		{<xsl:apply-templates select="."/>
		}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>
	]

}
</xsl:template>
<xsl:template match="atom:entry">
		"id" : "<xsl:value-of select="atom:id"/>",
      "title" : "<xsl:value-of select="atom:title"/>",
		"published" : "<xsl:value-of select="atom:published"/>",
      "updated" : "<xsl:value-of select="atom:updated"/>",
		<xsl:apply-templates select="georss:polygon"/>
		<xsl:apply-templats select="owc:serviceOffering"/>
		"categories" : [<xsl:for-each select="atom:categories"><xsl:apply-templates select="."/><xsl:if test="position() &lt; last()">,</xsl:if> </xsl:for-each>
		],
		"links" : [<xsl:for-each select="atom:link"><xsl:apply-templates select="."/><xsl:if test="position() &lt; last()">,</xsl:if> </xsl:for-each>
		]
</xsl:template>

<xsl:template match="atom:link">
			{
			"href" : "<xsl:value-of select="@href"/>",
			"rel" : "<xsl:value-of select="@rel"/>",
			"title" : "<xsl:value-of select="@title"/>",
			"type" : "<xsl:value-of select="@type"/>",
			"role" : "<xsl:value-of select="@xlink:role"/>"
  			}</xsl:template>


</xsl:stylesheet>
