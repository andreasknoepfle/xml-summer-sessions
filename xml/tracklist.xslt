<xsl:stylesheet version='2.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
  <xsl:output method='xml'/>
    <xsl:template match="/track">
     <a><xsl:attribute name="href">/search_tracks/show?q=<xsl:value-of select="fileId"/></xsl:attribute> 
      	 <ul class="breadcrumb">
      	 <li>
      	
      	 <b>   <xsl:apply-templates select='title'/></b>  <span class="divider">/</span>
      	 </li>
      	 <li>
      	
         <b>Start: </b> <xsl:apply-templates select='startPointAddress'/>  <span class="divider">/</span>
          </li>
          <li>
        
         <b>Ende:</b> <xsl:apply-templates select='endPointAddress'/> 
         </li>
        
    	</ul>
    </a>
    </xsl:template>
</xsl:stylesheet>