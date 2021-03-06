<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
                version="1.0"
                exclude-result-prefixes="doc">

<!-- ********************************************************************
     Id: htmlhelp.xsl,v 1.9 2001/12/06 17:52:55 kosek Exp
     ******************************************************************** 

     This file is used by htmlhelp.xsl if you want to generate source
     files for HTML Help.  It is based on the XSL DocBook Stylesheet
     distribution (especially on JavaHelp code) from Norman Walsh.

     ******************************************************************** -->

<!-- Customized for phpdoc needs :

    - used DOCBOOKXSL_HTML to locate HTML chunk.xsl file
    - all map and alias parts deleted, we do not need them
    - deleted autoindex from [OPTIONS]
    - added Index file to [OPTIONS] => new $htmlhelp.hhk param!
    - the index file will always be _index.html
    - made title a variable => two places to use it
    - added phpdoc window definition
    - added [MERGE FILES] section for manual notes file
    - added more special files to [FILES]
    - removed enumerate-images parts, we do not have any
      images to enumerate for compatibility reasons with
      other formats
    - made <book> the first item in the TOC, but not the absolute
      root. this is not fully correct, but makes the CHM more
      useable.
    - removed blocks for index terms, maps and aliases
    - removed href.target.with.base.dir, as we have all the
      files in the same dir
    - generate all hh[pkc] files into $base.dir
    - added a HHK generator part (slightly modified version of
      HHC generator)
-->
     
<xsl:import href="./docbook/docbook-xsl/html/chunkfast.xsl"/>

<!-- ==================================================================== -->
<!-- Customizations of standard HTML stylesheet parameters -->

<xsl:param name="suppress.navigation" select="1"/>

<!-- ==================================================================== -->

<xsl:template match="/">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:choose>
        <xsl:when test="count(key('id',$rootid)) = 0">
          <xsl:message terminate="yes">
            <xsl:text>ID '</xsl:text>
            <xsl:value-of select="$rootid"/>
            <xsl:text>' not found in document.</xsl:text>
          </xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Formatting from <xsl:value-of select="$rootid"/></xsl:message>
          <xsl:apply-templates select="key('id',$rootid)" mode="process.root"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="/" mode="process.root"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:call-template name="hhp"/>
  <xsl:call-template name="hhc"/>
  <xsl:call-template name="hhk"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="hhp">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="concat($base.dir,$htmlhelp.hhp)"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:call-template name="hhp-main"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<!-- ==================================================================== -->
<xsl:template name="hhp-main">
<xsl:text>[OPTIONS]
</xsl:text>
<xsl:text>Compatibility=1.1 or later
Compiled file=</xsl:text><xsl:value-of select="$htmlhelp.chm"/><xsl:text>
Contents file=</xsl:text><xsl:value-of select="$htmlhelp.hhc"/><xsl:text>
Index file=</xsl:text><xsl:value-of select="$htmlhelp.hhk"/><xsl:text>
Default topic=_index.html
Default Window=phpdoc
Display compile progress=No
Full-text search=Yes
Language=</xsl:text>
<xsl:if test="//@lang">
  <xsl:variable name="lang" select="//@lang[1]"/>
  <xsl:value-of select="document('htmlhelp-codes.xml')//gentext[@lang=string($lang)]"/>
</xsl:if>
<xsl:if test="not(//@lang)">
  <xsl:text>0x0409 English (United States)</xsl:text>
</xsl:if>
<xsl:text>
Title=</xsl:text>
<xsl:variable name="htmlhelp.title">
  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:value-of select="normalize-space(key('id',$rootid)//title[1])"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="normalize-space(//title[1])"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:value-of select="$htmlhelp.title"/>
<xsl:text>

[WINDOWS]
phpdoc="</xsl:text>
<xsl:value-of select="$htmlhelp.title"/>
<xsl:text>","</xsl:text>
<xsl:value-of select="$htmlhelp.hhc"/>
<xsl:text>","</xsl:text>
<xsl:value-of select="$htmlhelp.hhk"/>
<xsl:text>","_index.html","_index.html",,,,,0x23520,,0x386e,,,,,,,,0

[MERGE FILES]
php_manual_notes.chm

[FILES]
_atw.gif
_body.gif
_code.gif
_function.html
_google.gif
_index.html
_masterheader.jpg
_note.gif
_pixel.gif
_script.js
_skin_hi.js
_skin_lo.js
_style_hi.css
_style_lo.css
_subheader.gif
_warning.gif
</xsl:text>

<xsl:choose>
  <xsl:when test="$rootid != ''">
    <xsl:apply-templates select="key('id',$rootid)" mode="enumerate-files"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates mode="enumerate-files"/>
  </xsl:otherwise>
</xsl:choose>

</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="set|book|part|preface|chapter|appendix
                     |article
                     |reference|refentry
                     |sect1|sect2|sect3|sect4|sect5
                     |section
                     |book/glossary|article/glossary
                     |book/bibliography|article/bibliography
                     |book/glossary|article/glossary
                     |colophon"
              mode="enumerate-files">
  <xsl:variable name="ischunk"><xsl:call-template name="chunk"/></xsl:variable>
  <xsl:if test="$ischunk='1'">
    <xsl:call-template name="make-relative-filename">
      <xsl:with-param name="base.dir" select="''"/>
      <xsl:with-param name="base.name">
        <xsl:apply-templates mode="chunk-filename" select="."/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
  </xsl:if>
  <xsl:apply-templates select="*" mode="enumerate-files"/>
</xsl:template>

<xsl:template match="text()" mode="enumerate-files">
</xsl:template>

<!-- ==================================================================== -->

<!-- Following templates are not nice. It is because MS help compiler is unable
     to process correct HTML files. We must generate following weird
     stuff instead. -->

<xsl:template name="hhc">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="concat($base.dir,$htmlhelp.hhc)"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:call-template name="hhc-main"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="hhc-main">
  <xsl:text>&lt;HTML&gt;
&lt;HEAD&gt;
&lt;/HEAD&gt;
&lt;BODY&gt;
&lt;OBJECT type="text/site properties"&gt;
        &lt;param name="Window Styles" value="0x800227"&gt;
&lt;/OBJECT&gt;
&lt;UL&gt;
</xsl:text>

  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:apply-templates select="key('id',$rootid)" mode="hhc"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="hhc"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text>&lt;/UL&gt;
&lt;/BODY&gt;
&lt;/HTML&gt;</xsl:text>
</xsl:template>

<xsl:template match="book" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="_index.html"&gt;
  &lt;/OBJECT&gt;</xsl:text>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:apply-templates select="part|reference|preface|chapter|bibliography|appendix|article|colophon"
                       mode="hhc"/>
</xsl:template>

<xsl:template match="part|reference|preface|chapter|bibliography|appendix|article"
              mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="reference|preface|chapter|appendix|refentry|section|sect1|bibliodiv">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates
        select="reference|preface|chapter|appendix|refentry|section|sect1|bibliodiv"
        mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="section" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="section[count(ancestor::section) &lt; $htmlhelp.hhc.section.depth]">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="section" mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect1" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="sect2[$htmlhelp.hhc.section.depth > 1]">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect2"
                           mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect2" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="sect3[$htmlhelp.hhc.section.depth > 2]">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect3"
                           mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect3" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="sect4[$htmlhelp.hhc.section.depth > 3]">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect4"
                           mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect4" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:if test="sect5[$htmlhelp.hhc.section.depth > 4]">
    <xsl:text>&lt;UL&gt;</xsl:text>
      <xsl:apply-templates select="sect5"
                           mode="hhc"/>
    <xsl:text>&lt;/UL&gt;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="sect5|refentry|colophon|bibliodiv" mode="hhc">
  <xsl:variable name="title">
    <xsl:if test="$htmlhelp.autolabel=1">
      <xsl:variable name="label.markup">
        <xsl:apply-templates select="." mode="label.markup"/>
      </xsl:variable>
      <xsl:if test="normalize-space($label.markup)">
        <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
</xsl:template>

<!-- ==================================================================== -->

<!-- Similar code to HHC, but quite modified for HHK generation -->

<!-- Following templates are not nice. It is because MS help compiler is unable
     to process correct HTML files. We must generate following weird
     stuff instead. -->

<xsl:template name="hhk">
  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" select="concat($base.dir,$htmlhelp.hhk)"/>
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:call-template name="hhk-main"/>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$htmlhelp.encoding"/>
  </xsl:call-template>
</xsl:template>

<xsl:template name="hhk-main">
  <xsl:text>&lt;HTML&gt;
&lt;HEAD&gt;
&lt;/HEAD&gt;
&lt;BODY&gt;
&lt;OBJECT type="text/site properties"&gt;
        &lt;param name="Window Styles" value="0x800227"&gt;
&lt;/OBJECT&gt;
&lt;UL&gt;
</xsl:text>

  <xsl:choose>
    <xsl:when test="$rootid != ''">
      <xsl:apply-templates select="key('id',$rootid)" mode="hhk"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="hhk"/>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text>&lt;/UL&gt;
&lt;/BODY&gt;
&lt;/HTML&gt;</xsl:text>
</xsl:template>

<xsl:template match="book" mode="hhk">
  <xsl:variable name="title">
    <xsl:apply-templates select="." mode="title.markup"/>
  </xsl:variable>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="_index.html"&gt;
  &lt;/OBJECT&gt;</xsl:text>

  <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
        <xsl:value-of select="normalize-space($title)"/>
    <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
        <xsl:call-template name="href.target"/>
    <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  <xsl:apply-templates select="part|reference|preface|chapter|bibliography|appendix|article|colophon"
                       mode="hhk"/>
</xsl:template>

<xsl:template match="part|preface|chapter|appendix
                     |article
                     |reference|refentry
                     |sect1|sect2|sect3|sect4|sect5
                     |section
                     |book/glossary|article/glossary
                     |book/bibliography|article/bibliography
                     |book/glossary|article/glossary
                     |colophon"
              mode="hhk">
  <xsl:variable name="ischunk"><xsl:call-template name="chunk"/></xsl:variable>
  <xsl:if test="$ischunk='1'">
    <xsl:variable name="title">
      <xsl:apply-templates select="." mode="title.markup"/>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:call-template name="make-relative-filename">
        <xsl:with-param name="base.dir" select="''"/>
        <xsl:with-param name="base.name">
          <xsl:apply-templates mode="chunk-filename" select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>&lt;LI&gt; &lt;OBJECT type="text/sitemap"&gt;
    &lt;param name="Name" value="</xsl:text>
          <xsl:value-of select="normalize-space($title)"/>
      <xsl:text>"&gt;
    &lt;param name="Local" value="</xsl:text>
          <xsl:value-of select="$filename"/>
      <xsl:text>"&gt;
  &lt;/OBJECT&gt;</xsl:text>
  </xsl:if>
  <xsl:apply-templates select="*" mode="hhk"/>
</xsl:template>

<xsl:template match="text()" mode="hhk"/>

</xsl:stylesheet>
