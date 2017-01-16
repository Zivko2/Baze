SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























CREATE PROCEDURE [dbo].[SP_ACTUALIZATASAPEDIMP]  (@PI_codigo int)   as

SET NOCOUNT ON 

declare @PID_indiced int

	UPDATE PEDIMPDET
	SET     PEDIMPDET.PID_SEC_IMP= (SELECT SE_CODIGO FROM CONFIGURACION)
	FROM         PEDIMPDET
	WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND (PEDIMPDET.PID_SEC_IMP = 0 OR
	                      PEDIMPDET.PID_SEC_IMP IS NULL) AND (PEDIMPDET.PI_CODIGO = @PI_codigo)

	UPDATE PEDIMPDET
	SET     PEDIMPDET.PID_SEC_IMP= MAESTRO.MA_SEC_IMP
	FROM         PEDIMPDET INNER JOIN
	                      MAESTRO ON PEDIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (PEDIMPDET.PID_DEF_TIP = 'S') AND (PEDIMPDET.PID_SEC_IMP = 0 OR
	                      PEDIMPDET.PID_SEC_IMP IS NULL) AND (MAESTRO.MA_SEC_IMP > 0) AND (PEDIMPDET.PI_CODIGO = @PI_codigo)
	

	UPDATE PEDIMPDET
	SET PID_POR_DEF=dbo.GetAdvalorem(PEDIMPDET.AR_IMPMX, PEDIMPDET.PA_ORIGEN, PEDIMPDET.PID_DEF_TIP, PEDIMPDET.PID_SEC_IMP, PEDIMPDET.SPI_CODIGO)
	WHERE PEDIMPDET.PI_CODIGO = @PI_codigo	

	if (SELECT CF_SINGENERICOUM FROM CONFIGURACION)='S'
	and exists (SELECT MA_GENERICO FROM PEDIMPDET WHERE MA_GENERICO = 0 AND PI_CODIGO = @PI_codigo AND AR_IMPMX > 0)
	begin
		EXEC SP_ADDGENERICOS
	
		UPDATE PEDIMPDET
		SET     PEDIMPDET.MA_GENERICO= MAESTRO.MA_GENERICO, PEDIMPDET.EQ_GENERICO= MAESTRO.EQ_GEN, PEDIMPDET.ME_GENERICO= 
		                      MAESTRO_1.ME_COM
		FROM         MAESTRO INNER JOIN
		                      PEDIMPDET ON MAESTRO.MA_CODIGO = PEDIMPDET.MA_CODIGO AND 
		                      MAESTRO.MA_GENERICO <> PEDIMPDET.MA_GENERICO INNER JOIN
		                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE     (PEDIMPDET.PI_CODIGO = @PI_codigo)
	end























GO
