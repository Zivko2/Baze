SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































/* actualiza el valor en aduana de todos los pedimentos*/
CREATE PROCEDURE [dbo].[SP_ACTUALIZAVALORADUANA]   as



		UPDATE dbo.PEDIMPDET
	SET     PID_COS_UNIADU= round(round(round(PID_CTOT_DLS * pedimp.PI_TIP_CAM ,0)/isnull(PID_CANT,0),6)/EQ_GENERICO,6),
	PID_VAL_ADU= round(PID_CTOT_DLS * pedimp.PI_TIP_CAM ,0)
	FROM         dbo.PEDIMPDET INNER JOIN
	                      dbo.PEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
	WHERE     (dbo.PEDIMPDET.PID_CANT > 0) AND (dbo.PEDIMPDET.PID_CTOT_DLS > 0) AND (dbo.PEDIMPDET.PID_IMPRIMIR = 'S')
	and PID_COS_UNIADU- round(round(PID_CTOT_DLS * pedimp.PI_TIP_CAM ,0)/isnull(PID_CANT,0),6)/EQ_GENERICO >1
































GO
