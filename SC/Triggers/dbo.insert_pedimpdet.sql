SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO














CREATE TRIGGER [insert_pedimpdet] ON dbo.PEDIMPDET 
FOR INSERT, update
AS
SET NOCOUNT ON

/*IF EXISTS (SELECT * FROM pedImpDet , Inserted WHERE pedImpDet.pid_indiced = inserted.pid_indiced )
begin
	declare @pid_cant decimal(38,6), @pid_cos_uni decimal(38,6), @pid_can_gen decimal(38,6), @pid_ctot_dls decimal(38,6), @pid_saldogen decimal(38,6),
		@eq_generico decimal(28,14), @pid_can_ar decimal(38,6), @eq_impmx decimal(28,14), @pi_tip_cam decimal(38,6), 
		@pid_val_adu decimal(38,6), @pid_cos_unigen decimal(38,6),  @pi_ft_adu decimal(38,9), 
		@cp_codigo int, @pi_codigo int, @saldo decimal(38,6), @cant decimal(38,6), @afectado char(1), @pi_afectado char(1),
		@pid_descargable char(1), @pid_cos_uniadu decimal(38,6), @pedimpdescargable char(1), @ma_generico int,
		@me_gen int, @me_generico int, @ar_impmx int, @me_arimpmx int, @me_codigo int, @ccp_tipo varchar(5), 
		@pi_movimiento char(1), @pid_indiced int, @pa_origen int, @CF_PAIS_MX int, @CF_PAIS_USA int, @CF_PAIS_CA int,
		@pi_estatus char(1), @pi_ligacorrecta char(1)

	-- pasar en variables los campos del detalle que hay que comparar para ver si aplican los cambios
	select @pid_cant = pid_cant, @pid_cos_uni = pid_cos_uni, @pid_can_gen = pid_can_gen, @pid_ctot_dls = pid_ctot_dls,
	@eq_generico = eq_generico, @pid_can_ar = pid_can_ar, @eq_impmx = eq_impmx,
	@pid_val_adu = pid_val_adu, @pid_cos_unigen = pid_cos_unigen,@pid_cos_uniadu=pid_cos_uniadu,
	@pid_descargable=pid_descargable, @ma_generico=ma_generico, @me_generico=me_generico, @ar_impmx=ar_impmx, @me_arimpmx=me_arimpmx,
	@pid_indiced=pid_indiced, @pa_origen=pa_origen  from pedimpdet where pid_indiced in (select pid_indiced from inserted)

	select @pid_saldogen = pid_saldogen
	from pidescarga where pid_indiced=@pid_indiced

	if @EQ_GENERICO = 0
	set @EQ_GENERICO=1


	SELECT     @pi_tip_cam= isnull(dbo.PEDIMP.PI_TIP_CAM,1), @pi_ft_adu= isnull(dbo.PEDIMP.PI_FT_ADU,1), @afectado = dbo.pedimp.pi_afectado, @pi_afectado = dbo.pedimp.pi_afectado
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
	WHERE     dbo.PEDIMPDET.PID_INDICED in (select pid_indiced from inserted)

	select @pi_codigo= pi_codigo, @pi_movimiento=pi_movimiento, @cp_codigo =cp_codigo, @pi_ligacorrecta=pi_ligacorrecta,
	@pi_estatus= pi_estatus
	from pedimp where pi_codigo in (select pi_codigo from inserted)

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@pi_codigo)


	select @CF_PAIS_MX=CF_PAIS_MX, @CF_PAIS_USA=CF_PAIS_USA, @CF_PAIS_CA=CF_PAIS_CA from configuracion

	SELECT     @pedimpdescargable=dbo.CLAVEPED.CP_DESCARGABLE
	FROM         dbo.PEDIMP LEFT OUTER JOIN
	                      dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
	WHERE     (dbo.PEDIMP.PI_CODIGO = @pi_codigo)


	--   -----------------   Calculos --------------------------

	if update(pid_cant) or update(pid_cos_uni)
	begin
		if (@pid_ctot_dls <> (isnull(@pid_cant, 0) * isnull(@pid_cos_uni, 0)) or @pid_ctot_dls is null) and (@PID_CANT > 0 and @PID_CANT  is not null)
		and (@pid_cos_uni > 0 and @pid_cos_uni  is not null)
			update pedimpdet 
			set PID_CTOT_DLS = isnull(PID_CANT,0) * isnull(PID_COS_UNI,0)
			where pid_indiced in (select pid_indiced from inserted) 
			and (pid_ctot_dls <> (pid_cant * pid_cos_uni) or pid_ctot_dls is null)
			and (@pid_cos_uni > 0 and @pid_cos_uni  is not null)
			and (@PID_CANT > 0 and @PID_CANT  is not null)

	end

	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if update(pid_cant) or update(eq_impmx)
	if (@pid_can_ar <> (isnull(@pid_cant,0) * isnull(@eq_impmx,1)) or @pid_can_ar is null) and (@PID_CANT > 0 and @PID_CANT  is not null)
		update pedimpdet 
		set PID_CAN_AR = isnull(PID_CANT,0) * isnull(EQ_IMPMX,1)
		where pid_indiced in (select pid_indiced from inserted) 
		and (pid_can_ar <> (pid_cant * eq_impmx) or pid_can_ar is null)

--


	if update(pid_can_gen) or update(pid_cos_unigen) 
	begin
	
		if  (@pid_val_adu <>( isnull(@PID_CAN_GEN,0) * isnull(@PID_COS_UNIgen,0) * isnull(@PI_TIP_CAM,0)) * isnull(@pi_ft_adu,0) or @pid_val_adu is null)
			update pedimpdet
			set PEDIMPDET.PID_VAL_ADU =  round(isnull(PEDIMPDET.PID_CAN_GEN,0) * isnull(PEDIMPDET.PID_COS_UNIgen,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0),0)
	             		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
			where pedimpdet.pid_indiced in (select pid_indiced from inserted) and
			(PEDIMPDET.PID_VAL_ADU <> round(( isnull(PEDIMPDET.PID_CAN_GEN,0) * isnull(PEDIMPDET.PID_COS_UNIgen,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0)),0)
			 or pedimpdet.pid_val_adu is null)
	
		
		if update(pid_cos_unigen) 
		if  (@pid_cos_uniadu <>( isnull(@PID_COS_UNIgen,0) * isnull(@PI_TIP_CAM,0)) * isnull(@pi_ft_adu,1))-- or @pid_cos_uniadu is null)
			update pedimpdet
			set PEDIMPDET.PID_COS_UNIADU =   isnull(PEDIMPDET.PID_COS_UNIgen,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0)
	             		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
			where pedimpdet.pid_indiced in (select pid_indiced from inserted) and
			(PEDIMPDET.PID_COS_UNIADU <>  (isnull(PEDIMPDET.PID_COS_UNIgen,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,1)))
			 --or pedimpdet.pid_cos_uniadu is null)

	end



	if update(pid_cant) or update(pid_cos_uni) 
	begin

		if  (@pid_val_adu <> (isnull(@PID_CANT,0) * isnull(@PID_COS_UNI,0) * isnull(@PI_TIP_CAM,0)*@pi_ft_adu) or @pid_val_adu is null)
			update pedimpdet
			set PEDIMPDET.PID_VAL_ADU = round(isnull(PEDIMPDET.PID_CANT,0) * isnull(PEDIMPDET.PID_COS_UNI,0)* isnull(PEDIMP.PI_TIP_CAM,0) *isnull(PEDIMP.pi_ft_adu,0),0)
		             FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
			where pid_indiced in (select pid_indiced from inserted) 
			and (PEDIMPDET.pid_val_adu <> round((isnull(PEDIMPDET.PID_CANT,0) * isnull(PEDIMPDET.PID_COS_UNI,0) * isnull(PEDIMP.PI_TIP_CAM,0)*isnull(PEDIMP.pi_ft_adu,0)),0) or PEDIMPDET.pid_val_adu is null)

	
		if update(pid_cos_uni) and @EQ_GENERICO>0
		if  (@pid_cos_uniadu <>((isnull(@PID_COS_UNI,0) / isnull(@EQ_GENERICO,1)) * isnull(@PI_TIP_CAM,0) * isnull(@pi_ft_adu,0)))-- or @pid_cos_uniadu is null)
			update pedimpdet
			set PEDIMPDET.PID_COS_UNIADU =   (isnull(PEDIMPDET.PID_COS_UNI,0) / isnull(PEDIMPDET.EQ_GENERICO,1)) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0)
	             		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
			where pedimpdet.pid_indiced in (select pid_indiced from inserted) and
			(PEDIMPDET.PID_COS_UNIADU <>  ((isnull(PEDIMPDET.PID_COS_UNI,0) / isnull(PEDIMPDET.EQ_GENERICO,1)) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0)))
			 and isnull(PEDIMPDET.EQ_GENERICO,1)>0

	end



	if update(pid_cos_unigen) --or update(eq_generico)
	if @PID_COS_UNI <>  isnull(@PID_COS_UNIGEN,0) * isnull(@EQ_GENERICO,1) and (@PID_COS_UNIGEN>0)
	update pedimpdet
	set PID_COS_UNI =  isnull(PID_COS_UNIGEN,0) * isnull(EQ_GENERICO,1)
	where pid_indiced in (select pid_indiced from inserted) 
	and (pid_cos_uni <> (isnull(PID_COS_UNIGEN,0) * isnull(EQ_GENERICO,1)) or pid_cos_uni is null)


	if update(pid_cos_uni) and isnull(@EQ_GENERICO,1) >0
	if @PID_COS_UNIGEN <>  isnull(@PID_COS_UNI,0) / isnull(@EQ_GENERICO,1) and (@PID_COS_UNIGEN >0)
	update pedimpdet
	set PID_COS_UNIGEN =  isnull(PID_COS_UNI,0) / isnull(EQ_GENERICO,1)
	where pid_indiced in (select pid_indiced from inserted)  and isnull(EQ_GENERICO,1) >0
	and (pid_cos_unigen <> (isnull(PID_COS_UNI,0) / isnull(EQ_GENERICO,1)) or pid_cos_unigen is null)


	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if update(pid_cant) or update(eq_generico)
	if (@pid_can_gen <> (@pid_cant * @eq_generico) or @pid_can_gen is null) and (@PID_CANT > 0 and @PID_CANT  is not null)
		update pedimpdet
		set PID_CAN_GEN =  isnull(PID_CANT,0) * isnull(EQ_GENERICO,1)
		where pid_indiced in (select pid_indiced from inserted) 
		and (pid_can_gen <> (pid_cant * eq_generico) or pid_can_gen is null)




	if (update(pid_ctot_dls) or update(pid_cant) or update(eq_generico))
	if (isnull(@PID_CANT,0)) > 0 and isnull(@EQ_GENERICO,1)>0 and
		(@pid_cos_unigen <> ((isnull(@PID_CTOT_DLS,0)) / (isnull(@PID_CANT,0) * isnull(@EQ_GENERICO,1))) or @pid_cos_unigen is null)
		update pedimpdet
		set pedimpdet.PID_COS_UNIGEN =  (isnull(PEDIMPDET.PID_CTOT_DLS,0)) / (isnull(PID_CANT,0) * isnull(EQ_GENERICO,1))
	     		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
		where PEDIMPDET.pid_indiced in (select pid_indiced from inserted)  and (isnull(PID_CANT,0))>0  and  (isnull(EQ_GENERICO,1))>0 and isnull(PEDIMPDET.PID_CTOT_DLS,0)>0
		and (pedimpdet.PID_COS_UNIGEN <>  (isnull(PEDIMPDET.PID_CTOT_DLS,0)) / (isnull(PID_CANT,0) * isnull(EQ_GENERICO,1))
		or PEDIMPDET.pid_cos_unigen is null) 
--		and PEDIMPDET.PID_CTOT_DLS is not null and (isnull(PID_CANT,0) * isnull(EQ_GENERICO,1) is not null)

	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if update(pid_can_gen)  --or update(eq_generico)
	if ((@pid_cant <> (@pid_can_gen/@eq_generico) or @pid_cant is null)) and (@PID_CAN_GEN > 0 and @PID_CAN_GEN  is not null)
		update pedimpdet
		set PID_CANT = isnull(PID_CAN_GEN,0) / isnull(EQ_GENERICO,1)
		where pid_indiced in (select pid_indiced from inserted) 
		and (pid_cant <> (pid_can_gen/eq_generico) or pid_cant is null)
		and  eq_generico > 0 and eq_generico  is not null


	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if update(pid_can_gen) --or update(eq_impmx)
	if (@pid_can_ar <> (isnull(@PID_CAN_GEN,0) / isnull(@EQ_GENERICO,1)) * isnull(@EQ_IMPMX,1) or @pid_can_ar is null) and (@PID_CAN_GEN > 0 and @PID_CAN_GEN  is not null)
		update pedimpdet 
		set PID_CAN_AR = (isnull(PID_CAN_GEN,0) / isnull(EQ_GENERICO,1)) * isnull(EQ_IMPMX,1)
		where pid_indiced in (select pid_indiced from inserted) and isnull(EQ_GENERICO,1) >0
		and (pid_can_ar <> (isnull(PID_CAN_GEN,0) / isnull(EQ_GENERICO,1)) * isnull(EQ_IMPMX,1) or pid_can_ar is null)


	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if update(pid_can_gen) or update(pid_cos_unigen)
	if (@pid_ctot_dls <> (isnull(@PID_CAN_GEN,0) * isnull(@PID_COS_UNIgen,0)) or @pid_ctot_dls is null)
	update pedimpdet 
	set PEDIMPDET.PID_CTOT_DLS = isnull(PEDIMPDET.PID_CAN_GEN,0) * isnull(PEDIMPDET.PID_COS_UNIgen,0)
         	FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
	where pedimpdet.pid_indiced in (select pid_indiced from inserted)
	and (pid_ctot_dls <> (isnull(PEDIMPDET.PID_CAN_GEN,0) * isnull(PEDIMPDET.PID_COS_UNIgen,0)) or pid_ctot_dls is null)




	if update(pid_ctot_dls) 
	begin
	
		if  (@pid_val_adu <>(isnull(@PID_CTOT_DLS,0) * isnull(@PI_TIP_CAM,0) * isnull(@pi_ft_adu,0)) or @pid_val_adu is null)
			update pedimpdet
			set PEDIMPDET.PID_VAL_ADU = (isnull(PEDIMPDET.PID_CTOT_DLS,0) * isnull(PEDIMP.PI_TIP_CAM,0)) * isnull(PEDIMP.pi_ft_adu,0)
	             		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
			where pedimpdet.pid_indiced in (select pid_indiced from inserted) and
			(pedimpdet.pid_val_adu <>(isnull(PEDIMPDET.PID_CTOT_DLS,0) * isnull(PEDIMP.PI_TIP_CAM,0) * isnull(PEDIMP.pi_ft_adu,0))
			 or pedimpdet.pid_val_adu is null)

		if (@PID_CANT > 0 and @PID_CANT  is not null)
		if (@pid_cos_uni <> (isnull(@PID_CTOT_DLS,0)/isnull(@PID_CANT,0)) or @pid_cos_uni is null) 
			update pedimpdet 
			set  PID_COS_UNI=  isnull(PID_CTOT_DLS,0)/isnull(PID_CANT,0)
			where pid_indiced in (select pid_indiced from inserted) 
			and (pid_ctot_dls <> (isnull(PID_CTOT_DLS,0)/isnull(PID_CANT,0)) or PID_COS_UNI is null)
			and (PID_CANT > 0 and PID_CANT  is not null)

	end

   
-------------------------------

	if update(pid_cos_uni) 
	if (@PID_COS_UNIADU <> (isnull(@PID_COS_UNI,0)*isnull(@PI_TIP_CAM,0) * isnull(@pi_ft_adu,1)/ isnull(@EQ_GENERICO,1)) or (@PID_COS_UNIADU is null))
		update pedimpdet
		set PEDIMPDET.PID_COS_UNIADU =  (isnull(PID_COS_UNI,0)*isnull(PEDIMP.PI_TIP_CAM,0)*isnull(PEDIMP.pi_ft_adu,1)/ isnull(EQ_GENERICO,1))
	     		FROM PEDIMPDET LEFT OUTER JOIN PEDIMP ON PEDIMPDET.PI_CODIGO = PEDIMP.PI_CODIGO
		where pedimpdet.pid_indiced in (select pid_indiced from inserted)  and isnull(EQ_GENERICO, 1)>0
		and (PEDIMPDET.PID_COS_UNIADU <> (isnull(PID_COS_UNI,0)*isnull(PEDIMP.PI_TIP_CAM,0)*isnull(PEDIMP.pi_ft_adu,1)/ isnull(EQ_GENERICO,1))
                           or PEDIMPDET.PID_COS_UNIADU is null)
		

-- =================== actualizaciones ================================


	-- actualizacion del pid_saldo_gen 

	if @pi_estatus not in ('C', 'G', 'F', 'A')
	if @pedimpdescargable='S'
	begin
		if @pid_descargable='S'
		begin
			if (update(pid_cant) or update(eq_generico)) 
				update pidescarga  
				set pid_saldogen = isnull(PID_CANT,0) * isnull(EQ_GENERICO,1)
				from pedimpdet inner join pidescarga 
				on pedimpdet.pid_indiced=pidescarga.pid_indiced
				where pedimpdet.pid_indiced in (select pid_indiced from inserted) 
				and pedimpdet.pid_descargable<>'N'
		
		
			if (update(pid_can_gen)) 
				update pidescarga  
				set pid_saldogen = pid_can_gen
				from pedimpdet inner join pidescarga 
				on pedimpdet.pid_indiced=pidescarga.pid_indiced
				where pedimpdet.pid_indiced in (select pid_indiced from inserted) 
				and pedimpdet.pid_descargable<>'N'
		end

		if @pid_descargable='N'
		update pidescarga
		set pid_saldogen = 0
		where pid_indiced in (select pid_indiced from inserted) 
	

	end


	if @pedimpdescargable='N'
	begin
		if (update(pid_can_gen) or update(pid_cant))		
		begin
			update pidescarga
			set pid_saldogen = 0
			where pid_indiced in (select pid_indiced from inserted) 
	
			update pedimpdet
			set pid_descargable='N'
			where pid_descargable<>'N' and
			pid_indiced in (select pid_indiced from inserted) 
		end

	end

	-- actualizacion del pid_uso_saldo 

	if update(pid_can_gen) --or update(pid_saldogen)
	if (@pid_can_gen > @pid_saldogen) and (@pid_uso_saldo <> 'S')
		update pidescarga
		set pid_uso_saldo = 'S' 
		from pedimpdet inner join pidescarga 
		on pedimpdet.pid_indiced=pidescarga.pid_indiced
		where pedimpdet.pid_indiced in (select pid_indiced from inserted) 
		and pedimpdet.pid_can_gen > pidescarga.pid_saldogen
		and pidescarga.pid_uso_saldo <> 'S' 

	if update(pid_can_gen) --or update(pid_saldogen)
	if (@pid_can_gen = @pid_saldogen) and (@pid_uso_saldo <> 'N')	
		update pidescarga 
		set pid_uso_saldo = 'N'
		from pedimpdet inner join pidescarga 
		on pedimpdet.pid_indiced=pidescarga.pid_indiced
		where pedimpdet.pid_indiced in (select pid_indiced from inserted) 
		and pedimpdet.pid_can_gen = pidescarga.pid_saldogen
		and pidescarga.pid_uso_saldo <> 'N' 



	if exists(select * from maestro where ma_codigo=@ma_generico)
	begin
		select @me_gen= me_com from maestro where ma_codigo=@ma_generico

		if update(ma_generico) and @me_generico<>@me_gen
		update pedimpdet
		set me_generico=@me_gen
		where pid_indiced in (select pid_indiced from inserted) 
	end


	if exists(select * from arancel where ar_codigo=@ar_impmx)
	begin
		select @me_codigo= me_codigo from arancel where ar_codigo=@ar_impmx

		if update (ar_impmx) and @me_arimpmx<>@me_codigo
		update pedimpdet
		set me_arimpmx=@me_codigo
		where pid_indiced in (select pid_indiced from inserted) 
	end


	if update(pa_origen) and @pi_movimiento='S' and @ccp_tipo<>'TR'
	begin
		if (@pa_origen =@CF_PAIS_USA or @pa_origen =@CF_PAIS_CA)
			update pedimpdet
			set PID_REGIONFIN='N'
			where pedimpdet.pid_indiced in (select pid_indiced from inserted)
			and (pa_origen =@CF_PAIS_USA or pa_origen =@CF_PAIS_CA)
		else
		if (@pa_origen =@CF_PAIS_MX)
			update pedimpdet
			set PID_REGIONFIN='M'
			where pedimpdet.pid_indiced in (select pid_indiced from inserted)
			and pa_origen =@CF_PAIS_MX
		else
			update pedimpdet
			set PID_REGIONFIN='F'
			where pedimpdet.pid_indiced in (select pid_indiced from inserted)
			and (pa_origen <>@CF_PAIS_USA and pa_origen <>@CF_PAIS_CA
			and pa_origen <>@CF_PAIS_MX)
			


		if update(pid_regionfin) and @pi_movimiento='S' and @ccp_tipo='TR'
		begin
			UPDATE dbo.FACTEXPDET
			SET     dbo.FACTEXPDET.FED_DESTNAFTA = dbo.PEDIMPDET.PID_REGIONFIN
			FROM         dbo.PEDIMPDET LEFT OUTER JOIN
			                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
			WHERE     (dbo.PEDIMPDET.PID_INDICED in (select pid_indiced from inserted)) 
			AND (dbo.FACTEXPDET.FED_DESTNAFTA <> dbo.PEDIMPDET.PID_REGIONFIN)
		end
	
	
		if @pi_movimiento='S' and @ccp_tipo in ('IT', 'IV', 'VT')
		EXEC SP_ACTUALIZAPID_PAGACONTRIB @pid_indiced
	end


end*/














GO
