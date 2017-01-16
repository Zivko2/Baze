SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_FILLPAISARAMX] @arcodigo int    as

SET NOCOUNT ON 
--MX se refiere al pais de origen del arancel


EXEC SP_DROPTABLE 'PAISARATEMP'

SELECT ARANCEL.AR_CODIGO, MAESTRO.PA_ORIGEN AS PA_CODIGO, PAIS.SPI_CODIGO
INTO dbo.PAISARATEMP
FROM MAESTRO LEFT OUTER JOIN
    PAIS ON 
    MAESTRO.PA_ORIGEN = PAIS.PA_CODIGO RIGHT OUTER JOIN
    ARANCEL ON 
    MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO
WHERE AR_IMPMX=@arcodigo AND MAESTRO.PA_ORIGEN  NOT IN
(SELECT PA_CODIGO FROM PAISARA WHERE AR_CODIGO=@arcodigo)



INSERT INTO PAISARA(AR_CODIGO, PA_CODIGO, SPI_CODIGO, PAR_BEN)
SELECT AR_CODIGO, PA_CODIGO, SPI_CODIGO, -1
FROM PAISARATEMP
GROUP BY AR_CODIGO, PA_CODIGO, SPI_CODIGO


EXEC SP_DROPTABLE 'PAISARATEMP'






































GO
