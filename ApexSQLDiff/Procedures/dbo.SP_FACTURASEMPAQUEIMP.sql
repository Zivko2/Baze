SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_FACTURASEMPAQUEIMP] (@pl_folio varchar(25), @ar_fraccion varchar(20), @fi_no_sem varchar(20), @user_id int, @folios varchar(30) output)   as

declare @fid_indiced int, @fi_codigo int, @FID_NOPARTE varchar(30), @FID_NOMBRE varchar(150), @FID_NAME varchar(150), @FID_CANT_ST decimal(38,16), @FID_COS_UNI decimal(38,6), @FID_COS_TOT decimal(38,6), @FID_PES_UNI decimal(38,6), @FID_PES_NET decimal(38,6), @FID_PES_BRU decimal(38,6), @FID_PES_UNILB decimal(38,6), @FID_PES_NETLB decimal(38,6),
	@FID_PES_BRULB decimal(38,6), @OR_CODIGO int, @FID_OR_COMP varchar(100), @ORD_INDICED int, @FID_NOORDEN varchar(20), @FID_FEC_ENT datetime, @FID_NUM_ENT varchar(15), @FID_SEC_IMP smallint, @FID_POR_DEF decimal(38,6), @FID_DEF_TIP char(1), @FID_ENVIO varchar(20),
	@AR_IMPMX int, @AR_EXPFO int, @MA_CODIGO int, @MV_CODIGO int, @ME_CODIGO int, @MA_GENERICO int, @ME_ARIMPMX int, @PA_CODIGO int, @PL_CODIGO int, @PLD_INDICED int, @EQ_GEN decimal(28,14),
	@EQ_IMPMX decimal(28,14), @EQ_EXPFO decimal(28,14), @TI_CODIGO int, @FID_RATEEXPFO decimal(38,6), @SPI_CODIGO smallint, @MA_EMPAQUE int, @FID_CANTEMP decimal(8,6), @FID_FEC_ENV datetime, @ME_GEN int, @PID_INDICEDLIGA int, @PID_INDICEDLIGAR1 int,
	@TCO_CODIGO smallint, @FID_SALDO decimal(38,6), @FID_ENUSO char(1), @FID_NOPARTEAUX varchar(10), @EQ_EXPFO2 decimal(28,14), @Consecutivo varchar(20), @folio1 varchar(30), @folio2 varchar(30)


set @folios = ''
set @folio1 = ''
set @folio2 = ''
--Genera la factuar con la fraccion indicada
if exists(select subString(fi_folio,len(@pl_folio+'-')+1,len(fi_folio))
			from factimp where fi_folio like @pl_folio+'-%') 
	begin
		select @Consecutivo = Max(subString(fi_folio,len(@pl_folio+'-')+1,len(fi_folio)))
		 from factimp where fi_folio like @pl_folio+'-%'
		Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
	end
else
    begin
		Set @Consecutivo = '1'
    end
    
select @fi_codigo = cv_codigo from consecutivo where cv_tipo = 'FI'

insert into factimp(fi_codigo, FI_TIPO, TF_CODIGO, FI_FECHA, FI_TIPOCAMBIO, FI_PRIORIDAD, FI_ESTATUS, FI_FOLIO, TQ_CODIGO, TN_CODIGO, FI_NO_SEM,
					US_CODIGO, AG_MEX, AG_USA, FI_PINICIAL, FI_PFINAL, CP_CODIGO, PR_CODIGO, DI_PROVEE, CL_DESTFIN, DI_DESTFIN, CL_IMP, DI_IMP,
					CL_DESTINT, DI_DESTINT, CL_VEND, DI_VEND, CL_EXP, DI_EXP, CL_PROD, DI_PROD, CL_COMP, DI_COMP)

select top 1 @fi_codigo,'F', TF_CODIGO, convert(varchar(11), getdate(),101), 
	(select tc_cant from tcambio where tc_fecha = convert(varchar(11), getdate(),101)), 'N', 'S',
	@pl_folio+'-'+@Consecutivo, (select tq_codigo from tembarque where tq_nombre = 'ENVASES Y EMPAQUES'), 
	case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
		then 4 
		else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fi_no_sem, 
		
		(select us_codigo from personal
		where sysusrlst_id=@user_id
		and us_codigo in (select max(us_codigo) from personal
		where sysusrlst_id=@user_id)),
		
	(select AG_MEX from cliente where cl_empresa = 'S'),
	(select AG_USA from cliente where cl_empresa = 'S'),
	convert(varchar(11), getdate(),101),convert(varchar(11), getdate(),101),

	(SELECT 
	  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
	  AND RELTFACTTEMBAR.TF_CODIGO=pckList.TF_CODIGO) AS CP_CODIGO
	FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
	  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
	WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=pckList.TF_CODIGO) and TEMBARQUE.TQ_CODIGO = pcklist.tq_codigo),

	
	(SELECT     PR_CODIGO
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     PR_CODIGO
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_DESTFIN
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_DESTFIN
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_IMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_IMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_DESTINI
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),


	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_DESTINI
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_VEND
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_VEND
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_EXP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_EXP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_PROD
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_PROD
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),


	(SELECT     CL_COMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_COMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S')
	
		
from pcklist left outer join pcklistdet on pcklist.pl_codigo = pcklistdet.pl_codigo
where pcklist.pl_folio = @pl_folio and pcklistdet.ar_impmx  = (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
			and pcklistdet.pld_saldo > 0

exec SP_ACTUALIZACONSECUTIVOTABLA 'FI'

declare detalle cursor for
select 	PLD_NOPARTE, PLD_NOMBRE,  PLD_NAME, PLD_CANT_ST, PLD_COS_UNI, PLD_COS_TOT, PLD_PES_UNI, PLD_PES_NET, PLD_PES_BRU, PLD_PES_UNILB, PLD_PES_NETLB,
	PLD_PES_BRULB, OR_CODIGO, PLD_ORD_COMP, ORD_INDICED, PLD_NOORDEN, PLD_FEC_ENT, PLD_NUM_ENT, PLD_SEC_IMP, PLD_POR_DEF, PLD_DEF_TIP, PLD_ENVIO,
	AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, MA_GENERICO, isnull(ME_ARIMPMX,0), PA_CODIGO, PL_FOLIO, PCKLIST.PL_CODIGO, PLD_INDICED, EQ_GEN,
	EQ_IMPMX, EQ_EXPFO, TI_CODIGO, PLD_RATEEXPFO, SPI_CODIGO, isnull(MA_EMPAQUE,0), isnull(PLD_CANTEMP,0), PLD_FEC_ENV, isnull(ME_GEN,0), -1, -1,
	isnull(TCO_CODIGO,0), PLD_SALDO, PLD_ENUSO, PLD_NOPARTEAUX, EQ_EXPFO2
from pcklistdet left outer join pcklist on pcklistdet.pl_codigo = pcklist.pl_codigo
where pcklist.pl_folio = @pl_folio and pcklistdet.ar_impmx  = (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
  and pcklistdet.pld_saldo > 0
open detalle
FETCH NEXT FROM detalle INTO @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
	@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
	@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
	@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
	@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2
WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		select @fid_indiced = cv_codigo from consecutivo where cv_tipo = 'FID'
		insert into factimpdet (FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB,
					FID_PES_BRULB, OR_CODIGO, FID_ORD_COMP, ORD_INDICED, FID_NOORDEN, FID_FEC_ENT, FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO,
					AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PL_FOLIO, PL_CODIGO, PLD_INDICED, EQ_GEN,
					EQ_IMPMX, EQ_EXPFO, TI_CODIGO, FID_RATEEXPFO, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_FEC_ENV, ME_GEN, PID_INDICEDLIGA, PID_INDICEDLIGAR1,
					TCO_CODIGO, FID_SALDO, FID_ENUSO, FID_NOPARTEAUX, EQ_EXPFO2)
		Values (@fid_indiced, @fi_codigo, @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
		@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
		@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
		@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
		@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2)

		exec SP_ACTUALIZACONSECUTIVOTABLA 'FID'
		update pcklistdet set pld_saldo = 0, pld_enuso = 'S' where pld_indiced = @pld_indiced
		update pcklist set pl_estatus = 'C' where pl_folio = @pl_folio
		Set @folio1 = @pl_folio+'-'+@Consecutivo

		FETCH NEXT FROM detalle INTO @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
		@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
		@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
		@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
		@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2
	END

CLOSE detalle
DEALLOCATE detalle


--Genera factura con el resto de los detalles.
if exists(select subString(fi_folio,len(@pl_folio+'-')+1,len(fi_folio))
			from factimp where fi_folio like @pl_folio+'-%') 
	begin
		select @Consecutivo = Max(subString(fi_folio,len(@pl_folio+'-')+1,len(fi_folio)))
		 from factimp where fi_folio like @pl_folio+'-%'
		Set @Consecutivo = convert(varchar(20), convert(int,@Consecutivo) + 1)
	end
else
    begin
		Set @Consecutivo = '1'
    end
    
select @fi_codigo = cv_codigo from consecutivo where cv_tipo = 'FI'

insert into factimp(fi_codigo, FI_TIPO, TF_CODIGO, FI_FECHA, FI_TIPOCAMBIO, FI_PRIORIDAD, FI_ESTATUS, FI_FOLIO, TQ_CODIGO, TN_CODIGO, FI_NO_SEM,
					US_CODIGO, AG_MEX, AG_USA, FI_PINICIAL, FI_PFINAL, CP_CODIGO, PR_CODIGO, DI_PROVEE, CL_DESTFIN, DI_DESTFIN, CL_IMP, DI_IMP,
					CL_DESTINT, DI_DESTINT, CL_VEND, DI_VEND, CL_EXP, DI_EXP, CL_PROD, DI_PROD, CL_COMP, DI_COMP)

select top 1 @fi_codigo,'F', TF_CODIGO, convert(varchar(11), getdate(),101), 
	(select tc_cant from tcambio where tc_fecha = convert(varchar(11), getdate(),101)), 'N', 'S',
	@pl_folio+'-'+@Consecutivo, (select tq_codigo from tembarque where tq_nombre = 'TODO TIPO MATERIAL'), 
	case when (select TN_SALIDA from cliente where cl_empresa = 'S') = null 
		then 4 
		else (select TN_SALIDA from cliente where cl_empresa = 'S') end, @fi_no_sem, 
		
		(select us_codigo from personal
		where sysusrlst_id=@user_id
		and us_codigo in (select max(us_codigo) from personal
		where sysusrlst_id=@user_id)),

	(select AG_MEX from cliente where cl_empresa = 'S'),
    (select AG_USA from cliente where cl_empresa = 'S'),
	convert(varchar(11), getdate(),101),convert(varchar(11), getdate(),101),

	(SELECT 
	  (SELECT MAX(RELTFACTTEMBAR.CP_CODIGO) FROM RELTFACTTEMBAR WHERE RELTFACTTEMBAR.TQ_CODIGO = TEMBARQUE.TQ_CODIGO 
	  AND RELTFACTTEMBAR.TF_CODIGO=pckList.TF_CODIGO) AS CP_CODIGO
	FROM TEMBARQUE LEFT OUTER JOIN CONFIGURATEMBARQUE ON
	  TEMBARQUE.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO
	WHERE TEMBARQUE.TQ_CODIGO IN (SELECT TQ_CODIGO FROM RELTFACTTEMBAR WHERE TF_CODIGO=pckList.TF_CODIGO) and TEMBARQUE.TQ_CODIGO = pcklist.tq_codigo),
		
	(SELECT     PR_CODIGO
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     PR_CODIGO
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_DESTFIN
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_DESTFIN
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_IMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_IMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_DESTINI
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),


	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_DESTINI
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_VEND
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_VEND
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_EXP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_EXP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),

	(SELECT     CL_PROD
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_PROD
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S'),


	(SELECT     CL_COMP
		FROM         CLIENTEENTIDADES
		WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO),
		
	(select DI_INDICE
			from dir_cliente
			where cl_codigo = (SELECT     CL_COMP
								FROM         CLIENTEENTIDADES
								WHERE     OM_TIPO = 'E' and TF_CODIGO = pcklist.TF_CODIGO)
			and di_fiscal = 'S')
	
		
from pcklist left outer join pcklistdet on pcklist.pl_codigo = pcklistdet.pl_codigo
where pcklist.pl_folio = @pl_folio and pcklistdet.ar_impmx  not in (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
			and pcklistdet.pld_saldo > 0

exec SP_ACTUALIZACONSECUTIVOTABLA 'FI'

declare detalle2 cursor for
select 	PLD_NOPARTE, PLD_NOMBRE,  PLD_NAME, PLD_CANT_ST, PLD_COS_UNI, PLD_COS_TOT, PLD_PES_UNI, PLD_PES_NET, PLD_PES_BRU, PLD_PES_UNILB, PLD_PES_NETLB,
	PLD_PES_BRULB, OR_CODIGO, PLD_ORD_COMP, ORD_INDICED, PLD_NOORDEN, PLD_FEC_ENT, PLD_NUM_ENT, PLD_SEC_IMP, PLD_POR_DEF, PLD_DEF_TIP, PLD_ENVIO,
	AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, MA_GENERICO, isnull(ME_ARIMPMX,0), PA_CODIGO, PL_FOLIO, PCKLIST.PL_CODIGO, PLD_INDICED, EQ_GEN,
	EQ_IMPMX, EQ_EXPFO, TI_CODIGO, PLD_RATEEXPFO, SPI_CODIGO, isnull(MA_EMPAQUE,0), isnull(PLD_CANTEMP,0), PLD_FEC_ENV, isnull(ME_GEN,0), -1, -1,
	isnull(TCO_CODIGO,0), PLD_SALDO, PLD_ENUSO, PLD_NOPARTEAUX, EQ_EXPFO2
from pcklistdet left outer join pcklist on pcklistdet.pl_codigo = pcklist.pl_codigo
where pcklist.pl_folio = @pl_folio and pcklistdet.ar_impmx  not in (select ar_codigo from arancel where ar_fraccion = @ar_fraccion)
  and pcklistdet.pld_saldo > 0
open detalle2
FETCH NEXT FROM detalle2 INTO @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
	@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
	@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
	@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
	@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2
WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		select @fid_indiced = cv_codigo from consecutivo where cv_tipo = 'FID'
		insert into factimpdet (FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB,
					FID_PES_BRULB, OR_CODIGO, FID_ORD_COMP, ORD_INDICED, FID_NOORDEN, FID_FEC_ENT, FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO,
					AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PL_FOLIO, PL_CODIGO, PLD_INDICED, EQ_GEN,
					EQ_IMPMX, EQ_EXPFO, TI_CODIGO, FID_RATEEXPFO, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_FEC_ENV, ME_GEN, PID_INDICEDLIGA, PID_INDICEDLIGAR1,
					TCO_CODIGO, FID_SALDO, FID_ENUSO, FID_NOPARTEAUX, EQ_EXPFO2)
		Values (@fid_indiced, @fi_codigo, @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
		@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
		@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
		@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
		@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2)

		exec SP_ACTUALIZACONSECUTIVOTABLA 'FID'
		update pcklistdet set pld_saldo = 0, pld_enuso = 'S' where pld_indiced = @pld_indiced
		update pcklist set pl_estatus = 'C' where pl_folio = @pl_folio
		Set @folio2 = @pl_folio+'-'+@Consecutivo

		FETCH NEXT FROM detalle2 INTO @FID_NOPARTE, @FID_NOMBRE, @FID_NAME, @FID_CANT_ST, @FID_COS_UNI, @FID_COS_TOT, @FID_PES_UNI, @FID_PES_NET, @FID_PES_BRU, @FID_PES_UNILB, @FID_PES_NETLB,
		@FID_PES_BRULB, @OR_CODIGO, @FID_OR_COMP, @ORD_INDICED, @FID_NOORDEN, @FID_FEC_ENT, @FID_NUM_ENT, @FID_SEC_IMP, @FID_POR_DEF, @FID_DEF_TIP, @FID_ENVIO,
		@AR_IMPMX, @AR_EXPFO, @MA_CODIGO, @MV_CODIGO, @ME_CODIGO, @MA_GENERICO, @ME_ARIMPMX, @PA_CODIGO, @PL_FOLIO, @PL_CODIGO, @PLD_INDICED, @EQ_GEN,
		@EQ_IMPMX, @EQ_EXPFO, @TI_CODIGO, @FID_RATEEXPFO, @SPI_CODIGO, @MA_EMPAQUE, @FID_CANTEMP, @FID_FEC_ENV, @ME_GEN, @PID_INDICEDLIGA, @PID_INDICEDLIGAR1,
		@TCO_CODIGO, @FID_SALDO, @FID_ENUSO, @FID_NOPARTEAUX, @EQ_EXPFO2
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
