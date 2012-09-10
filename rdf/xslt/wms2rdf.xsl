<?xml version="1.0" encoding="UTF-8"?>
<!---
	Stylesheet transformation for WMS into dclite4g metadata model
	This xsl maps the service to a series and assumes all layers are datasets of that series 
	This was made and tested using the FAIRE WMS available at
	http://preview.grid.unep.ch:8080/geoserver/ows?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetCapabilities

	Still not used: Dimension*, Extent*,Attribution?, AuthorityURL*, Identifier*, DataURL*
-->

<xsl:stylesheet version="1.0" 
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:ical="http://www.w3.org/2002/12/cal/ical#"  
	xmlns:foaf="http://xmlns.com/foaf/spec/"  
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
	xmlns:xlink="http://www.w3.org/1999/xlink"  
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:atom="http://www.w3.org/2005/Atom"
	exclude-result-prefixes="xlink xsl"
	>
<xsl:include href="../../xslt/utils.xsl"/>
<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes"/>


<xsl:variable name="GETMAPonlineResource" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href"/>
<xsl:variable name="WMSonlineResource" select="/wms:WMS_Capabilities/wms:Service/OnlineResource/@xlink:href"/>
<xsl:variable name="ExceptionFormat" select="/wms:WMS_Capabilities/wms:Capability/wms:Exception/wms:Format[1]"/>


<xsl:template match="/">
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<xsl:apply-templates select="wms:WMS_Capabilities"/>
</rdf:RDF>
</xsl:template>


<xsl:template match="wms:WMS_Capabilities">



<xsl:variable name="WMSname" select="wms:Service/wms:Name"/>
<xsl:variable name="WMStitle" select="wms:Service/wms:Title"/>
<xsl:variable name="WMSabstract" select="wms:Service/wms:Abstract"/>

<xsl:variable name="WMSfees" select="wms:Service/wms:Fees"/>
<xsl:variable name="WMSaccessConstraints" select="wms:Service/wms:AccessConstraints"/>
<xsl:variable name="WMSkeywordList" select="wms:Service/wms:KeywordList"/>
<xsl:variable name="WMScontactInformation" select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/>


<xsl:apply-templates select="Service/ContactInformation"/>

<dclite4g:Series>
	<xsl:attribute name="rdf:about"><xsl:value-of select="$WMSonlineResource"/></xsl:attribute>
	<dc:identifier><xsl:value-of select="translate(substring-after($WMSonlineResource,'://'),'/','_')"/></dc:identifier>
	<dc:title><xsl:value-of select="wms:Service/wms:Title"/></dc:title>
	<dc:abstract><xsl:value-of select="wms:Service/wms:Abstract"/> It includes the following layers: <xsl:for-each select="//wms:Layer/wms:Title[../wms:Name!='']"> <xsl:value-of select="."/><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	</dc:abstract>
	<dc:publisher><xsl:attribute name="rdf:resource"><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress"/></xsl:attribute></dc:publisher>
	<dc:rights><xsl:value-of select="concat(wms:Service/wms:Fees,'/',wms:Service/wms:AccessConstraints)"/></dc:rights>
	<dc:subject><xsl:for-each select="//wms:Keyword[not(.=following::wms:Keyword)]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each></dc:subject>

	<xsl:variable name="maxX">
		<xsl:call-template name="max"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="maxY">
		<xsl:call-template name="max"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="minX">
		<xsl:call-template name="min"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="minY">
		<xsl:call-template name="min"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/></xsl:call-template>
	</xsl:variable>
	
	<dct:spatial>POLYGON((<xsl:value-of select="concat($minX,' ',$minY,',',$minX,' ',$maxY,',',$maxX,' ',$maxY,',',$maxX,' ',$minY,',',$minX,' ',$minY)"/>))</dct:spatial>
 	<dclite4g:projection>
 	<xsl:for-each select="//wms:Layer/wms:CRS[not(.=following::wms:Layer/wms:CRS)]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	</dclite4g:projection>
	<dc:format>
		<xsl:for-each select="//wms:Capability/wms:Request/wms:GetMap/wms:Format"><xsl:value-of select="."/><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	</dc:format>
</dclite4g:Series>

	<xsl:apply-templates select="//wms:Layer[wms:Name!='']"/>

</xsl:template>



<xsl:template match="wms:ContactInformation">
<foaf:Person>
	<xsl:attribute name="rdf:about">
	<xsl:value-of select="wms:ContactElectronicMailAddress"/>
	</xsl:attribute>
	<foaf:name><xsl:value-of select="wms:ContactPersonPrimary/wms:ContactPerson"/></foaf:name>
	<foaf:mbox><xsl:value-of select="wms:ContactElectronicMailAddress"/></foaf:mbox>
</foaf:Person>

</xsl:template>

<xsl:template match="wms:Layer">
	<xsl:variable name="name" select="wms:Name"/>
	<xsl:choose>
	<xsl:when test="string-length($name)=0">
		<xsl:variable name="parentTitle" select="wms:Title"/>
		<xsl:variable name="parentAbstract" select="wms:Abstract"/>
	</xsl:when>
	<xsl:otherwise>
	<dclite4g:DataSet>
		<xsl:variable name="title" select="wms:Title"/>
		<xsl:variable name="abstract" select="wms:Abstract"/>
		<xsl:variable name="metadataURL" select="wms:MetadataURL/wms:OnlineResource/@xlink:href"/>
		<xsl:variable name="scaleHint" select="concat(wms:ScaleHint/@min,',',wms:ScaleHint/@max)"/>
		<xsl:variable name="format" select="//wms:Capability/wms:Request/wms:GetMap/wms:Format[1]"/>
		<xsl:variable name="crs" select="wms:CRS"/>
		<xsl:variable name="maxX" select="wms:EX_GeographicBoundingBox/wms:eastBoundLongitude"/>
		<xsl:variable name="maxY" select="wms:EX_GeographicBoundingBox/wms:northBoundLatitude"/>
		<xsl:variable name="minX" select="wms:EX_GeographicBoundingBox/wms:westBoundLongitude"/>
		<xsl:variable name="minY" select="wms:EX_GeographicBoundingBox/wms:southBoundLatitude"/>
		
		<xsl:variable name="bbox" select="concat($minX + ($maxX - $minX) div 4,',',$minY + ($maxY - $minY) div 4,',',$maxX - ($maxX - $minX) div 4,',',$maxY - ($maxY - $minY) div 4)"/>
		<xsl:variable name="geoRatio" select="translate((number($maxX) - number($minX) ) div ( number($maxY) - number($minY) ),'-','' ) "/>
		<xsl:variable name="spatial" select="concat('POLYGON((',$minX,' ',$minY,',',$minX,' ',$maxY,',',$maxX,' ',$maxY,',',$maxX,' ',$minY,',',$minX,' ',$minY,'))')"/>
		<xsl:variable name="wmsRequest" select="concat($GETMAPonlineResource,'VERSION=','1.1.1','&amp;REQUEST=GetMap&amp;CRS=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor(400 * $geoRatio),'&amp;HEIGHT=',400,'&amp;LAYERS=',$name,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>
		<xsl:variable name="quicklookRequest" select="concat($GETMAPonlineResource,'?VERSION=','1.1.1','&amp;REQUEST=GetMap&amp;CRS=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor(100 * $geoRatio),'&amp;HEIGHT=',100,'&amp;LAYERS=',$name,'&amp;STYLES=',$style,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>
		

		<xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
		<dclite4g:series><xsl:attribute name="rdf:resource"><xsl:value-of select="$WMSonlineResource"/></xsl:attribute></dclite4g:series>
		<dc:identifier><xsl:value-of select="$name"/></dc:identifier>
		<dc:title><xsl:value-of select="$title"/></dc:title>
		<dc:abstract><xsl:value-of select="$abstract"/></dc:abstract>
		<dc:subject><dc:subject><xsl:for-each select="wms:KeywordList/wms:Keyword[not(.=following::wms:KeywordList/wms:Keyword)]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each></dc:subject>
</dc:subject>			
		<dct:spatial><xsl:value-of select="$spatial"/></dct:spatial>
		<!--
		<xsl:variable name="metadata" select="document(wms:MetadataURL/wms:OnlineResource/@xlink:href)"/>
		<dclite4g:resolution><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dclite4g:resolution"/></dclite4g:resolution>
		<ical:dtstart><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/ical:dtstart"/></ical:dtstart>
		<ical:dtend><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/ical:dtend"/></ical:dtend>
		<dct:created><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dct:created"/></dct:created>
		<dct:modified><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dct:modified"/></dct:modified>
		-->
<!-- 		<dc:publisher><xsl:attribute name="rdf:about"><xsl:value-of select="$metadata//dc:publisher/@rdf:resource"/></xsl:attribute></dc:publisher> -->
		<dc:format><xsl:value-of select="$format"/></dc:format>
		
		<dclite4g:projection><xsl:value-of select="$crs"/></dclite4g:projection>

		<dclite4g:quicklook>
			<xsl:attribute name="rdf:resource"><xsl:value-of select="$quicklookRequest"/></xsl:attribute>
		</dclite4g:quicklook>
		<dclite4g:onlineResource>
			<ws:WMS><xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute></ws:WMS>
		</dclite4g:onlineResource>
		<xsl:apply-templates select="wms:DataURL"/>
	</dclite4g:DataSet>
	</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template match="wms:DataURL">
	<dclite4g:onlineResource>
		<ws:HTTP>
			<xsl:attribute name="rdf:about"><xsl:value-of select="wms:OnlineResource/@xlink:href"/></xsl:attribute>
			<xsl:attribute name="atom:type"><xsl:value-of select="wms:Format"/></xsl:attribute>
			<xsl:attribute name="atom:relation">enclosure</xsl:attribute>
		</ws:HTTP>
	</dclite4g:onlineResource>
</xsl:template>


</xsl:stylesheet>
