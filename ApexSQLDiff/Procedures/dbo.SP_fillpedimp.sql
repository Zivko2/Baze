SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedimp] (@picodigo int, @user int)   as

--SET NOCOUNT ON 
declare @CF_MAN_EMPAQUE char(1), @CF_EMPDESPIMP char(1), @flete decimal(38,6), @seguro decimal(38,6), @embalaje decimal(38,6), @ccp_tipo varchar(5), @pi_fec_pag datetime,
@cfijadta decimal(38,6), @pi_val_adu decimal(38,6), @valdta decimal(38,6), @numfacturas int, @year int, @mes varchar(15), @PI_OBSERVA varchar(1100), @totalpartidas int, @semana int,
@iniciosem datetime, @inisem int, @finsem int, @peso decimal(38,6), @incrementa decimal(38,6), @pi_tip_cam decimal(38,6), @incrementamn float, @costototaldls decimal(38,6), @otros decimal(38,6),
@FechaActual varchar(10), @hora varchar(15), @em_codigo int

	alter table [PEDIMP] DISABLE TRIGGER [UPDATE_PEDIMP]

		SELECT     @CF_EMPDESPIMP=CF_EMPDESPIMP
		FROM         CONFIGURACION
	
	
		SELECT @PI_OBSERVA=PI_OBSERVA, @pi_tip_cam=pi_tip_cam FROM PEDIMP WHERE PI_CODIGO=@picodigo
	
		select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
		(select cp_codigo from pedimp where pi_codigo=@picodigo)

		if (select pi_llenaincrementa from configurapedimento)='S'	
		begin
			SELECT    @flete= isnull(sum(FI_FLETE),0), @seguro=isnull(sum(FI_SEGURO),0), @embalaje=isnull(sum(FI_EMBALAJE),0), @otros=isnull(sum(FI_OTROS),0)
			FROM         VFACTIMPFLETE
			WHERE     (PI_CODIGO = @picodigo)
		end

		if (select pi_llenapeso from configurapedimento)='S'
		begin
			SELECT     @peso =case when isnull(SUM(FID_PES_BRU),0)> 0 then isnull(SUM(FID_PES_BRU),0) else isnull(SUM(FID_PES_NET),0) end
			FROM   dbo.FACTIMPDET INNER JOIN FACTIMP
			ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
			WHERE     (FACTIMP.PI_CODIGO = @picodigo)
		end
	
		select @numfacturas=sum(fi_numvehiculos) from factimp where pi_codigo=@picodigo
	
	
	

/*===================== inicio incrementables ======================*/

	if (@ccp_tipo<>'VT' and @ccp_tipo<>'IV') 
	begin
		if (select pi_llenaincrementa from configurapedimento)='S'	
		begin
			select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)
	
			insert into  IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
			values (@user, 2, 'Actualizando Factor Aduana ', 'Updating Customs Factor ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)
		
	
			set @incrementa=(@flete+@seguro+@embalaje+@otros) 
			set @incrementamn= (@flete+@seguro+@embalaje+@otros)*@pi_tip_cam

			if @incrementa=0 and exists(select * from pedimpincrementa where pi_codigo=@picodigo)
			begin

				select @embalaje=pii_valor from vpedimpincrementaembalaje
				where pi_codigo=@picodigo
				
				select @seguro=pii_valor from vpedimpincrementaseguro
				where pi_codigo=@picodigo
				
				select @flete=pii_valor from vpedimpincrementaflete
				where pi_codigo=@picodigo
				
				select @otros=pii_valor from vpedimpincrementaotros
				where pi_codigo=@picodigo


				set @incrementa=(@flete+@seguro+@embalaje+@otros) 
				set @incrementamn= (@flete+@seguro+@embalaje+@otros)*@pi_tip_cam
			end
		
			select @costototaldls= sum(factimpdet.fid_cos_tot) 
			from factimpdet, factimp 
			where factimpdet.fi_codigo=factimp.fi_codigo and factimp.pi_codigo=@picodigo
		
	
			if (@costototaldls*@pi_tip_cam)>0
			begin
				begin tran
				update pedimp
				set pi_ft_adu = isnull(round(((@costototaldls*@pi_tip_cam)+@incrementamn)/(@costototaldls*@pi_tip_cam),9),1)
				where pi_codigo= @picodigo
				commit tran
			end
			else
			begin
				begin tran
				update pedimp
				set pi_ft_adu = 1
				where pi_codigo= @picodigo
				commit tran
			end
		end
		else
		begin
			begin tran
			update pedimp
			set pi_ft_adu = 1
			where pi_codigo= @picodigo
			commit tran
		end

	end	
/*===================== fin incrementables ======================*/





	if (select pi_llenapeso from configurapedimento)='S'
	begin
		update pedimp
		set pi_numvehiculos=isnull(@numfacturas,1), pi_bulto=(select isnull(sum(fi_totalb),0) from factimp where pi_codigo=@picodigo),
		pi_peso=@peso
		where pi_codigo=@picodigo
	end
	


	if @numfacturas>1 and  (@pi_observa not like '**PEDIMENTOS CONSOLIDADOS DTA POR %' or @pi_observa is null)
	begin
		update pedimp
		set pi_observa='**PEDIMENTOS CONSOLIDADOS DTA POR '+convert(varchar(5),@numfacturas)+' VEHICULOS DE CONFORMIDAD CON EL ART. 49 INCISO III DE LA LEY FEDERAL DE DERECHOS, EN BASE AL ART. 37 DE LA LEY ADUANERA VIGENTE Y 58 DEL REGLAMENTO.** '
		where pi_codigo=@picodigo		


		update pedimp
		set pi_sem=DATEPART(wk, PI_FEC_ENT)-1
		where pi_codigo=@picodigo

	
		if (select pi_llenaperiodobserva from configurapedimento)='S'
		begin
			SELECT @semana=pi_sem FROM PEDIMP WHERE PI_CODIGO = @picodigo
			
			

			if (@ccp_tipo='VT' or @ccp_tipo='IV') 
			begin
	
				SELECT     @mes=mes, @year=[year]
				FROM         VPEDIMPPERIODO
				GROUP BY mes, [year], PI_CODIGO
				HAVING      (PI_CODIGO = @picodigo)	
	
				update pedimp
				set pi_observa=isnull(pi_observa,'')+'SEMANA: '+convert(varchar(3),@semana)+' PERIODO: '+@mes +' DEL ' +convert(varchar(10), @year)
				where pi_codigo=@picodigo
			end
			else
			begin
				SELECT     @mes=month(pi_fec_ent), @year=year(pi_fec_ent)
				FROM         PEDIMP
				WHERE      (PI_CODIGO = @picodigo)	
	
	
	
				SELECT @iniciosem=case when datepart(dw, PI_FEC_ENT-7)=4 then PI_FEC_ENT-9 when datepart(dw, PI_FEC_ENT-7)=3 then PI_FEC_ENT-8 when datepart(dw, PI_FEC_ENT-7)=2 then 
				PI_FEC_ENT-7  end FROM PEDIMP WHERE PI_CODIGO = 215
	
				set @inisem=(select day(@iniciosem))
				set @finsem=(select day(@inisem+5))
	
				update pedimp
				set pi_observa=isnull(pi_observa,'')+'SEMANA: '+convert(varchar(3),@semana)+' DEL '+convert(varchar(10),@inisem)+' AL '+convert(varchar(10),@finsem)+' DEL MES '+convert(varchar(10),@mes)+' DEL '+convert(varchar(10), @year)
				where pi_codigo=@picodigo
	
			end
		end
	end



	exec sp_fillpedimpdet @picodigo, @ccp_tipo, @user		--inserta detalle del pedimento 


	if exists (select * from factimpcont, factimp where factimp.pi_codigo=@picodigo and factimp.fi_codigo=factimpcont.fi_codigo)
	exec fillpedimpcont @picodigo, @user	--inserta contenido del pedimento 

	select @totalpartidas=pi_cuentadet from pedimp where pi_codigo=@picodigo 



	if (select isnull(picf_agrupasaaisec,'N') from pedimpsaaiconfig where pi_codigo=@picodigo)='S'
	begin
		if (select pi_llenasecuencia from configurapedimento)='S'
		exec fillpedimpSec @picodigo, @user  -- genera solo la secuencia
	end

	if (select pi_llenapedimpdetb from configurapedimento)='S'
	/*if (select cf_pedimpdetb from configuracion)='S' */ and @totalpartidas>0 
	begin
		exec sp_fillpedimpdetB @picodigo, @user --inserta detalle B del pedimento 
	end



	if (select pi_llenaidentifica from configurapedimento)='S'
	begin
		exec fillpedimpidentifica @picodigo -- inserta  permisos a los identificadores a nivel pedimento 
	end


	if (select pi_llenaincrementa from configurapedimento)='S'	
	begin
		if (@flete>0 or @seguro>0 or @embalaje>0)
		exec sp_fillpedimpincrementa @picodigo, @user   -- inserta incrementables de la factura a la tabla pedimpincrementa
	end


	IF @CF_EMPDESPIMP='S' -- si la empresa quiere llevar el control del empaque que importa como desperdicio 
		begin

			if exists (select * from pedimpdet where pi_codigo= @picodigo and pid_imprimir='N' )  --inserta en almacendesp los empaques del pedimpdet 
			exec fillpedimpempalm  @picodigo, @user

		end

	if (select cf_descargas from configuracion)<>'N'
	exec sp_actualizapedimpvencimiento @picodigo, @user

	alter table [PEDIMP] ENABLE TRIGGER [UPDATE_PEDIMP]

	/* falta insertar los contenedores */


GO
