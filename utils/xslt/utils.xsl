<?xml version="1.0" encoding="UTF-8"?>
<!---
	Stylesheet transformation utils to manage list, time and geopgraphic space
	
<xsl:call-template name ="max">
  <xsl:with-param name ="list" />
  
<xsl:call-template name ="min">
  <xsl:with-param name ="list" />
  
  
<xsl:template match="text/text()" name="tokenize">
        <xsl:param name="text" select="."/>
        <xsl:param name="separator" select="','"/>
  
-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 	
>

	
<xsl:template name ="max">
  <xsl:param name ="list" select="."/>
  <xsl:choose>
   <xsl:when test ="$list">
    <xsl:variable name ="first" select ="$list[1]" />
    <xsl:variable name ="rest">
     <xsl:call-template name ="max">
      <xsl:with-param name ="list" select ="$list[position() != 1]" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="$first &gt; $rest">
      <xsl:value-of select ="$first"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select ="$rest"/>     
     </xsl:otherwise>
    </xsl:choose>  
   </xsl:when>
   <xsl:otherwise>-1000</xsl:otherwise>
  </xsl:choose> 
 </xsl:template>

<xsl:template name ="min">
  <xsl:param name ="list" select="."/>
  <xsl:choose >
   <xsl:when test ="$list">
    <xsl:variable name ="first" select ="$list[1]" />
    <xsl:variable name ="rest">
     <xsl:call-template name ="min">
      <xsl:with-param name ="list" select ="$list[position() != 1]" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="$first &lt; $rest">
      <xsl:value-of select ="$first"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select ="$rest"/>     
     </xsl:otherwise>
    </xsl:choose>  
   </xsl:when>
   <xsl:otherwise>1000</xsl:otherwise>
  </xsl:choose> 
 </xsl:template>

 <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text/text()" name="tokenize">
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

