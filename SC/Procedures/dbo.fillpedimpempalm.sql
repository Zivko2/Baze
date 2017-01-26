SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [fillpedimpempalm] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @PID_INDICED int, @MA_CODIGO int, @TI_CODIGO smallint, @PID_CANT_DESP decimal(38,6), @ME_CODIGO int, @PID_GENERA_EMP char(1), 
@EQ_GENERICO decimal(28,14), @MA_GENERICO int, @FechaActual varchar(10), @hora varchar(15), @em_codigo int


	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)


	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Calculando Empaque Almacen Desperdicio ', 'Calculating Scrap Warehouse Packing ',convert(varchar(10), @FechaActual,101), @hora, @em_codigo)

	if exists (select * from almacendesp where pi_codigo =@picodigo)
	delete from almacendesp where pi_codigo=@picodigo


	INSERT INTO ALMACENDESP (FETR_CODIGO, FETR_INDICED, MA_HIJO, TI_CODIGO, ADE_CANT, ME_CODIGO, ADE_SALDO, ADE_GENERADOPOR, 
             		         MA_GENERA_EMP, EQ_GENERICO, MA_GENERICO, TIPO_ENT_SAL, FETR_TIPO, ADE_PESO_UNIKG)

	SELECT     @picodigo, PID_INDICED, PEDIMPDET.MA_CODIGO, PEDIMPDET.TI_CODIGO, PID_CANT_DESP, PEDIMPDET.ME_CODIGO, PID_CANT_DESP, 'E', PID_GENERA_EMP, PEDIMPDET.EQ_GENERICO, PEDIMPDET.MA_GENERICO, 'E', 'P', 
		(select isnull(ma_peso_kg,0) from maestro where ma_codigo=pedimpdet.ma_codigo)
	FROM         PEDIMPDET left outer join maestro on pedimpdet.ma_codigo=maestro.ma_codigo
	WHERE     (PI_CODIGO = @picodigo) AND (PID_IMPRIMIR = 'N')  AND PID_CANT_DESP>0 and maestro.ma_genera_emp='D'



























GO
