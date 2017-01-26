SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_generamovconcilia]   as

DECLARE @FECHAHOY datetime, @PR_CODIGO int, @DI_PROVEE int, @DI_DESTINO int, @CONSECUTIVO int, 
@CONSECUTIVO2 int, @RC_FOLIO varchar(25), @MA_CODIGO int, @RCD_NOPARTE varchar(30),
@ALM_CODIGO int, @RCD_NOMBRE varchar(150), @RCD_COS_UNI decimal(38,6), @ME_ALM int,
@CAN_GEN decimal(38,6), @RCD_NAME varchar(150), @RCD_CANT decimal(38,6), @MA_GENERICO int, @ME_CODIGO int,
@RCD_COS_TOT decimal(38,6), @EQ_ALM decimal(28,14), @IVF_TIPOENTSAL CHAR(1)

/*	set @FECHAHOY = convert(datetime, convert(varchar(11), getdate(),101))

	if exists(select * from #INVENTAFIS where tipo='R')
	begin
		if not exists (select * from entsalalm where en_folio=convert(varchar(10),@FECHAHOY)+' AJUSTE RESTA')

		begin

			select @PR_CODIGO=CL_MATRIZ from cliente where CL_CODIGO=1

			SELECT     @DI_PROVEE= DI_INDICE
			FROM         dbo.DIR_CLIENTE
			WHERE     (DI_FISCAL = 'S') AND (CL_CODIGO = @PR_CODIGO)

			SELECT     @DI_DESTINO= DI_INDICE
			FROM         dbo.DIR_CLIENTE
			WHERE     (DI_FISCAL = 'S') AND (CL_CODIGO = 1)

			SELECT @CONSECUTIVO=ISNULL(MAX(EN_CODIGO),0) FROM ENTSALALM
			SET @CONSECUTIVO=@CONSECUTIVO+1

			SET @RC_FOLIO=convert(varchar(10),@FECHAHOY)+' AJUSTE RESTA'

			INSERT INTO ENTSALALM(EN_CODIGO, EN_FOLIO, EN_FECHA, TM_CODIGO, PR_CODIGO,
			DI_PROVEE, CL_DESTINO, DI_DESTINO, EN_TIPO, ALM_ORIGEN)

			SELECT @CONSECUTIVO, @RC_FOLIO, @FECHAHOY, 11, @PR_CODIGO,
				@DI_PROVEE, 1, @DI_DESTINO, 'S', ALM_CODIGO
			FROM         #INVENTAFIS
			WHERE     (TIPO='R')
			GROUP BY ALM_CODIGO


			if exists (select ivf_codigo from #INVENTAFIS where ivf_codigo<>-1 and tipo='R')
			insert into kardesalmacendet (ivf_codigo, en_codigo)
			select ivf_codigo, @CONSECUTIVO from #INVENTAFIS where ivf_codigo<>-1 and tipo='R'
			and @CONSECUTIVO not in (select en_codigo from kardesalmacendet)
			group by ivf_codigo
		
		end


			declare cur_AjusteDetResta cursor for
				SELECT     MA_CODIGO, CAN_GEN, IVF_TIPOENTSAL
				FROM         #INVENTAFIS
				WHERE     (TIPO='R')
			open cur_AjusteDetResta
			FETCH NEXT FROM cur_AjusteDetResta INTO @MA_CODIGO, @CAN_GEN, @IVF_TIPOENTSAL
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

			SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
			SET @CONSECUTIVO2=@CONSECUTIVO2+1
	
	
			SELECT @RCD_NOPARTE=MA_NOPARTE, @RCD_NOMBRE=MA_NOMBRE, @RCD_NAME=MA_NAME, @RCD_CANT=@CAN_GEN/EQ_GEN, 
			@ME_CODIGO=ME_COM, @EQ_ALM=EQ_GEN
			FROM MAESTRO WHERE MA_CODIGO=@MA_CODIGO

			SELECT @RCD_COS_UNI=MA_COSTO, @RCD_COS_TOT=MA_COSTO*@RCD_CANT FROM MAESTROCOST WHERE MA_CODIGO=@MA_CODIGO
			SELECT @ME_ALM=ME_COM FROM MAESTRO WHERE MA_CODIGO=@MA_GENERICO

				INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
				END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, EQ_ALM, END_CANTEMP, END_TIPOENTSAL)
		
				values ( @CONSECUTIVO2, @CONSECUTIVO, @MA_CODIGO, @RCD_NOPARTE, @RCD_NOMBRE, @RCD_NAME, @RCD_CANT, 
				@RCD_COS_UNI, @RCD_COS_TOT, @CAN_GEN, @ME_CODIGO, @ME_ALM, @EQ_ALM, 0, @IVF_TIPOENTSAL)

			FETCH NEXT FROM cur_AjusteDetResta INTO @MA_CODIGO, @CAN_GEN, @IVF_TIPOENTSAL
			END
		CLOSE cur_AjusteDetResta
		DEALLOCATE cur_AjusteDetResta


		exec sp_descarga_entsalalm @CONSECUTIVO
	end




--================= SUMA ===================

	if exists(select * from #INVENTAFIS where tipo='S')
	begin
		if not exists (select * from entsalalm where en_folio=convert(varchar(10),@FECHAHOY)+' AJUSTE SUMA')
		begin

			select @PR_CODIGO=CL_MATRIZ from cliente where CL_CODIGO=1

			SELECT     @DI_PROVEE= DI_INDICE
			FROM         dbo.DIR_CLIENTE
			WHERE     (DI_FISCAL = 'S') AND (CL_CODIGO = @PR_CODIGO)

			SELECT     @DI_DESTINO= DI_INDICE
			FROM         dbo.DIR_CLIENTE
			WHERE     (DI_FISCAL = 'S') AND (CL_CODIGO = 1)

			SELECT @CONSECUTIVO=ISNULL(MAX(EN_CODIGO),0) FROM ENTSALALM
			SET @CONSECUTIVO=@CONSECUTIVO+1

			SET @RC_FOLIO=convert(varchar(10),@FECHAHOY)+' AJUSTE SUMA'

			INSERT INTO ENTSALALM(EN_CODIGO, EN_FOLIO, EN_FECHA, TM_CODIGO, PR_CODIGO,
			DI_PROVEE, CL_DESTINO, DI_DESTINO, EN_TIPO, ALM_DESTINO)

			SELECT @CONSECUTIVO, @RC_FOLIO, @FECHAHOY, 6, @PR_CODIGO,
				@DI_PROVEE, 1, @DI_DESTINO, 'E', ALM_CODIGO
			FROM         #INVENTAFIS
			WHERE     (TIPO='S')
			GROUP BY ALM_CODIGO


			if exists (select ivf_codigo from #INVENTAFIS where ivf_codigo<>-1 and tipo='S')
			insert into kardesalmacendet (ivf_codigo, en_codigo)
			select ivf_codigo,  @CONSECUTIVO from #INVENTAFIS where ivf_codigo<>-1 and tipo='S'
			and @CONSECUTIVO not in (select en_codigo from kardesalmacendet)
			group by ivf_codigo

		end


			declare cur_AjusteDetSuma cursor for
				SELECT     MA_CODIGO, CAN_GEN, IVF_TIPOENTSAL
				FROM         #INVENTAFIS
				WHERE     (TIPO='S')
			open cur_AjusteDetSuma
			FETCH NEXT FROM cur_AjusteDetSuma INTO @MA_CODIGO, @CAN_GEN, @IVF_TIPOENTSAL
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

			SELECT @CONSECUTIVO2=ISNULL(MAX(END_INDICED),0) FROM ENTSALALMDET
			SET @CONSECUTIVO2=@CONSECUTIVO2+1
	
	
			SELECT @RCD_NOPARTE=MA_NOPARTE, @RCD_NOMBRE=MA_NOMBRE, @RCD_NAME=MA_NAME, @RCD_CANT=@CAN_GEN/EQ_GEN, 
			@ME_CODIGO=ME_COM, @EQ_ALM=EQ_GEN
			FROM MAESTRO WHERE MA_CODIGO=@MA_CODIGO

			SELECT @RCD_COS_UNI=MA_COSTO, @RCD_COS_TOT=MA_COSTO*@RCD_CANT FROM MAESTROCOST WHERE MA_CODIGO=@MA_CODIGO
			SELECT @ME_ALM=ME_COM FROM MAESTRO WHERE MA_CODIGO=@MA_GENERICO

				INSERT INTO ENTSALALMDET (END_INDICED, EN_CODIGO, MA_CODIGO, END_NOPARTE, END_NOMBRE, END_NAME, END_CANT, END_COS_UNI, 
				END_COS_TOT, END_CAN_ALM, ME_CODIGO, ME_ALM, EQ_ALM, END_CANTEMP, END_TIPOENTSAL)
		
				values ( @CONSECUTIVO2, @CONSECUTIVO, @MA_CODIGO, @RCD_NOPARTE, @RCD_NOMBRE, @RCD_NAME, @RCD_CANT, 
				@RCD_COS_UNI, @RCD_COS_TOT, @CAN_GEN, @ME_CODIGO, @ME_ALM, @EQ_ALM, 0, @IVF_TIPOENTSAL)

			FETCH NEXT FROM cur_AjusteDetSuma INTO @MA_CODIGO, @CAN_GEN, @IVF_TIPOENTSAL
			END
		CLOSE cur_AjusteDetSuma
		DEALLOCATE cur_AjusteDetSuma


		exec sp_descarga_entsalalm @CONSECUTIVO
	end
*/


























GO
