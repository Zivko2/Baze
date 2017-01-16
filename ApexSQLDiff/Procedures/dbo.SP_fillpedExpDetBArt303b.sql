SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedExpDetBArt303b] (@pib_indiceb int)   as

SET NOCOUNT ON
declare @TotalAranUSA decimal(38,6), @MontoIgi decimal(38,6), @MontoExento decimal(38,6), @PI_TIP_CAMPAGO decimal(38,6), 
@PI_IMPORTECONTRSINRECARGOS decimal(38,6), @PI_FECHAPAGO datetime, @PI_FEC_PAG datetime, @recargo decimal(38,6), @VINPCMAX decimal(38,6),
@VINPCMIN decimal(38,6), @FactorAct decimal(38,6), @PIB_VALORMCIANOORIG decimal(38,6), @MontoExentofinal decimal(38,6), @PIB_ADVMNIMPUSA decimal(38,6),
@PIB_ADVMNIMPUSA2 decimal(38,6), @PIB_IMPORTECONTR decimal(38,6), @SUMATASA decimal(38,6), @ccp_tipo varchar(5), @cp_art303 char(1),
@PIB_ADVMNIMPMEX decimal(38,6), @PIB_DESTNAFTA char(1), @CONSECUTIVO int, @PIID_CODIGO int, @picodigo int,
@PIB_IMPORTECONTRUSD decimal(38,6), @PI_IMPORTECONTRSINRECARGOSUSD decimal(38,6), @cf_pagocontribdet char(1), @FED_INDICED int

		select @picodigo=pi_codigo from pedimpdetb where pib_indiceb=@pib_indiceb
		
		SELECT @PI_TIP_CAMPAGO=PI_TIP_CAMPAGO, @PI_FECHAPAGO=PI_FECHAPAGO,
		@PI_FEC_PAG=PI_FEC_PAG
		FROM PEDIMP WHERE PI_CODIGO =@picodigo
	
		select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
		(select cp_codigo from pedimp where pi_codigo=@picodigo)
	
		if @ccp_tipo<>'re'
			select @cp_art303= cp_art303 from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)
		else
		begin
			if exists(select * from pedimp where pi_rectifica is null and pi_codigo = @picodigo)
			select @cp_art303= cp_art303 from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@picodigo))
			else
			select @cp_art303= cp_art303 from claveped where cp_codigo in (select cp_rectifica from pedimp where pi_codigo=@picodigo)
		end
	


		if (@PI_FECHAPAGO > @PI_FEC_PAG+60) 
		begin
			/* se esta truncando a 4 decimales, no redondeando */
			SELECT     @FactorAct=round(FACTORACT, 4, 1)
			FROM         dbo.VFACTORACT
			WHERE     (PI_CODIGO = @picodigo)
	
	
		end
		else 
		begin
			set @FactorAct=1
		end
	
		select @SUMATASA=round(isnull(SUMATASA,0),2) from VRECARGO WHERE PI_CODIGO =@picodigo
	
	
		select @cf_pagocontribdet=cf_pagocontribdet from configuracion





	---------------------------------------------------------------------------- inicia llenado ----------------------------------------------------------------------------------------------------------------
	if @cf_pagocontribdet='S'
	begin
		if exists (select * from temppedimpdetbfed where fed_indiced in 
		(select fed_indiced from dbo.VFACTEXPDETpib where pib_indiceb=@pib_indiceb))
	
		delete from temppedimpdetbfed where fed_indiced in 
		(select fed_indiced from dbo.VFACTEXPDETpib where pib_indiceb=@pib_indiceb)
	
	
		declare cur_pedimpdetb303Fedb cursor for
			SELECT     dbo.VFACTEXPDETpib.FED_INDICED, dbo.PEDIMPDETB.PI_codigo, dbo.PEDIMPDETB.PIB_DESTNAFTA
			FROM         dbo.VFACTEXPDETpib INNER JOIN
			                      dbo.PEDIMPDETB ON dbo.VFACTEXPDETpib.PIB_INDICEB = dbo.PEDIMPDETB.PIB_INDICEB
			WHERE     (dbo.PEDIMPDETB.PIB_INDICEB = @pib_indiceb) 
	
		open cur_pedimpdetb303Fedb
		fetch next from cur_pedimpdetb303Fedb into @FED_INDICED, @picodigo, @PIB_DESTNAFTA
		while (@@fetch_status =0)
		begin
	
			if not exists (select * from temppedimpdetbfed where fed_indiced=@FED_INDICED)
			insert into temppedimpdetbfed (FED_INDICED, PIB_INDICEB, PI_CODIGO, PIB_VALORMCIANOORIG, PIB_ADVMNIMPUSA, PIB_ADVMNIMPMEX, PIB_EXCENCION, 
	                      PIB_IMPORTECONTRSINRECARGOS, PIB_IMPORTECONTR, PIB_IMPORTECONTRUSD, PIB_IMPORTERECARGOS)
			values (@FED_INDICED, @PIB_INDICEB, @picodigo, 0, 0, 0, 0, 0, 0, 0, 0)
	
			if exists (select * from  dbo.VDATOSPEDEXPPAGOUSA WHERE FED_INDICED = @FED_INDICED )
			begin
				SELECT     @TOTALARANUSA=sum(isnull(TOTALARANUSA,0)), @PIB_ADVMNIMPUSA=sum(isnull(TOTALARANUSAMN,0))
				FROM         dbo.VDATOSPEDEXPPAGOUSA
				WHERE FED_INDICED = @FED_INDICED 
				GROUP BY FED_INDICED
			end
			else
			begin
				set @TOTALARANUSA=0
				set @PIB_ADVMNIMPUSA=0
	
			end
			
			if exists (select * from dbo.VDATOSPEDEXPPAGOMEX WHERE FED_INDICED = @FED_INDICED)
			begin
				SELECT     @PIB_VALORMCIANOORIG=SUM(isnull(VALORMERCNOORIGMN,0)), @MontoIgi=SUM(isnull(MONTOIGIMXMN/@PI_TIP_CAMPAGO,0)),
					@PIB_ADVMNIMPMEX=SUM(isnull(MONTOIGIMXMN,0))
				FROM         dbo.VDATOSPEDEXPPAGOMEX
				WHERE FED_INDICED = @FED_INDICED 
				GROUP BY FED_INDICED
			end
			else
			begin
				set     @PIB_VALORMCIANOORIG=0
				set @MontoIgi=0
				set @PIB_ADVMNIMPMEX=0
			end
	
	
	
				UPDATE TempPEDIMPDETBFed
				SET PIB_ADVMNIMPUSA = @PIB_ADVMNIMPUSA
				WHERE FED_INDICED = @FED_INDICED 
	
	
				if @PIB_DESTNAFTA='N'	/* cuando el destino es no nafta no se paga nada */
				begin
					UPDATE TempPEDIMPDETBFed
					SET PIB_ADVMNIMPMEX = 0,
					PIB_EXCENCION = 0, 
					PIB_IMPORTECONTRSINRECARGOS = 0,
					PIB_IMPORTERECARGOS= 0,
					PIB_IMPORTECONTR = 0,  
					PIB_IMPORTECONTRUSD = 0,  
					PIB_VALORMCIANOORIG = isnull(@PIB_VALORMCIANOORIG,0)
					WHERE FED_INDICED = @FED_INDICED 
				end
				else
				begin--1
					if @cp_art303='S'
					begin /* si aplica el articulo 303 */
						if isnull(@PIB_ADVMNIMPMEX,0) >@PIB_ADVMNIMPUSA
						begin
							-- sin actualizar
							set @PI_IMPORTECONTRSINRECARGOS=round(((@PIB_ADVMNIMPMEX)-isnull(@PIB_ADVMNIMPUSA,0)),2)
							set @PI_IMPORTECONTRSINRECARGOSUSD=round(((@MontoIgi)-isnull(@TOTALARANUSA,0)),2)
							set @MontoExentofinal=(@PIB_ADVMNIMPUSA)
	
						end
						else
						begin  
							set @PI_IMPORTECONTRSINRECARGOS=0
							set @PI_IMPORTECONTRSINRECARGOSUSD=0							set @MontoExentofinal=isnull((@PIB_ADVMNIMPMEX),0)
						end
	
				
						set @PIB_IMPORTECONTR=isnull((@PI_IMPORTECONTRSINRECARGOS*@FactorAct),0) 
						set @PIB_IMPORTECONTRUSD=isnull((@PI_IMPORTECONTRSINRECARGOSUSD*@FactorAct),0) 
				
					
						if (@PI_FECHAPAGO > @PI_FEC_PAG+60) and @PIB_IMPORTECONTR>0
							set @recargo= @PIB_IMPORTECONTR * (@SUMATASA/100)
						else 
							set @recargo=0
	
			
					end
					else
					begin /* si no aplica el articulo 303 */
						set @PI_IMPORTECONTRSINRECARGOS=round(@PIB_ADVMNIMPMEX,2)
						set @PI_IMPORTECONTRSINRECARGOSUSD=round(@MontoIgi,2)
						set @PIB_IMPORTECONTR=isnull((@PI_IMPORTECONTRSINRECARGOS*@FactorAct),0) 
						set @PIB_IMPORTECONTRUSD=isnull((@PI_IMPORTECONTRSINRECARGOSUSD*@FactorAct),0) 
				
						if (@PI_FECHAPAGO > @PI_FEC_PAG+60) and @PIB_IMPORTECONTR>0
	
							set @recargo= @PIB_IMPORTECONTR * (@SUMATASA/100)
						else
							set @recargo=0
	
	
						set @MontoExentofinal=0
					end	
					
					
					UPDATE TempPEDIMPDETBFed
					SET PIB_ADVMNIMPMEX = isnull(@PIB_ADVMNIMPMEX,0),
					PIB_EXCENCION = isnull(@MontoExentofinal,0), 
					PIB_IMPORTECONTRSINRECARGOS = isnull(@PI_IMPORTECONTRSINRECARGOS,0),
					PIB_IMPORTERECARGOS= isnull(@recargo,0),
					PIB_IMPORTECONTR = isnull(@PIB_IMPORTECONTR,0),  /*actualizada */
					PIB_IMPORTECONTRUSD = isnull(@PIB_IMPORTECONTRUSD,0),
					PIB_VALORMCIANOORIG = isnull(@PIB_VALORMCIANOORIG,0)
					WHERE FED_INDICED = @FED_INDICED 
		
				end
	
	
		fetch next from cur_pedimpdetb303Fedb into @FED_INDICED, @picodigo, @PIB_DESTNAFTA
		end
	
		close cur_pedimpdetb303Fedb
		deallocate cur_pedimpdetb303Fedb
			

		UPDATE dbo.PEDIMPDETB
		SET     dbo.PEDIMPDETB.PIB_VALORMCIANOORIG= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_VALORMCIANOORIG,0), 
			dbo.PEDIMPDETB.PIB_ADVMNIMPUSA= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_ADVMNIMPUSA,0), 
			dbo.PEDIMPDETB.PIB_ADVMNIMPMEX= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_ADVMNIMPMEX,0), 
			dbo.PEDIMPDETB.PIB_EXCENCION= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_EXCENCION,0), 
			dbo.PEDIMPDETB.PIB_IMPORTECONTRSINRECARGOS= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_IMPORTECONTRSINRECARGOS,0), 
			dbo.PEDIMPDETB.PIB_IMPORTECONTR= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_IMPORTECONTR,0), 
			dbo.PEDIMPDETB.PIB_IMPORTECONTRUSD= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_IMPORTECONTRUSD,0), 
			dbo.PEDIMPDETB.PIB_IMPORTERECARGOS= isnull(dbo.VTEMPPEDIMPDETBFED.PIB_IMPORTERECARGOS,0)
		FROM         dbo.PEDIMPDETB INNER JOIN
		                      dbo.VTEMPPEDIMPDETBFED ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.VTEMPPEDIMPDETBFED.PIB_INDICEB
		WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo)

	end
	else	-- no detallado, por agrupacion saai
	begin

		select @PIB_DESTNAFTA=PIB_DESTNAFTA from pedimpdetb where pib_indiceb=@PIB_INDICEB


		if exists (select * from  dbo.VDATOSPEDEXPPAGOUSA WHERE PIB_INDICEB = @PIB_INDICEB)
		begin
			SELECT     @TOTALARANUSA=sum(isnull(TOTALARANUSA,0)), @PIB_ADVMNIMPUSA=sum(isnull(TOTALARANUSAMN,0))
			FROM         dbo.VDATOSPEDEXPPAGOUSA
			WHERE PIB_INDICEB = @PIB_INDICEB
			GROUP BY PIB_INDICEB
		end
		else
		begin
			set @TOTALARANUSA=0
			set @PIB_ADVMNIMPUSA=0

		end

		if exists (select * from dbo.VDATOSPEDEXPPAGOMEX WHERE PIB_INDICEB = @PIB_INDICEB)
		begin
			SELECT     @PIB_VALORMCIANOORIG=SUM(isnull(VALORMERCNOORIGMN,0)), @MontoIgi=SUM(isnull(MONTOIGIMXMN/@PI_TIP_CAMPAGO,0)),
				@PIB_ADVMNIMPMEX=SUM(isnull(MONTOIGIMXMN,0))
			FROM         dbo.VDATOSPEDEXPPAGOMEX
			WHERE PIB_INDICEB = @PIB_INDICEB
			GROUP BY PIB_INDICEB
		end
		else
		begin
			set     @PIB_VALORMCIANOORIG=0
			set @MontoIgi=0
			set @PIB_ADVMNIMPMEX=0
		end
		

			UPDATE PEDIMPDETB
			SET PIB_ADVMNIMPUSA = @PIB_ADVMNIMPUSA
			WHERE PIB_INDICEB = @PIB_INDICEB


			if @PIB_DESTNAFTA='N'	/* cuando el destino es no nafta no se paga nada */
			begin
				UPDATE PEDIMPDETB
				SET PIB_ADVMNIMPMEX = 0,
				PIB_EXCENCION = 0, 
				PIB_IMPORTECONTRSINRECARGOS = 0,
				PIB_IMPORTERECARGOS= 0,
				PIB_IMPORTECONTR = 0,  
				PIB_IMPORTECONTRUSD = 0,  
				PIB_VALORMCIANOORIG = isnull(@PIB_VALORMCIANOORIG,0)
				WHERE PIB_INDICEB = @PIB_INDICEB
			end
			else
			begin--1
				if @cp_art303='S'
				begin /* si aplica el articulo 303 */
					if @PIB_ADVMNIMPMEX >@PIB_ADVMNIMPUSA
					begin
						-- sin actualizar
						set @PI_IMPORTECONTRSINRECARGOS=round(((@PIB_ADVMNIMPMEX)-isnull(@PIB_ADVMNIMPUSA,0)),2)
						set @PI_IMPORTECONTRSINRECARGOSUSD=round(((@MontoIgi)-isnull(@TOTALARANUSA,0)),2)
						set @MontoExentofinal=(@PIB_ADVMNIMPUSA)

					end
					else
					begin  
						set @PI_IMPORTECONTRSINRECARGOS=0
						set @PI_IMPORTECONTRSINRECARGOSUSD=0						set @MontoExentofinal=(@PIB_ADVMNIMPMEX)
					end

			
					set @PIB_IMPORTECONTR=isnull((@PI_IMPORTECONTRSINRECARGOS*@FactorAct),0) 
					set @PIB_IMPORTECONTRUSD=isnull((@PI_IMPORTECONTRSINRECARGOSUSD*@FactorAct),0) 
			
				
					if (@PI_FECHAPAGO > @PI_FEC_PAG+60) and @PIB_IMPORTECONTR>0
						set @recargo= @PIB_IMPORTECONTR * (@SUMATASA/100)
					else 
						set @recargo=0

		
				end
				else
				begin /* si no aplica el articulo 303 */
					set @PI_IMPORTECONTRSINRECARGOS=round(@PIB_ADVMNIMPMEX,2)
					set @PI_IMPORTECONTRSINRECARGOSUSD=round(@MontoIgi,2)
					set @PIB_IMPORTECONTR=isnull((@PI_IMPORTECONTRSINRECARGOS*@FactorAct),0) 
					set @PIB_IMPORTECONTRUSD=isnull((@PI_IMPORTECONTRSINRECARGOSUSD*@FactorAct),0) 
			
					if (@PI_FECHAPAGO > @PI_FEC_PAG+60) and @PIB_IMPORTECONTR>0

						set @recargo= @PIB_IMPORTECONTR * (@SUMATASA/100)
					else
						set @recargo=0


					set @MontoExentofinal=0
				end	
				
				
				UPDATE PEDIMPDETB
				SET PIB_ADVMNIMPMEX = @PIB_ADVMNIMPMEX,
				PIB_EXCENCION = @MontoExentofinal, 
				PIB_IMPORTECONTRSINRECARGOS = isnull(@PI_IMPORTECONTRSINRECARGOS,0),
				PIB_IMPORTERECARGOS= isnull(@recargo,0),
				PIB_IMPORTECONTR = isnull(@PIB_IMPORTECONTR,0),  /*actualizada */
				PIB_IMPORTECONTRUSD = isnull(@PIB_IMPORTECONTRUSD,0),
				PIB_VALORMCIANOORIG = isnull(@PIB_VALORMCIANOORIG,0)
				WHERE PIB_INDICEB = @PIB_INDICEB
	
			end
	end


		
		IF NOT EXISTS (SELECT * FROM PEDIMPDETIDENTIFICA WHERE PIB_INDICEB=@PIB_INDICEB AND IDE_CODIGO=114)
		begin

			 EXEC SP_GETCONSECUTIVO @TIPO='PIID',@VALUE=@CONSECUTIVO OUTPUT

			 insert into PEDIMPDETIDENTIFICA (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_TIPO)
			values (@CONSECUTIVO, @PIB_INDICEB, 114, 17, 'Regla  3.3.28., numeral 2.*', 'C')
		end
	

	select @PIID_CODIGO=max(piid_codigo) from pedimpdetidentifica 

	update consecutivo
	set cv_codigo =  isnull(@PIID_CODIGO,0) + 1
	where cv_tipo = 'PIID'


	exec sp_fillpedExpArt303 @picodigo

GO
