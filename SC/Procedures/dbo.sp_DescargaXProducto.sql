SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[sp_DescargaXProducto] (@cft_tipo char(1), @CodigoFactura int, @MetodoDescarga Varchar(4), @Fed_indiced int,  @ma_codigo int,
@tipodescarga varchar(2), @Fed_fecha_struct varchar(10), @KAP_CantTotADescargar decimal(38,6), @KAP_CantADescargar decimal(38,6), @KAP_Saldo_fed decimal(38,6) Output) AS

DECLARE @CantRestantePadre decimal(38,6), @bst_hijo int, @Bst_incorpor decimal(38,6), @TipoDescarga2 char(1), @Bst_tip_ens char(1),
	@Bst_Disch char(1), @Cant_a_Desc decimal(38,6), @cft_tipo2 char(1), @Kap_codigoSaldo int, @total decimal(38,6),  @Kap_CantDesc decimal(38,6)



	if  (@cft_tipo = 'S') OR (@cft_tipo = 'P') 
	begin

		if exists(select * from vpidescarga where ma_codigo=@ma_codigo)
		begin
			exec sp_DescargaxComponente 'N', @CodigoFactura, @MetodoDescarga, @fed_indiced, 0, @ma_codigo,
			@tipodescarga, @KAP_CantTotADescargar, @KAP_CantADescargar, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output
	
			if @Kap_codigoSaldo >0 
				delete from kardespedtemp where kap_codigo=@Kap_codigoSaldo


			if @Kap_Saldo_fed > 0
			begin
				select @total=sum(kap_cantdesc) from kardespedtemp where ma_hijo= @ma_codigo
				
				update kardespedtemp
				set Kap_CantTotADescargar=@total, Kap_Saldo_fed=0, Kap_estatus='D'
				 where ma_hijo= @ma_codigo
				
			end 

		end
		else
		set @Kap_Saldo_fed=@KAP_CantADescargar

	end



	if ((@cft_tipo = 'S') OR (@cft_tipo = 'P')) and @KAP_Saldo_FED > 0  
	begin


		set @CantRestantePadre=@KAP_Saldo_FED

		DECLARE Hijos CURSOR LOCAL FOR
			SELECT  bst_hijo, sum(Bst_incorpor * ISNULL(FactConv,1)), Bst_Disch, Bst_tip_ens, cft_tipo
			FROM    bom_struct LEFT OUTER JOIN maestro ON bom_struct.bst_hijo = maestro.ma_codigo 
				LEFT OUTER JOIN configuratipo ON maestro.ti_codigo = configuratipo.ti_codigo
			WHERE   bom_struct.Bsu_subensamble = @ma_codigo and bom_struct.bst_tip_ens <>'P' 
				and (@Fed_fecha_struct  BETWEEN Bst_perini AND Bst_perfin) and Bst_incorpor>0
			GROUP BY bst_hijo, Bst_Disch, cft_tipo, Bst_tip_ens
		OPEN Hijos

		fetch next from Hijos  into  @bst_hijo, @Bst_incorpor, @Bst_Disch, @Bst_tip_ens, @cft_tipo2
		if ( @@fetch_status <> 0 )  
		begin
			set @cft_tipo2 = 'P'
		end
		else
		WHILE ( @@fetch_status = 0 ) 
		begin
			if @tipodescarga='D'
			  set @TipoDescarga2='D'
			else
			  set @TipoDescarga2='N'


			--if @Bst_Disch = 'S' or @cft_tipo2='S' or @cft_tipo2='P'
			begin
				if (@cft_tipo2 = 'S' or @cft_tipo2 = 'P') and @Bst_tip_ens<>'C'
				begin
					set @Cant_a_Desc = round(@CantRestantePadre * @Bst_incorpor,6) 
					set @KAP_Saldo_FED= 0

					exec  sp_DescargaXProducto @cft_tipo2, @CodigoFactura, @MetodoDescarga, @fed_indiced, @bst_hijo,  										
								@TipoDescarga2, @Fed_fecha_struct , @Cant_a_Desc, @Cant_a_Desc, @KAP_Saldo_FED Output

				end
				else
				if @Bst_Disch = 'S'
				begin
					set @Cant_a_Desc = round(@CantRestantePadre * @Bst_incorpor,6)
					set @KAP_Saldo_FED= 0			
		

					exec sp_DescargaxComponente 'S', @CodigoFactura, @MetodoDescarga, @fed_indiced, @ma_codigo, @bst_hijo,
						@TipoDescarga2, @Cant_a_Desc, @Cant_a_Desc, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output

					
		
				end
			end
			fetch next from Hijos  into  @bst_hijo, @Bst_incorpor, @Bst_Disch, @Bst_tip_ens, @cft_tipo2
		end
		close  Hijos
		deallocate Hijos
	end 
		--PRINT 'descargando diferente de subensamble y pt'
		--===================================================================
	else
	     exec sp_DescargaxComponente 'S', @CodigoFactura, @MetodoDescarga, @fed_indiced, 0, @ma_codigo,
		@tipodescarga, @KAP_CantTotADescargar, @KAP_CantADescargar, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output
GO
