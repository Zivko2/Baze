SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_13021]   as



		UPDATE IMPORTSPECDET
	SET     IMPORTSPECDET.IMD_AGRUP= IMPORTFIELDS.IMF_AGRUP
	FROM         IMPORTSPECDET INNER JOIN
	                      IMPORTFIELDS ON IMPORTSPECDET.IMF_CODIGO = IMPORTFIELDS.IMF_CODIGO
	WHERE IMPORTSPECDET.IMD_AGRUP IS NULL


	UPDATE    PEDIMP
	SET              ZO_CODIGO = 1
	WHERE     (ZO_CODIGO IS NULL)


	UPDATE PEDIMP
	SET MT_CODIGO=(SELECT MT_CODIGO FROM MEDIOTRAN
                            WHERE MT_CLA_PED = '7') , 
                     MT_ARRIBO=(SELECT MT_CODIGO FROM MEDIOTRAN
                            WHERE MT_CLA_PED = '7') , 
	        MT_SALIDA=(SELECT MT_CODIGO FROM MEDIOTRAN
                            WHERE MT_CLA_PED = '7')                        
	WHERE MT_CODIGO IS NULL



























GO
