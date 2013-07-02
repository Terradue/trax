<?xml version="1.0" encoding="UTF-8"?>
<!---
	Stylesheet transformation for WMS GetCapabilities  
	
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

<xsl:output method="text" version="1.0" encoding="iso-8859-1" indent="yes" omit-xml-declaration="no"/>

<xsl:variable name="version" select="wms:WMS_Capabilities/@version | WMT_MS_Capabilities/@version"/>
<xsl:variable name="GETMAPonlineResource" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
<xsl:variable name="GETCAPABILITIESonlineResource" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource/@xlink:href"/>
<xsl:variable name="GETCAPABILITIESformat" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetCapabilities/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetCapabilities/Format[1]"/>

<xsl:variable name="WMSonlineResource" select="/wms:WMS_Capabilities/wms:Service/wms:OnlineResource/@xlink:href | /WMT_MS_Capabilities/Service/OnlineResource/@xlink:href"/>
<xsl:variable name="ExceptionFormat" select="/wms:WMS_Capabilities/wms:Capability/wms:Exception/wms:Format[1] | /WMT_MS_Capabilities/Capability/Exception/Format[1]"/>
<xsl:variable name="format" select="/wms:WMS_Capabilities/wms:Capability/wms:Request/wms:GetMap/wms:Format[1] | /WMT_MS_Capabilities/Capability/Request/GetMap/Format[1]"/>
<xsl:variable name="rights" select="concat('Fee:',/wms:WMS_Capabilities/wms:Service/wms:Fees | /WMT_MS_Capabilities/Service/Fees,' / Contraints:',/wms:WMS_Capabilities/wms:Service/wms:AccessConstraints | /WMT_MS_Capabilities/Service/AccessConstraints)"/>

<xsl:template name="msg">
      <xsl:message terminate="yes">
       - WMS Utils -
       
       Copyright 2011-2012 Terradue srl
       This product includes software developed by
       Terradue srl (http://www.terradue.com/).
       
       Stylesheet transformations for OGC WMS (1.1.1 and 1.3.0) GetCapabilities 
       It extract information for bash processing

       Please send bugs and suggestions to info@terradue.com
       
       Accepted Parameters:
       		- mode : The processing mode (Optional) 
       			If equal to 'list' it will only list the available layers.
       			If equal to 'help' it will display this message.
       			
       			
       		
       	Example:
       	xsltproc --stringparam mode "list" wms-utils.xsl 'http://nsidc.org/cgi-bin/atlas_south?SERVICE=WMS&amp;VERSION=1.1.1&amp;REQUEST=GetCapabilities'

      </xsl:message>
</xsl:template>


<xsl:template match="/">

<xsl:if test="count(wms:WMS_Capabilities | WMT_MS_Capabilities)=0">
      <xsl:message terminate="no">
        Error: WMS Capabilities root element was not found!
      </xsl:message>
      <xsl:call-template name="help"/>
</xsl:if>

<xsl:choose>
<xsl:when test="$mode='help'">
	<xsl:call-template name="msg"/>
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

       WMS Service : <xsl:value-of select="wms:Service/wms:Title | Service/Title"/>

       <xsl:call-template name="help"/>
       
</xsl:template>

<!-- HTML Elements -->



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

</xsl:stylesheet>
