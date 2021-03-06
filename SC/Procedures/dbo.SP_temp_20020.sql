SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[SP_temp_20020]   as



		UPDATE FACTEXP
	SET   FACTEXP.TF_CODIGO=(SELECT TF_CODIGO FROM TFACTURA WHERE TF_NOMBRE = 'EXPORTACION DEFINITIVA')
	FROM  FACTEXP INNER JOIN PEDIMP ON FACTEXP.PI_CODIGO = PEDIMP.PI_CODIGO INNER JOIN
	      CLAVEPED ON PEDIMP.CP_CODIGO = CLAVEPED.CP_CODIGO
	WHERE     (CLAVEPED.CP_CLAVE = 'A1') AND
	FACTEXP.TF_CODIGO IN
		(SELECT TF_CODIGO FROM  TFACTURA WHERE TF_NOMBRE = 'EXPORTACION MAQUILA')



	UPDATE AVISOTRASLADODET
	SET     AVISOTRASLADODET.ATID_TIP_ENS= replace(replace(replace(MAESTRO.MA_TIP_ENS, 'A', 'C'), 'E', 'C'), 'P', 'C') 
	FROM         AVISOTRASLADODET INNER JOIN
	                      MAESTRO ON AVISOTRASLADODET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE AVISOTRASLADODET.ATID_TIP_ENS IS NULL


	UPDATE AVISOTRASLADODET
	SET     AVISOTRASLADODET.ATID_FECHA_STRUCT= AVISOTRASLADO.ATI_FECHAEMISION
	FROM         AVISOTRASLADODET INNER JOIN
	                      AVISOTRASLADO ON AVISOTRASLADODET.ATI_CODIGO = AVISOTRASLADO.ATI_CODIGO
	WHERE  AVISOTRASLADODET.ATID_FECHA_STRUCT IS NULL



GO
