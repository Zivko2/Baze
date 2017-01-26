SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_fillpedimpdetB] (@picodigo int, @user int, @concilia char(1)='N')   as

SET NOCOUNT ON 
declare @pi_movimiento char(1), @ccp_tipo varchar(5), @cp_clave varchar(5), @pi_tip_cam decimal(38,6), @cf_pagocontribucion char(1), 
@FechaActual varchar(10), @hora varchar(15), @contribsum decimal(38,6), @em_codigo int, @consecutivo int, @X smallint,
@PIB_INDICEB int, @MCA varchar(150), @MOD varchar(150), @SERIE varchar(150), @PIC_EQUIPADOCON varchar(1100), @valores varchar(1100)


	select  @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)
	select @cp_clave =cp_clave from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo)

	select @pi_movimiento=pi_movimiento, @pi_tip_cam=pi_tip_cam from pedimp where pi_codigo=@picodigo

	select @cf_pagocontribucion=cf_pagocontribucion from configuracion

	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


	exec BorradoPedImpDetB @picodigo

--	if exists (select * from pedimpdetb where pi_codigo=@picodigo)
--	delete from pedimpdetb where pi_codigo=@picodigo

	exec SP_CreaVFillPedImpDetB @picodigo

    --glr (16-sep-2010)
    --cuando la tabla estaba vacía se obtenía NULL y ocurría un error al intentar
    --cambiar la semilla, ahora el consecutivo queda en un 1 en dicho caso
    set @consecutivo = isnull((select max([PIB_IndiceB]) + 1
                               from   PedimpDetB), 1)


	dbcc checkident (Pedimpdetb, reseed, @consecutivo) WITH NO_INFOMSGS


 	--IF (SELECT PI_LLENASECUENCIADETB FROM CONFIGURAPEDIMENTO)='S' OR
	 IF (SELECT PICF_PEDIMPSAAISINAGRUP FROM PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='S'--  no se hace ninguna agrupacion
	begin
		SET @X=0 	
		Update pedimpdet 
		SET PID_SECUENCIA=@X,@X=@X+1 
		Where pi_codigo=@picodigo

		update PEDIMPSAAICONFIG
		set PICF_AGRUPASAAISEC='S'
		WHERE PI_CODIGO=@picodigo
	end


	if (select PICF_AGRUPASAAISEC from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
	begin
		if (select PICF_SAAIDIVPA from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
		begin
			if (select PICF_SAAIDIVCOSGEN from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N' 
			begin
				--print 'sp_fillpedimpdetBSinPa'
					exec fillpedimpdetBSinPa @picodigo, @pi_movimiento, @user	/*inserta detalle B del pedimento */
			end
			else
			begin
				--print 'sp_fillpedimpdetBSinPaCosGen'
					exec fillpedimpdetBSinPaCosGen @picodigo, @pi_movimiento, @user	/*inserta detalle B del pedimento */
			end
	
		end
		else
		begin
			if (select PICF_SAAIDIVCOSGEN from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N' 
			begin
				--print 'sp_fillpedimpdetBPa'
					exec fillpedimpdetBPa @picodigo, @pi_movimiento, @user	 /*inserta detalle B del pedimento */
			end
			else
			begin
				--print 'sp_fillpedimpdetBPaCosGen'
					exec fillpedimpdetBPaCosGen @picodigo, @pi_movimiento, @user	/*inserta detalle B del pedimento */
			end
		end
	end
	else
	begin
		exec fillpedimpdetBSec @picodigo, @pi_movimiento, @user	/*inserta detalle B del pedimento */
	end	

/*=========================== Inicio actualizacion de la tabla pedimpdetbcontribucion ============================*/


	begin 
	
		delete from pedimpdetbcontribucion where pi_codigo =@picodigo 

		delete from pedimpdetbcontribucion where pib_indiceb in (select pib_indiceb from pedimpdetb where pi_codigo=@picodigo)

		-- insercion de advalorem como contribuciones
		if (select pi_llenaAdvDetb from configurapedimento)='S'
		exec sp_CalculaAdvalorem @picodigo, @pi_movimiento, @user
	

		-- insercion de iva, dta  y cuotas compensatorias como contribuciones
		if (select pi_llenaIVADTACC from configurapedimento)='S'
		begin
			if @concilia<>'S'
			exec sp_CalculoDTAIVA @picodigo, @user
		end
	

		UPDATE pedimpdetbcontribucion
		SET PIB_CONTRIBTOTMN= -1
		WHERE PI_CODIGO = @picodigo AND PIB_CONTRIBPOR = -1


		-- insercion de recargos para cuando se hace actualizacion

		if @ccp_tipo='CN' and @cp_clave='F4' and exists(select * from vrecargoF4 where pi_codigo=@picodigo)
		begin
	
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Calculando Recargos ', 'Calculating Surcharges ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	
	
	
			select @contribsum= sum(PIB_CONTRIBTOTMN) from pedimpdetbcontribucion where pi_codigo=@picodigo
	
			if exists (select * from pedimpcontribucion where pi_codigo =@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='7'))
			delete from pedimpcontribucion where pi_codigo=@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='7')
	
		
			insert into pedimpcontribucion(pi_codigo, con_codigo, PIT_CONTRIBTOTMN, PG_CODIGO, TTA_CODIGO)
			select @picodigo, (select con_codigo from contribucion where con_clave='7'), round(((sumatasa/100)*@contribsum),0), 
				(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '2') 
			from vrecargoF4
			where pi_codigo=@picodigo and round(((sumatasa/100)*@contribsum),0) is not null
		end



		if @ccp_tipo='RG' and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S'
		begin

			SELECT     case when ceiling(DATEDIFF(day, dbo.PIDescarga.PID_FECHAVENCE, GETDATE())/15)*
			(select CF_MULTAEXCPLAZO from CONFIGURACION)> dbo.KARDESPED.KAP_CANTDESC * dbo.PEDIMPDET.PID_COS_UNIGEN*dbo.PEDIMP.PI_TIP_CAM
			then dbo.KARDESPED.KAP_CANTDESC * dbo.PEDIMPDET.PID_COS_UNIGEN*dbo.PEDIMP.PI_TIP_CAM
			else ceiling(DATEDIFF(day, dbo.PIDescarga.PID_FECHAVENCE, GETDATE())/15) *
			(select CF_MULTAEXCPLAZO from CONFIGURACION) end as valor
			into #Valores
			FROM         dbo.PEDIMP INNER JOIN
			                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO RIGHT OUTER JOIN
			                      dbo.KARDESPED INNER JOIN
			                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED INNER JOIN
			                      dbo.PIDescarga ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.PIDescarga.PID_INDICED ON 
			                      dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_FACT RIGHT OUTER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
			WHERE     (dbo.FACTEXP.PI_RECTIFICA = @picodigo) OR
			                      (dbo.FACTEXP.PI_CODIGO = @picodigo)


						
			if exists (select * from pedimpcontribucion where pi_codigo =@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='11'))
			delete from pedimpcontribucion where pi_codigo=@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='11')
	
		
			insert into pedimpcontribucion(pi_codigo, con_codigo, PIT_CONTRIBTOTMN, PG_CODIGO, TTA_CODIGO)
			select @picodigo, (select con_codigo from contribucion where con_clave='11'), round((select sum(valor) from #valores),0), 
				(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '2') 
			from pedimp
			where pi_codigo=@picodigo
			
		end
	
		-- Actualizacion de la tabla pedimpdetbidentifica
	end



	

		if (select pi_llenaIdentificaDet from configurapedimento)='S'
		begin

			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Calculando Identificadores Agrupacion SAAI ', 'Calculating Identificators SAAI Group ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
	

			Exec sp_fillpedimpdetidentifica @picodigo, @pi_movimiento, @ccp_tipo
	
			exec sp_fillpedimpdetPerm @picodigo
		end

		if @ccp_tipo='RE'
		begin

			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Calculando Diferencias entre pedimento R1-Origial ', 'Calculating Diferences between Orign Ped.-R1 ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

			exec SP_CALCULADIFCIONTRIBR1 @picodigo

		end

		if (select pi_llenaSecuenciaDetb from configurapedimento)='S'
		begin

			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Calculando Secuencia Agrupacion SAAI ', 'Calculating Secuence SAAI Group ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


			-- la agrupacion saai no se genero por secuencia, se lleno la secuencia B y se pasa al detalle
			if (select ISNULL(PICF_AGRUPASAAISEC,'N') from PEDIMPSAAICONFIG WHERE PI_CODIGO=@picodigo)='N'
			begin
		
				UPDATE dbo.PEDIMPDET
				SET     dbo.PEDIMPDET.PID_SECUENCIA= dbo.PEDIMPDETB.PIB_SECUENCIA
				FROM         PEDIMPDETB INNER JOIN
			                      PEDIMPDET ON PEDIMPDETB.PIB_INDICEB = PEDIMPDET.PIB_INDICEB 
				WHERE   dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO 
				AND  (PEDIMPDETB.PI_CODIGO = @picodigo) AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
		
			end

		end

		update pedimp
		set pi_cuentadetb=(select isnull(count(*),0) from pedimpdetb where pedimpdetb.pi_codigo=pedimp.pi_codigo)
		where pi_codigo=@picodigo



	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Llenando Observaciones (Mca, Mod y Ser) ', 'Fillin Comments (Mca, Mod y Ser) ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)



	DECLARE cur_Observa CURSOR FOR
		SELECT PIB_INDICEB, replace(replace(PIC_MARCA,'N/A',''),' ',''), replace(replace(PIC_MODELO,'N/A',''),' ',''), replace(replace(PIC_SERIE,'N/A',''),' ',''), replace(replace(PIC_EQUIPADOCON,'N/A',''),' ','')
		FROM         PedImpCont inner join pedimpdet 
			on pedimpdet.pid_indiced=pedimpcont.pid_indiced
		where pedimpdet.pi_codigo=@picodigo
		group by PIB_INDICEB, PIC_MARCA, PIC_MODELO, PIC_SERIE, PIC_EQUIPADOCON
		order by PIB_INDICEB
	open cur_Observa
		FETCH NEXT FROM cur_Observa INTO @PIB_INDICEB, @MCA, @MOD, @SERIE, @PIC_EQUIPADOCON
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
			IF @MCA<>'' and @MCA<>'N/A'
			SET @MCA='MCA.: '+@MCA
	
			IF @MOD<>'' and @MOD<>'N/A'
			SET @MOD =', MOD.: '+@MOD
	
			IF @SERIE<>'' and @SERIE<>'N/A'
			SET @SERIE=', SER.: '+@SERIE
			
			IF @PIC_EQUIPADOCON<>'' and @PIC_EQUIPADOCON<>'N/A'
			SET @PIC_EQUIPADOCON=', VIENE CON: '+@PIC_EQUIPADOCON
	
			SET @valores = @MCA+@MOD+@SERIE+@PIC_EQUIPADOCON

			IF RTRIM(LTRIM(@valores))<>''	
			UPDATE PEDIMPDETB
			SET PIB_OBSERVA=ISNULL(PIB_OBSERVA,'')+' '+@valores
			WHERE PIB_INDICEB=@PIB_INDICEB
	
		FETCH NEXT FROM cur_Observa INTO @PIB_INDICEB, @MCA, @MOD, @SERIE, @PIC_EQUIPADOCON
	
	END
	
	CLOSE cur_Observa
	DEALLOCATE cur_Observa

	--Se trate de material de empaque, as¡ como al material de embalaje para transporte.

	UPDATE PEDIMPDETB
	SET PIB_OBSERVA=(case when
			  (select max(ti_codigo) from pedimpdet where pib_indiceb=pedimpdetb.pib_indiceb 
			  having max(ti_codigo) in (select ti_codigo from tipo where ti_nombre='EMPAQUES Y ENVASES' or ti_nombre='ETIQUETAS Y FOLLETOS')) is null then
			'APLICACION DE LA REGLA 16 DEL TLCAN, Regla de Comercio Exterior 3.3.27'
			  else
			--Yolanda Avila
			--2010-10-12
			--'APLICACION DE LA REGLA 16 DEL TLCAN, Regla de Comercio Exterior 3.3.27 ultimo parrafo subinciso 9' end)
			'IMPORTACION TEMPORAL DE MATERIAL DE EMPAQUE CON BASE EN LA REGLA 1.16.13 CUARTO PARRAFO FRACCION II INCISO i) DE LAS RCGMCE, EL ARTICULO 15 FRACCION VI DEL DECRETO IMMEX, Y LA REGLA 16 DE LAS REGLAS EN MATERIA ADUANERA DEL TLCAN, EN VIGOR' end)
	WHERE PIB_SERVICIO='S' AND PI_CODIGO=@picodigo


GO
