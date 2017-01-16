SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_DescargaxComponente] (@BuscaEquivale char(1), @CodigoFactura int, @MetodoDescarga Varchar(4), @fed_indiced int, @ma_padre int, @ma_codigo int,
@tipodescarga varchar(2), @KAP_CantTotADescargar decimal(38,6), @KAP_CantADescargar decimal(38,6), @Kap_Saldo_fed decimal(38,6) Output, @Kap_codigoSaldo int Output, @Kap_CantDesc decimal(38,6) Output) AS

declare @ma_codigoSust int, @CantDesc_Sustituto decimal(38,6), @grupo int, @ma_codigoGen int, @CantDesc_Gen decimal(38,6), @CF_USAEQUIVALENTE char(1), @CF_DESCARGASBUS char(1),
@Fed_fecha_struct varchar(11), @Ma_hijoNvo int, @CantidadDesv decimal(38,6)

	SELECT     @CF_USAEQUIVALENTE = CF_USAEQUIVALENTE, @CF_DESCARGASBUS=CF_DESCARGASBUS
	FROM         CONFIGURACION

	select @Fed_fecha_struct=convert(varchar(11),Fed_fecha_struct,101) from factexpdet where fed_indiced=@fed_indiced



	/*

	if @ma_padre <>0 
	begin
		exec SP_AplicaDesviacion @ma_padre, @ma_codigo, @Fed_fecha_struct, @KAP_CantADescargar, @Ma_hijoNvo Output, @CantidadDesv Output

		if @Ma_hijoNvo>0
		set @ma_codigo=@Ma_hijoNvo

	end	*/



	exec Sp_BuscaPedimento @CodigoFactura, @MetodoDescarga, @fed_indiced, 0, @ma_codigo, 
		@tipodescarga, @KAP_CantTotADescargar, @KAP_CantADescargar, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output

	--exec SP_ESTATUSKARDESPEDFED @fed_indiced

	if @BuscaEquivale ='S' and @Kap_Saldo_fed> 0
	begin
		--========== equivalentes =============
		if @CF_USAEQUIVALENTE='S' 
		   if @Kap_Saldo_fed> 0 and exists (select ma_codigo from maestrosust where ma_codigo=@ma_codigo) 
		begin
			DECLARE SUSTITUTOS CURSOR LOCAL FOR
				SELECT MA_CODIGOSUST
				FROM  MAESTROSUST
				WHERE (MA_CODIGO = @ma_codigo)
			OPEN SUSTITUTOS
			fetch next from SUSTITUTOS into @ma_codigoSust
			WHILE (@@fetch_status = 0) AND (@Kap_Saldo_fed > 0)
			begin
	
				set @CantDesc_Sustituto = @Kap_Saldo_fed 
	
		
				if exists(select * from vpidescarga where ma_codigo=@ma_codigo)
				begin
					exec Sp_BuscaPedimento @CodigoFactura, @MetodoDescarga, @fed_indiced, @ma_codigo, @ma_codigoSust, 
						@tipodescarga, @KAP_CantTotADescargar, @CantDesc_Sustituto, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output


					if @Kap_CantDesc > 0
					delete from kardespedtemp where ma_hijo=@ma_codigo and Kap_Saldo_fed=KAP_CantTotADescargar

				end		

				--if @Kap_codigoSaldo >0 
				--delete from kardespedtemp where kap_codigo=@Kap_codigoSaldo

	
	
				fetch next from SUSTITUTOS into  @ma_codigoSust
			end
			close  SUSTITUTOS
			deallocate SUSTITUTOS


		end
	
	
		-- PENDIENTES POR GRUPO GENERICO
		if @CF_DESCARGASBUS<>'G' and @Kap_Saldo_fed> 0 and
		   (SELECT CF_USAEQUIVALENTE FROM  CONFIGURACION)='N' and
		   (SELECT CF_PENDGR FROM  CONFIGURACION)='S' 
		begin
			select @grupo=ma_generico from maestro where ma_codigo = @ma_codigo
	
			DECLARE GRUPOGEN CURSOR LOCAL FOR
				SELECT     MA_CODIGO
				FROM       VPIDESCARGA				
				WHERE     ( MA_GENERICO = @grupo )
			OPEN GRUPOGEN
			fetch next from GRUPOGEN into  @ma_codigoGen
			WHILE ( @@fetch_status = 0 ) AND ( @Kap_Saldo_fed> 0 )
			begin
	
				set @CantDesc_Gen = @Kap_Saldo_fed 
	
			
				exec Sp_BuscaPedimento @CodigoFactura, @MetodoDescarga, @fed_indiced, @ma_codigo, @ma_codigoGen, 
					@tipodescarga, @KAP_CantTotADescargar, @CantDesc_Gen, @Kap_Saldo_fed Output, @Kap_codigoSaldo Output, @Kap_CantDesc Output

				if @Kap_CantDesc > 0
				delete from kardespedtemp where ma_hijo=@ma_codigo and Kap_Saldo_fed=KAP_CantTotADescargar


				fetch next from GRUPOGEN into  @ma_codigoGen
			end
			close  GRUPOGEN
			deallocate GRUPOGEN
	
		end
	
	
	
	end
GO
