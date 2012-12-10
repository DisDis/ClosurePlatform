<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">
 
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:param name="old_file"/>
  <xsl:param name="lost_file"/>

  <xsl:variable name="new-data">
    <xsl:copy-of  select="//xliff:trans-unit"/>
  </xsl:variable>

  <xsl:variable name="old-and-lost">
    <xsl:choose>
      <xsl:when test="$lost_file">
	<xsl:copy-of select="document($old_file)//xliff:trans-unit union document($lost_file)//xliff:trans-unit"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="document($old_file)//xliff:trans-unit"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="find-lost">
    <xsl:param name="node"/>
    <xsl:variable name="pair" select="$new-data/xliff:trans-unit[./xliff:note/text() = $node/xliff:note/text()]"/>
    <xsl:if test="not ($pair)">
      <xsl:apply-templates select="$node"/>
    </xsl:if>	 
  </xsl:template>

  <xsl:template match="xliff:body">
	<xsl:copy>
    	<xsl:for-each select="$old-and-lost/xliff:trans-unit">
      		<xsl:call-template name="find-lost">
			<xsl:with-param name="node" select="."/>
      		</xsl:call-template>
    	</xsl:for-each>
    </xsl:copy>
   </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>