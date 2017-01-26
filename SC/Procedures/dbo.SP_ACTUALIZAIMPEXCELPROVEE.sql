SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAIMPEXCELPROVEE] (@CODIGO INT, @TIPO CHAR(1))   as


Declare @MA_CODIGO INT, @pa_codigo INT, @mv_codigo int, @porcentaje decimal(38,6), @MV_COS_UNI decimal(38,6), @MV_PES_UNIKG decimal(38,6), 
@SE_CODIGO INT, @SPI_CODIGO INT, @MV_DEF_TIP CHAR(1), @CONPAIS CHAR(1)


	IF EXISTS(SELECT ISNULL(ORIGEN,'') FROM IMPEXCELFACTIMP WHERE ISNULL(ORIGEN,'')<>'') 
 		SET @CONPAIS='S'
	ELSE
		SET @CONPAIS='N'

	if @TIPO='F'
	begin
		DECLARE cur_maestroprovee CURSOR FOR
			SELECT     MA_CODIGO, PA_CODIGO
			FROM         FACTIMPDET
			WHERE     (FI_CODIGO = @CODIGO)
		open cur_maestroprovee  
		
		
			FETCH NEXT FROM cur_maestroprovee into @MA_CODIGO, @PA_CODIGO
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				IF @CONPAIS='N'
				SELECT @pa_codigo=PA_CODIGO FROM VMAESTROPROVEEGROUP WHERE MA_CODIGO=@MA_CODIGO
		
				EXEC SP_ACTUALIZATASABAJAMAPROVEE '1',@ma_codigo, @pa_codigo, @mv_codigo output, @porcentaje output
				
		
				SELECT     @MV_COS_UNI=ISNULL(MV_COS_UNI,0), @MV_PES_UNIKG=ISNULL(MV_PES_UNIKG,0), @SE_CODIGO=ISNULL(SE_CODIGO,0), @SPI_CODIGO=ISNULL(SPI_CODIGO,0), @MV_DEF_TIP=MV_DEF_TIP
				FROM         MAESTROPROVEE
				WHERE     (MV_CODIGO =@mv_codigo)
	

				if @MV_COS_UNI>0 and @MV_COS_UNI is not null
				begin
					update factimpdet
					set fid_cos_uni=@MV_COS_UNI
					where ma_codigo=@MA_CODIGO
					and fi_codigo=@CODIGO and fid_cos_uni=0
		
					update factimpdet
					set fid_cos_tot=round(@MV_COS_UNI*factimpdet.fid_cant_st,6)
					where ma_codigo=@MA_CODIGO
					and fi_codigo=@CODIGO 
		
		
				end
		
		
				if @MV_PES_UNIKG>0 and @MV_PES_UNIKG is not null
				begin
					update factimpdet
					set FID_PES_UNI=@MV_PES_UNIKG, FID_PES_NET=round(@MV_PES_UNIKG*factimpdet.fid_cant_st,6),
					     FID_PES_BRU=round(@MV_PES_UNIKG*factimpdet.fid_cant_st,0), FID_PES_UNILB=round(@MV_PES_UNIKG*2.20462442018378,6), 
					     FID_PES_NETLB=round(@MV_PES_UNIKG*2.20462442018378*factimpdet.fid_cant_st,6), FID_PES_BRULB=round(@MV_PES_UNIKG*2.20462442018378*Factimpdet.fid_cant_st,6)
					where ma_codigo=@MA_CODIGO
					and fi_codigo=@CODIGO and FID_PES_UNI=0
				end
		
		
				update factimpdet
				set fid_sec_imp=isnull(@SE_CODIGO,0), spi_codigo=isnull(@SPI_CODIGO,0), fid_por_def=isnull(@porcentaje,-1), fid_def_tip=isnull(@MV_DEF_TIP,'G'),
				pa_codigo=@pa_codigo
				where ma_codigo=@MA_CODIGO
				and fi_codigo=@CODIGO

		
			FETCH NEXT FROM cur_maestroprovee into @MA_CODIGO, @PA_CODIGO
		
		END
		
		CLOSE cur_maestroprovee
		DEALLOCATE cur_maestroprovee
	end
	else
	begin
		DECLARE cur_maestroprovee CURSOR FOR
			SELECT     MA_CODIGO, PA_CODIGO
			FROM         PCKLISTDET
			WHERE     (PL_CODIGO = @CODIGO)
		open cur_maestroprovee  
		
		
			FETCH NEXT FROM cur_maestroprovee into @MA_CODIGO, @PA_CODIGO
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				IF @CONPAIS='N'
				SELECT @pa_codigo=PA_CODIGO FROM VMAESTROPROVEEGROUP WHERE MA_CODIGO=@MA_CODIGO
		
				EXEC SP_ACTUALIZATASABAJAMAPROVEE '1',@ma_codigo, @pa_codigo, @mv_codigo output, @porcentaje output
		
		
				SELECT     @MV_COS_UNI=MV_COS_UNI, @MV_PES_UNIKG=MV_PES_UNIKG, @SE_CODIGO=SE_CODIGO, @SPI_CODIGO=SPI_CODIGO, @MV_DEF_TIP=MV_DEF_TIP
				FROM         MAESTROPROVEE
				WHERE     (MV_CODIGO =@mv_codigo)
		
		
				if @MV_COS_UNI>0 and @MV_COS_UNI is not null
				begin
					update PCKLISTDET
					set PLD_cos_uni=@MV_COS_UNI
					where ma_codigo=@MA_CODIGO
					and PL_codigo=@CODIGO and PLD_cos_uni=0
		
					update PCKLISTDET
					set PLD_cos_tot=round(@MV_COS_UNI*PCKLISTDET.PLD_cant_st,6)
					where ma_codigo=@MA_CODIGO
					and PL_codigo=@CODIGO 
		
		
				end
		
		
				if @MV_PES_UNIKG>0 and @MV_PES_UNIKG is not null
				begin
					update PCKLISTDET
					set PLD_PES_UNI=@MV_PES_UNIKG, PLD_PES_NET=round(@MV_PES_UNIKG*PCKLISTDET.PLD_cant_st,6),
					     PLD_PES_BRU=round(@MV_PES_UNIKG*PCKLISTDET.PLD_cant_st,0), PLD_PES_UNILB=round(@MV_PES_UNIKG*2.20462442018378,6), 
					     PLD_PES_NETLB=round(@MV_PES_UNIKG*2.20462442018378*PCKLISTDET.PLD_cant_st,6), PLD_PES_BRULB=round(@MV_PES_UNIKG*2.20462442018378*PCKLISTDET.PLD_cant_st,6)
					where ma_codigo=@MA_CODIGO
					and PL_codigo=@CODIGO and PLD_PES_UNI=0
				end
		
		
				update PCKLISTDET
				set PLD_sec_imp=isnull(@SE_CODIGO,0), spi_codigo=isnull(@SPI_CODIGO,0), PLD_por_def=isnull(@porcentaje,-1), PLD_def_tip=isnull(@MV_DEF_TIP,'G'),
				pa_codigo=@pa_codigo
				where ma_codigo=@MA_CODIGO
				and PL_codigo=@CODIGO


	
			FETCH NEXT FROM cur_maestroprovee into @MA_CODIGO, @PA_CODIGO
		
		END
		
		CLOSE cur_maestroprovee
		DEALLOCATE cur_maestroprovee
	
	end

GO
