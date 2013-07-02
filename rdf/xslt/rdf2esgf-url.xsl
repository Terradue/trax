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
 
 Stylesheet transformation for dclite4g stores to construct a cmd line for the 
 download of esgf products     
-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:dclite4g="http://xmlns.com/2008/dclite4g#" 
	xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#" 
	xmlns:os="http://a9.com/-/spec/opensearch/1.1/"
	xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/"
	xmlns:esgf="http://www.esgf.org/ns">
<xsl:output method="text" version="1.0" encoding="utf-8" indent="yes"/>
<xsl:template match="rdf:RDF">
 -v <xsl:value-of select="dclite4g:DataSet/esgf:variable"/> -b <xsl:value-of select="//rdf:Description/os:Query/@geo:box"/> <xsl:apply-templates select="dclite4g:DataSet"/><xsl:text> 
 </xsl:text>
</xsl:template>
<xsl:template match="dclite4g:DataSet">
<xsl:text> </xsl:text><xsl:value-of select="dclite4g:onlineResource/ws:OPeNDAP/@rdf:about"/> </xsl:template>
</xsl:stylesheet>