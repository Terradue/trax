<?xml version="1.0" encoding="UTF-8"?>
<!---

Copyright 2013 Terradue Srl.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 
 Stylesheet transformation for WMS/WFS GetCapabilities into OWS Context Document
	This xsl maps the service to a feed and assumes all named layers are entries
	
        TO-DO: add WCS support 
        TO-DO: add WPS support 
        TO-DO: add CSW support 
        
	TO-DO: get geo names of selected bbox	
-->

<xsl:stylesheet version="1.0" 
	xmlns="http://www.w3.org/2005/Atom"
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:exsl="http://exslt.org/common"
	xmlns:georss="http://www.georss.org/georss"
	xmlns:gml="http://www.opengis.net/gml"
	xmlns:owc="http://www.opengis.net/owc/1.0" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:wfs="http://www.opengis.net/wfs"
	xmlns:wms="http://www.opengis.net/wms"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="xlink xsl wfs wms dct exsl"
	>
	
	
<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes" omit-xml-declaration="yes"/>
<xsl:variable name="default_icon_height" select="'100'"/>
<xsl:variable name="default_map_height" select="'500'"/>

<xsl:variable name='_help'>
       - OWS2OWC -
       
       Copyright 2011-2013 Terradue srl
       This product includes software developed by
       Terradue srl (http://www.terradue.com/).
       
       Transform OGC Web Services GetCapabilities documents in OGC Context Document in ATOM encoding version 1.0.
       Currently it supports:
                - Web Map Specification (WMS) 1.1.1 and 1.3.0
                - Web Feature Specification (WFS) 1.0.0 and 1.1.0 
       
       
       It maps the service to a feed and assumes all named items (layers or features) are entries
	
       The ATOM feeds produced are classified as valid by http://validator.w3.org/feed/
       Please send bugs and suggestions to info@terradue.com
       
       Accepted Parameters:
       		- now : Parameter with the curret or desired update date to insert on the atom:updated element (Mandatory)
       		- bbox : Restrict Context file to a specific BBOX in the format: minlon, minlat, maxlon, maxlat (Optional)
       		- entry : Restrict Context file to a given layer or feature (Optional). If not present the entire Capabilities document will be processed
       		- iconheight : Height of the preview image (Optional) for WMS. Default value is <xsl:value-of select="$default_icon_height"/>
       		- mapheight : Height of the map image (Optional) for WMS. Default value is <xsl:value-of select="$default_map_height"/>
       		- mode : The processing mode (Optional) 
       			if equal to 'feed' it will produce a valid ATOM feed (default).
       			If equal to 'fragment' it will only produce the entry with the feature or layer. It must be used with the entry parameter.
       			If equal to 'help' it will display this message.
       			If equal to 'fragment-url' it will only produce the entry URLS with the feature or layer request. It must be used with the entry parameter.
       			If equal to 'list' it will show all the entries available on the OGC GetCapabilities documents.
       		
       	Example:
       	xsltproc --stringparam layer "sea_ice_extent_01" --stringparam now "`date +%Y-%m-%dT%H:%M:%S`" --stringparam fragment "true" ows2owc.xsl 'http://nsidc.org/cgi-bin/atlas_south?SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities'

</xsl:variable>

<xsl:param name="entry" select="''"/>
<xsl:param name="date" select="''"/>
<xsl:param name="bbox" select="''"/>
<xsl:param name="now" select="''"/>
<xsl:param name="icon_height" select="$default_icon_height"/>
<xsl:param name="map_height" select="$default_map_height"/>
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

<xsl:variable name="version" select="/*/@version"/>

<xsl:variable name="default_operation"><xsl:choose>
	<xsl:when test="/wfs:WFS_Capabilities">GetFeature</xsl:when>
	<xsl:when test="/wms:WMS_Capabilities | /WMT_MS_Capabilities">GetMap</xsl:when>
	<xsl:otherwise>UNKNOWN</xsl:otherwise></xsl:choose>
</xsl:variable>

<xsl:variable name="service_name"><xsl:choose>
	<xsl:when test="/wfs:WFS_Capabilities">WFS</xsl:when>
	<xsl:when test="/wms:WMS_Capabilities | /WMT_MS_Capabilities">WMS</xsl:when>
	<xsl:otherwise>UNKNOWN</xsl:otherwise></xsl:choose>
</xsl:variable>

<xsl:variable name="offering_code"><xsl:choose>
	<xsl:when test="$service_name='WFS'">http://www.opengis.net/spec/owc/1.0/req/atom/wfs</xsl:when>
	<xsl:when test="$service_name='WMS'">http://www.opengis.net/spec/owc/1.0/req/atom/wms</xsl:when>
	<xsl:otherwise>http://www.opengis.net/spec/owc/1.0/req/atom</xsl:otherwise></xsl:choose>
</xsl:variable>


<xsl:variable name="capabilities_online_resource" select="/wfs:WFS_Capabilities/wfs:Capability/wfs:Request/wfs:GetCapabilities/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource | /wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href | /*/ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>
<xsl:variable name="capabilities_format" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/Format[1] | /*/ows:OperationsMetadata/ows:Operation[@name='GetCapabilities']/ows:Parameter[@name='AcceptFormats']/ows:Value[1]"/>

<xsl:variable name="operation_online_resource" select="/wfs:WFS_Capabilities/wfs:Capability/wfs:Request/wfs:GetFeature/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource | /wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href | /*/ows:OperationsMetadata/ows:Operation[@name=$default_operation]/ows:DCP/ows:HTTP/ows:Get/@xlink:href"/>
<xsl:variable name="data_format"><xsl:choose>
<xsl:when test="/wfs:WFS_Capabilities/wfs:Capability/wfs:Request/wfs:GetFeature/wfs:ResultFormat"><xsl:choose><xsl:when test="wfs:WFS_Capabilities/wfs:Capability/wfs:Request/wfs:GetFeature/wfs:ResultFormat/*[name()='_GML3']">GML3</xsl:when><xsl:otherwise><xsl:value-of select="name(/wfs:WFS_Capabilities/wfs:Capability/wfs:Request/wfs:GetFeature/wfs:ResultFormat/*[1])"/></xsl:otherwise></xsl:choose></xsl:when>
<xsl:otherwise><xsl:value-of select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetMap/Format[1] | /*/ows:OperationsMetadata/ows:Operation[@name=$default_operation]/ows:Parameter[@name='outputFormat']/ows:Value[1]"/></xsl:otherwise>
</xsl:choose></xsl:variable>

<xsl:variable name="exception_format" select="/wms:WMS_Capabilities/wms:Capability/wms:Exception/wms:Format[1] | /WMT_MS_Capabilities/Capability/Exception/Format[1]"/>

<xsl:variable name="service_online_resoure" select="$capabilities_online_resource"/>

<xsl:variable name="rights" select="concat('Fee:',/wms:WMS_Capabilities/wms:Service/wms:Fees | /WMT_MS_Capabilities/Service/Fees | /*/ows:ServiceIdentification/ows:Fees,' / Contraints:',/wms:WMS_Capabilities/wms:Service/wms:AccessConstraints | /WMT_MS_Capabilities/Service/AccessConstraints | /*/ows:ServiceIdentification/ows:AccessConstraints)"/>



<xsl:template match="/">

<xsl:if test="count(wms:WMS_Capabilities | WMT_MS_Capabilities | wfs:WFS_Capabilities)=0">
      <xsl:message terminate="yes">
        Error: Capabilities root element was not found! Is this a capabilities document?        
        <xsl:value-of select="$_help"/>
      </xsl:message>
</xsl:if>

<xsl:if test="now='' ">
      <xsl:message terminate="yes">
        Error: Parameter now is an empty string!
        	try to add the parameter to the xslt processor using a valid ISO-8601 date (--stringparam now "`date +%Y-%m-%dT%H:%M:%S`")

        <xsl:value-of select="$_help"/>
      </xsl:message>
</xsl:if>

<xsl:choose>
<xsl:when test="$mode='help'">
      <xsl:message terminate="yes">
        <xsl:value-of select="$_help"/>
      </xsl:message>
</xsl:when>
<xsl:when test="($mode='fragment' or $mode='fragment-url') and $entry!=''">
	<xsl:apply-templates select="//wms:Layer[wms:Name=$entry] | //Layer[Name=$entry] | //wfs:FeatureType[wfs:Name=$entry]"/>
</xsl:when>
<xsl:when test="$mode='list'">
	<xsl:for-each  select="//wms:Layer[wms:Name!=''] | //Layer[Name!=''] | //wfs:FeatureType ">
<xsl:value-of select="wms:Name | Name | wfs:Name"/>
<xsl:text>
</xsl:text>
	</xsl:for-each>
</xsl:when>
<xsl:otherwise>
	<xsl:apply-templates select="wfs:WFS_Capabilities | wms:WMS_Capabilities | WMT_MS_Capabilities"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="wfs:WFS_Capabilities | wms:WMS_Capabilities | WMT_MS_Capabilities">
<xsl:value-of disable-output-escaping="yes" select="'&lt;?xml version=&quot;1.0&quot; encoding=&quot;iso-8859-1&quot;?&gt;'"/> 
<xsl:text>
</xsl:text>
<feed xml:lang='en'>

      <category scheme="http://www.opengis.net/spec/owc/specReference" 
              term="http://www.opengis.net/spec/owc/1.0/req/atom" 
              label="This file is compliant with version 1.0 of OGC Context"/> 
      <title>
       <xsl:value-of select="ows:ServiceIdentification/ows:Title | wms:Service/wms:Title | Service/Title"/>
      </title>
      <id><xsl:value-of select="$service_online_resoure"/>/</id> 
   
      <xsl:apply-templates select="ows:ServiceProvider | wms:ContactInformation | ContactInformation"/>
  
      <xsl:apply-templates select="ows:ServiceIdentification/ows:Abstract | wms:Service/wms:Abstract | Service/Abstract"/>
      
      <xsl:if test="$now!=''">
      <updated><xsl:value-of select="$now"/>Z</updated>        
      </xsl:if>


      
      <dc:publisher><xsl:value-of select='wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization | Service/ContactInformation/ContactPersonPrimary/ContactOrganization | ows:ServiceProvider/ows:ProviderName'/></dc:publisher>
      <generator uri="https://github.com/Terradue/trax/" version="1.0">
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
		      <xsl:value-of select="concat($coords/*[2],' ',$coords/*[1],' ',$coords/*[2],' ',$coords/*[3],' ',$coords/*[4],' ',$coords/*[3],' ',$coords/*[4],' ',$coords/*[1],' ',$coords/*[2],' ',$coords/*[1])"/>
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
     
     <xsl:for-each select="//ows:Keyword[not(.=following::ows:Keyword)] | //wms:Keyword[not(.=following::wms:Keyword)] | //Keyword[not(.=following::Keyword)]">
     <category>
     	<xsl:attribute name="scheme"><xsl:value-of select="$service_online_resoure"/></xsl:attribute>
     	<xsl:attribute name="term"><xsl:value-of select="."/></xsl:attribute> 
     </category>
     </xsl:for-each>
    
     <xsl:choose>
	<xsl:when test="$entry!=''">
		<xsl:apply-templates select="(//wms:Layer[wms:Name=$entry])[1] | (//Layer[Name=$entry])[1] | (wfs:FeatureTypeList/wfs:FeatureType[wfs:Name=$entry])[1]"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:apply-templates select="//wms:Layer[wms:Name!=''] | //Layer[Name!=''] | wfs:FeatureTypeList/wfs:FeatureType"/>
	</xsl:otherwise>
     </xsl:choose>
</feed>
     
</xsl:template>



<xsl:template match="wms:Layer | Layer | wfs:FeatureType">
<!---
	<xsl:copy-of select="(ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox) | (ancestor-or-self::Layer/LatLonBoundingBox) | (ancestor-or-self::wfs:FeatureType/wfs:LatLongBoundingBox)"/>
	<xsl:message terminate="yes"/>
-->
	<xsl:variable name="maxX">
	<xsl:choose>
		<xsl:when test="$bbox!=''"><xsl:value-of select="$coords/*[3]"/></xsl:when>
		<xsl:when test="ows:WGS84BoundingBox/ows:UpperCorner">
			<xsl:value-of select="substring-before(ows:WGS84BoundingBox/ows:UpperCorner,' ')"/>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:value-of select="(ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox)[last()]/wms:eastBoundLongitude | (ancestor-or-self::Layer/LatLonBoundingBox)[last()]/@maxx | (ancestor-or-self::wfs:FeatureType/wfs:LatLongBoundingBox)[last()]/@maxx "/>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:variable name="maxY">
	<xsl:choose>
		<xsl:when test="$bbox!=''"><xsl:value-of select="$coords/*[4]"/></xsl:when>
		<xsl:when test="ows:WGS84BoundingBox/ows:UpperCorner">
			<xsl:value-of select="substring-after(ows:WGS84BoundingBox/ows:UpperCorner,' ')"/>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="(ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox)[last()]/wms:northBoundLatitude | (ancestor-or-self::Layer/LatLonBoundingBox)[last()]/@maxy | (ancestor-or-self::wfs:FeatureType/wfs:LatLongBoundingBox)[last()]/@maxy"/></xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:variable name="minX">
	<xsl:choose>
		<xsl:when test="$bbox!=''"><xsl:value-of select="$coords/*[1]"/></xsl:when>
		<xsl:when test="ows:WGS84BoundingBox/ows:LowerCorner">
			<xsl:value-of select="substring-before(ows:WGS84BoundingBox/ows:LowerCorner,' ')"/>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="(ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox)[last()]/wms:westBoundLongitude | (ancestor-or-self::Layer/LatLonBoundingBox)[last()]/@minx | (ancestor-or-self::wfs:FeatureType/wfs:LatLongBoundingBox)[last()]/@minx"/></xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
        <xsl:variable name="minY">
    	<xsl:choose>
		<xsl:when test="$bbox!=''"><xsl:value-of select="$coords/*[2]"/></xsl:when>
		<xsl:when test="ows:WGS84BoundingBox/ows:LowerCorner">
			<xsl:value-of select="substring-after(ows:WGS84BoundingBox/ows:LowerCorner,' ')"/>
		</xsl:when>
		<xsl:otherwise><xsl:value-of select="(ancestor-or-self::wms:Layer/wms:EX_GeographicBoundingBox)[last()]/wms:southBoundLatitude | (ancestor-or-self::Layer/LatLonBoundingBox)[last()]/@miny | (ancestor-or-self::wfs:FeatureType/wfs:LatLongBoundingBox)[last()]/@miny"/></xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	<xsl:variable name="georatio" select="translate((number($maxX) - number($minX) ) div ( number($maxY) - number($minY) ),'-','' ) "/>
	
	<xsl:variable name="name" select="wms:Name | Name | wfs:Name"/>
	
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

	<xsl:variable name="bbox">
	<xsl:choose>
	<xsl:when test="($service_name='WMS' and $version='1.3.0' and $crs='EPSG:4326') or (/wfs:WFS_Capabilities and $version!='1.0.0') ">
		<xsl:value-of select="concat($minY,',',$minX,',',$maxY,',',$maxX)"/></xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="concat($minX,',',$minY,',',$maxX,',',$maxY)"/>
	</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="style" select="wms:Style[1]/wms:Name | Style[1]/Name"/>

	<xsl:variable name="get_request">
		<xsl:value-of select="$operation_online_resource"/><xsl:if test="substring-before($operation_online_resource,'?')=''">?</xsl:if><xsl:value-of select="concat('&amp;SERVICE=',$service_name, '&amp;VERSION=',$version,'&amp;REQUEST=',$default_operation,'&amp;BBOX=',$bbox)"/><xsl:choose>
			<xsl:when test="$service_name='WFS'"><xsl:value-of select="concat('&amp;OUTPUTFORMAT=',$data_format,'&amp;TYPENAME=',$name,'&amp;MAXFEATURES=10')"/>
			</xsl:when>
			<xsl:when test="$service_name='WMS'"><xsl:value-of select="concat( '&amp;',$crsName, '=',$crs,'&amp;WIDTH=',floor($map_height * $georatio),'&amp;HEIGHT=',$map_height,'&amp;LAYERS=',$name,'&amp;FORMAT=',$data_format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$exception_format)"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="get_capabilities_request"><xsl:value-of select="$capabilities_online_resource"/><xsl:if test="substring-before($capabilities_online_resource,'?')=''">?</xsl:if><xsl:value-of select="concat('&amp;SERVICE=',$service_name,'&amp;VERSION=',$version,'&amp;REQUEST=GetCapabilities')"/></xsl:variable>	
	<xsl:variable name="quicklook_request" select="concat($operation_online_resource,'&amp;SERVICE=',$service_name, '&amp;VERSION=',$version,'&amp;REQUEST=GetMap&amp;', $crsName, '=',$crs,'&amp;BBOX=',$bbox,'&amp;WIDTH=',floor($icon_height * $georatio),'&amp;HEIGHT=',$icon_height,'&amp;LAYERS=',$name,'&amp;STYLES=',$style,'&amp;FORMAT=',$data_format,'&amp;BGCOLOR=0xffffff&amp;TRANSPARENT=TRUE&amp;EXCEPTIONS=',$exception_format)"/>		
	<xsl:variable name="describedby_request"><xsl:value-of select="$operation_online_resource"/><xsl:if test="substring-before($operation_online_resource,'?')=''">?</xsl:if><xsl:value-of select="concat('&amp;SERVICE=',$service_name, '&amp;VERSION=',$version,'&amp;REQUEST=describeFeatureType&amp;TYPENAME=',$name,'')"/></xsl:variable>	

<xsl:choose>
<xsl:when test="$mode='fragment-url'">
<xsl:value-of disable-output-escaping="yes" select="$get_capabilities_request"/> 
<xsl:text>
</xsl:text>
<xsl:value-of disable-output-escaping="yes" select="$get_request"/> 
</xsl:when>
<xsl:otherwise>
<entry>	
	<!--
	todo: get geo names of selections
	<xsl:value-of select="concat('http://eo-virtual-archive4.esa.int/search/geo/rdf?geometry=POLYGON((',$minX,' ',$minY,',',$minX,' ',$maxY,',',$maxX,' ',$maxY,',',$maxX,' ',$minY,',',$minX,' ',$minY,'))')"/>
	-->
	
	<id><xsl:value-of select="concat($service_online_resoure,wms:Name | wfs:Name)"/>/</id>

        <title><xsl:value-of select="wms:Title | wfs:Title | Title"/></title>

        <!--
        Repeat feed author and dc:publisher elements to ease xml fragment extraction
        -->
        <xsl:apply-templates select="/*/ows:ServiceProvider | /wms:WMS_Capabilities/wms:Service/wms:ContactInformation | /WMT_MS_Capabilities/Service/ContactInformation"/>
        
  
        <xsl:apply-templates select="wms:Attribution/wms:Title | Attribution/Title"/>
        
        <dc:publisher><xsl:value-of select='/wms:WMS_Capabilities/wms:Service/wms:ContactInformation/wms:ContactPersonPrimary/wms:ContactOrganization | /WMT_MS_Capabilities/Service/ContactInformation/ContactPersonPrimary/ContactOrganization |
/wfs:WFS_Capabilities/ows:ServiceProvider/ows:ProviderName | /*/ows:ServiceProvider/ows:ProviderName'/></dc:publisher>

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
	
	<link rel='enclosure'>
		<xsl:attribute name="type"><xsl:value-of select="$data_format"/></xsl:attribute>
		<xsl:attribute name="title"><xsl:value-of select="concat($service_name,' output for ', wfs:Title | wms:Title | Title )"/></xsl:attribute>
		<xsl:attribute name="href"><xsl:value-of select="$get_request"/></xsl:attribute>
	</link>
			
	<xsl:if test="$service_name='WMS'">
		<link rel='icon'>
			<xsl:attribute name="type"><xsl:value-of select="$data_format"/></xsl:attribute>
			<xsl:attribute name="title">Preview for <xsl:value-of select="wms:Title | Title"/></xsl:attribute>
			<xsl:attribute name="href"><xsl:value-of select="$quicklook_request"/></xsl:attribute>
		</link>
	</xsl:if>

	
	<xsl:if test="$service_name='WFS'">
		<link rel='describedby'>
			<xsl:attribute name="type">text/xml</xsl:attribute>
			<xsl:attribute name="title">Description of Features</xsl:attribute>
			<xsl:attribute name="href"><xsl:value-of select="$describedby_request"/></xsl:attribute>
		</link>
	</xsl:if>
	
	
	
	<link rel='via'>
        <xsl:attribute name="type"><xsl:value-of select="$capabilities_format"/></xsl:attribute>
		<xsl:attribute name="title">Original GetCapabilities document</xsl:attribute>
		<xsl:attribute name="href">
			<xsl:value-of select="$get_capabilities_request"/>        
		</xsl:attribute>
	</link>
	<xsl:apply-templates select="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL"/>

        
	<content type='html'>
	<xsl:if test="$service_name='WMS'">
        &lt;br/&gt;
	&lt;img border='1' align='right' height='<xsl:value-of select="$icon_height"/>'src='<xsl:value-of select="$quicklook_request"/>'/&gt;
	<xsl:apply-templates select="wms:Attribution | Attribution" mode="html"/>
	</xsl:if>
	&lt;br/&gt;
	This resource is available from a OGC <xsl:value-of select="$service_name"/> Service (version <xsl:value-of select="$version"/>) and it contains the following access points:
	&lt;ul&gt;
	&lt;li&gt;
	&lt;a href='<xsl:value-of select="$get_request"/>'&gt;
	<xsl:value-of select="$default_operation"/> &lt;/a&gt; request in <xsl:value-of select="$data_format"/> (atom:link[@rel="enclosure"])
	&lt;/li&gt;
	
	&lt;li&gt;
	&lt;a href='<xsl:value-of select="$get_capabilities_request"/>'&gt;
	GetCapabilities &lt;/a&gt; request (atom:link[@rel="via"])
	&lt;/li&gt;
	&lt;/li&gt;<xsl:if  test="$service_name='WFS'">
	&lt;li&gt;
	&lt;a href='<xsl:value-of select="$describedby_request"/>'&gt;
	Describe Feature &lt;/a&gt; request for <xsl:value-of select="$name"/> (atom:link[@rel="describedby"])
	&lt;/li&gt;</xsl:if><xsl:apply-templates select="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL" mode="html"/>
	&lt;/ul&gt;
	<xsl:value-of select="wfs:Abstract | wms:Abstract | Abstract"/>
	&lt;p style='font-size:small'&gt;OGC Context CITE Testing XSLT (Extensible Stylesheet Language Transformations) by Terradue Srl.&lt;/p&gt;
	</content>
	         
	 <owc:offering>
	 	<xsl:attribute name="code"><xsl:value-of select="$offering_code"/></xsl:attribute>
		<owc:operation method="GET" code="GetCapabilities">
			<xsl:attribute name="href"><xsl:value-of select="$get_capabilities_request"/></xsl:attribute>
		</owc:operation>
		<owc:operation method="GET">
			<xsl:attribute name="code"><xsl:value-of select="$default_operation"/></xsl:attribute>
			<xsl:attribute name="href"><xsl:value-of select="$get_request"/></xsl:attribute>
			<xsl:if test="$service_name='WFS'">
			<owc:result>
			<xsl:attribute name="type">
			<xsl:choose>
				<xsl:when test="($version='1.0.0' and $data_format='GML2') or ($data_format='text/xml; subtype=gml/2.1.2')">application/gml+xml; version=2</xsl:when>
				<xsl:when test="($version='1.0.0' and $data_format='GML3') or ($data_format='text/xml; subtype=gml/3.1.1')">application/gml+xml; version=3.1</xsl:when>
				<xsl:when test="($version='1.0.0' and $data_format='JSON') or ($data_format='application/json')">application/json</xsl:when>
				<xsl:otherwise><xsl:value-of select="$data_format"/></xsl:otherwise>
			</xsl:choose>
			</xsl:attribute><ola>sdsd</ola>
			<xsl:copy-of select="document(translate($get_request,' ','+'))"/>
			</owc:result>
			</xsl:if>
		</owc:operation>
		   
		<xsl:for-each select="wms:Style | Style">
		<owc:styleSet>
			<owc:name><xsl:value-of select="wms:Name | Name"/></owc:name>
			<owc:title><xsl:value-of select="wms:Title | Title"/></owc:title>
			<owc:abstract><xsl:value-of select="wms:Abstract | Abstract"/></owc:abstract>
			<owc:legendURL>
				<xsl:attribute name="href"><xsl:value-of select="wms:LegendURL/wms:OnlineResource/@xlink:href | LegendURL/OnlineResource/@xlink:href"/></xsl:attribute>
				<xsl:attribute name="type"><xsl:value-of select="wms:LegendURL/wms:Format | LegendURL/Format"/></xsl:attribute>
			</owc:legendURL>
		</owc:styleSet>		
		</xsl:for-each>
	</owc:offering>
</entry>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="ows:ServiceIdentification/ows:Abstract | wms:Service/wms:Abstract | Service/Abstract">
	<subtitle type="text">
	<xsl:value-of select="."/>
        </subtitle>
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



<xsl:template match="ows:ServiceProvider | wms:ContactInformation | ContactInformation">
	<author>
		<name>
		<xsl:value-of  select="ows:ServiceContact/ows:IndividualName | wms:ContactPersonPrimary/wms:ContactPerson | ContactPersonPrimary/ContactPerson"/>
		</name>
		<email>
		<xsl:value-of select="ows:ServiceContact/ows:ContactInfo/ows:Address/ows:ElectronicMailAddress | wms:ContactElectronicMailAddress | ContactElectronicMailAddress"/>
		</email>
		<uri><xsl:value-of select="ows:ServiceProvider/ows:ProviderSite/@xlink:href | /wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href"/></uri>
	</author>
</xsl:template>



<xsl:template match="wms:Attribution | Attribution" mode="html">
	&lt;b&gt;&lt;a href='<xsl:value-of select="(wms:OnlineResource | OnlineResource )/@xlink:href"/>'&gt;<xsl:value-of select="wms:Title | Title"/>&lt;/a&gt;&lt;/b&gt;
<xsl:apply-templates select="wms:LogoURL | LogoURL" mode="html"/></xsl:template>

<xsl:template match="wms:LogoURL | LogoURL" mode="html">
	&lt;img src='<xsl:value-of select="(wms:OnlineResource | OnlineResource )/@xlink:href"/>' hspace='20' align='left' width='<xsl:value-of select="@width"/>' height='<xsl:value-of select="@height"/>'&gt;
</xsl:template>

<xsl:template match="wms:DataURL | DataURL | wms:MetadataURL | MetadataURL" mode="html">
	&lt;li&gt;
	<xsl:value-of select="local-name()"/> is available &lt;a href='<xsl:value-of select="wms:OnlineResource/@xlink:href | OnlineResource/@xlink:href"/>'&gt;
	<xsl:if test="@wms:type | @type != ''">  <xsl:value-of select="@wms:type | @type"/> - </xsl:if>
	<xsl:if test="wms:Format | Format != ''"> <xsl:value-of select="wms:Format | Format"/></xsl:if>
	&lt;/a&gt;
	&lt;/li&gt;</xsl:template>


<xsl:template name="tokenize">
        <xsl:param name="text" select="."/>
        <xsl:param name="separator" select="','"/>
        <xsl:choose>
            <xsl:when test="not(contains($text, $separator))">
                <item>
                    <xsl:value-of select="normalize-space($text)"/>
                </item>
            </xsl:when>
            <xsl:otherwise>
                <item>
                    <xsl:value-of select="normalize-space(substring-before($text, $separator))"/>
                </item>
                <xsl:call-template name="tokenize">
                    <xsl:with-param name="text" select="substring-after($text, $separator)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>

</xsl:stylesheet>
