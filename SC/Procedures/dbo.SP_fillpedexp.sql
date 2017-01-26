SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_fillpedexp] (@picodigo int, @user int)   as

SET NOCOUNT ON 
DECLARE @CCP_TIPO varchar(5), @numfacturas int, @mes varchar(15), @year int, @PI_OBSERVA varchar(1100), @totalpartidas int, @semana int,
@iniciosem datetime, @inisem int, @finsem int, @peso decimal(38,6), @pi_desp_equipo char(1), @cp_codigo int, @cp_rectifica int


	SELECT @CCP_TIPO=CCP_TIPO FROM CONFIGURACLAVEPED WHERE CP_CODIGO
	IN (SELECT CP_CODIGO FROM PEDIMP WHERE PI_CODIGO=@picodigo)

	SELECT @PI_OBSERVA=PI_OBSERVA, @cp_codigo=cp_codigo, @pi_desp_equipo=pi_desp_equipo, @cp_rectifica=cp_rectifica FROM PEDIMP WHERE PI_CODIGO=@picodigo



	select @numfacturas=count(fe_codigo) from factexp where pi_codigo=@picodigo

--	select @numfacturas=sum(fe_numvehiculos) from factexp where pi_codigo=@picodigo or pi_rectifica=@picodigo

	SELECT     @peso =case when isnull(SUM(FED_PES_BRU),0)> 0 then isnull(SUM(FED_PES_BRU),0) else isnull(SUM(FED_PES_NET),0) end
	FROM   dbo.FACTEXPDET INNER JOIN FACTEXP
	ON FACTEXPDET.FE_CODIGO=FACTEXP.FE_CODIGO
	WHERE     (FACTEXP.PI_CODIGO = @picodigo)


	update pedimp
	set pi_numvehiculos= isnull(@numfacturas,1), pi_bulto=(select isnull(sum(fe_totalb),0) from factexp where pi_codigo=@picodigo),
	pi_peso=@peso
	where pi_codigo=@picodigo


	update pedimp
	set pi_sem=DATEPART(wk, PI_FEC_ENT)-1
	where pi_codigo=@picodigo


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



	if (@ccp_tipo='ER') and  (select cp_art303 from claveped where cp_codigo =@cp_codigo)='S'
	and @pi_desp_equipo='N' and
	 (SELECT     COUNT(DIR_CLIENTE.PA_CODIGO)
	FROM         FACTEXP LEFT OUTER JOIN
	                      DIR_CLIENTE ON FACTEXP.DI_DESTFIN = DIR_CLIENTE.DI_INDICE
	WHERE     (FACTEXP.PI_CODIGO = @picodigo) AND (DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_MX  FROM          dbo.CONFIGURACION) OR
	                      DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_USA FROM  dbo.CONFIGURACION) OR
	                      DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_CA  FROM  dbo.CONFIGURACION)))=0 
	begin
			update pedimp
			set pi_pagado='S'
			where pi_codigo=@picodigo
	
	end

	if (@ccp_tipo='RE') and  (select cp_art303 from claveped where cp_codigo =@cp_rectifica)='S'
	and @pi_desp_equipo='N' and
	 (SELECT     COUNT(DIR_CLIENTE.PA_CODIGO)
	FROM         FACTEXP LEFT OUTER JOIN
	                      DIR_CLIENTE ON FACTEXP.DI_DESTFIN = DIR_CLIENTE.DI_INDICE
	WHERE     (FACTEXP.PI_CODIGO = @picodigo) AND (DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_MX  FROM          dbo.CONFIGURACION) OR
	                      DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_USA FROM  dbo.CONFIGURACION) OR
	                      DIR_CLIENTE.PA_CODIGO =  (SELECT     CF_PAIS_CA  FROM  dbo.CONFIGURACION)))=0 
	begin
			update pedimp
			set pi_pagado='S'
			where pi_codigo=@picodigo
	
	end



	if @CCP_TIPO='CT'
	begin

		exec sp_fillpedexpdet_complementa @picodigo, @user
	end
	else
	begin
		if exists(select * from factexp where pi_codigo=@picodigo or pi_rectifica=@picodigo
		and tq_codigo in (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D'))
  			exec sp_fillpedexpdetdesp @picodigo, @CCP_TIPO, @user		/*inserta detalle y contenido del pedimento cuando existesn facturas que son de desperdicio*/
		else
			exec sp_fillpedexpdet @picodigo, @CCP_TIPO, @user		/*inserta detalle y contenido del pedimento */


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

	
	
		exec fillpedexpcont @picodigo, @user	/*inserta contenido del pedimento */
	
		exec fillpedimpidentifica @picodigo -- inserta  los identificadores a nivel pedimento 
	
		/*exec sp_fillpedexpincrementa @picodigo, @user   inserta incrementables de la factura a la tabla pedimpincrementa ESTO SOLO APLICA A LA IMPORTACION*/
	

	end


GO
