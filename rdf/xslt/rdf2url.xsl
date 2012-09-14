<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
>
<xsl:output method="text" version="1.0" encoding="utf-8" indent="yes"/>

<xsl:template match="rdf:RDF">
	<xsl:apply-templates select="dclite4g:DataSet"/>
</xsl:template>

<xsl:template match="dclite4g:DataSet">
	<xsl:apply-templates select="dclite4g:onlineResource"/>
</xsl:template>


<xsl:template match="dclite4g:onlineResource">
	<xsl:value-of select="ws:*/@rdf:about"/><xsl:text>
</xsl:text>
</xsl:template>



</xsl:stylesheet>

