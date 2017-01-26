SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedimento] (@picodigo int, @user int, @TipoMov char(1)='E')   as

SET NOCOUNT ON
declare @CCP_TIPO varchar(5), @ccptipo2 varchar(5), @pi_movimiento varchar(1), @FechaActual varchar(10), @hora varchar(15), @pi_folio varchar(25), 
@em_codigo int, @totalpartidas int, @pi_rectifica int, @fc_codigo int, @fc_foliocl varchar(25), @ad_descl int, @fc_patentecl varchar(5), @cp_codigov int, @fc_fecha varchar(11)


	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


	if exists (select * from IntradeGlobal.dbo.Avance where AVA_MENSAJENO=2 and em_codigo=@em_codigo and sysuslst_id=@user)
	delete from IntradeGlobal.dbo.Avance where AVA_MENSAJENO=2  and em_codigo=@em_codigo and sysuslst_id=@user


	if not exists(select * from PEDIMPSAAICONFIG where pi_codigo=@picodigo) 
	  insert into PEDIMPSAAICONFIG(PI_CODIGO, PICF_SAAIDIVCOSGEN, PICF_SAAIDIVPA, PICF_SAAIDIVDESC, PICF_AGRUPASAAISEC, PICF_APLICANOMS, PICF_SAAIDETDIVFACT, PICF_IVAPROPORCIONAL, PICF_PEDIMPSINAGRUP, PICF_SAAIDETDIVPO, PICF_PEDIMPSECFACT, PICF_PEDIMPSAAISINAGRUP) 
	  SELECT @picodigo, ISNULL(CF_SAAIDIVCOSGEN,'N'), ISNULL(CF_SAAIDIVPA,'N'), ISNULL(CF_SAAIDIVDESC,'N'), ISNULL(CF_AGRUPASAAISEC,'N'), ISNULL(CF_APLICANOMS,'S'), ISNULL(CF_SAAIDETDIVFACT,'N'), 
	  ISNULL(CF_IVAPROPORCIONAL,'S'), isnull(CF_PEDIMPSINAGRUP, 'N'), isnull(CF_SAAIDETDIVPO,'N'), isnull(CF_PEDIMPSECFACT, 'N'), isnull(CF_PEDIMPSINAGRUP, 'N') FROM CONFIGURACION


	if (select CF_GENAUTFACTEXPPO from configuracion)='S'
	update PEDIMPSAAICONFIG
	set PICF_PEDIMPSINAGRUP='S'
	WHERE PI_CODIGO=@picodigo


	SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO
	IN (SELECT CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)

	select @pi_movimiento=pi_movimiento, @pi_rectifica=pi_rectifica from pedimp where pi_codigo=@picodigo

	select @ccptipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@pi_rectifica)


	select @fc_codigo=isnull(fc_codigo,0) from pedimp where pi_codigo=@picodigo


	if @fc_codigo<>0 and (@CCP_TIPO IN ('EV', 'IV', 'VT') or @ccptipo2 IN ('EV', 'IV', 'VT'))
	begin
		select @fc_foliocl=isnull(fc_foliocl,''), @ad_descl=isnull(ad_descl,0), @fc_patentecl=isnull(fc_patentecl,''),
		@cp_codigov=cp_codigo, @fc_fecha=convert(varchar(11),fc_fecha,101) from factcons where fc_codigo=@fc_codigo


		if @fc_foliocl<>'' and not exists(select * from pedimpvirtual where pi_codigo=@picodigo and pi_pedvirtual=@fc_foliocl)
		insert into PEDIMPVIRTUAL(PI_CODIGO, AD_CODIGO, PI_PATENTE, PI_PEDVIRTUAL, CP_CODIGO, AR_CODIGO, PI_FECHA, PI_CANTIDAD, ME_CODIGO)
		values(@picodigo, @ad_descl, @fc_patentecl, @fc_foliocl, @cp_codigov, 0, @fc_fecha, 0, 0)
		
	end



	if @TipoMov='E' 
	begin

			update pedimp
			set pi_ligacorrecta='N'
			where pi_codigo=@picodigo
		
			update factimp
			set mo_codigo=163
			where mo_codigo is null
			and pi_codigo=@picodigo
		
		
			select @pi_folio=pi_folio from pedimp where pi_codigo=@picodigo
		
		
			select @FechaActual = convert(varchar(10), getdate(),101)
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
		
		              Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		              values(@user,2,'Inicio de Proceso ','Beginning Process ',@FechaActual,@Hora, @em_codigo)
		
		
		
		
		
			if exists (select * from pedimpdet where pi_codigo =@picodigo) or exists(select * from pidescarga where pi_codigo =@picodigo)
			begin
				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
				
				/*===================== Borrando detalles ======================*/
				
				Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
				values(@user,2,'Borrando detalle anterior ','Deleting Previous Detail ',@FechaActual,@Hora, @em_codigo)
				
				exec BorradoPedImpDet @picodigo
			--	delete from pedimpdet where pi_codigo=@picodigo	
			--	delete from pidescarga where pi_codigo=@picodigo	
			end
		
	
	
			exec sp_fillpedimptransporte @picodigo
	
	
	
			if @CCP_TIPO='RE' 
			begin
	
				if @ccptipo2='CN' or @ccptipo2='RP' or (@ccptipo2='RG'  and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@pi_rectifica)='S')
				begin
					--print 'entra CN2'
					if exists (select * from factexp where pi_rectifica=@picodigo and fe_codigo in (select fe_codigo from factexpdet group by fe_codigo))
					exec sp_fillpedimp_rect @picodigo, @user
	
					exec SP_ACTUALIZAESTATUSPEDIMP @PICODIGO
				end
				else
				begin
					delete from dbo.PIDescarga where pi_codigo in (select pi_codigo from pedimprect where pi_no_rect=@picodigo)
		
					if exists (select * from factimp where pi_rectifica=@picodigo and fi_codigo in (select fi_codigo from factimpdet group by fi_codigo))
						exec sp_fillpedimp_rect @picodigo, @user
					else
						if exists (select * from factimp where pi_codigo=@picodigo and fi_codigo in (select fi_codigo from factimpdet group by fi_codigo))
						exec sp_fillpedimp @picodigo, @user
				end
			end
			else
			begin
				if @CCP_TIPO='CN' or @CCP_TIPO='RP' or (@CCP_TIPO='RG'  and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S')
				begin
		                                 if exists (select * from factexp where pi_codigo=@picodigo and fe_codigo in (select fe_codigo from factexpdet group by fe_codigo))-- or 
					--(select PI_GENERAF4KARDES from pedimp where pi_codigo=@picodigo)='S'
					exec sp_fillpedexpReg @picodigo, @user
				end
				else
				if exists (select * from factimp where pi_codigo=@picodigo and fi_codigo in (select fi_codigo from factimpdet group by fi_codigo))
				exec sp_fillpedimp @picodigo, @user
			end
	
	
	
			update pedimp
			set pi_cuentadet=(select count(pid_indiced) from pedimpdet where pi_codigo=@picodigo)
			where pi_codigo =@picodigo
		
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values(@user,2,'Proceso Terminado ','Process Completed ',@FechaActual,@Hora, @em_codigo)
		
		
			UPDATE IMPORTACIONEXCEL
			SET IE_SELFACT='N'
		
			IF (select mt_codigo from pedimp where pi_codigo=@picodigo) is null
			begin
				UPDATE PEDIMP
				SET MT_CODIGO=(select mt_codigo from mediotran where mt_cla_ped='7'), 
				MT_SALIDA=(select mt_codigo from mediotran where mt_cla_ped='7'), 
				MT_ARRIBO=(select mt_codigo from mediotran where mt_cla_ped='7')
				WHERE     (PI_CODIGO = @picodigo)
			end
	

			if (select CF_GENAUTFACTEXPPO from configuracion)='S'
			begin
				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
				Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
				values(@user,1.9,'Generando Documentos de Salida Base PO ','Generating Export Documents basis PO ',@FechaActual,@Hora, @em_codigo)

				--exec SP_GENAUTFACTEXPPO @picodigo
				--Yolanda 2008-12-31	
 				exec SP_GENAUTFACTEXPPO @picodigo, 0, 1


			end
	
			exec SP_CREATABLALOG 60
			insert into sysusrlog60 (user_id, mov_id, referencia, frmtag, fechahora)
			values (@user, 2, 'Reproceso de Pedimento ('+@pi_folio+')', 60, getdate())
		
			--print @CCP_TIPO
		
			if @CCP_TIPO<>'CN' and @CCP_TIPO<>'RP'  AND @ccptipo2<>'RP' AND @ccptipo2<>'CN' or (@CCP_TIPO='RG' and (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)<>'S') 
				exec sp_ligacorrecta @picodigo
			else
			begin
				update pedimp
				set pi_ligacorrecta='S'
				where pi_codigo=@picodigo
			end
	
	
	end	
	else  /*====================================SALIDAS =======================================*/
	begin
			update pedimp
			set pi_ligacorrecta='N'
			where pi_codigo=@picodigo
	
			update factexp
			set mo_codigo=163
			where mo_codigo is null
			and pi_codigo=@picodigo
	
			select @pi_folio=pi_folio from pedimp where pi_codigo=@picodigo
		
		
			select @FechaActual = convert(varchar(10), getdate(),101)
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
		
		             Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
		           values(@user,2,'Inicio de Proceso ','Beginning Process ',@FechaActual,@Hora, @em_codigo)
		
		
		
		
			if exists (select * from pedimpdet where pi_codigo =@picodigo) or exists(select * from pidescarga where pi_codigo =@picodigo)
			begin
				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
				
				/*===================== Borrando detalles ======================*/
				
				Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
				values(@user,2,'Borrando detalle anterior ','Deleting Previous Detail ',@FechaActual,@Hora, @em_codigo)
				
				exec BorradoPedImpDet @picodigo
			--	delete from pedimpdet where pi_codigo=@picodigo	
			--	delete from pidescarga where pi_codigo=@picodigo	
			end
	
	
			exec sp_fillpedimptransporte @picodigo
	
	
	
	
			if @CCP_TIPO='RE'
			begin
				if exists (select * from factexp where pi_rectifica=@picodigo and fe_codigo in (select fe_codigo from factexpdet group by fe_codigo))
				exec sp_fillpedimp_rect @picodigo, @user
			end
			else
			begin
				if @CCP_TIPO='CT'
				begin 
					exec sp_fillpedexpCompl @picodigo, @user
	
					select @totalpartidas=pi_cuentadet from pedimp where pi_codigo=@picodigo 
				
				
					if (select cf_pedimpdetb from configuracion)='S' and @totalpartidas>0
					begin
						exec sp_fillpedimpdetB @picodigo, @user --inserta detalle B del pedimento 
					end
				
	
					--exec sp_fillpedExpComplArt303 @picodigo
				end
				else
	                                          if exists (select * from factexp where pi_codigo=@picodigo and fe_codigo in (select fe_codigo from factexpdet group by fe_codigo))						
				   begin
					if (@CCP_TIPO<>'CN'  or (select pi_desp_equipo from pedimp where pi_codigo=@picodigo)='S') and
					   (@CCP_TIPO<>'RG'  or (select pi_desp_equipo from pedimp where pi_codigo=@picodigo)='N') 
						exec sp_fillpedexp @picodigo, @user
	
				   end
			end
	
	
	
			update pedimp
			set pi_cuentadet=(select count(pid_indiced) from pedimpdet where pi_codigo=@picodigo)
			where pi_codigo =@picodigo
		

		
		
			UPDATE IMPORTACIONEXCEL
			SET IE_SELFACT='N'
		
			IF (select mt_codigo from pedimp where pi_codigo=@picodigo) is null
			begin
				UPDATE PEDIMP
				SET MT_CODIGO=(select mt_codigo from mediotran where mt_cla_ped='7'), 
				MT_SALIDA=(select mt_codigo from mediotran where mt_cla_ped='7'), 
				MT_ARRIBO=(select mt_codigo from mediotran where mt_cla_ped='7')
				WHERE     (PI_CODIGO = @picodigo)
			end
		
			exec SP_CREATABLALOG 60
			insert into sysusrlog60 (user_id, mov_id, referencia, frmtag, fechahora)
			values (@user, 2, 'Reproceso de Pedimento ('+@pi_folio+')', 60, getdate())
		
		
		
			if @CCP_TIPO<>'CT' and @CCP_TIPO<>'CN'
			begin
				select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
			
				Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
				values(@user,2,'Verificando Liga Correcta ','Verified Correct link ',@FechaActual,@Hora, @em_codigo)

				exec sp_ligacorrecta @picodigo
			end
			else
			begin
				update pedimp
				set pi_ligacorrecta='S'
				where pi_codigo=@picodigo
			end
		


			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
		
			Insert Into IntradeGlobal.dbo.Avance (sysuslst_id,ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values(@user,2,'Proceso Terminado ','Process Completed ',@FechaActual,@Hora, @em_codigo)

	end

GO
