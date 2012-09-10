<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns="http://schemas.opengis.net/wms/1.1.1/WMS_MS_Capabilities.dtd" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:ical="http://www.w3.org/2002/12/cal/ical#" 
	xmlns:owl="http://www.w3.org/2002/07/owl#" 
	xmlns:fp="http://downlode.org/Code/RDF/file-properties/" 
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:wms="http://schemas.opengis.net/wms/1.1.1/"  >

<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes"/>

<xsl:template match="WMT_MS_Capabilities">

<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

<xsl:variable name="WMSname" select="Service/Name"/>
<xsl:variable name="WMStitle" select="Service/Title"/>
<xsl:variable name="WMSabstract" select="Service/Abstract"/>
<xsl:variable name="WMSonlineResource" select="Service/OnlineResource/@xlink:href"/>
<xsl:variable name="GETMAPonlineResource" select="//Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
<xsl:variable name="WMSfees" select="Service/Fees"/>
<xsl:variable name="WMSaccessConstraints" select="Service/AccessConstraints"/>
<xsl:variable name="WMSkeywordList" select="Service/KeywordList"/>
<xsl:variable name="WMScontactInformation" select="Service/ContactInformation/ContactElectronicMailAddress"/>

<xsl:for-each select="Capability/Layer/*">
	<xsl:variable name="name" select="Name"/>
	<xsl:choose>
	<xsl:when test="string-length($name)=0">
		<xsl:variable name="parentTitle" select="Title"/>
		<xsl:variable name="parentAbstract" select="Abstract"/>
	</xsl:when>
	<xsl:otherwise>
	<dclite4g:Series>
		<xsl:variable name="title" select="Title"/>
		<xsl:variable name="abstract" select="Abstract"/>
		<xsl:variable name="metadataURL" select="MetadataURL/OnlineResource/@xlink:href"/>
		<xsl:variable name="keywordList" select="KeywordList"/>
		<xsl:variable name="scaleHint" select="concat(ScaleHint/@min,',',ScaleHint/@max)"/>
		<xsl:variable name="bbox" select="concat(LatLonBoundingBox/@minx,',',LatLonBoundingBox/@miny,',',LatLonBoundingBox/@maxx,',',LatLonBoundingBox/@maxy)"/>
		

<!--
Still not used 
Dimension*, Extent*,
Attribution?, AuthorityURL*, Identifier*, DataURL*,
FeatureListURL*, Style*, Layer*
-->
		<xsl:choose>
		<xsl:when test="string-length($metadataURL)=0">
		<xsl:attribute name="rdf:about"><xsl:value-of select="concat($WMSonlineResource,'#',$name)"/></xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
		<xsl:attribute name="rdf:about"><xsl:value-of select="$metadataURL"/></xsl:attribute>
		</xsl:otherwise>
		</xsl:choose>
		<dc:identifier><xsl:value-of select="concat($WMSonlineResource,'#',$name)"/></dc:identifier>
		<dc:title><xsl:value-of select="$title"/></dc:title>
		<dc:abstract><xsl:value-of select="$abstract"/></dc:abstract>
		<dc:contact><xsl:value-of select="$WMScontactInformation"/></dc:contact>
		<dc:rights><xsl:value-of select="concat($WMSfees,'/',$WMSaccessConstraints)"/></dc:rights>
		<dc:subject><xsl:value-of select="$keywordList"/></dc:subject>
		<dct:spatial><xsl:value-of select="concat('POLYGON((',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@miny,',',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@maxy,',',LatLonBoundingBox/@maxx,' ',LatLonBoundingBox/@maxy,',',LatLonBoundingBox/@maxx,' ',LatLonBoundingBox/@miny,',',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@miny,'))')"/>
		</dct:spatial>
		<dclite4g:projection>
		<xsl:for-each select="SRS">
		<xsl:value-of select="concat(.,' ')"/>
		</xsl:for-each>
		</dclite4g:projection>
		<dc:format><xsl:for-each select="//Capability/Request/GetMap/Format">
		<xsl:value-of select="concat(.,' ')"/>
		</xsl:for-each>
		</dc:format>
	</dclite4g:Series>

	<xsl:variable name="geoRatio" select="translate((number(LatLonBoundingBox/@maxx) - number(LatLonBoundingBox/@minx) ) div ( number(LatLonBoundingBox/@maxy) - number(LatLonBoundingBox/@miny) ),'-','' ) "/>
	<xsl:variable name="spatial" select="concat('POLYGON((',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@miny,',',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@maxy,',',LatLonBoundingBox/@maxx,' ',LatLonBoundingBox/@maxy,',',LatLonBoundingBox/@maxx,' ',LatLonBoundingBox/@miny,',',LatLonBoundingBox/@minx,' ',LatLonBoundingBox/@miny,'))')"/>

	<xsl:variable name="dtstart" select="substring-before(Extent[@name='time'],'/')"/>
	<xsl:variable name="dtend" select="substring-before(substring-after(Extent[@name='time'],'/'),'/')"/>	

	<xsl:for-each select="SRS">
	<xsl:variable name="srs" select="."/>
	<xsl:for-each select="//Capability/Request/GetMap/Format">
	
	<xsl:variable name="format" select="."/>
	<xsl:variable name="wmsRequest" select="concat($GETMAPonlineResource,'VERSION=','1.1.1','&amp;REQUEST=GetMap&amp;SERVICE=WMS&amp;SRS=',$srs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',400 * $geoRatio,'&amp;HEIGHT=',400,'&amp;LAYERS=',$name,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=application/vnd.ogc.se_inimage')"/>

	<xsl:variable name="quicklookRequest" select="concat($GETMAPonlineResource,'VERSION=','1.1.1','&amp;REQUEST=GetMap&amp;SERVICE=WMS&amp;SRS=',$srs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',100 * $geoRatio,'&amp;HEIGHT=',100,'&amp;LAYERS=',$name,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=application/vnd.ogc.se_inimage')"/>
	
	<dclite4g:DataSet>
		<xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
		<dc:format><xsl:value-of select="."/></dc:format>
		<dct:spatial><xsl:value-of select="$spatial"/></dct:spatial>
		<ical:dtstart><xsl:value-of select="$dtstart"/></ical:dtstart>
		<ical:dtend><xsl:value-of select="$dtend"/></ical:dtend>
		<dct:created></dct:created>
		<dct:modified></dct:modified>
		<dclite4g:resolution><xsl:value-of select="$scaleHint"/></dclite4g:resolution>
		<dclite4g:projection><xsl:value-of select="$srs"/></dclite4g:projection>
		<dclite4g:quicklook>
			<xsl:attribute name="rdf:resource"><xsl:value-of select="$quicklookRequest"/></xsl:attribute>
		</dclite4g:quicklook>
		<dclite4g:onlineResource>
			<ws:WMS>
			<xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
			<!--
			<xsl:for-each select="//Layer[Name=$name]/Extent">
				<wms:dimension>
				<xsl:attribute name="rdf:about"><xsl:value-of select="concat('#',@name)"/></xsl:attribute>
				<wms:extent>
					<xsl:value-of select="."/>
				</wms:extent>
				</wms:dimension>
			</xsl:for-each>
			
			<xsl:for-each select="//Layer[Name=$name]/Style[Name='default']/">
				<wms:dimension>
				<xsl:attribute name="rdf:about"><xsl:value-of select="concat('#',./Title)"/></xsl:attribute>
				<wms:extent>
					<xsl:value-of select="Na"/>
				</wms:extent>
				</wms:dimension>
			</xsl:for-each>
			-->
			</ws:WMS>
		</dclite4g:onlineResource>
		
	</dclite4g:DataSet>
	</xsl:for-each>
	</xsl:for-each>
	</xsl:otherwise>
	</xsl:choose>
</xsl:for-each>

</rdf:RDF>
</xsl:template>


</xsl:stylesheet>
