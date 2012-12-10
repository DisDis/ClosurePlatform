<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2">

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:param name="old_file"/>
  <xsl:param name="lost_file"/>
 
  <xsl:variable name="new-data" select="/"/>
  <xsl:variable name="old-data" select="document($old_file)//xliff:trans-unit "/>

  <xsl:variable name="old-and-lost-data">
    <xsl:choose>
      <xsl:when test="$lost_file">
	<xsl:value-of select="$old-data | document($lost_file)//xliff:trans-unit"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$old-data"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:template name="copy-old-node">
    <xsl:param name="node"/>
    <xsl:param name="ids"/>
    <trans-unit>
      <xsl:apply-templates select="$node/@* except $node/@id"/>
      <xsl:attribute name="id">
	<xsl:value-of select="$ids"/>
      </xsl:attribute>
      <xsl:apply-templates select="$node/node()"/>
    </trans-unit>

  </xsl:template> 

   <xsl:template match="xliff:trans-unit">
    <xsl:variable name="current-description" select="current()/xliff:note/text()"/>
    <xsl:variable name="old-node" select="$old-data[xliff:note/text() = $current-description]"/>
    <xsl:choose>
      <xsl:when test="$old-node">
	<xsl:call-template name="copy-old-node">
	  <xsl:with-param name="node" select="$old-node"/>
	  <xsl:with-param name="ids" select="./@id"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:apply-templates  select="@* | node()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
	<xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>