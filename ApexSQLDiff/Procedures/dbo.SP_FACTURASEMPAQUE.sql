SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_FACTURASEMPAQUE] (@le_folio varchar(25), @ar_fraccion varchar(20), @fe_no_sem varchar(20), @user_id int, @folios varchar(30) output)   as

declare @fe_codigo int, @fed_indiced int, @MA_CODIGO int, @FED_NOMBRE varchar(150), @FED_NOPARTE varchar(30), @FED_NAME varchar(150), @ME_CODIGO int, @FED_CANT decimal(38,6), @FED_GRA_MP decimal(38,6), @FED_GRA_MO decimal(38,6),
						@FED_GRA_EMP decimal(38,6), @FED_GRA_ADD decimal(38,6), @FED_GRA_GI decimal(38,6), @FED_GRA_GI_MX decimal(38,6), @FED_NG_MP decimal(38,6), @FED_NG_EMP decimal(38,6), @FED_NG_ADD decimal(38,6), @FED_NG_USA decimal(38,6), @FED_COS_UNI decimal(38,6),
						@FED_COS_TOT decimal(38,6), @FED_PES_UNI decimal(38,6), @FED_PES_NET decimal(38,6), @FED_PES_BRU decimal(38,6), @FED_PES_UNILB decimal(38,6), @FED_PES_NETLB decimal(38,6), @FED_PES_BRULB decimal(38,6), @FED_SEC_IMP smallint,
						@FED_DEF_TIP char(1), @FED_POR_DEF decimal(38,6), @FED_LOTE varchar(50), @AR_IMPMX int, @AR_EXPMX int, @AR_IMPFO int, @MA_GENERICO int, @PA_CODIGO int , @EQ_GEN decimal(28,14), @EQ_IMPFO decimal(28,14), @EQ_EXPMX decimal(28,14),
						@TI_CODIGO int , @FED_RATEEXPMX decimal(38,6), @FED_RATEIMPFO decimal(38,6), @SPI_CODIGO smallint, @FED_SALDO decimal(38,6), @FED_RETRABAJO char(1), @MA_EMPAQUE int, @FED_CANTEMP decimal(38,6), @FED_TIP_ENS char(1),
						@MA_NOPARTECL varchar(30), @FED_NAFTA char(1), @TCO_CODIGO smallint, @END_INDICED int, @EN_CODIGO int, @CL_CODIGO int, @MA_STRUCT int, @AR_ORIG int, @AR_NG_EMP int, @FED_NOPARTEAUX varchar(10),
						@FED_PRECIO_UNI decimal(38,6), @FED_PRECIO_TOT decimal(38,6), @LE_CODIGO int, @LED_INDICED int,
						@Consecutivo varchar(20), @folio1 varchar(30), @folio2 varchar(30)

set @folios = ''
set @folio1 = ''
set @folio2 = ''
--Genera la factuar con la fraccion indicada
if exists(select subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio))
			from factexp where fe_folio like @le_folio+'-%') 
	begin
		select @Consecutivo = Max(subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio)))
		 from factexp where fe_folio like @le_folio+'-%'
		Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
	end
else
    begin
		Set @Consecutivo = '1'
    end
    
select @fe_codigo = cv_codigo from consecutivo where cv_tipo = 'FE'

insert into factexp(FE_CODIGO, FE_TIPO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_PRIORIDAD, FE_ESTATUS,
					FE_FOLIO, TQ_CODIGO, TN_CODIGO, FE_NO_SEM, US_CODIGO, AG_MX, AGT_CODIGO,
					AG_US,FE_PINICIAL, FE_PFINAL, CP_CODIGO, CL_PROD, DI_PROD, CL_DESTINI, DI_DESTINI, CL_EXP, DI_EXP,
					CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, CL_COMP, DI_COMP)
select top 1 @fe_codigo, 'F',tf_codigo, convert(varchar(11), getdate(),101),
		(select tc_cant from tcambio where tc_fecha = convert(varchar(11), getdate(),101)),'N','D',
		@le_folio+'-'+@Consecutivo,(select tq_codigo from tembarque where tq_nombre = 'ENVASES Y EMPAQUES'), 
		case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
		then 4 
		else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fe_no_sem, 
		
		(select us_codigo from personal
		where sysusrlst_id=@user_id
		and us_codigo in (select max(us_codigo) from personal
		where sysusrlst_id=@user_id)),
		
		(select AG_MEX from cliente where cl_empresa = 'S'),
		(SELECT     AGENCIAPATENTE.AGT_CODIGO
		FROM         CLIENTE INNER JOIN
							  AGENCIAPATENTE ON CLIENTE.AG_MEX = AGENCIAPATENTE.AG_CODIGO
		WHERE     (AGENCIAPATENTE.AGT_DEFAULT = 'S') AND (CLIENTE.CL_EMPRESA = 'S') and (AGENCIAPATENTE.AGT_TIPO='A')),
		(select AG_USA from cliente where cl_empresa = 'S'),
		convert(varchar(11), getdate(),101),convert(varchar(11), getdate(),101),	

		(SELECT 
		  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
		  AND RELTFACTTEMBAR.TF_CODIGO=listaexp.TF_CODIGO) AS CP_CODIGO
		FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
		  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
		WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=listaExp.TF_CODIGO) 
		and tembarque.tq_codigo = listaexp.TQ_CODIGO),
		
		
		(SELECT     CL_PROD
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),

		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_PROD
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),
		
		(SELECT     CL_destini
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_DESTINI
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_EXP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_EXP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_DESTFIN
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_DESTFIN
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_VEND
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_VEND
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_IMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_IMP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),
		
		(SELECT     CL_COMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_COMP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S')
	from listaexp left outer join listaexpdet on listaexp.le_codigo = listaexpdet.le_codigo
	where listaexp.le_folio = @le_folio and listaexpdet.ar_expmx  = (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
			and listaexpdet.led_saldo > 0
	
exec SP_ACTUALIZACONSECUTIVOTABLA 'FE'

declare detalle cursor for
select					MA_CODIGO, LED_NOMBRE, LED_NOPARTE, LED_NAME, ME_CODIGO, isnull(LED_SALDO,0), isnull(LED_GRA_MP,0), isnull(LED_GRA_MO,0), 
						isnull(LED_GRA_EMP,0), isnull(LED_GRA_ADD,0), isnull(LED_GRA_GI,0), isnull(LED_GRA_GI_MX,0), isnull(LED_NG_MP,0), isnull(LED_NG_EMP,0), isnull(LED_NG_ADD,0), isnull(LED_NG_USA,0), isnull(LED_COS_UNI,0),
						isnull(LED_COS_TOT,0), isnull(LED_PES_UNI,0), isnull(LED_PES_NET,0), isnull(LED_PES_BRU,0), isnull(LED_PES_UNILB,0), isnull(LED_PES_NETLB,0), isnull(LED_PES_BRULB,0), isnull(LED_SEC_IMP,0),
						isnull(LED_DEF_TIP,'G'), isnull(LED_POR_DEF,-1), LED_LOTE, isnull(AR_IMPMX,0), isnull(AR_EXPMX,0), isnull(AR_IMPFO,0), MA_GENERICO,PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX,
						TI_CODIGO, LED_RATEEXPMX, LED_RATEIMPFO, isnull(SPI_CODIGO,0), 0, LED_RETRABAJO, isnull(MA_EMPAQUE,0), LED_CANTEMP, LED_TIP_ENS,
						MA_NOPARTECL, LED_NAFTA, TCO_CODIGO, END_INDICED, EN_CODIGO, CL_CODIGO, MA_STRUCT, isnull(AR_ORIG,0), isnull(AR_NG_EMP,0), LED_NOPARTEAUX,
						LED_PRECIO_UNI, LED_PRECIO_TOT, listaexpdet.LE_CODIGO, LED_INDICED
from listaexpdet left outer join listaexp on listaexpdet.le_codigo = listaexp.le_codigo
where listaexp.le_folio = @le_folio and listaexpdet.ar_expmx  = (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
	and led_saldo > 0
	open detalle
	FETCH NEXT FROM detalle INTO @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
						@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
						@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
						@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
						@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
						@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
						@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		select @fed_indiced = cv_codigo from consecutivo where cv_tipo = 'FED'
		insert into factexpdet(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_CANT, FED_GRA_MP, FED_GRA_MO,
								FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, FED_NG_USA, FED_COS_UNI,
								FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, FED_SEC_IMP,
								FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, MA_GENERICO, PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX,
								TI_CODIGO, FED_RATEEXPMX, FED_RATEIMPFO, SPI_CODIGO, FED_SALDO, FED_RETRABAJO, MA_EMPAQUE, FED_CANTEMP, FED_TIP_ENS,
								MA_NOPARTECL, FED_NAFTA, TCO_CODIGO, END_INDICED, EN_CODIGO, CL_CODIGO, MA_STRUCT, AR_ORIG, AR_NG_EMP, FED_NOPARTEAUX,
								FED_PRECIO_UNI, FED_PRECIO_TOT, LE_CODIGO, LED_INDICED)
				values(@fed_indiced, @fe_codigo, @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
						@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
						@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
						@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
						@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
						@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
						@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED)
		exec SP_ACTUALIZACONSECUTIVOTABLA 'FED'
		update listaexpdet set led_saldo = 0, led_enuso = 'S' where led_indiced = @led_indiced
		update listaexp set le_estatus = 'C' where le_folio = @le_folio
		Set @folio1 = @le_folio+'-'+@Consecutivo
		FETCH NEXT FROM detalle INTO @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
							@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
							@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
							@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
							@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
							@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
							@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED
	END
CLOSE detalle
DEALLOCATE detalle


--Genera factura con el resto de los detalles.
if exists(select subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio))
			from factexp where fe_folio like @le_folio+'-%') 
	begin
		select @Consecutivo = Max(subString(fe_folio,len(@le_folio+'-')+1,len(fe_folio)))
		 from factexp where fe_folio like @le_folio+'-%'
		Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
	end
else
    begin
		Set @Consecutivo = '1'
    end
    
select @fe_codigo = cv_codigo from consecutivo where cv_tipo = 'FE'

insert into factexp(FE_CODIGO, FE_TIPO, TF_CODIGO, FE_FECHA, FE_TIPOCAMBIO, FE_PRIORIDAD, FE_ESTATUS,
					FE_FOLIO, TQ_CODIGO, TN_CODIGO, FE_NO_SEM, US_CODIGO, AG_MX, AGT_CODIGO,
					AG_US,FE_PINICIAL, FE_PFINAL, CP_CODIGO, CL_PROD, DI_PROD, CL_DESTINI, DI_DESTINI, CL_EXP, DI_EXP,
					CL_DESTFIN, DI_DESTFIN, CL_VEND, DI_VEND, CL_IMP, DI_IMP, CL_COMP, DI_COMP)
select top 1 @fe_codigo, 'F',tf_codigo, convert(varchar(11), getdate(),101),
		(select tc_cant from tcambio where tc_fecha = convert(varchar(11), getdate(),101)),'N','D',
		@le_folio+'-'+@Consecutivo,(select tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL'), 
		case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
		then 4 
		else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fe_no_sem, 
		
		(select us_codigo from personal
		where sysusrlst_id=@user_id
		and us_codigo in (select max(us_codigo) from personal
		where sysusrlst_id=@user_id)),
		
		(select AG_MEX from cliente where cl_empresa = 'S'),
		(SELECT     AGENCIAPATENTE.AGT_CODIGO
		FROM         CLIENTE INNER JOIN
							  AGENCIAPATENTE ON CLIENTE.AG_MEX = AGENCIAPATENTE.AG_CODIGO
		WHERE     (AGENCIAPATENTE.AGT_DEFAULT = 'S') AND (CLIENTE.CL_EMPRESA = 'S') and (AGENCIAPATENTE.AGT_TIPO='A')),
		(select AG_USA from cliente where cl_empresa = 'S'),
		convert(varchar(11), getdate(),101),convert(varchar(11), getdate(),101),	

		(SELECT 
		  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
		  AND RELTFACTTEMBAR.TF_CODIGO=listaexp.TF_CODIGO) AS CP_CODIGO
		FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
		  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
		WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=listaExp.TF_CODIGO) 
		and tembarque.tq_codigo = listaexp.TQ_CODIGO),
		
		(SELECT     CL_PROD
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),

		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_PROD
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),
		
		(SELECT     CL_destini
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_DESTINI
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_EXP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_EXP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_DESTFIN
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_DESTFIN
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_VEND
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_VEND
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),

		(SELECT     CL_IMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_IMP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S'),
		
		(SELECT     CL_COMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO),
		
		(select DI_INDICE
		from dir_cliente
		where cl_codigo = (SELECT     CL_COMP
							FROM         CLIENTEENTIDADES
							WHERE     OM_TIPO = 'S' and TF_CODIGO = listaexp.TF_CODIGO)
		and di_fiscal = 'S')
	from listaexp left outer join listaexpdet on listaexp.le_codigo = listaexpdet.le_codigo
	where listaexp.le_folio = @le_folio and listaexpdet.ar_expmx  not in (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
		and listaexpdet.led_saldo > 0

exec SP_ACTUALIZACONSECUTIVOTABLA 'FE'

declare detalle2 cursor for
select					MA_CODIGO, LED_NOMBRE, LED_NOPARTE, LED_NAME, ME_CODIGO, isnull(LED_SALDO,0), isnull(LED_GRA_MP,0), isnull(LED_GRA_MO,0), 
						isnull(LED_GRA_EMP,0), isnull(LED_GRA_ADD,0), isnull(LED_GRA_GI,0), isnull(LED_GRA_GI_MX,0), isnull(LED_NG_MP,0), isnull(LED_NG_EMP,0), isnull(LED_NG_ADD,0), isnull(LED_NG_USA,0), isnull(LED_COS_UNI,0),
						isnull(LED_COS_TOT,0), isnull(LED_PES_UNI,0), isnull(LED_PES_NET,0), isnull(LED_PES_BRU,0), isnull(LED_PES_UNILB,0), isnull(LED_PES_NETLB,0), isnull(LED_PES_BRULB,0), isnull(LED_SEC_IMP,0),
						isnull(LED_DEF_TIP,'G'), isnull(LED_POR_DEF,-1), LED_LOTE, isnull(AR_IMPMX,0), isnull(AR_EXPMX,0), isnull(AR_IMPFO,0), MA_GENERICO,PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX,
						TI_CODIGO, LED_RATEEXPMX, LED_RATEIMPFO, isnull(SPI_CODIGO,0), 0, LED_RETRABAJO, isnull(MA_EMPAQUE,0), LED_CANTEMP, LED_TIP_ENS,
						MA_NOPARTECL, LED_NAFTA, TCO_CODIGO, END_INDICED, EN_CODIGO, CL_CODIGO, MA_STRUCT, isnull(AR_ORIG,0), isnull(AR_NG_EMP,0), LED_NOPARTEAUX,
						LED_PRECIO_UNI, LED_PRECIO_TOT, listaexpdet.LE_CODIGO, LED_INDICED
from listaexpdet left outer join listaexp on listaexpdet.le_codigo = listaexp.le_codigo
where listaexp.le_folio = @le_folio and listaexpdet.ar_expmx  not in (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
	and listaexpdet.led_saldo > 0
	open detalle2
	FETCH NEXT FROM detalle2 INTO @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
						@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
						@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
						@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
						@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
						@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
						@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED 

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		select @fed_indiced = cv_codigo from consecutivo where cv_tipo = 'FED'
		insert into factexpdet(FED_INDICED, FE_CODIGO, MA_CODIGO, FED_NOMBRE, FED_NOPARTE, FED_NAME, ME_CODIGO, FED_CANT, FED_GRA_MP, FED_GRA_MO,
								FED_GRA_EMP, FED_GRA_ADD, FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, FED_NG_USA, FED_COS_UNI,
								FED_COS_TOT, FED_PES_UNI, FED_PES_NET, FED_PES_BRU, FED_PES_UNILB, FED_PES_NETLB, FED_PES_BRULB, FED_SEC_IMP,
								FED_DEF_TIP, FED_POR_DEF, FED_LOTE, AR_IMPMX, AR_EXPMX, AR_IMPFO, MA_GENERICO, PA_CODIGO, EQ_GEN, EQ_IMPFO, EQ_EXPMX,
								TI_CODIGO, FED_RATEEXPMX, FED_RATEIMPFO, SPI_CODIGO, FED_SALDO, FED_RETRABAJO, MA_EMPAQUE, FED_CANTEMP, FED_TIP_ENS,
								MA_NOPARTECL, FED_NAFTA, TCO_CODIGO, END_INDICED, EN_CODIGO, CL_CODIGO, MA_STRUCT, AR_ORIG, AR_NG_EMP, FED_NOPARTEAUX,
								FED_PRECIO_UNI, FED_PRECIO_TOT, LE_CODIGO, LED_INDICED)
				values(@fed_indiced, @fe_codigo, @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
						@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
						@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
						@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
						@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
						@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
						@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED)

		exec SP_ACTUALIZACONSECUTIVOTABLA 'FED'
		update listaexpdet set led_saldo = 0, led_enuso = 'S' where led_indiced = @led_indiced
		update listaexp set le_estatus = 'C' where le_folio = @le_folio
		Set @folio2 = @le_folio+'-'+@Consecutivo
		FETCH NEXT FROM detalle2 INTO @MA_CODIGO , @FED_NOMBRE , @FED_NOPARTE , @FED_NAME , @ME_CODIGO , @FED_CANT , @FED_GRA_MP , @FED_GRA_MO ,
							@FED_GRA_EMP , @FED_GRA_ADD , @FED_GRA_GI , @FED_GRA_GI_MX , @FED_NG_MP , @FED_NG_EMP , @FED_NG_ADD , @FED_NG_USA , @FED_COS_UNI ,
							@FED_COS_TOT , @FED_PES_UNI , @FED_PES_NET , @FED_PES_BRU , @FED_PES_UNILB , @FED_PES_NETLB , @FED_PES_BRULB , @FED_SEC_IMP ,
							@FED_DEF_TIP , @FED_POR_DEF , @FED_LOTE , @AR_IMPMX , @AR_EXPMX , @AR_IMPFO , @MA_GENERICO , @PA_CODIGO , @EQ_GEN , @EQ_IMPFO , @EQ_EXPMX ,
							@TI_CODIGO , @FED_RATEEXPMX , @FED_RATEIMPFO , @SPI_CODIGO , @FED_SALDO , @FED_RETRABAJO , @MA_EMPAQUE , @FED_CANTEMP , @FED_TIP_ENS ,
							@MA_NOPARTECL , @FED_NAFTA , @TCO_CODIGO , @END_INDICED , @EN_CODIGO , @CL_CODIGO , @MA_STRUCT , @AR_ORIG , @AR_NG_EMP , @FED_NOPARTEAUX ,
							@FED_PRECIO_UNI , @FED_PRECIO_TOT, @LE_CODIGO, @LED_INDICED
	END	
CLOSE detalle2
DEALLOCATE detalle2

if (@folio1 <> '')
	set @folios = @Folio1
if (@folio2 <> '')
	if (@folios <> '')
		set @folios = @folios+', '+@folio2
	else
		set @folios = @folio2

GO
