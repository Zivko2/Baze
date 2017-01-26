SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE PROCEDURE [dbo].[SP_temp_13024]   as

/*
	UPDATE FACTEXP
	SET     FACTEXP.ET_CODIGO= ENTRYSUMDET.ET_CODIGO
	FROM         ENTRYSUMDET INNER JOIN
	                      FACTEXP ON ENTRYSUMDET.FE_CODIGO = FACTEXP.FE_CODIGO

*/

	UPDATE FASTDET
	SET     FSTD_UNE= CONVERT(VARCHAR(10),ET_CODIGO)+ FSTD_TIPOENTRY

	DELETE FROM FASTBARCODE
	WHERE FST_CODIGO NOT IN (SELECT FST_CODIGO FROM [FAST])

	UPDATE dbo.PEDIMPDET
	SET     PID_COS_UNIADU= round(round(round(PID_CTOT_DLS * pedimp.PI_TIP_CAM ,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,6)
	FROM         dbo.PEDIMPDET INNER JOIN
	                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
	WHERE     (dbo.PEDIMPDET.PID_CANT > 0) AND (dbo.PEDIMPDET.PID_CTOT_DLS > 0) AND (dbo.PEDIMPDET.PID_IMPRIMIR = 'S')
	and PID_COS_UNIADU- round(round(PID_CTOT_DLS * pedimp.PI_TIP_CAM ,0)/isnull(PID_CANT,0),6)/EQ_GENERICO >1

























GO
