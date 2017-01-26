SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [fillpedExpDetBArt303fed] (@picodigo int, @Complementario char(1) ='N')   as

SET NOCOUNT ON

declare @TotalAranUSA decimal(38,6), @MontoIgi decimal(38,6), @MontoExento decimal(38,6), @PI_TIP_CAMPAGO decimal(38,6), @FED_INDICED int, 
@PI_IMPORTECONTRSINRECARGOS decimal(38,6), @PI_FECHAPAGO datetime, @PI_FEC_PAG datetime, @recargo decimal(38,6), @VINPCMAX decimal(38,6),
@VINPCMIN decimal(38,6), @FactorAct decimal(38,6), @PIB_INDICEB INT, @PIB_VALORMCIANOORIG decimal(38,6), @MontoExentofinal decimal(38,6), @PIB_ADVMNIMPUSA decimal(38,6),
@PIB_ADVMNIMPUSA2 decimal(38,6), @PIB_IMPORTECONTR decimal(38,6), @SUMATASA decimal(38,6), @ccp_tipo varchar(5), @cp_art303 char(1),
@PIB_ADVMNIMPMEX decimal(38,6), @PIB_DESTNAFTA char(1), @CONSECUTIVO int, @PIID_CODIGO int, @PI_IMPORTECONTRSINRECARGOSUSD decimal(38,6),
@PIB_IMPORTECONTRUSD decimal(38,6)

	

	IF NOT EXISTS (SELECT * FROM PEDIMPDETB WHERE PI_CODIGO=@picodigo)
	begin
		exec sp_fillpedimpdetB @picodigo, 1	/*inserta detalle B del pedimento */
	end


	if @Complementario='S'
	begin
		select @PI_TIP_CAMPAGO=pi_tip_cam, @PI_FECHAPAGO=PI_FEC_PAG
		from pedimp where pi_codigo in (select pi_complementa from pedimp where pi_codigo=@picodigo)

		SELECT @PI_FEC_PAG=PI_FEC_PAG
		FROM PEDIMP WHERE PI_CODIGO=@picodigo

	end
	else
	begin
		SELECT @PI_TIP_CAMPAGO=PI_TIP_CAMPAGO, @PI_FECHAPAGO=PI_FECHAPAGO,
		@PI_FEC_PAG=PI_FEC_PAG
		FROM PEDIMP WHERE PI_CODIGO=@picodigo
	end

	
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
			SELECT     @FactorAct=max(round(FACTORACT, 4, 1))
			FROM         dbo.VFACTORACT
			WHERE     (PI_CODIGO = @picodigo)
		
		end
		else 
		begin
			set @FactorAct=1
		end
	
		select @SUMATASA=round(isnull(SUMATASA,0),2) from VRECARGO WHERE PI_CODIGO =@picodigo
	
	



	---------------------------------------------------------------------------- inicia llenado ----------------------------------------------------------------------------------------------------------------

	--if exists (select * from temppedimpdetbfed where fed_indiced in 
	--(select fed_indiced from factexpdet where fe_codigo in (select fe_codigo from factexp where pi_codigo=@picodigo)))

	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOUSA'
	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOMEX'


	/*=========================*/



	DELETE FROM KARDATOSPEDEXPDESC WHERE PI_CODIGOPEDEXP=@picodigo

	INSERT INTO KARDATOSPEDEXPDESC (KAP_PED_CONST, KAP_INDICED_FACT, KAP_INDICED_PED, KAP_CANTDESC, PI_TIP_CAM, PIB_INDICEB, PI_CODIGOPEDEXP, KAP_COS_UNI, 
	                      PID_POR_DEF, KAP_DEF_TIP, KAP_CODIGO, PID_PAGACONTRIB, PA_ORIGEN, AR_IMPMX, SPI_CODIGO, KAP_SECIMP, PID_NOMBRE, PID_NOPARTE, MA_CODIGO)
	SELECT     KAP_PED_CONST, KAP_INDICED_FACT, KAP_INDICED_PED, KAP_CANTDESC, PI_TIP_CAM, PIB_INDICEB, PI_CODIGOPEDEXP, KAP_COS_UNI, 
	                      PID_POR_DEF, KAP_DEF_TIP, KAP_CODIGO, PID_PAGACONTRIB, PA_ORIGEN, AR_IMPMX, SPI_CODIGO, KAP_SECIMP, PID_NOMBRE, PID_NOPARTE, MA_CODIGO
	FROM         VDATOSPEDEXPDESCxPedExpT


	
	DELETE FROM KARDATOSPEDEXPPAGOUSA WHERE PI_CODIGO=@picodigo

	INSERT INTO KARDATOSPEDEXPPAGOUSA (PIB_INDICEB, FED_INDICED, AR_EXPFO, TOTALARANUSAMN, PIB_SECUENCIA, PI_CODIGO, PIB_DESTNAFTA, TOTALARANUSA, 
	FED_RATEIMPFO, TOTALVALORGRAVUSA, TOTALVALORGRAVMN)
	SELECT     PIB_INDICEB, FED_INDICED, AR_EXPFO, TOTALARANUSAMN, PIB_SECUENCIA, PI_CODIGO, PIB_DESTNAFTA, TOTALARANUSA, FED_RATEIMPFO,
	TOTALVALORGRAVUSA, TOTALVALORGRAVMN
	FROM         VDATOSPEDEXPPAGOUSAxPedExp

	/*=========================*/


	SELECT     FED_INDICED, sum(isnull(TOTALARANUSA,0)) AS TOTALARANUSA, sum(isnull(TOTALARANUSAMN,0)) AS TOTALARANUSAMN
	INTO dbo.DATOSPEDEXPPAGOUSA
	FROM         dbo.VDATOSPEDEXPPAGOUSAxPedExp
	WHERE PI_CODIGO = @picodigo
	GROUP BY FED_INDICED

	SELECT     FED_INDICED, SUM(isnull(VALORMERCNOORIGMN,0)) AS VALORMERCNOORIGMN, SUM(isnull(MONTOIGIMXUSD,0)) AS MONTOIGIMXUSD,
		SUM(isnull(MONTOIGIMXMN,0)) AS MONTOIGIMXMN
	INTO dbo.DATOSPEDEXPPAGOMEX
	FROM         dbo.VDATOSPEDEXPPAGOMEXxPedExp
	WHERE PI_CODIGO = @picodigo
	GROUP BY FED_INDICED

	EXEC SP_DROPTABLE 'FACTEXPDET303'

	SELECT     dbo.VFACTEXPDETpib.FED_INDICED, dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_DESTNAFTA
	into dbo.FACTEXPDET303
	FROM         dbo.VFACTEXPDETpib INNER JOIN
	                      dbo.PEDIMPDETB ON dbo.VFACTEXPDETpib.PIB_INDICEB = dbo.PEDIMPDETB.PIB_INDICEB
	WHERE     (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 


	delete from temppedimpdetbfed where fed_indiced in 
	(select fed_indiced from FACTEXPDET303)


	insert into temppedimpdetbfed (FED_INDICED, PIB_INDICEB, PI_CODIGO, PIB_VALORMCIANOORIG, PIB_ADVMNIMPUSA, PIB_ADVMNIMPMEX, PIB_EXCENCION, 
              PIB_IMPORTECONTRSINRECARGOS, PIB_IMPORTECONTR, PIB_IMPORTECONTRUSD, PIB_IMPORTERECARGOS)
	SELECT     FED_INDICED, PIB_INDICEB, @picodigo, 0, 0, 0, 0, 0, 0, 0, 0
	FROM         FACTEXPDET303






--- calculos
	UPDATE TempPEDIMPDETBFed
	SET PIB_ADVMNIMPMEX = 0,
	PIB_EXCENCION = 0, 
	PIB_IMPORTECONTRSINRECARGOS = 0,
	PIB_IMPORTERECARGOS= 0,
	PIB_IMPORTECONTR = 0,  
	PIB_IMPORTECONTRUSD = 0
	WHERE FED_INDICED IN (select fed_indiced from FACTEXPDET303 where pib_destnafta='N')

	UPDATE TempPEDIMPDETBFed
	SET PIB_VALORMCIANOORIG = isnull((SELECT SUM(isnull(DATOSPEDEXPPAGOMEX.VALORMERCNOORIGMN,0)) FROM DATOSPEDEXPPAGOMEX WHERE DATOSPEDEXPPAGOMEX.FED_INDICED = TempPEDIMPDETBFed.fed_indiced),0),
	PIB_ADVMNIMPUSA = isnull((SELECT sum(isnull(DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0)) FROM DATOSPEDEXPPAGOUSA WHERE DATOSPEDEXPPAGOUSA.FED_INDICED = TempPEDIMPDETBFed.fed_indiced),0)
	WHERE FED_INDICED IN (select fed_indiced from FACTEXPDET303)

	if @cp_art303='S'
	begin
		UPDATE TempPEDIMPDETBFed
		SET     PIB_ADVMNIMPMEX = ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN, 0),
		PIB_ADVUSDIMPMEX =ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD, 0),
		PIB_IMPORTECONTRSINRECARGOS=isnull((case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then
					ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) - ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0) else 0 end),0),
		PIB_EXCENCION = isnull((case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then
				TOTALARANUSAMN else MONTOIGIMXMN end),0),
		PIB_IMPORTECONTR=isnull((case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then
				(ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) - ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0))*@FactorAct else 0 end),0),
		PIB_IMPORTECONTRUSD=isnull((case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN, 0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then
				(isnull(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD,0) - isnull(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSA,0))*@FactorAct else 0 end),0),
		PIB_IMPORTERECARGOS=isnull((case when (@PI_FECHAPAGO > @PI_FEC_PAG+60) and (case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then (ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) - ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0))*@FactorAct else 0 end)>0 then	(case when ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) > ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN, 0) then
				(ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0) - ISNULL(dbo.DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0))*@FactorAct else 0 end)*(@SUMATASA/100)
				else 0 end),0)
		FROM         dbo.TempPEDIMPDETBFed INNER JOIN
		                      dbo.FactExpDet303 ON dbo.TempPEDIMPDETBFed.FED_INDICED = dbo.FactExpDet303.fed_indiced LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOMEX ON dbo.FactExpDet303.fed_indiced = dbo.DATOSPEDEXPPAGOMEX.FED_INDICED LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOUSA ON dbo.FactExpDet303.fed_indiced = dbo.DATOSPEDEXPPAGOUSA.FED_INDICED
		WHERE dbo.TempPEDIMPDETBFed.PIB_INDICEB in (select pib_indiceb from pedimpdetb where pib_destnafta<>'N' and pi_codigo=@picodigo)

	end
	else
	begin

		UPDATE TempPEDIMPDETBFed
		SET     PIB_ADVMNIMPMEX = ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0),
		PIB_ADVUSDIMPMEX = ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD,0),
		PIB_IMPORTECONTRSINRECARGOS=ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0),
		PIB_EXCENCION = 0,
		PIB_IMPORTECONTR=ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0),
		PIB_IMPORTECONTRUSD=  isnull(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD*@FactorAct,0),
		PIB_IMPORTERECARGOS=isnull((case when (@PI_FECHAPAGO > @PI_FEC_PAG+60) and ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0)>0 then
				ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0)*(@SUMATASA/100)
				else 0 end),0)
		FROM         dbo.TempPEDIMPDETBFed INNER JOIN
		                      dbo.FactExpDet303 ON dbo.TempPEDIMPDETBFed.FED_INDICED = dbo.FactExpDet303.fed_indiced LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOMEX ON dbo.FactExpDet303.fed_indiced = dbo.DATOSPEDEXPPAGOMEX.FED_INDICED LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOUSA ON dbo.FactExpDet303.fed_indiced = dbo.DATOSPEDEXPPAGOUSA.FED_INDICED
		WHERE dbo.TempPEDIMPDETBFed.PIB_INDICEB in (select pib_indiceb from pedimpdetb where pib_destnafta<>'N' and pi_codigo=@picodigo)	
	end




	declare cur_FactExpDet303Fed cursor for
		SELECT     FED_INDICED, PIB_INDICEB, PIB_DESTNAFTA
		FROM         FACTEXPDET303
	open cur_FactExpDet303Fed
	fetch next from cur_FactExpDet303Fed into @FED_INDICED, @PIB_INDICEB, @PIB_DESTNAFTA
	while (@@fetch_status =0)
	begin



			IF NOT EXISTS (SELECT * FROM PEDIMPDETIDENTIFICA WHERE PIB_INDICEB=@PIB_INDICEB AND IDE_CODIGO=114)
			begin
	
				 EXEC SP_GETCONSECUTIVO @TIPO='PIID',@VALUE=@CONSECUTIVO OUTPUT
	
				 insert into PEDIMPDETIDENTIFICA (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_TIPO)
				values (@CONSECUTIVO, @PIB_INDICEB, 114, 17, 'Regla  3.3.28., numeral 2.*', 'C')
			end

		

	fetch next from cur_FactExpDet303Fed into @FED_INDICED, @PIB_INDICEB, @PIB_DESTNAFTA
	end

	close cur_FactExpDet303Fed
	deallocate cur_FactExpDet303Fed
		
			
	
	select @PIID_CODIGO=max(piid_codigo) from pedimpdetidentifica 
	
	update consecutivo
	set cv_codigo =  isnull(@PIID_CODIGO,0) + 1
	where cv_tipo = 'PIID'



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


	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOUSA'
	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOMEX'
	EXEC SP_DROPTABLE 'FACTEXPDET303'

GO
