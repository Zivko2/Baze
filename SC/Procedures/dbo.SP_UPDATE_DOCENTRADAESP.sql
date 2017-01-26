SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_UPDATE_DOCENTRADAESP] (@chkgenerico1 int, @chkeqgen1 int, @chkarimpmx1 int, @chkporcenttasa1 int, @chkarexpusa1 int, @DtEntradaInicial datetime, @DtEntradaFinal datetime, @ma_codigo int)   as

SET NOCOUNT ON 
declare @cf_descargabus char(1)
BEGIN


	select @cf_descargabus=CF_DESCARGASBUS from configuracion

	IF (@chkgenerico1 = 1)
	begin
		UPDATE dbo.FACTIMPDET
		SET  dbo.FACTIMPDET.MA_GENERICO = dbo.MAESTRO.MA_GENERICO 
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.MA_CODIGO=@ma_codigo

		if @cf_descargabus<>'G'
		begin
			-- pedimento normal						
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.MA_GENERICO= dbo.MAESTRO.MA_GENERICO, dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN, 
			                      dbo.PEDIMPDET.ME_GENERICO= MAESTRO_1.ME_COM
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

			-- pedimento r1
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.MA_GENERICO= dbo.MAESTRO.MA_GENERICO, dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN, 
			                      dbo.PEDIMPDET.ME_GENERICO= MAESTRO_1.ME_COM
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo
		end
		else
		begin
			-- pedimento normal
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.MA_GENERICO= dbo.MAESTRO.MA_GENERICO, dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN, 
			                      dbo.PEDIMPDET.ME_GENERICO= MAESTRO_1.ME_COM
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
			and dbo.PEDIMPDET.PI_CODIGO in (select pi_codigo from vpedimp where pi_estatus='N' or pi_estatus='S' or pi_estatus='T')
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

			-- pedimento r1
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.MA_GENERICO= dbo.MAESTRO.MA_GENERICO, dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN, 
			                      dbo.PEDIMPDET.ME_GENERICO= MAESTRO_1.ME_COM
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
			and dbo.PEDIMPDET.PI_CODIGO in (select pi_codigo from vpedimp where pi_estatus='N' or pi_estatus='S' or pi_estatus='T')
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo
		end
	end



	IF (@chkeqgen1 = 1)
	begin
		UPDATE dbo.FACTIMPDET
		SET  dbo.FACTIMPDET.EQ_GEN = dbo.MAESTRO.EQ_GEN  
		FROM         dbo.FACTIMP LEFT OUTER JOIN
             		         dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.MA_CODIGO=@ma_codigo


		if @cf_descargabus<>'G'
		begin
			-- pedimento normal						
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

			-- pedimento r1
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo
		end
		else
		begin
			-- pedimento normal
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
			and dbo.PEDIMPDET.PI_CODIGO in (select pi_codigo from vpedimp where pi_estatus='N' or pi_estatus='S' or pi_estatus='T')
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

			-- pedimento r1
			UPDATE dbo.PEDIMPDET
			SET     dbo.PEDIMPDET.EQ_GENERICO= dbo.MAESTRO.EQ_GEN
			FROM         dbo.PEDIMPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
			WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
			FROM         dbo.FACTIMP LEFT OUTER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
			WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
			and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
			and dbo.PEDIMPDET.PI_CODIGO in (select pi_codigo from vpedimp where pi_estatus='N' or pi_estatus='S' or pi_estatus='T')
			and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo
		end

	end



	IF (@chkarimpmx1 = 1)
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.AR_IMPMX = dbo.MAESTRO.AR_IMPMX
		FROM         dbo.FACTIMP LEFT OUTER JOIN
             		         dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.MA_CODIGO=@ma_codigo

		-- pedimento normal
		UPDATE dbo.PEDIMPDET
		SET     dbo.PEDIMPDET.AR_IMPMX= dbo.MAESTRO.AR_IMPMX
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

		-- pedimento r1
		UPDATE dbo.PEDIMPDET
		SET     dbo.PEDIMPDET.AR_IMPMX= dbo.MAESTRO.AR_IMPMX
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo


	end


	IF (@chkporcenttasa1 = 1)
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.FID_POR_DEF= dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
		 dbo.FACTIMPDET.FID_DEF_TIP= dbo.MAESTRO.MA_DEF_TIP,
		dbo.FACTIMPDET.FID_SEC_IMP= (SELECT 'FID_SEC_IMP'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='S' THEN  dbo.MAESTRO.MA_SEC_IMP ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),
		dbo.FACTIMPDET.SPI_CODIGO= (SELECT 'SPI_CODIGO'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='P' THEN  dbo.MAESTRO.SPI_CODIGO ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO)
		FROM         dbo.FACTIMP LEFT OUTER JOIN
             		         dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.MA_CODIGO=@ma_codigo



		-- pedimento normal
		UPDATE dbo.PEDIMPDET
		SET     dbo.PEDIMPDET.PID_POR_DEF= dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
		dbo.PEDIMPDET.PID_DEF_TIP= dbo.MAESTRO.MA_DEF_TIP,
		dbo.PEDIMPDET.PID_SEC_IMP= (SELECT 'PID_SEC_IMP'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='S' THEN  dbo.MAESTRO.MA_SEC_IMP ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),
		dbo.PEDIMPDET.SPI_CODIGO= (SELECT 'SPI_CODIGO'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='P' THEN  dbo.MAESTRO.SPI_CODIGO ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO)
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

		-- pedimento r1
		UPDATE dbo.PEDIMPDET
		SET dbo.PEDIMPDET.PID_POR_DEF= dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
		dbo.PEDIMPDET.PID_DEF_TIP= dbo.MAESTRO.MA_DEF_TIP,
		dbo.PEDIMPDET.PID_SEC_IMP= (SELECT 'PID_SEC_IMP'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='S' THEN  dbo.MAESTRO.MA_SEC_IMP ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),
		dbo.PEDIMPDET.SPI_CODIGO= (SELECT 'SPI_CODIGO'= CASE WHEN dbo.MAESTRO.MA_DEF_TIP='P' THEN  dbo.MAESTRO.SPI_CODIGO ELSE 0 END
		FROM MAESTRO WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO)
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo


	end

	IF (@chkarexpusa1 = 1)
	begin
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.AR_EXPFO = dbo.MAESTRO.AR_EXPFO
		FROM         dbo.FACTIMP LEFT OUTER JOIN
             		         dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	             	         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.MA_CODIGO=@ma_codigo

		-- pedimento normal
		UPDATE dbo.PEDIMPDET
		SET     dbo.PEDIMPDET.AR_EXPFO= dbo.MAESTRO.AR_EXPFO
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGA
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and dbo.FACTIMPDET.PID_INDICEDLIGA is not null and dbo.FACTIMPDET.PID_INDICEDLIGA<>-1
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is null or dbo.FACTIMPDET.PID_INDICEDLIGAR1=-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo

		-- pedimento r1
		UPDATE dbo.PEDIMPDET
		SET     dbo.PEDIMPDET.AR_EXPFO= dbo.MAESTRO.AR_EXPFO
		FROM         dbo.PEDIMPDET INNER JOIN
		                      dbo.MAESTRO ON dbo.PEDIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_CONSTA = MAESTRO_1.MA_NOPARTE
		WHERE dbo.PEDIMPDET.PID_INDICED in (SELECT  dbo.FACTIMPDET.PID_INDICEDLIGAR1
		FROM         dbo.FACTIMP LEFT OUTER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
             		         dbo.MAESTRO ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= @DtEntradaInicial AND dbo.FACTIMP.FI_FECHA <= @DtEntradaFinal)
		and (dbo.FACTIMPDET.PID_INDICEDLIGAR1 is not null and dbo.FACTIMPDET.PID_INDICEDLIGAR1<>-1))
		and dbo.PEDIMPDET.MA_CODIGO=@ma_codigo
	end



	
END



GO
