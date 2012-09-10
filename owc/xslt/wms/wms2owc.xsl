<?xml version="1.0" encoding="UTF-8"?>
<!---
	Stylesheet transformation for WMS GetCapabilities into OWS Context Document
	This xsl maps the service to a feed and assumes all named layers are entries
	Copyright 2011-2012 Terradue srl
        This product includes software developed by
        Terradue srl (http://www.terradue.com/).
        
	TO-DO:
-->

<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:georss="http://www.georss.org/georss"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:owc="http://www.opengis.net/owc" 
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:xlink="http://www.w3.org/1999/xlink"  
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="xlink xsl wms dct exsl"
	>
<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes"/>
	
<xsl:include href="../../utils.xsl"/>
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

<xsl:variable name="version" select="wms:WMS_Capabilities/@version | WMT_MS_Capabilities/@version"/>
<xsl:variable name="GETMAPonlineResource" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
<xsl:variable name="GETCAPABILITIESonlineResource" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
<xsl:variable name="GETCAPABILITIESformat" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/Format[1]"/>

<xsl:variable name="WMSonlineResource" select="/wms:WMS_Capabilities/wms:Service/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Service/OnlineResource/@xlink:href"/>
<xsl:variable name="ExceptionFormat" select="/wms:WMS_Capabilities/wms:Capability/wms:Exception/wms:Format[1] | /WMT_MS_Capabilities/Capability/Exception/Format[1]"/>
<xsl:variable name="format" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetMap/Format[1]"/>
<xsl:variable name="rights" select="concat('Fee:',/wms:WMS_Capabilities/wms:Service/wms:Fees | /WMT_MS_Capabilities/Service/Fees,' / Contraints:',/wms:WMS_Capabilities/wms:Service/wms:AccessConstraints | /WMT_MS_Capabilities/Service/AccessConstraints)"/>

<xsl:template name="help">
      <xsl:message terminate="yes">
       - WMS2OWC -
       
       Copyright 2011-2012 Terradue srl
       This product includes software developed by
       Terradue srl (http://www.terradue.com/).
       
       Transform OGC WMS (1.1.1 and 1.3.0) GetCapabilities documents in OGC Context Document in ATOM encoding version 1.0.
       It maps the service to a feed and assumes all named layers are entries
	
       The ATOM feeds produced are classified as valid by http://validator.w3.org/feed/
       Please send bugs and suggestions to info@terradue.com
       
       Accepted Parameters:
       		- now : Parameter with the curret or desired update date to insert on the atom:updated element (Mandatory)
       		- bbox : Restrict Context file to a specific BBOX in the format: minlon, minlat, maxlon, maxlat (Optional)
       		- layer : Restrict Context file to a given layer (Optional). If not present the entire Capabilities document will be processed
       		- iconheight : Height of the preview image (Optional). Default value if <xsl:value-of select="$defaulticonheight"/>
       		- mapheight : Height of the map image (Optional). Default value if <xsl:value-of select="$defaultmapheight"/>
       		- mode : The processing mode (Optional) 
       			if equal to 'feed' it will produce a valid ATOM feed (default).
       			If equal to 'fragment' it will only produce the entry of a layer. It must be used with the layer parameter.
       			If equal to 'list' it will only list the available layers.
       			If equal to 'help' it will display this message.
       			
       			
       		
       	Example:
       	xsltproc --stringparam layer "sea_ice_extent_01" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" --stringparam fragment "true" wms2owc.xsl 'http://nsidc.org/cgi-bin/atlas_south?SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities'

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
<xsl:when test="$mode='list'">
	<xsl:for-each  select="//wms:Layer[wms:Name!=''] | //Layer[Name!='']">
		<xsl:value-of select="wms:Name | Name"/>
		<xsl:text>
		</xsl:text>
	</xsl:for-each>
</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates select="wms:WMS_Capabilities | WMT_MS_Capabilities"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="wms:WMS_Capabilities | WMT_MS_Capabilities">
<feed xml:lang='en'>
	
      <title>
       <xsl:value-of select="wms:Service/wms:Title | Service/Title"/>
      </title>
      <id><xsl:value-of select="$WMSonlineResource"/>/</id> 
      <category scheme="http://www.opengis.net/owc/specReference" 
              term="1.0" 
              label="This file is compliant with version 1.0 of OGC Context"/> 
   
  
      <xsl:apply-templates select="wms:Service/wms:Abstract | Service/Abstract"/>
      
      <xsl:if test="$now!=''">
      <updated><xsl:value-of select="$now"/>Z</updated>        
      </xsl:if>

      <xsl:apply-templates select="wms:Service/wms:ContactInformation"/>
      
      <dc:publisher><xsl:value-of select='wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization | Service/ContactInformation/ContactPersonPrimary/ContactOrganization'/></dc:publisher>
      <generator uri="https://svn.opengeospatial.org/ogc-projects/cite/scripts/owsc/1.0/trunk/utils/xslt/wms/1.3.0/wms2owc.xsl" version="1.0">
        OGC Context CITE Testing XSLT (Extensible Stylesheet Language Transformations)   
      </generator>
      <rights>
         Terradue Srl.
         Copyright (c) 2012. Some rights reserved.  This feed is
         licensed under a Creative Commons Attribution 3.0 License. 
      </rights>
      
       <!-- if the bbox is defined then use it for the feed -->
      <xsl:if test="$bbox!=''">      
	      <georss:where>
		<gml:Polygon>
		  <gml:exterior>
		    <gml:LinearRing>
		      <gml:posList>
		      <xsl:value-of select="concat($coords/item[2],' ',$coords/item[1],' ',$coords/item[2],' ',$coords/item[3],' ',$coords/item[4],' ',$coords/item[3],' ',$coords/item[4],' ',$coords/item[1],' ',$coords/item[2],' ',$coords/item[1])"/>
		      </gml:posList>
		     </gml:LinearRing>
		  </gml:exterior>
		</gml:Polygon>
	     </georss:where>
      </xsl:if>
  
     <xsl:comment>
     Add this the link with the self relation
     Change the href to the location of the file
     &lt;link rel="self" type="application/atom+xml" href="http://some.server/path/file.atom"/&gt;
     </xsl:comment>
    
     <xsl:if test="$date!=''">
     <dc:date><xsl:value-of select="$date"/></dc:date>
     </xsl:if>
     <xsl:comment>
     If known you can also add the resources date or dates ranges
     for example :
     &lt;date&gt;2010-05-03T09:04:59.000Z&lt;/dc:date&gt;
     </xsl:comment> 
     
     <xsl:for-each select="//wms:Keyword[not(.=following::wms:Keyword)] | //Keyword[not(.=following::Keyword)]">
     <category>
     	<xsl:attribute name="scheme"><xsl:value-of select="$WMSonlineResource"/></xsl:attribute>
     	<xsl:attribute name="term"><xsl:value-of select="."/></xsl:attribute> 
     </category>
     </xsl:for-each>
    
     <xsl:choose>
	<xsl:when test="$layer!=''">
		<xsl:apply-templates select="//wms:Layer[wms:Name=$layer] | //Layer[Name=$layer]"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates select="//wms:Layer[wms:Name!=''] | //Layer[Name!='']"/>
	</xsl:otherwise>
     </xsl:choose>
</feed>
     
</xsl:template>



<xsl:template match="wms:Layer | Layer">
<entry>
	<xsl:variable name="maxX"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[3]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:eastBoundLongitude | ancestor-or-self::Layer/LatLonBoundingBox/@maxx"/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:variable name="maxY"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[4]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:northBoundLatitude | ancestor-or-self::Layer/LatLonBoundingBox/@maxy"/></xsl:otherwise></xsl:choose></xsl:variable>
	<xsl:variable name="minX"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[1]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:westBoundLongitude | ancestor-or-self::Layer/LatLonBoundingBox/@minx"/></xsl:otherwise></xsl:choose></xsl:variable>
        <xsl:variable name="minY"><xsl:choose><xsl:when test="$bbox!=''"><xsl:value-of select="$coords/item[2]"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox/wms:southBoundLatitude | ancestor-or-self::Layer/LatLonBoundingBox/@miny"/></xsl:otherwise></xsl:choose></xsl:variable>
	
		
	<id><xsl:value-of select="concat($WMSonlineResource,wms:Name)"/>/</id>
        <title><xsl:value-of select="wms:Title | Title"/></title>
        <!--<summary><xsl:value-of select="wms:Abstract | Abstract"/></summary>
        -->
        <xsl:comment>
        Repeat feed dc:author and dc:publisher elements to ease xml fragment extraction
        </xsl:comment>
        <xsl:apply-templates select="/wms:WMS_Capabilities/wms:Service/wms:ContactInformation | /WMT_MS_Capabilities/Service/ContactInformation"/>  
        <dc:publisher><xsl:value-of select='/wms:WMS_Capabilities/wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization | /WMT_MS_Capabilities/Service/ContactInformation/ContactPersonPrimary/ContactOrganization'/></dc:publisher>
        <xsl:if test="$now!=''">
        <updated><xsl:value-of select="$now"/>Z</updated>        
        </xsl:if>
        <dc:rights><xsl:value-of select="$rights"/></dc:rights>
	<georss:where>
		<gml:Polygon>
		  <gml:exterior>
		    <gml:LinearRing>
		      <gml:posList>
		      <xsl:value-of select="concat($minY,' ',$minX,' ',$minY,' ',$maxX,' ',$maxY,' ',$maxX,' ',$maxY,' ',$minX,' ',$minY,' ',$minX)"/>
		      </gml:posList>
		     </gml:LinearRing>
		  </gml:exterior>
		</gml:Polygon>
	</georss:where>	
	
	<xsl:variable name="georatio" select="translate((number($maxX) - number($minX) ) div ( number($maxY) - number($minY) ),'-','' ) "/>
	
	<xsl:variable name="name" select="wms:Name | Name"/>
	
	
	<xsl:variable name="crsName" select="local-name(wms:CRS[1] | SRS[1])"/>
	
	
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

	<xsl:variable name="bbox"><xsl:choose><xsl:when test="$version='1.3.0' and $crs='EPSG:4326'"><xsl:value-of select="concat($minY,',',$minX,',',$maxY,',',$maxX)"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="concat($minX,',',$minY,',',$maxX,',',$maxY)"/></xsl:otherwise></xsl:choose></xsl:variable>

	
	<xsl:variable name="style" select="wms:Style[1]/wms:Name | Style[1]/Name"/>
		
	<xsl:variable name="wmsRequest" select="concat($GETMAPonlineResource,'VERSION=',$version,'&amp;REQUEST=GetMap&amp;', $crsName, '=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor($mapheight * $georatio),'&amp;HEIGHT=',$mapheight,'&amp;LAYERS=',$name,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>
	<xsl:variable name="quicklookRequest" select="concat($GETMAPonlineResource,'VERSION=',$version,'&amp;REQUEST=GetMap&amp;', $crsName, '=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor($iconheight * $georatio),'&amp;HEIGHT=',$iconheight,'&amp;LAYERS=',$name,'&amp;STYLES=',$style,'&amp;FORMAT=',$format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$ExceptionFormat)"/>
	
	
	<link rel='enclosure'>
		<xsl:attribute name="type"><xsl:value-of select="$format"/></xsl:attribute>
		<xsl:attribute name="title">WMS output for <xsl:value-of select="wms:Title | Title"/></xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
	</link>
	
	<link rel='icon'>
		<xsl:attribute name="type"><xsl:value-of select="$format"/></xsl:attribute>
		<xsl:attribute name="title">Preview for <xsl:value-of select="wms:Title | Title"/></xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="$quicklookRequest"/></xsl:attribute>
	</link>
	
	<link rel='via'>
        	<xsl:attribute name="type"><xsl:value-of select="$GETCAPABILITIESformat"/></xsl:attribute>
		<xsl:attribute name="title">Original GetCapabilities document</xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="concat($GETCAPABILITIESonlineResource,'VERSION=',$version,'&amp;REQUEST=GetCapabilities')"/></xsl:attribute>
	</link>
	<xsl:apply-templates select="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL"/>
        
        <content type='html'>
             	&lt;br/&gt;
             	&lt;img border='1' align='right' height='<xsl:value-of select="$iconheight"/>' 
             		src='<xsl:value-of select="$quicklookRequest"/>'
             		/&gt;
             	
             	This resource is available from a OGC WMS <xsl:value-of select="$version"/> Service..
             	&lt;br/&gt;
             	Available links :
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
             	&lt;br/&gt;
             	&lt;br/&gt;
             	&lt;p style='font-size:small'&gt;OGC Context CITE Testing XSLT (Extensible Stylesheet Language Transformations) by Terradue Srl.&lt;/p&gt;
         </content>
         
	 <owc:ServiceOffering type="http://www.opengis.net/spec/OWC/1.0/req/wms">
	 	<owc:Operation name="GetMap">
		  <owc:Request method="GET">
			<xsl:attribute name="href"><xsl:value-of select="$wmsRequest"/></xsl:attribute>
		  </owc:Request>
		</owc:Operation>
		<owc:Operation name="GetCapabilities">
		  <owc:Request method="GET">
			<xsl:attribute name="href"><xsl:value-of select="$GETCAPABILITIESonlineResource"/>VERSION=1.3.0&amp;REQUEST=GetCapabilities</xsl:attribute>
		  </owc:Request>
		</owc:Operation>
		<xsl:for-each select="wms:Style">
		<owc:Style>
			<owc:Name><xsl:value-of select="wms:Name"/></owc:Name>
			<owc:Title><xsl:value-of select="wms:Title"/></owc:Title>
			<owc:Abstract><xsl:value-of select="wms:Abstract"/></owc:Abstract>
			<owc:Legend>
				<xsl:attribute name="href"><xsl:value-of select="wms:LegendURL/wms:OnlineResource/@xlink:href"/></xsl:attribute>
				<xsl:attribute name="type"><xsl:value-of select="wms:LegendURL/wms:Format"/></xsl:attribute>
			</owc:Legend>
		</owc:Style>
		</xsl:for-each>
	</owc:ServiceOffering>
	
	 
             
</entry>
</xsl:template>

<xsl:template match="wms:Service/wms:Abstract | Service/Abstract">
	<subtitle type="text">
	<xsl:value-of select="."/>
        </subtitle>
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
	<link rel='related'>
		<xsl:attribute name="href"><xsl:value-of select="wms:OnlineResource/@xlink:href | OnlineResource/@xlink:href"/></xsl:attribute>
		<xsl:attribute name="type">
		<xsl:choose>
		<xsl:when test="substring-after(wms:Format | Format,'/')='' or substring-after(wms:Format | Format,' ')!=''">application/octet-stream</xsl:when>
		<xsl:otherwise>
		<xsl:value-of select="wms:Format | Format"/>
		</xsl:otherwise>
		</xsl:choose>
		</xsl:attribute>
	</link>
	</xsl:if>
</xsl:template>


<xsl:template match="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL" mode="html">
	&lt;li&gt;
	<xsl:value-of select="local-name()"/> is available &lt;a href='<xsl:value-of select="wms:OnlineResource/@xlink:href | OnlineResource/@xlink:href"/>'&gt;
	<xsl:if test="@wms:type | @type != ''">  <xsl:value-of select="@wms:type | @type"/> - </xsl:if>
	<xsl:if test="wms:Format | Format != ''"> <xsl:value-of select="wms:Format | Format"/></xsl:if>
	&lt;/a&gt;
	&lt;/li&gt;

</xsl:template>



<xsl:template match="wms:ContactInformation | ContactInformation">
      <author>
        <name><xsl:value-of select="wms:ContactPersonPrimary/wms:ContactPerson | ContactPersonPrimary/ContactPerson"/></name>
        <email><xsl:value-of select="wms:ContactElectronicMailAddress | ContactElectronicMailAddress"/></email>
      </author>
</xsl:template>


</xsl:stylesheet>
