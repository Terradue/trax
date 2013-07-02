<?xml version="1.0" encoding="UTF-8"?>
<!---

Copyright 2012 Terradue Srl.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 
 
 Stylesheet transformation for WMS GetCapabilities into RDF dclite4g Store
 This xsl maps the service to a Series and assumes all named layers are DataSet
	
 
-->

<xsl:stylesheet version="1.0" 
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:foaf="http://xmlns.com/foaf/spec/"  
	xmlns:ical="http://www.w3.org/2002/12/cal/ical#"  
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
	xmlns:xlink="http://www.w3.org/1999/xlink"  
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	
	exclude-result-prefixes="xlink xsl wms exsl"
	>
<xsl:include href="../../utils/xslt/utils.xsl"/>		
<xsl:include href="../../utils/xslt/wms-utils.xsl"/>	


<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes" omit-xml-declaration="no"/>
	
<xsl:variable name="defaulticonheight" select="'100'"/>
<xsl:variable name="defaultmapheight" select="'500'"/>

<xsl:param name="layer" select="''"/>
<xsl:param name="date" select="''"/>
<xsl:param name="bbox" select="''"/>
<xsl:param name="now" select="''"/>
<xsl:param name="iconheight" select="$defaulticonheight"/>
<xsl:param name="mapheight" select="$defaultmapheight"/>
<xsl:param name="mode" select="''"/>

<xsl:variable name='_coords'>
<xsl:choose>
	<xsl:when test="$bbox!=''">
		<xsl:call-template name="tokenize">
		 <xsl:with-param name="text" select="$bbox"/>
		 <xsl:with-param name="separator" select="','"/> 
	        </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<bbox/>
	</xsl:otherwise>
</xsl:choose>    
</xsl:variable>
<xsl:variable name="coords" select="exsl:node-set($_coords)"/>

<xsl:template name="help">
      <xsl:message terminate="yes">
       - WMS2RDF -
       
       Copyright 2011-2012 Terradue srl
       This product includes software developed by
       Terradue srl (http://www.terradue.com/).
       
       Transform OGC WMS (1.1.1 and 1.3.0) GetCapabilities documents in RDF Documents using the dclite4g model 
       It maps the service to a dclite4g:Series and assumes all named layers are dclite4g:DataSet
	
       
       Please send bugs and suggestions to info@terradue.com
       
       Accepted Parameters:
       		- now : Parameter with the curret or desired update date to insert on the atom:updated element (Mandatory)
       		- bbox : Restrict Context file to a specific BBOX in the format: minlon, minlat, maxlon, maxlat (Optional)
       		- layer : Restrict Context file to a given layer (Optional). If not present the entire Capabilities document will be processed
       		- iconheight : Height of the preview image (Optional). Default value if <xsl:value-of select="$defaulticonheight"/>
       		- mapheight : Height of the map image (Optional). Default value if <xsl:value-of select="$defaultmapheight"/>
       		- mode : The processing mode (Optional) 
       			if equal to 'series' it will produce a valid RDF with the Series and DataSet elements (default).
       			If equal to 'fragment' it will only produce the entry of a layer mapped to a DataSet. It must be used with the layer parameter.
       			If equal to 'help' it will display this message.
       			
       	Example:
       	xsltproc --stringparam layer "sea_ice_extent_01" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" wms2rdf.xsl 'http://nsidc.org/cgi-bin/atlas_south?SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities'

      </xsl:message>
</xsl:template>


<xsl:template match="/">

<xsl:if test="count(wms:WMS_Capabilities | WMT_MS_Capabilities)=0">
      <xsl:message terminate="no">
        Error: WMS Capabilities root element was not found!
      </xsl:message>
      <xsl:call-template name="help"/>
</xsl:if>

<xsl:if test="now='' ">
      <xsl:message terminate="yes">
        Error: Parameter now is an empty string!
        	try to add the parameter to the xslt processor using a valid ISO-8601 date (--stringparam now "`date +%Y-%m-%dT%H:%M:%S`")
      </xsl:message>
      <xsl:call-template name="help"/>
</xsl:if>

<xsl:choose>
<xsl:when test="$mode='help'">
	<xsl:call-template name="help"/>
</xsl:when>
<xsl:when test="$mode='fragment' and $layer!=''">
	<xsl:apply-templates select="//wms:Layer[wms:Name=$layer] | //Layer[Name=$layer]"/>
</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates select="wms:WMS_Capabilities | WMT_MS_Capabilities"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="wms:WMS_Capabilities | WMT_MS_Capabilities">
<rdf:RDF>
<dclite4g:Series>
      <xsl:attribute name="rdf:about"><xsl:value-of select="$WMSonlineResource"/></xsl:attribute>
      	
      <dc:title><xsl:value-of select="wms:Service/wms:Title | Service/Title"/></dc:title>
      <dc:identifier><xsl:value-of select="translate(substring-after($WMSonlineResource,'://'),'/','_')"/></dc:identifier>
      <dc:abstract><xsl:value-of select="wms:Service/wms:Abstract | Service/Abstract"/> It includes the following layers: <xsl:for-each select="//wms:Layer/wms:Title[../wms:Name!=''] | //Layer/Title[../Name!='']"> <xsl:value-of select="."/><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
      </dc:abstract>
      <dc:publisher><xsl:attribute name="rdf:resource"><xsl:value-of select="wms:Service/wms:ContactInformation/wms:ContactElectronicMailAddress | Service/ContactInformation/ContactElectronicMailAddress"/></xsl:attribute></dc:publisher>
      <dc:rights><xsl:value-of select="concat(wms:Service/wms:Fees | Service/Fees,'/',wms:Service/wms:AccessConstraints | Service/AccessConstraints)"/></dc:rights>
      <dc:subject><xsl:for-each select="//wms:Keyword[not(.=following::wms:Keyword) | //Keyword[not(.=following::Keyword)]]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each></dc:subject>

	<xsl:variable name="maxX">
		<xsl:call-template name="max"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude | Capability/Layer/*/LatLonBoundingBox/@maxx"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="maxY">
		<xsl:call-template name="max"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:northBoundLatitude | Capability/Layer/*/LatLonBoundingBox/@maxy"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="minX">
		<xsl:call-template name="min"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:westBoundLongitude | Capability/Layer/*/LatLonBoundingBox/@minx"/></xsl:call-template>
	</xsl:variable>
	<xsl:variable name="minY">
		<xsl:call-template name="min"><xsl:with-param name="list" select="wms:Capability/wms:Layer/*/wms:EX_GeographicBoundingBox/wms:southBoundLatitude | Capability/Layer/*/LatLonBoundingBox/@miny"/></xsl:call-template>
	</xsl:variable>
	
	<dct:spatial>POLYGON((<xsl:value-of select="concat($minX,' ',$minY,',',$minX,' ',$maxY,',',$maxX,' ',$maxY,',',$maxX,' ',$minY,',',$minX,' ',$minY)"/>))</dct:spatial>
 	<dclite4g:projection>
 	<xsl:for-each select="//wms:Layer/wms:CRS[not(.=following::wms:Layer/wms:CRS)] | //Layer/CRS[not(.=following::wms:Layer/wms:CRS)]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	</dclite4g:projection>
	<dc:format>
		<xsl:for-each select="//wms:Capability/wms:Request/wms:GetMap/wms:Format"><xsl:value-of select="."/><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each>
	</dc:format>
</dclite4g:Series>
    
     <xsl:choose>
	<xsl:when test="$layer!=''">
		<xsl:apply-templates select="//wms:Layer[wms:Name=$layer] | //Layer[Name=$layer]"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates select="//wms:Layer[wms:Name!=''] | //Layer[Name!='']"/>
	</xsl:otherwise>
     </xsl:choose>
</rdf:RDF>
     
</xsl:template>


<xsl:template match="wms:ContactInformation | ContactInformation">
<foaf:Person>
	<xsl:attribute name="rdf:about">
	<xsl:value-of select="wms:ContactElectronicMailAddress | ContactElectronicMailAddress"/>
	</xsl:attribute>
	<foaf:name><xsl:value-of select="wms:ContactPersonPrimary/wms:ContactPerson | ContactPersonPrimary/ContactPerson"/></foaf:name>
	<foaf:mbox><xsl:value-of select="wms:ContactElectronicMailAddress | ContactElectronicMailAddress"/></foaf:mbox>
</foaf:Person>

</xsl:template>


<xsl:template match="wms:Layer[wms:Name!=''] | Layer[Name!='']">

	<xsl:variable name="maxX"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[3]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude | ancestor-or-self::Layer/LatLonBoundingBox/@maxx"/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:variable name="maxY"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[4]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:northBoundLatitude | ancestor-or-self::Layer/LatLonBoundingBox/@maxy"/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:variable name="minX"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[1]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:westBoundLongitude | ancestor-or-self::Layer/LatLonBoundingBox/@minx"/></xsl:otherwise></xsl:choose></xsl:variable>
        <xsl:variable name="minY"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[2]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:southBoundLatitude | ancestor-or-self::Layer/LatLonBoundingBox/@miny"/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:variable name="crsName" select="local-name(wms:CRS[1] | SRS[1])"/>
	
	<xsl:variable name="name" select="wms:Name | Name"/>
	
	<dclite4g:DataSet>
		<xsl:variable name="title" select="wms:Title | Title "/>
		<xsl:variable name="abstract" select="wms:Abstract | Abstract  "/>
		<xsl:variable name="metadataURL" select="wms:MetadataURL/wms:OnlineResource/@xlink:href"/>
		<xsl:variable name="scaleHint" select="concat(wms:ScaleHint/@min,',',wms:ScaleHint/@max)"/>
		<xsl:variable name="format" select="//wms:Capability/wms:Request/wms:GetMap/wms:Format[1]"/>
		
		<xsl:variable name="georatio" select="translate((number($maxX) - number($minX) ) div ( number($maxY) - number($minY) ),'-','' ) "/>
		<xsl:variable name="spatial" select="concat('POLYGON((',$minX,' ',$minY,',',$minX,' ',$maxY,',',$maxX,' ',$maxY,',',$maxX,' ',$minY,',',$minX,' ',$minY,'))')"/>
		<xsl:variable name="bbox"><xsl:choose><xsl:when test="$version='1.3.0' and $crs='EPSG:4326'"><xsl:value-of select="concat($minY,',',$minX,',',$maxY,',',$maxX)"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="concat($minX,',',$minY,',',$maxX,',',$maxY)"/></xsl:otherwise></xsl:choose></xsl:variable>
	
		<xsl:variable name="style" select="wms:Style[1]/wms:Name | Style[1]/Name"/>

		<!-- preference for Plate Carre on element -->
		<!-- if no crs available then check parent --> 

		<xsl:variable name="crs">
		<xsl:choose>
			<xsl:when test="count(wms:CRS[.='EPSG:4326'] | SRS[.='EPSG:4326'])!=0">EPSG:4326</xsl:when>
			<xsl:when test="count(wms:CRS[.='CRS:84'] | SRS[.='CRS:84'])!=0">CRS:84</xsl:when>
			<xsl:when test="count(wms:CRS[1] | SRS[1])!=0"><xsl:value-of select="wms:CRS[1] | SRS[1]"/></xsl:when>
			<xsl:when test="count(ancestor::wms:Layer/wms:CRS[.='EPSG:4326'] | ancestor::Layer/SRS[.='EPSG:4326'])!=0">EPSG:4326</xsl:when>
			<xsl:when test="count(ancestor::wms:Layer/wms:CRS[.='CRS:84'] | ancestor::Layer/SRS[.='CRS:84'])!=0">CRS:84</xsl:when>
			<xsl:otherwise><xsl:value-of select="ancestor::wms:Layer/wms:CRS[1] | ancestor::Layer/SRS[1]"/></xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="wmsRequest" select="concat($GETMAPonlineResource,'VERSION=',$version,'&amp;REQUEST=GetMap&amp;', $crsName, '=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor($mapheight * $georatio),'&amp;HEIGHT=',$mapheight,'&amp;LAYERS=',$name,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>
		<xsl:variable name="quicklookRequest" select="concat($GETMAPonlineResource,'VERSION=',$version,'&amp;REQUEST=GetMap&amp;', $crsName, '=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor($iconheight * $georatio),'&amp;HEIGHT=',$iconheight,'&amp;LAYERS=',$name,'&amp;STYLES=',$style,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>

		<xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
		<dclite4g:series><xsl:attribute name="rdf:resource"><xsl:value-of select="$WMSonlineResource"/></xsl:attribute></dclite4g:series>
		<dc:identifier><xsl:value-of select="$name"/></dc:identifier>
		<dc:title><xsl:value-of select="$title"/></dc:title>
		
		<dc:abstract><xsl:choose><xsl:when test="$abstract!=''"><xsl:value-of select="$abstract"/></xsl:when>
		<xsl:otherwise> &lt;br/&gt;
             	&lt;img border='1' align='right' height='<xsl:value-of select="$iconheight"/>'src='<xsl:value-of select="$quicklookRequest"/>'/&gt;
             	<xsl:apply-templates select="wms:Attribution | Attribution" mode="html"/>
             	&lt;br/&gt;
             	This resource is available from a OGC WMS <xsl:value-of select="$version"/> Service 
             	&lt;ul&gt;
             	&lt;li&gt;
             	&lt;a href='<xsl:value-of select="$wmsRequest"/>'&gt;
             	GetMap &lt;/a&gt; request in <xsl:value-of select="$format"/>
             	&lt;a href='<xsl:value-of select="$GETCAPABILITIESonlineResource"/>VERSION=<xsl:value-of select="$version"/>&amp;REQUEST=GetCapabilities'&gt;
             	&lt;/li&gt;
             	&lt;li&gt;
             	GetCapabilities &lt;/a&gt; request.
             	&lt;/li&gt;
             	<xsl:apply-templates select="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL" mode="html"/>
             	&lt;/ul&gt;
             	&lt;p style='font-size:small'&gt;OGC Context CITE Testing XSLT (Extensible Stylesheet Language Transformations) by Terradue Srl.&lt;/p&gt;
             	</xsl:otherwise>
             	</xsl:choose></dc:abstract>
		<dc:subject><xsl:for-each select="wms:KeywordList/wms:Keyword[not(.=following::wms:KeywordList/wms:Keyword)]"><xsl:value-of select="." /><xsl:if test="position() &lt; last()">, </xsl:if></xsl:for-each></dc:subject>
		
		<dct:spatial><xsl:value-of select="$spatial"/></dct:spatial>
		<dc:format><xsl:value-of select="$format"/></dc:format>
		<xsl:if test="$now!=''">
			<dct:dateSubmitted><xsl:value-of select="$now"/>Z</dct:dateSubmitted>        
		</xsl:if>

		<dclite4g:projection><xsl:value-of select="$crs"/></dclite4g:projection>

		<dclite4g:quicklook>
			<xsl:attribute name="rdf:resource"><xsl:value-of select="$quicklookRequest"/></xsl:attribute>
		</dclite4g:quicklook>
		<dclite4g:onlineResource>
			<ws:WMS><xsl:attribute name="rdf:about"><xsl:value-of select="$wmsRequest"/></xsl:attribute></ws:WMS>
		</dclite4g:onlineResource>
		<xsl:apply-templates select="wms:DataURL"/>

	</dclite4g:DataSet>
		<!--
		<xsl:variable name="metadata" select="document(wms:MetadataURL/wms:OnlineResource/@xlink:href)"/>
		<dclite4g:resolution><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dclite4g:resolution"/></dclite4g:resolution>
		<ical:dtstart><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/ical:dtstart"/></ical:dtstart>
		<ical:dtend><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/ical:dtend"/></ical:dtend>
		<dct:created><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dct:created"/></dct:created>
		<dct:modified><xsl:value-of select="$metadata/rdf:RDF/dclite4g:DataSet/dct:modified"/></dct:modified>
		-->
<!-- 		<dc:publisher><xsl:attribute name="rdf:about"><xsl:value-of select="$metadata//dc:publisher/@rdf:resource"/></xsl:attribute></dc:publisher> -->
	
</xsl:template>



<xsl:template match="wms:Service/wms:Abstract | Service/Abstract">
	<dc:abstract>
	<xsl:value-of select="."/>
        </dc:abstract>
</xsl:template>     

    
<xsl:template match="wms:Attribution/wms:Title | Attribution/Title">
<dc:creator><xsl:value-of select="."/></dc:creator>
</xsl:template>        




<xsl:template match="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL">
	<xsl:if test="wms:Format | Format != ''">
	<xsl:if test="substring-after(wms:Format | Format,'/')='' or substring-after(wms:Format | Format,' ')!=''">
	<xsl:comment>
	This resource seems to have an invalid MIME-type: 
	"<xsl:value-of select="wms:Format | Format"/>"
	The link element will use the generic application/octet-stream MIME-type to ensure valid ATOM feed
	</xsl:comment>
	</xsl:if>
	<dclite4g:onlineResource>
		<ws:WMS>
			<xsl:attribute name="rdf:about"><xsl:value-of select="wms:OnlineResource/@xlink:href | OnlineResource/@xlink:href"/></xsl:attribute>
			<xsl:attribute name="atom:type">
			<xsl:choose>
			<xsl:when test="substring-after(wms:Format | Format,'/')='' or substring-after(wms:Format | Format,' ')!=''">application/octet-stream</xsl:when>
			<xsl:otherwise>
			<xsl:value-of select="wms:Format | Format"/>
			</xsl:otherwise>
			</xsl:choose></xsl:attribute>
			<xsl:attribute name="atom:relation">enclosure</xsl:attribute></ws:WMS>
	</dclite4g:onlineResource>
	</xsl:if>
</xsl:template>


<!--
<xsl:template match="wms:ContactInformation | ContactInformation">
      <author>
        <name><xsl:value-of select="wms:ContactPersonPrimary/wms:ContactPerson | ContactPersonPrimary/ContactPerson"/></name>
        <email><xsl:value-of select="wms:ContactElectronicMailAddress | ContactElectronicMailAddress"/></email>
      </author>
</xsl:template>
-->



</xsl:stylesheet>
