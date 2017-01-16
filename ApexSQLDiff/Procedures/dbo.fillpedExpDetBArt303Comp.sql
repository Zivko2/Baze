SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE dbo.[fillpedExpDetBArt303Comp] (@picodigo int, @Complementario char(1) ='N')   as

SET NOCOUNT ON
declare @TotalAranUSA decimal(38,6), @MontoIgi decimal(38,6), @MontoExento decimal(38,6), @PI_TIP_CAMPAGO decimal(38,6), 
@PI_IMPORTECONTRSINRECARGOS decimal(38,6), @PI_FECHAPAGO datetime, @PI_FEC_PAG datetime, @recargo decimal(38,6), @VINPCMAX decimal(38,6),
@VINPCMIN decimal(38,6), @FactorAct decimal(38,6), @PIB_INDICEB INT, @PIB_VALORMCIANOORIG decimal(38,6), @MontoExentofinal decimal(38,6), @TOTALARANUSAMN decimal(38,6),
@TOTALARANUSAMN2 decimal(38,6), @PIB_IMPORTECONTR decimal(38,6), @SUMATASA decimal(38,6), @ccp_tipo varchar(5), @cp_art303 char(1),
@MONTOIGIMXMN decimal(38,6), @PIB_DESTNAFTA char(1), @CONSECUTIVO int, @PIID_CODIGO int, @PI_IMPORTECONTRSINRECARGOSUSD decimal(38,6),
@PIB_IMPORTECONTRUSD decimal(38,6)

	

	IF NOT EXISTS (SELECT * FROM PEDIMPDETB WHERE PI_CODIGO=@picodigo)
	begin
		exec sp_fillpedimpdetB @picodigo, 1	--inserta detalle B del pedimento 
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
			-- se esta truncando a 4 decimales, no redondeando 
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


	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOUSA'
	EXEC SP_DROPTABLE 'pedimpdetb303'

	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOMEX'
	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOUSA'



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

	SELECT PIB_INDICEB, SUM(isnull(VALORMERCNOORIGMN,0)) AS VALORMERCNOORIGMN, SUM(isnull(MONTOIGIMXUSD,0)) AS MONTOIGIMXUSD,
		SUM(isnull(MONTOIGIMXMN,0)) AS MONTOIGIMXMN
	into dbo.DATOSPEDEXPPAGOMEX
	FROM         dbo.VDATOSPEDEXPPAGOMEXxPedExp
	WHERE PI_CODIGO = @picodigo
	GROUP BY PIB_INDICEB

	SELECT PIB_INDICEB, sum(isnull(TOTALARANUSA,0)) AS TOTALARANUSA, sum(isnull(TOTALARANUSAMN,0)) AS TOTALARANUSAMN
	INTO dbo.DATOSPEDEXPPAGOUSA
	FROM         dbo.VDATOSPEDEXPPAGOUSAxPedExp
	WHERE PI_CODIGO = @picodigo
	GROUP BY PIB_INDICEB

		EXEC SP_DROPTABLE 'pedimpdetb303'

		select pib_indiceb, pib_destnafta
		into dbo.pedimpdetb303
		from pedimpdetb
		where pi_codigo=@picodigo


--- calculos
	UPDATE PEDIMPDETB
	SET PIB_ADVMNIMPMEX = 0,
	PIB_EXCENCION = 0, 
	PIB_IMPORTECONTRSINRECARGOS = 0,
	PIB_IMPORTERECARGOS= 0,
	PIB_IMPORTECONTR = 0,  
	PIB_IMPORTECONTRUSD = 0
	WHERE PIB_INDICEB IN (select pib_indiceb from pedimpdetb303 where pib_destnafta='N')

	UPDATE PEDIMPDETB
	SET PIB_VALORMCIANOORIG = isnull((SELECT SUM(isnull(DATOSPEDEXPPAGOMEX.VALORMERCNOORIGMN,0)) FROM DATOSPEDEXPPAGOMEX WHERE DATOSPEDEXPPAGOMEX.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0),
	PIB_ADVMNIMPUSA = isnull((SELECT sum(isnull(DATOSPEDEXPPAGOUSA.TOTALARANUSAMN,0)) FROM DATOSPEDEXPPAGOUSA WHERE DATOSPEDEXPPAGOUSA.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB),0)
	WHERE PIB_INDICEB IN (select pib_indiceb from pedimpdetb303)

	if @cp_art303='S'
	begin
		UPDATE PEDIMPDETB
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
		FROM         dbo.PEDIMPDETB INNER JOIN
		                      dbo.pedimpdetb303 ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.pedimpdetb303.pib_indiceb LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOMEX ON dbo.pedimpdetb303.pib_indiceb = dbo.DATOSPEDEXPPAGOMEX.PIB_INDICEB LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOUSA ON dbo.pedimpdetb303.pib_indiceb = dbo.DATOSPEDEXPPAGOUSA.PIB_INDICEB
		WHERE PEDIMPDETB.pib_destnafta<>'N'

	end
	else
	begin

		UPDATE PEDIMPDETB
		SET     PIB_ADVMNIMPMEX = ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0),
		PIB_ADVUSDIMPMEX = ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD,0),
		PIB_IMPORTECONTRSINRECARGOS=ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN,0),
		PIB_EXCENCION = 0,
		PIB_IMPORTECONTR=ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0),
		PIB_IMPORTECONTRUSD=  isnull(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXUSD*@FactorAct,0),
		PIB_IMPORTERECARGOS=isnull((case when (@PI_FECHAPAGO > @PI_FEC_PAG+60) and ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0)>0 then
				ISNULL(dbo.DATOSPEDEXPPAGOMEX.MONTOIGIMXMN*@FactorAct,0)*(@SUMATASA/100)
				else 0 end),0)
		FROM         dbo.PEDIMPDETB INNER JOIN
		                      dbo.pedimpdetb303 ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.pedimpdetb303.pib_indiceb LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOMEX ON dbo.pedimpdetb303.pib_indiceb = dbo.DATOSPEDEXPPAGOMEX.PIB_INDICEB LEFT OUTER JOIN
		                      dbo.DATOSPEDEXPPAGOUSA ON dbo.pedimpdetb303.pib_indiceb = dbo.DATOSPEDEXPPAGOUSA.PIB_INDICEB
		WHERE PEDIMPDETB.pib_destnafta<>'N'
	end


	declare cur_pedimpdetb303 cursor for
		select pib_indiceb, pib_destnafta
		from pedimpdetb303
		where pib_destnafta<>'N'
	open cur_pedimpdetb303
	fetch next from cur_pedimpdetb303 into @PIB_INDICEB, @PIB_DESTNAFTA
	while (@@fetch_status =0)
	begin


			IF NOT EXISTS (SELECT * FROM PEDIMPDETIDENTIFICA WHERE PIB_INDICEB=@PIB_INDICEB AND IDE_CODIGO=114)
			begin
	
				 EXEC SP_GETCONSECUTIVO @TIPO='PIID',@VALUE=@CONSECUTIVO OUTPUT
	
				 insert into PEDIMPDETIDENTIFICA (PIID_CODIGO, PIB_INDICEB, IDE_CODIGO, IDED_CODIGO, PIID_DESC, PIID_TIPO)
				values (@CONSECUTIVO, @PIB_INDICEB, 114, 17, 'Regla  3.3.28., numeral 2.*', 'C')
			end

		

	fetch next from cur_pedimpdetb303 into @PIB_INDICEB, @PIB_DESTNAFTA
	end

	close cur_pedimpdetb303
	deallocate cur_pedimpdetb303
		
			
	
	select @PIID_CODIGO=max(piid_codigo) from pedimpdetidentifica 
	
	update consecutivo
	set cv_codigo =  isnull(@PIID_CODIGO,0) + 1
	where cv_tipo = 'PIID'

	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOMEX'
	EXEC SP_DROPTABLE 'DATOSPEDEXPPAGOUSA'
	EXEC SP_DROPTABLE 'pedimpdetb303'








GO
