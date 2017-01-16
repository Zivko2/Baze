SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















CREATE PROCEDURE dbo.stp_Incorpora (@CodigoPert int, @CodigoMP int, @Incorpora decimal(38,6) , @Factconv decimal(28,14), @EntraVigor datetime, @PerCamb char(1), @PerFin DateTime, @ModifyDate DateTime, @Trans char(1), @mecodigo int, @Ma_tip_ens char(1), @Disch char(1), @bst_sec smallint=0, @bst_secant smallint=0, @yaexiste char(1) output)    as


SET NOCOUNT ON 
declare @Fact decimal(38,6), @Factalm decimal(38,6), @UMGen Int, @Dis Char(1), @ModifyDateFinal DateTime, @manoparte Varchar(30), @manoparteAux Varchar(10),
@manopartepadre Varchar(30), @manopartepadreAux Varchar(10), @Ma_tip_ensant char(1), @cft_tipo char(1), @bsu_subensamble int, @UMAlm Int, 
@bm_codigo int, @bmPerfin datetime, @bm_entravigor datetime, @bm_codigo2 int, @bm_entravigor2 datetime, @perfin2 datetime,
@bstcodigoanterior int, @bst_codigo int, @count int, @me_viejo int, @bst_pesoviejo decimal(38,6), @dummy varchar(2)

set @ModifyDateFinal = convert(datetime, convert(varchar(11), getdate(),101))
set @yaexiste='N'

	if exists(select * from bom_struct where BSU_SUBENSAMBLE = @CodigoPert
			and BST_HIJO = @CodigoMP
			and bst_perini = @EntraVigor
			and bst_perfin = @PerFin
			and bst_sec=@bst_sec) and @bst_sec<>@bst_secant
	set @yaexiste='S'

	if @yaexiste='N' 
	begin


	
		if exists (select * from maestro where ma_codigo=@CodigoMP)
		begin

			select    @Fact = dbo.MAESTRO.EQ_GEN, 
				@Dis = dbo.MAESTRO.MA_DISCHARGE, 
				@UMGen = isnull(MAESTRO1.ME_COM,19), 
				@manoparte = dbo.MAESTRO.MA_NOPARTE,
				@manoparteAux = dbo.MAESTRO.MA_NOPARTEAUX
			FROM         dbo.MAESTRO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO1.MA_CODIGO











			WHERE     (dbo.MAESTRO.MA_CODIGO =  @codigoMP)
			
			/*if @paorigen is null
			select    @paorigen = dbo.MAESTRO.PA_ORIGEN
			FROM         dbo.MAESTRO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO1.MA_CODIGO
			WHERE     (dbo.MAESTRO.MA_CODIGO =  @codigoMP)*/
		end
		else
		begin
			select    @Fact = factconv, 
				@Dis = BST_DISCH, 
				@UMGen = ME_GEN, 
				@manoparte = BST_NOPARTE,
				@manoparteAux = BST_NOPARTEAUX
			FROM BOM_STRUCT WHERE BST_HIJO=@codigoMP AND BST_CODIGO
			IN (SELECT MAX(BST_CODIGO) FROM BOM_STRUCT WHERE BST_HIJO=@codigoMP)

		
			/*if @paorigen is null
			select @paorigen=PA_CODIGO
			FROM BOM_STRUCT WHERE BST_HIJO=@codigoMP AND BST_CODIGO
			IN (SELECT MAX(BST_CODIGO) FROM BOM_STRUCT WHERE BST_HIJO=@codigoMP)*/
		
		
		end
		
			select @me_viejo=me_codigo from bom_struct
			where     BSU_SUBENSAMBLE = @CodigoPert
				and BST_HIJO = @CodigoMP
				and bst_perini = @EntraVigor
				and bst_perfin = @PerFin 
		
		
		
			select @manopartepadre = ma_noparte, @manopartepadreAux = ma_noparteAux from maestro where ma_codigo = @CodigoPert
		
		
			if @Ma_tip_ensant<> @Ma_tip_ens and @Ma_tip_ens='C'
			set @Disch='S'
		
		
			select @bst_codigo=bst_codigo, @Ma_tip_ensant =BST_TIP_ENS from bom_struct where bsu_subensamble =@CodigoPert and bst_hijo=@CodigoMP 
			and bst_perini = @EntraVigor and bst_perfin = @PerFin 
		
			select @count = count(bst_codigo) from bom_struct where bsu_subensamble =@CodigoPert and bst_hijo=@CodigoMP 
		
		
			if @count>1
			begin
				-- inmediato anterior
				SELECT @bstcodigoanterior = max(bst_codigo) FROM bom_struct WHERE bsu_subensamble =@CodigoPert
				and bst_hijo=@CodigoMP and bst_codigo <>@bst_codigo and bst_codigo<@bst_codigo
		
			end
		
		
			-- me_codigo1=um antes del cambio y me_codigo2=um nueva, al cambiar la unidad de medida actualiza el costo de acuerdo a la unidad de medida anterior y la
			-- nueva
		
		
			/*if @me_viejo<>@mecodigo
			begin
				update bom_struct		
				set bom_struct.bst_peso_kg= round(bom_struct.bst_peso_kg/ equivale.eq_cant,6)
				from         equivale inner join
				                      bom_struct on equivale.me_codigo1 = bom_struct.me_codigo 
				where     (equivale.me_codigo2 = @mecodigo)
					and BSU_SUBENSAMBLE = @CodigoPert
					and BST_HIJO = @CodigoMP
					and bst_perini = @EntraVigor
					and bst_perfin = @PerFin and  (equivale.eq_cant >0 and  equivale.eq_cant  is not null)
		
			end*/
		
		
		
		
		
			
		
			if @PerCamb='N' 
			begin
					UPDATE BOM_Struct
					SET BST_INCORPOR= @Incorpora,
					factconv = @factconv, 
					BST_TRANS = @Trans, 
					ME_CODIGO = @mecodigo,
					BST_TIP_ENS = @Ma_tip_ens,
					BST_DISCH = @Disch,
					bst_sec=@bst_sec
					where BSU_SUBENSAMBLE = @CodigoPert
					and BST_HIJO = @CodigoMP
					and bst_perini = @EntraVigor
					and bst_perfin = @PerFin
					and bst_sec=@bst_secant
		
			end	
			else
			begin
			
					/* actualiza el bom_struct anterior a la modificacion */
					if @count>1
					begin
						update bom_struct
						set bst_perfin=@ModifyDate
						where bst_codigo=@bstcodigoanterior
					end
					
					--print @ModifyDateFinal	
					--print @PerFin
		
					if not exists (select * from bom_struct where BSU_SUBENSAMBLE = @CodigoPert
						AND BST_HIJO = @CodigoMP
						and bst_perini = @ModifyDateFinal
						and bst_perfin = @PerFin)
					begin	
								INSERT INTO BOM_Struct (BSU_Subensamble,  
				                                               	BST_Hijo, 
								BSU_NOPARTE,
								BSU_NOPARTEAUX,
								BST_NOPARTE,
								BST_NOPARTEAUX,
								BST_PerINI, 
				             		                          BST_PerFIN, 
						             	             BST_DISCH, 
			                          		 		ME_CODIGO,
								ME_GEN,
								BST_INCORPOR,
					                     	         	factconv ,
								BST_TRANS,
								BST_TIP_ENS,
								bst_sec)
				
						    VALUES  (@CodigoPert, 
					             			@CodigoMP, 
								@manopartepadre,
								@manopartepadreAux,
								@manoparte,
								@manoparteAux,
							             @ModifyDateFinal, 
						             		@PerFin, 
							             @Dis, 
							             @mecodigo,
							  	@UMGen,
								@Incorpora, 
								@factconv,
								@Trans,
								@Ma_tip_ens,
								@bst_sec)
		
		
		/*				select @bst_codigo = max(bst_codigo) from bom_struct
			
						-- actualizar bom_costo
						if exists (select * from vmaestrocost where ma_codigo=@CodigoMP)
						exec sp_actualizaBomCosto @bst_codigo
			
						exec stpTipoCosto @bst_codigo,  @Trans, @paorigen, @tipocosto=@dummy output
						update bom_struct set bst_tipocosto = @dummy 
						where bst_codigo = @bst_codigo*/
			
					end
					else
					begin
		
							UPDATE BOM_Struct
							SET BST_INCORPOR= @Incorpora,
							factconv = @factconv, 
							BST_TRANS = @Trans, 							ME_CODIGO = @mecodigo,
							BST_TIP_ENS = @Ma_tip_ens,
							BST_DISCH = @Disch,
							bst_sec=@bst_sec
							where BSU_SUBENSAMBLE = @CodigoPert
							and BST_HIJO = @CodigoMP
							and bst_perini = @ModifyDateFinal
							and bst_perfin = @PerFin
							and bst_sec=@bst_secant
					end
					
			end
	
	end


















GO
