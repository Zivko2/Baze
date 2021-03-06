SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_ACTUALIZATASAFACTEXP]  (@fe_codigo int)   as

SET NOCOUNT ON 

declare @FED_indiced int

	--if not exists(select * from arancel where convert(varchar(11),AR_ULTMODIFTIGIE,101)= convert(varchar(11),getdate(),101))
	--exec SP_ACTUALIZAARANCELBASETIGIE



	-- actualiza tasas
	UPDATE FACTEXPDET  
	SET FACTEXPDET.FED_RATEIMPFO= dbo.GetAdvalorem(FACTEXPDET.AR_IMPFO, FACTEXPDET.PA_CODIGO, 'G', 0, 0)
	FROM  FACTEXPDET
	WHERE     FACTEXPDET.FE_CODIGO =@fe_codigo AND FACTEXPDET.FED_NAFTA='N'
	

	UPDATE FACTEXPDET  
	SET FACTEXPDET.FED_RATEIMPFO= 0
	FROM  FACTEXPDET 
	WHERE     FACTEXPDET.FE_CODIGO =@fe_codigo AND FACTEXPDET.FED_NAFTA='S'


	if (SELECT CF_SINGENERICOUM FROM CONFIGURACION)='S'
	and exists (SELECT MA_GENERICO FROM FACTEXPDET WHERE MA_GENERICO = 0 AND FE_CODIGO = @fe_codigo AND AR_IMPFO > 0)
	begin
		EXEC SP_ADDGENERICOS
	
		UPDATE FACTEXPDET
		SET     FACTEXPDET.MA_GENERICO= MAESTRO.MA_GENERICO, FACTEXPDET.EQ_GEN= MAESTRO.EQ_GEN, FACTEXPDET.ME_GENERICO= 
		                      MAESTRO_1.ME_COM
		FROM         MAESTRO INNER JOIN
		                      FACTEXPDET ON MAESTRO.MA_CODIGO = FACTEXPDET.MA_CODIGO AND 
		                      MAESTRO.MA_GENERICO <> FACTEXPDET.MA_GENERICO INNER JOIN
		                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE     (FACTEXPDET.FE_CODIGO = @fe_codigo)
	end

	EXEC SP_ACTUALIZAEQARAFACTEXP @FE_codigo
/*
	UPDATE MAESTRO
	SET     MAESTRO.AR_IMPFO=FACTEXPDET.AR_IMPFO, MAESTRO.AR_EXPMX=FACTEXPDET.AR_EXPMX,
	                      MAESTRO.EQ_EXPMX=FACTEXPDET.EQ_EXPMX
	FROM         FACTEXPDET INNER JOIN
	                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (FACTEXPDET.FE_CODIGO =@FE_codigo)*/





















GO
