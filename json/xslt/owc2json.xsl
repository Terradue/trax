<?xml version="1.0" encoding="UTF-8" ?>
<!--
/*	     
 *    Copyright 2011-2013 Terradue srl
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
-->

<!-- DEVELOPMENT VERSION try with care -->

<xsl:stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:atom="http://www.w3.org/2005/Atom" 
      	xmlns:dc="http://purl.org/dc/elements/1.1/" 
      	xmlns:georss="http://www.georss.org/georss" 
      	xmlns:xlink="http://www.w3.org/1999/xlink"
      	xmlns:owc="http://www.opengis.net/owc/1.0" 
>

<xsl:import href="atom2json.xsl"/>

<xsl:output method="text" indent="yes"/>

<xsl:template match="atom:feed">
	<xsl:apply-imports/>
</xsl:template>

<xsl:template match="atom:entry">
		<xsl:apply-imports/>,
		"offerings" : [<xsl:for-each select="owc:offering">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>]
		
</xsl:template>

<xsl:template match="owc:offering">
		<xsl:for-each select="@*"><xsl:apply-templates select="."/>,</xsl:for-each>
		"operations" : [<xsl:for-each select="owc:operation">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>
		],
		"contents" : [<xsl:for-each select="owc:content">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>
		]
</xsl:template>

<xsl:template match="owc:operation">
		<xsl:for-each select="@*"><xsl:apply-templates select="."/>,</xsl:for-each>
		"request" : { <xsl:apply-templates select="owc:request"/> } ,
		"result" : { <xsl:apply-templates select="owc:result"/> }
</xsl:template>

<xsl:template match="owc:request | owc:result">
		<xsl:for-each select="@*"><xsl:apply-templates select="."/>,</xsl:for-each>
		"content" : { <xsl:value-of select="."/> } 
</xsl:template>

<!---
<xsl:template match="@owc:*">
	"<xsl:value-of select="local-name(.)"/>" : "<xsl:value-of select="."/>",<xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/></xsl:template>
-->


</xsl:stylesheet>
