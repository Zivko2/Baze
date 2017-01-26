SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_UPDATE_PEDABIERTO] (@chkgenerico3 int, @chkeqgen3 int, @chkarimpmx3 int, @chkporcenttasa3 int, @chkarexpusa3 int, @DtEntradaInicial datetime, @DtEntradaFinal datetime)   as

SET NOCOUNT ON 
BEGIN
	IF (@chkgenerico3 = 1)
		UPDATE dbo.PEDIMPDET
		SET  dbo.PEDIMPDET.MA_GENERICO = dbo.MAESTRO.MA_GENERICO 
		FROM         dbo.PEDIMP LEFT OUTER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.PEDIMP.PI_FEC_PAG >= @DtEntradaInicial AND dbo.PEDIMP.PI_FEC_PAG <= @DtEntradaFinal)
		and dbo.PEDIMP.pi_tipo ='A' and dbo.PEDIMP.PI_MOVIMIENTO='E'


	IF (@chkeqgen3 = 1)
		UPDATE dbo.PEDIMPDET
		SET  dbo.PEDIMPDET.EQ_GENERICO = dbo.MAESTRO.EQ_GEN  
		FROM         dbo.PEDIMP LEFT OUTER JOIN
             		         dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.PEDIMP.PI_FEC_PAG >= @DtEntradaInicial AND dbo.PEDIMP.PI_FEC_PAG <= @DtEntradaFinal)
		and dbo.PEDIMP.pi_tipo ='A' and dbo.PEDIMP.PI_MOVIMIENTO='E'

	IF (@chkarimpmx3 = 1)
		UPDATE dbo.PEDIMPDET
		SET dbo.PEDIMPDET.AR_IMPMX = dbo.MAESTRO.AR_IMPMX
		FROM         dbo.PEDIMP LEFT OUTER JOIN
             		         dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.PEDIMP.PI_FEC_PAG >= @DtEntradaInicial AND dbo.PEDIMP.PI_FEC_PAG <= @DtEntradaFinal)
		and dbo.PEDIMP.pi_tipo ='A' and dbo.PEDIMP.PI_MOVIMIENTO='E'

	IF (@chkporcenttasa3 = 1)
		UPDATE dbo.PEDIMPDET
		SET dbo.PEDIMPDET.PID_POR_DEF= dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, 
					isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
					isnull(dbo.MAESTRO.SPI_CODIGO,0))
		FROM         dbo.PEDIMP LEFT OUTER JOIN
             		         dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.PEDIMP.PI_FEC_PAG >= @DtEntradaInicial AND dbo.PEDIMP.PI_FEC_PAG <= @DtEntradaFinal)
		and dbo.PEDIMP.pi_tipo ='A' and dbo.PEDIMP.PI_MOVIMIENTO='E'

	IF (@chkarexpusa3 = 1)
		UPDATE dbo.PEDIMPDET
		SET dbo.PEDIMPDET.AR_EXPFO = dbo.MAESTRO.AR_EXPFO
		FROM         dbo.PEDIMP LEFT OUTER JOIN
             		         dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	             	         dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.PEDIMP.PI_FEC_PAG >= @DtEntradaInicial AND dbo.PEDIMP.PI_FEC_PAG <= @DtEntradaFinal)
		and dbo.PEDIMP.pi_tipo ='A' and dbo.PEDIMP.PI_MOVIMIENTO='E'


	
END

GO
