<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ead="urn:isbn:1-931666-22-9"
  xmlns:fn="http://exslt.org/common" 
  exclude-result-prefixes="xsl ead fn">
  <xsl:output standalone="yes"/>
  <xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="LOWER">abcdefghijklmnopqrstuvwxyz</xsl:variable>

  <!-- Utility Templates -->

  <!-- 
    Copy all attributes except those passed in as a space-delimited list in the except parameter.
    Used to fulfill requirement 5 ("Remove all label attributes") among other things.
  -->
  <xsl:template name="copy-attributes">
    <!-- Exclude certain attributes (default: @label) -->
    <xsl:param name="except">label</xsl:param>
    <xsl:variable name="except-match">
      <xsl:text>|</xsl:text>
      <xsl:value-of select="translate($except,' ','|')"/>
      <xsl:text>|</xsl:text>
    </xsl:variable>
    <xsl:for-each select="@*">
      <xsl:if test="not(contains($except-match,concat('|',name(),'|')))">
        <xsl:copy/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Remove whitespace surrounding delimiters in text strings -->
  <xsl:template name="normalize-delimited-text">
    <xsl:param name="string"/>
    <xsl:param name="delimiter">--</xsl:param>
    <xsl:choose>
      <xsl:when test="contains($string,$delimiter)">
        <xsl:value-of select="normalize-space(substring-before($string,$delimiter))"/>
        <xsl:value-of select="$delimiter"/>
        <xsl:call-template name="normalize-delimited-text">
          <xsl:with-param name="string"
            select="normalize-space(substring-after($string,$delimiter))"/>
          <xsl:with-param name="delimiter" select="$delimiter"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Copy existing element, removing @label and adding attributes passed in through the $attributes parameter -->

  <xsl:template name="add-attributes">
    <xsl:param name="attributes"/>
    <xsl:copy>
      <xsl:call-template name="copy-attributes"/>
      <xsl:if test="$attributes">
        <xsl:variable name="attrs" select="fn:node-set($attributes)"/>
        <xsl:for-each select="$attrs/*">
          <xsl:variable name="attr-name" select="name()"/>
          <xsl:variable name="attr-value" select="./text()"/>
          <xsl:if test="$attr-value">
            <xsl:attribute name="{$attr-name}">
              <xsl:value-of select="$attr-value"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Add @id values and DC @encodinganalogs to eadheader -->

  <xsl:template match="ead:eadheader">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a23</id>
        <relatedencoding>dc</relatedencoding>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:eadid">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>identifier</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:titleproper[not(@type='filing')]">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>title</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:titleproper/ead:date">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>date</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:author">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>creator</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader/ead:sponsor">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>contributor</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:publisher">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>publisher</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:publicationstmt/ead:date">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>date</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:eadheader//ead:langusage/ead:language">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>language</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Add @id values and MARC21 @encodinganalogs to archdesc -->

  <xsl:template match="ead:archdesc">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <relatedencoding>marc21</relatedencoding>
        <type>inventory</type>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:repository">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>852</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:repository/ead:corpname">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>852$a</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:repository/ead:subarea">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>852$b</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:unitid">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>099</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:origination/ead:persname" priority="2">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>100</encodinganalog>
        <role><xsl:call-template name="normalize-role"/></role>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:origination/ead:corpname" priority="2">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>110</encodinganalog>
        <role><xsl:call-template name="normalize-role"/></role>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:origination/ead:famname" priority="2">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>100</encodinganalog>
        <role><xsl:call-template name="normalize-role"/></role>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:unittitle">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>245$a</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:unitdate[@type='inclusive']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>245$f</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:unitdate[@type='bulk']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>245$g</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:physdesc/ead:extent">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>300$a</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:abstract">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>5203_</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:langmaterial/ead:language">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>546</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:bioghist">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a2</id>
        <encodinganalog>
          <xsl:choose>
            <xsl:when test="translate(ead:head/text(),$UPPER,$LOWER) = 'biographical note'">5450_</xsl:when>
            <xsl:when test="translate(ead:head/text(),$UPPER,$LOWER) = 'historical note'">5451_</xsl:when>
          </xsl:choose>
        </encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:scopecontent">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a3</id>
        <encodinganalog>5202_</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:odd">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a5</id>
        <encodinganalog>500</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:arrangement">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a4</id>
        <encodinganalog>351</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:altformavail">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a9</id>
        <encodinganalog>530</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:accessrestrict">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a14</id>
        <encodinganalog>506</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:userestrict">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a15</id>
        <encodinganalog>540</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:prefercite">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a18</id>
        <encodinganalog>524</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:custodhist">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a16</id>
        <encodinganalog>561</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:acqinfo">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a19</id>
        <encodinganalog>541</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:accruals">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a10</id>
        <encodinganalog>584</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:processinfo">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a20</id>
        <encodinganalog>583</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:separatedmaterial">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a7</id>
        <encodinganalog>5440_</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:otherfindaid">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a8</id>
        <encodinganalog>555</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:relatedmaterial">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a6</id>
        <encodinganalog>5441_</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a12</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:subject">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>650</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:subject[@source='nwda']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>690</encodinganalog>
        <altrender>nodisplay</altrender>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:persname[@role='subject']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>600</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:persname[not(@role='subject')]">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>700</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:corpname[@role='subject']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>610</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:corpname[not(@role='subject')]">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>710</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:famname[@role='subject']">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>600</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:famname[not(@role='subject')]">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>700</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:geogname">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>651</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:genreform">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>655</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:occupation">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>656</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:controlaccess/ead:function">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <encodinganalog>657</encodinganalog>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:appraisal">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a39</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:bibliography">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a11</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:did">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a1</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:fileplan">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a37</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:index">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a38</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:originalsloc">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a36</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="ead:archdesc//ead:phystech">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <id>a35</id>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- 6. Remove all head elements except bioghist/head -->
  <xsl:template match="ead:head[not(parent::ead:bioghist)]"/>

  <!-- 8. Add appropriate type attribute to dsc element -->
  <xsl:template match="ead:dsc">
    <xsl:copy>
      <xsl:call-template name="copy-attributes"/>
      <xsl:attribute name="id">a23</xsl:attribute>
      <xsl:choose>
        <xsl:when
          test="*[starts-with(local-name(),'c0') and (@level='series' or @level='subgrp')] and *[starts-with(local-name(),'c0') and (@level='file' or @level='item')]">
          <xsl:attribute name="type">combined</xsl:attribute>
        </xsl:when>
        <xsl:when test="*[starts-with(local-name(),'c0') and (@level='series' or @level='subgrp')]">
          <xsl:attribute name="type">analyticover</xsl:attribute>
        </xsl:when>
        <xsl:when test="*[starts-with(local-name(),'c0') and (@level='file' or @level='item')]">
          <xsl:attribute name="type">in-depth</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- 10. Convert container type values to lowercase -->
  <xsl:template match="ead:container">
    <xsl:copy>
      <xsl:call-template name="copy-attributes"/>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="translate(@type,$UPPER,$LOWER)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- 11. Remove whitespace in controlaccess headings -->
  <xsl:template match="ead:controlaccess/*/text()">
    <xsl:call-template name="normalize-delimited-text">
      <xsl:with-param name="string" select="."/>
      <xsl:with-param name="delimiter">--</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- 12. Remove call number from title -->
  <xsl:template match="ead:titleproper/ead:num"/>

  <!-- 13. Replace incorrect role attribute values -->
  <xsl:template name="normalize-role">
    <xsl:if test="@role">
      <xsl:choose>
        <xsl:when test="contains(@role,'(')">
          <xsl:value-of
            select="translate(normalize-space(substring-before(@role,'(')),$UPPER,$LOWER)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@role"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ead:origination/ead:*" priority="1">
    <xsl:call-template name="add-attributes">
      <xsl:with-param name="attributes">
        <role><xsl:call-template name="normalize-role"/></role>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- Pass all other elements and attributes through unaltered -->
  <xsl:template match="*">
    <xsl:copy>
      <xsl:call-template name="copy-attributes"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
