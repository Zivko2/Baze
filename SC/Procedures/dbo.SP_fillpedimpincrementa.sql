SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_fillpedimpincrementa] (@picodigo int, @user int)   as

SET NOCOUNT ON 
DECLARE @FechaActual varchar(10), @hora varchar(15), @ccp_tipo varchar(5), @em_codigo int

	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo in
	(select cp_codigo from pedimp where pi_codigo=@picodigo)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))


	SET @FechaActual = convert(varchar(10), getdate(),101)
	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	
	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Calculando Incrementables ', 'Calculating Additional Costs ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)


	if @ccp_tipo<>'RE'
	begin
		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=2)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=2

		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 2, isnull(sum(FI_FLETE),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_CODIGO = @picodigo) 
		HAVING isnull(sum(FI_FLETE),0)>0

	
		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=1)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=1
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 1, isnull(sum(FI_SEGURO),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_CODIGO = @picodigo) 
		HAVING isnull(sum(FI_SEGURO),0)>0


		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=3)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=3
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 3, isnull(sum(FI_EMBALAJE),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_CODIGO = @picodigo) 
		HAVING isnull(sum(FI_EMBALAJE),0)>0


		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=11)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=11
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 11, isnull(sum(FI_OTROS),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_CODIGO = @picodigo) 
		HAVING isnull(sum(FI_OTROS),0)>0


	end
	else
	begin
		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=2)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=2

		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 2, isnull(sum(FI_FLETE),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_RECTIFICA = @picodigo) 
		HAVING isnull(sum(FI_FLETE),0)>0

	
		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=1)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=1
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 1, isnull(sum(FI_SEGURO),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_RECTIFICA = @picodigo)
		HAVING isnull(sum(FI_SEGURO),0)>0

		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=3)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=3
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo, 3, isnull(sum(FI_EMBALAJE),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_RECTIFICA = @picodigo) AND isnull(FI_EMBALAJE,0)>0
		HAVING isnull(sum(FI_EMBALAJE),0)>0


		if exists(select * from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=11)
		delete from pedimpincrementa where pi_codigo = @picodigo and ic_codigo=11
	
		INSERT INTO PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)
		SELECT    @picodigo,11, isnull(sum(FI_OTROS),0)
		FROM         VFACTIMPFLETE
		WHERE     (PI_RECTIFICA = @picodigo) AND isnull(FI_OTROS,0)>0
		HAVING isnull(sum(FI_OTROS),0)>0

		--Inserta incrementables que solo fueron capturados en pedimento original y no estan en la factura
		insert into PEDIMPINCREMENTA(PI_CODIGO, IC_CODIGO, PII_VALOR)	
		select @picodigo, pedimpIncrementa.IC_CODIGO, pedimpIncrementa.PII_VALOR
		from pedimp
			left outer join pedimprect on pedimp.pi_codigo = pedimprect.pi_codigo
			left outer join pedimpIncrementa on pedimp.pi_codigo = pedimpIncrementa.pi_codigo
			left outer join pedimpIncrementa pr on pedimpIncrementa.ic_codigo = pr.ic_codigo and pr.pi_codigo = @picodigo
		where pedimprect.pi_no_rect = @picodigo and pr.pi_codigo is null and pedimpincrementa.pi_codigo is not null


	end

GO
