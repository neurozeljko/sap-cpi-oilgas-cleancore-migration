<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    
    <!-- Kopira sve postojece elemente i atribute -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Clean Core transformacija za Oil & Gas: preimenovanje starih nasleđenih tagova -->
    <xsl:template match="LegacyPlantID">
        <PlantID><xsl:apply-templates select="@*|node()"/></PlantID>
    </xsl:template>
    
    <xsl:template match="LegacyFuelVolume">
        <FuelVolume><xsl:apply-templates select="@*|node()"/></FuelVolume>
    </xsl:template>
</xsl:stylesheet>
