SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GeneraBomBaseDescargas] (@fechaini varchar(10), @fechafin varchar(10), @fe_codigo int=0)   as




-- arregla parcialmente descargados y borra no se encuentra en pedimento
exec GeneraParcialesKardesPed @fechaini, @fechafin, @fe_codigo, 'N'


exec GeneraBomBaseDescargas1 @fechaini, @fechafin, @fe_codigo, 'S'

/*declare @entravigor datetime, @BST_PT int, @fed_indiced int,
@CODIGOFACTURA int, @countbom INT, @FETR_CODIGO int, @FETR_INDICED int, @MA_HIJO int, @RE_NOPARTE varchar(30), @RE_NOMBRE varchar(150), 
	@RE_NAME varchar(150), @RE_INCORPOR decimal(38,6), @TI_HIJO int, @ME_CODIGO int, @MA_GENERICO int, @ME_GEN int, @RE_INCORPORGEN decimal(38,6),
	 @FACTCONV  decimal(28,14), @CONSECUTIVO INT, @re_indicer INT, @fed_retrabajo char(1), @fed_cant decimal(38,6)

if @fe_codigo is null
set @fe_codigo=0

--crea una tabla temporal
exec sp_droptable 'RETRABAJOTemp'

	print 'Creando tabla RETRABAJOTemp'
	CREATE TABLE [dbo].[RETRABAJOTemp] (
		[RE_INDICER] [int] IDENTITY (1, 1) NOT NULL ,
		[TIPO_FACTRANS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		[FETR_CODIGO] [int] NOT NULL ,
		[FETR_INDICED] [int] NOT NULL ,
		[MA_HIJO] [int] NOT NULL ,
		[RE_NOPARTE] [varchar] (30) NULL ,
		[RE_NOMBRE] [varchar] (150) NULL ,
		[RE_NAME] [varchar] (150) NULL ,
		[RE_INCORPOR] decimal(38,6) NULL ,
		[TI_HIJO] [smallint] NULL ,
		[ME_CODIGO] [int] NULL ,
		[MA_GENERICO] [int] NULL ,
		[ME_GEN] [int] NULL ,
		[RE_INCORPORGEN] decimal(38,6) NULL DEFAULT (1),
		[FACTCONV] decimal(28,14) NULL ,
		[FETR_RETRABAJODES] [char] (1) NULL 
	) ON [PRIMARY]



--SELECT @CONSECUTIVO=ISNULL(MAX(re_indicer),0)+1 FROM retrabajo
dbcc checkident (retrabajotemp, reseed, 1) WITH NO_INFOMSGS

exec sp_droptable 'RetrabajoMod'


if @fe_codigo>0 
begin
	print 'Creando tabla RetrabajoMod'
	select fed_indiced
	into RetrabajoMod
	from factexpdet left outer join factexp
	on factexp.fe_codigo=factexpdet.fe_codigo
	where fed_indiced in (SELECT KAP_INDICED_FACT FROM KARDESPED where (kap_estatus='p'or kap_estatus='n') and kap_factrans=@fe_codigo)
	and factexpdet.fe_codigo=@fe_codigo
end
else
begin
	print 'Creando tabla RetrabajoMod'
	select fed_indiced
	into RetrabajoMod
	from factexpdet left outer join factexp
	on factexp.fe_codigo=factexpdet.fe_codigo
	where fed_indiced in (SELECT KAP_INDICED_FACT FROM KARDESPED left outer join factexp on kardesped.kap_factrans=factexp.fe_codigo
			        where (kap_estatus='p'or kap_estatus='n') and fe_fecha>=@fechaini and fe_fecha<=@fechafin)
--	and fe_fecha>=@fechaini and fe_fecha<=@fechafin
end


-- arregla parcialmente descargados y borra no se encuentra en pedimento
exec GeneraParcialesKardesPed @fechaini, @fechafin, @fe_codigo

print 'Llenando tabla RetrabajoModHist'
	if exists (select * from dbo.sysobjects where name='RetrabajoModHist')
	begin
		insert into RetrabajoModHist(fed_indiced, fed_retrabajo)
		select RetrabajoMod.fed_indiced, factexpdet.fed_retrabajo from RetrabajoMod inner join factexpdet on RetrabajoMod.fed_indiced=factexpdet.fed_indiced 
		where factexpdet.fed_indiced not in (select fed_indiced from RetrabajoModHist)
	end
	else
	begin
		select RetrabajoMod.fed_indiced , factexpdet.fed_retrabajo
		into RetrabajoModHist
		from RetrabajoMod inner join factexpdet on RetrabajoMod.fed_indiced=factexpdet.fed_indiced 
	end

ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet

print 'actualizando FED_RETRABAJO'
UPDATE FACTEXPDET
SET FED_RETRABAJO='E'
WHERE FED_RETRABAJO<>'E' and FED_RETRABAJO<>'D' and fed_indiced in (select fed_indiced from RetrabajoMod)


DELETE FROM RETRABAJO
WHERE TIPO_FACTRANS='F' and FETR_INDICED in (select fed_indiced from RetrabajoMod)

ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet

--if exists(select * from retrabajo where fetr_indiced in (select fed_indiced from RetrabajoMod))	
--delete from retrabajo where fetr_indiced in (select fed_indiced from RetrabajoMod)



exec sp_droptable 'CANTDESCARGADA'	

print 'Generando la tabla CANTDESCARGADA'

SELECT     KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO, dbo.trunc(SUM(KAP_CANTDESC),6) AS KAP_CANTDESC
INTO CANTDESCARGADA
FROM         KARDESPED
WHERE KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod)
GROUP BY KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO
HAVING  round(SUM(KAP_CANTDESC),6) >0


print 'Insertando en la tabla RETRABAJOTemp'
	INSERT INTO RETRABAJOTemp (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN)

	SELECT     'F', KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO, isnull(MAESTRO.MA_NOPARTE, (select max(pid_noparte) from pedimpdet where ma_codigo=CANTDESCARGADA.ma_hijo)), 
		isnull(MAESTRO.MA_NOMBRE, (select max(pid_nombre) from pedimpdet where ma_codigo=CANTDESCARGADA.ma_hijo)), 
		isnull(MAESTRO.MA_NAME,(select max(pid_name) from pedimpdet where ma_codigo=CANTDESCARGADA.ma_hijo)),
		 dbo.trunc(KAP_CANTDESC/FACTEXPDET.FED_CANT/ISNULL(MAESTRO.EQ_GEN, 1),6), 
		isnull(MAESTRO.TI_CODIGO,(select max(ti_codigo) from pedimpdet where ma_codigo=CANTDESCARGADA.ma_hijo)), 
		isnull(MAESTRO.ME_COM,19), isnull(MAESTRO.MA_GENERICO, (select max(ma_generico) from pedimpdet where ma_codigo=CANTDESCARGADA.ma_hijo)), 
		isnull(MAESTROGEN.ME_COM,19),
		isnull(MAESTRO.EQ_GEN,1) AS EQ_GEN, 'N', ROUND(KAP_CANTDESC/FACTEXPDET.FED_CANT,6)
	FROM CANTDESCARGADA LEFT OUTER JOIN FACTEXPDET ON 
		CANTDESCARGADA.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED
		LEFT OUTER JOIN MAESTRO 
		ON CANTDESCARGADA.MA_HIJO=MAESTRO.MA_CODIGO 
		LEFT OUTER JOIN MAESTRO MAESTROGEN ON
		MAESTRO.MA_GENERICO = MAESTROGEN.MA_CODIGO
	WHERE ROUND(KAP_CANTDESC/FACTEXPDET.FED_CANT/ISNULL(MAESTRO.EQ_GEN, 1),6) >0


	select @RE_INDICER= max(RE_INDICER)+1 from RETRABAJO

print 'Insertando en la tabla RETRABAJO'

	INSERT INTO RETRABAJO (RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN)

	SELECT @RE_INDICER+RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
		TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN
	FROM RETRABAJOTemp


	select @RE_INDICER= max(RE_INDICER) from RETRABAJO

	update consecutivo
	set cv_codigo =  isnull(@RE_INDICER,0) + 1
	where cv_tipo = 'RE'


print 'Borrando Tablas: RETRABAJOTemp y CANTDESCARGADA'

exec sp_droptable 'RETRABAJOTemp'
exec sp_droptable 'CANTDESCARGADA'	

--if exists(select * from kardesped where  KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod) and kap_estatus='N')
--delete from kardesped
--WHERE KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod)
--and kap_estatus='N'

exec sp_droptable 'RetrabajoMod'

print 'Proceso terminado'*/



GO
