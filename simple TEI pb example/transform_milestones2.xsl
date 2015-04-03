<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        <html>
            <body>
                <xsl:for-each select="//tei:pb">
                    
                    <xsl:variable name="self" select="."></xsl:variable>
                    
                    <xsl:variable name="idx" select="index-of(//tei:pb/@n, ./@n)">
                    </xsl:variable>
                    
                    <xsl:variable name="nextPb" select="following::tei:pb[1]"/>
                    
                    <xsl:if test="$idx mod 2 = 1">
                                <xsl:call-template name="setUpPages">
                                    <xsl:with-param name="firstPb" select="."/>
                                    <xsl:with-param name="secondPb" select="$nextPb"/>
                                    <xsl:with-param name="Page">0</xsl:with-param>
                                </xsl:call-template>
                                
                                <xsl:if test="$nextPb">
                                    <xsl:call-template name="setUpPages">
                                        <xsl:with-param name="firstPb" select="."/>
                                        <xsl:with-param name="secondPb" select="$nextPb"/>
                                        <xsl:with-param name="Page">1</xsl:with-param>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:if>


                </xsl:for-each>
            </body>
        </html>
    </xsl:template>


    <xsl:template name="setUpPages">
        <xsl:param name="firstPb"/>
        <xsl:param name="secondPb"/>
        <xsl:param name="Page"/>

        <div>
            <xsl:attribute name="id">
                <xsl:text>page</xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>page_wrapper</xsl:text>
                <xsl:if test="$Page = '1'">
                    <xsl:text> grey_text</xsl:text>
                </xsl:if>
            </xsl:attribute>

            <xsl:call-template name="processNextNode">
                <xsl:with-param name="currentNode" select="$firstPb"/>
            </xsl:call-template>
        </div>
        <xsl:if test="$secondPb">
            <div>
                <xsl:attribute name="id">
                    <xsl:text>page</xsl:text>
                    <xsl:value-of select="@n+1"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>page_wrapper</xsl:text>
                <xsl:if test="$Page = '0'">
                    <xsl:text> grey_text</xsl:text>
                </xsl:if>
                </xsl:attribute>
    
    
                <xsl:call-template name="processNextNode">
                    <xsl:with-param name="currentNode" select="$secondPb"/>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="processNextNode">
       <xsl:param name="currentNode"/>
        <xsl:variable name="nextNode" select="$currentNode/following-sibling::node()[1]"/>

        <xsl:choose>
            <xsl:when test="$nextNode/descendant-or-self::tei:pb">
                <xsl:call-template name="foundPb">
                    <xsl:with-param name="currentNode" select="$nextNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="local-name($currentNode) = 'TEI'"></xsl:when>
                    <xsl:when test="not($nextNode)">
                        <xsl:call-template name="processNextNode">
                            <xsl:with-param name="currentNode" select="$currentNode/parent::node()"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$nextNode"/>
                        <xsl:call-template name="processNextNode">
                            <xsl:with-param name="currentNode" select="$nextNode"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="foundPb">
        <xsl:param name="currentNode"/>
        <xsl:param name="terminate_param"/>
        <!-- choose the first child node of the node passed to this template -->
        <xsl:variable name="childNode" select="$currentNode/child::node()[1]"/>

        <xsl:choose>
            <xsl:when test="local-name($currentNode) = 'pb'">
                <!-- if node is pb finish - if it is the last pb apply templates to the following elements -->
                <xsl:if test="$currentNode = tei:pb[not(following::tei:pb)]">
                    <xsl:apply-templates select="following::node()"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$currentNode//tei:pb">
                <xsl:call-template name="foundPb">
                    <xsl:with-param name="currentNode" select="$childNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$currentNode"/>
                <xsl:call-template name="processNextNode">
                    <xsl:with-param name="currentNode" select="$currentNode"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>



</xsl:stylesheet>
