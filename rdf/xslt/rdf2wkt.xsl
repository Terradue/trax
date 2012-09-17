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
 
 
 Stylesheet transformation for dclite4g stores to access wkt arrays 
       
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" 
	xmlns:dct="http://purl.org/dc/terms/" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:ical="http://www.w3.org/2002/12/cal/ical#" 
	xmlns:eop="http://www.genesi-dr.eu/spec/opensearch/extensions/eop/1.0/"
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
   xmlns:dif="http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/" 
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 	xmlns="http://www.w3.org/2005/Atom"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/"
	xmlns:echo="http://www.echo.nasa.gov/esip"
	xmlns:georss="http://www.georss.org/georss/10"
>
<xsl:output method="text" version="1.0" encoding="utf-8" indent="yes"/>

<xsl:template match="rdf:RDF">
	<xsl:apply-templates select="dclite4g:DataSet"/>
</xsl:template>

<xsl:template match="dclite4g:DataSet">
	<xsl:apply-templates select="dct:spatial"/>
</xsl:template>


<xsl:template match="dct:spatial">
	<xsl:value-of select="."/><xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>

