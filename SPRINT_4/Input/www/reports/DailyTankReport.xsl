<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>
<xsl:variable name="strings" select="document('DailyTankReport_Strings.xml')/DailyTankReport/StaticText"/>

<!-- get culture specific number formats -->
<xsl:param name="Volume_Format_String" select="$strings/Volume_Format_String"/>
<xsl:param name="Percent_Format_String" select="$strings/Percent_Format_String"/>
<xsl:param name="Decimal_Separator" select="$strings/Decimal_Separator"/>
<xsl:param name="Number_Group_Separator" select="$strings/Number_Group_Separator"/>

<!-- literals for single and double quotes if you need them -->
<xsl:variable name="d-quote">&#34;</xsl:variable>
<xsl:variable name="s-quote">&#39;</xsl:variable>

<!-- format declarations -->
<xsl:param name ="volumeFormat">
  <xsl:choose>
	<xsl:when test="$Decimal_Separator = '.'"> 
	  <xsl:choose>
		<xsl:when test="$Number_Group_Separator=','">
		  <xsl:text>volumeFormat1</xsl:text>
		</xsl:when>
		<xsl:when test="$Number_Group_Separator=' '">
		  <xsl:text>volumeFormat2</xsl:text>
		</xsl:when>
		<xsl:when test="$Number_Group_Separator= $s-quote">
		  <xsl:text>volumeFormat3</xsl:text>
		</xsl:when>
        <xsl:otherwise>
		  <xsl:text>volumeFormat1</xsl:text>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="$Decimal_Separator = ','">
	  <xsl:choose>
		<xsl:when test="$Number_Group_Separator = '.'">
		  <xsl:text>volumeFormat4</xsl:text>
		</xsl:when>
		<xsl:when test="$Number_Group_Separator = ' '">
		  <xsl:text>volumeFormat5</xsl:text>
		</xsl:when>
		<xsl:when test="$Number_Group_Separator = $s-quote">
		  <xsl:text>volumeFormat6</xsl:text>
		</xsl:when>
        <xsl:otherwise>
		  <xsl:text>volumeFormat1</xsl:text>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
  </xsl:choose>
</xsl:param>

<!-- select which percent format fits the required separators -->
<xsl:param name ="percentFormat">
  <xsl:choose>
	<xsl:when test="$Decimal_Separator = '.'">
	  <xsl:text>percentFormat1</xsl:text>
	</xsl:when>
	<xsl:when test="$Decimal_Separator = ','">
	  <xsl:text>percentFormat2</xsl:text>
 	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>percentFormat1</xsl:text>
	</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:decimal-format name="volumeFormat1" decimal-separator="." grouping-separator="," NaN="-"/>
<xsl:decimal-format name="volumeFormat2" decimal-separator="." grouping-separator=" " NaN="-"/>
<xsl:decimal-format name="volumeFormat3" decimal-separator="." grouping-separator="'" NaN="-"/>
<xsl:decimal-format name="volumeFormat4" decimal-separator="," grouping-separator="." NaN="-"/>
<xsl:decimal-format name="volumeFormat5" decimal-separator="," grouping-separator=" " NaN="-"/>
<xsl:decimal-format name="volumeFormat6" decimal-separator="," grouping-separator="'" NaN="-"/>
<xsl:decimal-format name="percentFormat1" decimal-separator="." grouping-separator="," NaN="-"/>
<xsl:decimal-format name="percentFormat2" decimal-separator="," grouping-separator="." NaN="-"/>

<xsl:template match="/">
  <HTML>
	<HEAD>
	  <TITLE>PeriodID: <xsl:value-of select="/DailyTankReport/DailyTotals[1]/Period_ID"/></TITLE>
	</HEAD>
	<BODY>
	  <h3><xsl:value-of select="$strings/Title"/></h3>
	  <p><xsl:value-of select="$strings/OpenDate"/>: <xsl:value-of select="/DailyTankReport/DailyTotals[1]/Open_Date_Locale"/><br/>
	  <xsl:value-of select="$strings/CloseDate"/>: <xsl:value-of select="/DailyTankReport/DailyTotals[1]/Close_Date_Locale"/><br/>
	  <xsl:value-of select="$strings/Period"/>: <xsl:value-of select="/DailyTankReport/DailyTotals[1]/Period_ID"/></p>
	  <table>	     
		<!-- Tank Header -->	       
		<th><xsl:value-of select="$strings/Tank"/><xsl:value-of select="$strings/Number"/></th>
		<xsl:for-each select="//DailyTankReport/DailyTotals">
		  <th>
			<xsl:attribute name="style">
			  <xsl:choose>
				<xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				<xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				<xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				<xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				<xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				<xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				<xsl:otherwise>
				  <xsl:choose>
					<xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					<xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
				  </xsl:choose>
				</xsl:otherwise>
			  </xsl:choose>
			</xsl:attribute>
		  <xsl:value-of select="$strings/Tank"/>-<xsl:value-of select="Tank_Number"/><br></br>(<xsl:value-of select="normalize-space(Tank_Name)"/>)</th>
		</xsl:for-each>
		<!-- Group -->	       
		<tr>
		  <td><b><xsl:value-of select="$strings/LinkedTo"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:value-of select="Group_Str"/>
			</td>
		  </xsl:for-each>
		</tr>		
		<!-- Product Name -->	       
		<tr>
		  <td><b><xsl:value-of select="$strings/Product"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:value-of select="Grade_Name"/>
			</td>
		  </xsl:for-each>
		</tr>		
		<!-- Capacity -->	       
		<tr>
		  <td><b><xsl:value-of select="$strings/Capacity"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>					
			  <xsl:value-of select="format-number(Capacity,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Line break -->	       
		<tr>
		  <td><b>------------------------</b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>		
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			------------------------</td>
		  </xsl:for-each>
		</tr>
		<!-- Initial Stock-->	       
		<tr>
		  <td><b><xsl:value-of select="$strings/InitialStock"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>					
			  <xsl:value-of select="format-number(Open_DipStock,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Deliveries-->	       
		<tr>
		  <td><b>+ <xsl:value-of select="$strings/Deliveries"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>					
			  <xsl:value-of select="format-number(Delivery,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Transfers -->	       
		<tr>
		  <td><b>- <xsl:value-of select="$strings/Transfers"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:choose>
				<xsl:when test="Transfer_In>0">
				  +<xsl:value-of select="format-number(Transfer_In,$Volume_Format_String,$volumeFormat)"/>
				</xsl:when>
				<xsl:when test="Transfer_Out>0">
				  -<xsl:value-of select="format-number(Transfer_Out,$Volume_Format_String,$volumeFormat)"/>
				</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			  </xsl:choose>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- SubTotal -->	       
		<tr>
		  <td><b><xsl:value-of select="$strings/SubTotal"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>					
			  <xsl:value-of select="format-number(SubTotal_Book_Stock,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>		
		<!-- PumpUse -->	       
		<tr>
		  <td><b>- <xsl:value-of select="$strings/PumpUse"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>					
			  <xsl:value-of select="format-number(PumpUse_By_Deliveries,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>				
		<!-- Book Stock -->	       
		<tr>
		  <td><b>= <xsl:value-of select="$strings/BookStock"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<xsl:choose>				     
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>		
					  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose></xsl:otherwise>			      
					</xsl:choose>
				  </xsl:attribute>
			      <xsl:value-of select="format-number(Group_Computed_Book_Stock,$Volume_Format_String,$volumeFormat)"/>
		      	</td>
			  </xsl:when>
			  <xsl:when test="Group_Members=-1">
			  </xsl:when>
			  <xsl:otherwise>
				<td>
				  <xsl:attribute name="style">
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
				  <xsl:value-of select="format-number(Computed_Book_Stock,$Volume_Format_String,$volumeFormat)"/>
				</td>
			  </xsl:otherwise>
			  <!-- A strapped child tank? then no column -->
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>
		<!-- Line break -->	       
		<tr>
		  <td><b>------------------------</b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			------------------------</td>
		  </xsl:for-each>
		</tr>
		<!-- Dip Stock -->
		<tr>
		  <td><b><xsl:value-of select="$strings/DipStock"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:value-of select="format-number(Close_DipStock,$Volume_Format_String,$volumeFormat)"/>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Line break -->	       
		<tr>
		  <td><b>------------------------</b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			------------------------</td>
		  </xsl:for-each>
		</tr>
		<!-- Variance -->
		<tr>
		  <td><b><xsl:value-of select="$strings/Variance"/>:</b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			</td>
		  </xsl:for-each>
		</tr>		
		<!-- Variance by Volume -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByVolume"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<xsl:choose>				     
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
			      <xsl:value-of select="format-number(Group_Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
		      	</td>
			  </xsl:when>
			  <xsl:when test="Group_Members=-1"></xsl:when>
			  <xsl:otherwise>
				<td>
				  <xsl:attribute name="style">
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
				  <xsl:value-of select="format-number(Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
				</td>
			  </xsl:otherwise>			          
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>	
		<!-- Variance by Percentage -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByPercentage"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<xsl:choose>				     
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>
					  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
				  <xsl:choose>				      
					<xsl:when test="Group_Variance_Status=1">++++++++++</xsl:when>
					<xsl:when test="Group_Variance_Status=-1">----------</xsl:when>
					<xsl:otherwise><xsl:value-of select="format-number(Group_Variance_Percentage,$Percent_Format_String,$percentFormat)"/></xsl:otherwise>
				  </xsl:choose>
		      	</td>
			  </xsl:when>
			  <xsl:when test="Group_Members=-1"></xsl:when>
			  <xsl:otherwise>
				<td>
				  <xsl:attribute name="style">
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
				  <!-- this does not do the same as the v3 report which shows the percentage if within tolerance OR indicators if over or under outside tolerance -->
				  <xsl:choose>
					<xsl:when test="Variance_Status=1">++++++++++</xsl:when>
					<xsl:when test="Variance_Status=-1">----------</xsl:when>
					<xsl:otherwise><xsl:value-of select="format-number(Variance_Percentage,$Percent_Format_String,$percentFormat)"/></xsl:otherwise>
				  </xsl:choose>
			  </td></xsl:otherwise>
			</xsl:choose>				      
			
		  </xsl:for-each>
		</tr>	
		<!-- Variance Reason -->	       
		<tr>
		</tr>
		<tr>
		  <td><b><xsl:value-of select="$strings/VarianceReasons"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			____________________</td>
		  </xsl:for-each>
		</tr>				
		<tr>
		  <td>5 <xsl:value-of select="$strings/DayVariance"/><br></br>
		  <xsl:value-of select="/DailyTankReport/Period_Close[1]/First5DayClose"/> to <br></br>
		  <xsl:value-of select="/DailyTankReport/Period_Close[1]/Last5DayClose"/>
		  </td>	
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Variance by Volume -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByVolume"/></b></td>
		  <xsl:for-each select="//DailyTankReport/FiveDayTotals">
			<xsl:choose>
			  <!-- A strapped parent tank? then apply colspan and style -->
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>					
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>
					</xsl:choose>
				  </xsl:attribute>
				  <!-- group field to display -->			
				  <xsl:value-of select="format-number(Group_Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
		      	</td>
				<!-- A strapped child tank? then no column -->
				</xsl:when><xsl:when test="Group_Members=-1"></xsl:when>
				<!-- unstrapped tank? -->
				<xsl:otherwise>
				  <td>
					<xsl:attribute name="style">
					  <xsl:choose>
						<xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						<xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					  </xsl:choose>
					</xsl:attribute>           
					<xsl:value-of select="format-number(Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
				  </td>
				</xsl:otherwise>			          
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>			
		<!-- Variance by Percentage -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByPercentage"/></b></td>
		  <xsl:for-each select="//DailyTankReport/FiveDayTotals">
			<xsl:choose>
			  <!-- A strapped parent tank? then apply colspan and style -->
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
					<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>				      
					  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>			      
					</xsl:choose>
				  </xsl:attribute>			
				  <xsl:choose>				      
					<xsl:when test="Group_Variance_Status=1">++++++++++</xsl:when>
					<xsl:when test="Group_Variance_Status=-1">----------</xsl:when>
					<xsl:otherwise><xsl:value-of select="format-number(Group_Variance_Percentage,$Percent_Format_String,$percentFormat)"/></xsl:otherwise>
				  </xsl:choose>
				</td>
				<!-- A strapped child tank? then no column -->
				</xsl:when><xsl:when test="Group_Members=-1"></xsl:when>
				<!-- unstrapped tank? -->
				<xsl:otherwise>
				  <td>
					<xsl:attribute name="style">
					  <xsl:choose>
						<xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						<xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					  </xsl:choose>
					</xsl:attribute>           
					<xsl:value-of select="format-number(Variance_Percentage,$Percent_Format_String,$percentFormat)"/>
				  </td>
				</xsl:otherwise>			          
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>	
		
		<tr>
		  <td>30 <xsl:value-of select="$strings/DayVariance"/><br></br>
		  <xsl:value-of select="/DailyTankReport/Period_Close[1]/First30DayClose"/> to <br></br>
		  <xsl:value-of select="/DailyTankReport/Period_Close[1]/Last30DayClose"/>				
		  </td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>				      
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			</td>
		  </xsl:for-each>
		</tr>
		<!-- Variance by Volume -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByVolume"/></b></td>
		  <xsl:for-each select="//DailyTankReport/ThirtyDayTotals">
			<xsl:choose>
			  <!-- A strapped parent tank? then apply colspan and style -->
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>				      
					  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>			      
					</xsl:choose>
				  </xsl:attribute>
				  <!-- group field to display -->			
				  <xsl:value-of select="format-number(Group_Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
		      	</td>
				<!-- A strapped child tank? then no column -->
				</xsl:when><xsl:when test="Group_Members=-1"></xsl:when>
				<!-- unstrapped tank? -->
				<xsl:otherwise>
				  <td>
					<xsl:attribute name="style">
					  <xsl:choose>
						<xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						<xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					  </xsl:choose>
					</xsl:attribute>           
					<xsl:value-of select="format-number(Variance_Volume,$Volume_Format_String,$volumeFormat)"/>
				</td></xsl:otherwise>			          
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>			
		<!-- Variance by Percentage -->
		<tr>
		  <td>&#160;&#160;<b><xsl:value-of select="$strings/ByPercentage"/></b></td>
		  <xsl:for-each select="//DailyTankReport/ThirtyDayTotals">
			<xsl:choose>
			  <!-- A strapped parent tank? then apply colspan and style -->
			  <xsl:when test="Group_Members>0">
				<td>
				  <xsl:attribute name="colspan">
			      	<xsl:value-of select="Group_Members"/>
				  </xsl:attribute>
				  <xsl:attribute name="style">
					<xsl:choose>				      
					  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
					  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
					  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
					  <xsl:otherwise>
						<xsl:choose>
						  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
						</xsl:choose>
					  </xsl:otherwise>			      
					</xsl:choose>
				  </xsl:attribute>			
				  <xsl:choose>				      
					<xsl:when test="Group_Variance_Status=1">++++++++++</xsl:when>
					<xsl:when test="Group_Variance_Status=-1">----------</xsl:when>
					<xsl:otherwise><xsl:value-of select="format-number(Group_Variance_Percentage,$Percent_Format_String,$percentFormat)"/></xsl:otherwise>
				  </xsl:choose>
		      	</td>				
				<!-- A strapped child tank? then no column -->
				</xsl:when><xsl:when test="Group_Members=-1"></xsl:when>
				<!-- unstrapped tank? -->
				<xsl:otherwise>
				  <td>
					<xsl:attribute name="style">
					  <xsl:choose>
						<xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
						<xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					  </xsl:choose>
					</xsl:attribute>
					<xsl:choose>				      
					  <xsl:when test="Variance_Status=1">++++++++++</xsl:when>
					  <xsl:when test="Variance_Status=-1">----------</xsl:when>
					  <xsl:otherwise><xsl:value-of select="format-number(Variance_Percentage,$Percent_Format_String,$percentFormat)"/></xsl:otherwise>
					</xsl:choose>
				</td></xsl:otherwise>			          
			</xsl:choose>				      
		  </xsl:for-each>
		</tr>	
		<!-- Line break -->	       
		<tr>
		  <td><b>------------------------</b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			------------------------</td>
		  </xsl:for-each>
		</tr>
		<tr>
		  <td><b><xsl:value-of select="$strings/Deliveries"/></b></td>	
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			</td>
		  </xsl:for-each>
		</tr>
		<tr>
		  <td><b><xsl:value-of select="$strings/NoteNumber"/></b></td>
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<xsl:variable name="deliverynotetanknumber" select="Tank_ID"/>				
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:for-each select="//DailyTankReport/Tank_Deliveries">
				<xsl:choose>	
				  <!-- same tank -->
				  <xsl:when test="Tank_ID =$deliverynotetanknumber">
					<xsl:value-of select="Tank_Delivery_ID"/>:
					<xsl:value-of select="Original_Invoice_Number"/><br></br>
				  </xsl:when>
				  <!-- none -->
				  <xsl:otherwise></xsl:otherwise>
				</xsl:choose>						
			  </xsl:for-each>
			</td>
		  </xsl:for-each>
		</tr>
		<tr>
		  <td><b><xsl:value-of select="$strings/DeliveryVolume"/></b></td>	
		  <xsl:for-each select="//DailyTankReport/DailyTotals">
			<xsl:variable name="deliverynotetanknumber" select="Tank_ID"/>				
			<td>
			  <xsl:attribute name="style">
				<xsl:choose>
				  <xsl:when test="Group_ID=1">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=2">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=3">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:when test="Group_ID=4">text-align:right;background-color:#bcd5e5;</xsl:when>
				  <xsl:when test="Group_ID=5">text-align:right;background-color:#e5bcd5;</xsl:when>
				  <xsl:when test="Group_ID=6">text-align:right;background-color:#d5e5bc;</xsl:when>
				  <xsl:otherwise>
					<xsl:choose>
					  <xsl:when test="position() mod 2 = 1">text-align:right; background-color:#f0f0f0;</xsl:when>
					  <xsl:otherwise>text-align:right; background-color:white;</xsl:otherwise>
					</xsl:choose>
				  </xsl:otherwise>
				</xsl:choose>
			  </xsl:attribute>
			  <xsl:for-each select="//DailyTankReport/Tank_Deliveries">
				<xsl:choose>	
				  <!-- same tank -->
				  <xsl:when test="Tank_ID =$deliverynotetanknumber">
					<xsl:value-of select="format-number(Drop_Volume,Volume_Format_String,$volumeFormat)"/><br></br>
				  </xsl:when>
				  <!-- none -->
				  <xsl:otherwise></xsl:otherwise>
				</xsl:choose>						
			  </xsl:for-each>
			</td>
		  </xsl:for-each>			
		</tr>				
	  </table>
	  
	  <!-- Signature -->
	  <table>
		<th>		
		  <td width="10"></td>
		  <td></td>
		</th>
		<tr>
		  <td colspan="2"><p><xsl:value-of select="$strings/VarianceConfirmationText"/></p></td>
		</tr>
		<tr>
		  <td><xsl:value-of select="$strings/Signature"/>:</td>
		  <td>_____________________________</td>
		</tr>	
		<tr>
		  <td></td>
		  <td><b><xsl:value-of select="$strings/ApproversName"/></b></td>
		</tr>
	  </table>
	  <br>
	  </br>
	  <br>
	  </br>
	  
	  <i>
		<!-- Variance Table reference -->
		<table>
		  <th><xsl:value-of select="$strings/VarianceID"/></th>
		  <th><xsl:value-of select="$strings/VarianceDescription"/></th>
		  <xsl:for-each select="//DailyTankReport/Tank_Variance_Reason">
			<tr>
			  <td><xsl:value-of select="Reason_ID"/></td>
			  <td><xsl:value-of select="Reason_Description"/></td>
			</tr>
		  </xsl:for-each>
		</table>
	  </i>
	</BODY>	      
  </HTML>
</xsl:template>	 
</xsl:stylesheet>
