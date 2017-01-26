SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















/* Insert en BOM_STRUCT*/
CREATE PROCEDURE stpGrabaStruct(@codigo Int, @codigoPert int, @EntraVigor DateTime, @PerFin DateTime, @PerCamb Char(1), @Ma_tip_ens CHAR(1), @bst_sec smallint=0, @bst_codigo int output)   as

SET NOCOUNT ON 

DECLARE @Fact decimal(38,6), @Factalm decimal(38,6), @UniMed Int, @UMGen Int, @UMAlm Int, @Tipo Int, @TipoLetra char(1), @Dis Char(1), @FechaInsert DateTime, @nopartepadre  varchar(30),
@nopartepadreAux  varchar(10), @noparte varchar(30), @noparteAux varchar(10), @PAORIGEN INT, @cft_tipo char(1), @bsu_subensamble int, @ma_trans CHAR(1),
@ma_peso_kg decimal(38,6), @ar_codigo int, @yaexiste char(1)

select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo=@Codigo)
Set @FechaInsert = convert(datetime, convert(varchar(11), getdate(),101))

declare @bmPerfin datetime, @bm_entravigor datetime, @bm_codigo2 int, @bm_entravigor2 datetime, @perfin2 datetime,@dummy varchar(2)


	if @PerCamb='N'
	set @EntraVigor=@EntraVigor
	else 
	set @EntraVigor=@FechaInsert


	set @yaexiste='N'


	if @Ma_tip_ens='A' 
	set @Ma_tip_ens='F'

		if exists (select * from bom_struct where bst_perfin = @PerFin and bsu_subensamble =@CodigoPert 
					and bst_hijo = @Codigo and bst_perini = @entravigor and bst_sec=@bst_sec) 
		set @yaexiste='S'

		
		if @yaexiste='N'
		begin
			


		    --Yolanda Avila (2009-11-16) --Regreso de version a la 33
			--if (select count(*) from MAESTROREFER where ma_codigo=@codigo)>0
			if exists(select * from MAESTROREFER where ma_codigo=@codigo)
			begin
				SELECT     @Fact = dbo.MAESTROREFER.EQ_GEN, 
					@Factalm = 1, 
					@Tipo = dbo.MAESTROREFER.TI_CODIGO, 
					@UniMed = dbo.MAESTROREFER.ME_COM, 
					@Dis = 'N', 
					@UMGen = MAESTRO1.ME_COM, 
					@UMAlm = 0, 
				             @Tipoletra = dbo.CONFIGURATIPO.CFT_TIPO,
					@Noparte = dbo.MAESTROREFER.MA_NOPARTE,
					@NoparteAux = isnull(dbo.MAESTROREFER.MA_NOPARTEAUX,''),
					@Paorigen = isnull(dbo.MAESTROREFER.PA_ORIGEN,154),
					@ma_trans= ISNULL(dbo.MAESTROREFER.MA_TRANS,'N'),
					@ma_peso_kg= isnull(dbo.MAESTROREFER.MA_PESO_KG,0),
					@ar_codigo=0
				FROM         dbo.MAESTROREFER LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.MAESTROREFER.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO1 ON dbo.MAESTROREFER.MA_GENERICO = MAESTRO1.MA_CODIGO
				WHERE     (dbo.MAESTROREFER.MA_CODIGO =  @codigo)
	
			
			end
			else
				SELECT     @Fact = dbo.MAESTRO.EQ_GEN, 
					@Factalm = dbo.MAESTRO.EQ_ALM, 
					@Tipo = dbo.MAESTRO.TI_CODIGO, 
					@UniMed = dbo.MAESTRO.ME_COM, 
					@Dis = dbo.MAESTRO.MA_DISCHARGE, 
					@UMGen = MAESTRO1.ME_COM, 
					@UMAlm = MAESTRO.ME_ALM, 
				             @Tipoletra = dbo.CONFIGURATIPO.CFT_TIPO,
					@Noparte = dbo.MAESTRO.MA_NOPARTE,
					@NoparteAux = dbo.MAESTRO.MA_NOPARTEAUX,
					@Paorigen = dbo.MAESTRO.PA_ORIGEN,
					@ma_trans= dbo.MAESTRO.MA_TRANS,
					@ma_peso_kg= isnull(dbo.MAESTRO.MA_PESO_KG,0),
					@ar_codigo=dbo.MAESTRO.AR_IMPFO
				FROM         dbo.MAESTRO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
				                      dbo.MAESTRO MAESTRO1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO1.MA_CODIGO
				WHERE     (dbo.MAESTRO.MA_CODIGO =  @codigo)


				if @ma_trans is null
				set @ma_trans='N'
				
				if @Fact is null
				set @Fact=1
	
				if @Dis is null
				set @Dis='N'

				if @noparteAux is null
				set @noparteAux=''




			select @nopartepadre = ma_noparte, @nopartepadreAux = ma_noparteAux from maestro where ma_codigo =@codigopert

				if @nopartepadreAux is null
				set @nopartepadreAux=''
				
			

		    INSERT INTO BOM_Struct (BSU_Subensamble,   
			BST_Hijo, 
			BSU_NOPARTE,
			BSU_NOPARTEAUX,
			BST_NOPARTE,
			BST_NOPARTEAUX,
                                       BST_PerINI, 
	                          BST_PerFIN, 
             		             FACTCONV, 
             		             BST_DISCH, 
             		             ME_CODIGO,
			ME_GEN,
			BST_TIP_ENS,
			bst_trans,
			bst_sec)

		    VALUES  (@CodigoPert, 
			@Codigo, 
			@nopartepadre,
			@nopartepadreAux,
			@noparte,
			@noparteAux,
			@EntraVigor, 
			@PerFin, 
			@Fact, 
			@Dis, 
			@UniMed,
			isnull(@UMGen,19),
			@Ma_tip_ens,
			@ma_trans,
			@bst_sec)

			
			
			

			select @bst_codigo=bst_codigo from bom_struct where bst_perfin = @PerFin and bsu_subensamble =@CodigoPert 
					and bst_hijo = @Codigo and bst_perini = @entravigor and bst_sec=@bst_sec


			select @bst_codigo=bst_codigo from bom_struct where bst_perfin = @PerFin and bsu_subensamble =@CodigoPert 
					and bst_hijo = @Codigo and bst_perini = @entravigor and bst_sec=@bst_sec

		end
		else
			set @bst_codigo=0

GO
