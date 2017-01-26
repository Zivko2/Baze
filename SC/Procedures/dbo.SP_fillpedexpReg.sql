SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedexpReg] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @totalpartidas int, @ccp_tipo varchar(5), @VINPCMAX decimal(38,6), @pi_fec_sal datetime, @PI_FEC_ENTPI datetime, @peso decimal(38,6), 
@numfacturas smallint, @pi_observa varchar(1100), @cp_codigo int

if exists (select * from pedimpdet where pi_codigo =@picodigo)
delete from pedimpdet where pi_codigo=@picodigo


	select @pi_observa=pi_observa, @cp_codigo=cp_codigo from pedimp where pi_codigo=@picodigo


	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo =@cp_codigo


	select @numfacturas=count(fe_codigo) from factexp where pi_codigo=@picodigo


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





	/* =====================  factor de actualizacion para el cambio de regimen =============================== */
	SELECT    @PI_FEC_ENTPI=PI_FEC_ENTpi, @pi_fec_sal=PI_FEC_PAG
	FROM         VPAGOCONTRIBPERIODOF4
	WHERE     (PI_CODIGO = @picodigo)


	-- periodo fecha de entrada de la mercancia hasta la fecha de cambio de regimen
	-- inpc maximo
	SELECT     @VINPCMAX=IN_CANT
	FROM         INPC
	WHERE IN_FECINI IN (SELECT MAX(dbo.INPC.IN_FECINI) FROM  dbo.INPC WHERE IN_FECINI <= @pi_fec_sal)

	/*para la materia prima el impuesto general de importacion se determina aplicando la tasa arancelaria preferencial 
	vigente a la fecha de entrada de las mercancias al territorio nacional en los terminos del articulo 56, fraccion I de la Ley, actualizado conforme
	 al art-culo 17-A del Codigo y una cantidad equivalente al importe de los recargos que corresponderian en los terminos del articulo 21 del Codigo, 
	a partir del mes en que las mercancias se importen temporalmente y hasta que las mismas se paguen */

	-- truncado a 4 decimales no redondeado

	UPDATE PEDIMP
	set PI_FT_ACT =  round(isnull((@VINPCMAX /(SELECT max(IN_CANT)
						        FROM INPC WHERE IN_FECINI IN (SELECT MAX(IN_FECINI) FROM  INPC WHERE IN_FECINI <= @PI_FEC_ENTPI
					     	        and dbo.INPC.IN_FECINI NOT IN (SELECT MAX(dbo.INPC.IN_FECINI) FROM INPC WHERE IN_FECINI <= @PI_FEC_ENTPI)))),0),4,0),
	PI_FEC_CAMREG=@PI_FEC_ENTPI
	WHERE PI_CODIGO=@picodigo

	if (select cp_clave from claveped where cp_codigo=@cp_codigo)='F4'
		if (@pi_observa not like '**CAMBIO DE REGIMEN DE ACUERDO A LOS ARTS. %' or @pi_observa is null)
		begin
			update pedimp
			set pi_observa='**CAMBIO DE REGIMEN DE ACUERDO A LOS ARTS. 56, 93 Y 109 DE LA LEY ADUANERA Y 157 DE SU REGLAMENTO VIGENTES.**'
			where pi_codigo=@picodigo		
		end


	/*=================================*/

	
	if (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S' -- cambio de regimen de desperdicio
	begin
		if exists(select * from factexp where pi_codigo=@picodigo or pi_rectifica=@picodigo
		and tq_codigo in (SELECT TQ_CODIGO FROM CONFIGURATEMBARQUE WHERE CFQ_TIPO = 'D'))
  			exec sp_fillpedexpdetdesp @picodigo, 'CN', @user		/*inserta detalle y contenido del pedimento cuando existesn facturas que son de desperdicio*/
		else
			exec sp_fillpedexpdet @picodigo, 'CN', @user		/*inserta detalle y contenido del pedimento */
	end
	else
	 exec sp_fillpedimpdetReg @picodigo, @user

	select @totalpartidas=pi_cuentadet from pedimp where pi_codigo=@picodigo 

	if (select cf_pedimpdetb from configuracion)='S' and @totalpartidas>0
	begin
		exec sp_fillpedimpdetB @picodigo, @user	--inserta detalle B del pedimento 
		--exec sp_fillpedExpDetBArt303 @picodigo
	end

	exec sp_fillpedexpincrementa @picodigo, @user  /* inserta incrementables de la factura a la tabla pedimpincrementa*/

	exec sp_fillpedimpprueba @picodigo /* llena prueba suficiente*/




	if (select pi_llenaidentifica from configurapedimento)='S'
	begin
		exec fillpedimpidentifica @picodigo -- inserta  permisos a los identificadores a nivel pedimento 
	end

GO
