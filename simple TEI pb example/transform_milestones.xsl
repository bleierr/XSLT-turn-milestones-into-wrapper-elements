<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="1.0">
    <xsl:template match="/">
        <html>
            <body>
                <xsl:for-each select="//tei:pb">
                    <!-- loops over all pb elements and turns them into div@class=page_wrapper 
                         the current pb node is then passed to the processNextNode template
                         if the current pb node is the last pb, templates will be applied to its following siblings, and processing ends
                    -->
                    <div>
                        <xsl:attribute name="id">
                            <xsl:text>page</xsl:text>
                            <xsl:value-of select="@n"></xsl:value-of>
                        </xsl:attribute>
                        <xsl:attribute name="class">page_wrapper</xsl:attribute>
                        
                        <xsl:choose>
                            <xsl:when test="position() = last()">
                                <xsl:apply-templates select="following-sibling::node()"></xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="processNextNode">
                                    <xsl:with-param name="Node" select="."/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    
    
    <xsl:template name="processNextNode">
        <!-- this template takes node as input and processes its next following sibling     
        -->
        <xsl:param name="Node"/>
        <xsl:variable name="nextNode" select="$Node/following-sibling::node()[1]"/>
        
        <xsl:choose>
            <xsl:when test="$nextNode/descendant-or-self::tei:pb">
                <!-- if next node contains a pb as child go to foundPb template -->
                <xsl:call-template name="foundPb">
                    <xsl:with-param name="Node" select="$nextNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="not($nextNode)">
                        <!-- no next node - pass parent to processNextNode -->
                        <xsl:call-template name="processNextNode">
                            <xsl:with-param name="Node" select="$Node/parent::node()"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--  apply templates of next node and pass next node to processNextNode-->
                        <xsl:apply-templates select="$nextNode"/>
                        <xsl:call-template name="processNextNode">
                            <xsl:with-param name="Node" select="$nextNode"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="foundPb">
        <xsl:param name="Node"/>
        <!-- choose the first child node of the node passed to this template -->
        <xsl:variable name="childNode" select="$Node/child::node()[1]"></xsl:variable>
        
        <xsl:choose>
            <xsl:when test="local-name($Node) = 'pb'">
                <!-- if node is pb finish -->
                
            </xsl:when>
            <xsl:when test="$Node//tei:pb">
                <xsl:call-template name="foundPb">
                    <xsl:with-param name="Node" select="$childNode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$Node"></xsl:apply-templates>
                <xsl:call-template name="processNextNode">
                    <xsl:with-param name="Node" select="$Node"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    
    
    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates></xsl:apply-templates>
        </p>
    </xsl:template>
    
    
    
</xsl:stylesheet>