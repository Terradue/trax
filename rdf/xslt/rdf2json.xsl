<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" 
	xmlns:echo="http://www.echo.nasa.gov/esip"
	xmlns:eop="http://www.genesi-dr.eu/spec/opensearch/extensions/eop/1.0/"
	xmlns:foaf="http://xmlns.com/foaf/spec/"  
	xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
	xmlns:georss="http://www.georss.org/georss/10"
	xmlns:ical="http://www.w3.org/2002/12/cal/ical#" 
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 	
>
<!---
	Stylesheet transformation for WMS GetCapabilities into JSON documents
	
	
	Copyright 2011-2012 Terradue srl
        This product includes software developed by
        Terradue srl (http://www.terradue.com/).
        
	TO-DO: get geo names of selected bbox 
	
	<xsl:value-of select="."/>"<xsl:if test="position() &lt; last()">, </xsl:if>
-->

<xsl:param name="mode" select="''"/> 
<xsl:output method="text" version="1.0" encoding="utf-8" indent="yes"/>

<xsl:template match="rdf:RDF"><xsl:if test="$mode!='fragment'">{	<xsl:apply-templates select="rdf:Description"/>
	"datasets" : [</xsl:if><xsl:for-each select="dclite4g:DataSet">
	<xsl:apply-templates select="."/><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	<xsl:if test="$mode!='fragment'">]
}</xsl:if>
</xsl:template>

<xsl:template match="rdf:Description">
	<xsl:for-each select="os:*[.!='']">
	"<xsl:value-of select="local-name(.)"/>" : "<xsl:value-of select="."/>",</xsl:for-each>
</xsl:template>

<xsl:template match="dclite4g:DataSet">
		{<xsl:apply-templates select="*[local-name(.)!='onlineResource']"/>,
		"url" : [<xsl:apply-templates select="dclite4g:onlineResource"/>
			]
		}</xsl:template>

<xsl:template match="dclite4g:DataSet/*[.!='']">
		"<xsl:value-of select="translate(name(.),':','_')"/>" : "<xsl:value-of select="."/>"<xsl:if test="position() &lt; last()">, </xsl:if>
</xsl:template>

<xsl:template match="dclite4g:DataSet/*[@rdf:resource!='']">
		"<xsl:value-of select="translate(name(.),':','_')"/>" : "<xsl:value-of select="@rdf:resource"/>"<xsl:if test="position() &lt; last()">, </xsl:if>
</xsl:template>


<xsl:template match="dclite4g:DataSet/dclite4g:onlineResource">
			"<xsl:value-of select="ws:*/@rdf:about"/>"<xsl:if test="position() &lt; last()">, </xsl:if>
</xsl:template>


<xsl:template match="dct:spatial">
	<xsl:value-of select="."/><xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>

