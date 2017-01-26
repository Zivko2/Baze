SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[GeneraNegativosDescargas] (@fe_codigo int)   as


declare @entravigor datetime, @BST_PT int, @fed_indiced int,
@CODIGOFACTURA int, @countbom INT, @FETR_CODIGO int, @FETR_INDICED int, @MA_HIJO int, @RE_NOPARTE varchar(30), @RE_NOMBRE varchar(150), 
	@RE_NAME varchar(150), @RE_INCORPOR decimal(38,6), @TI_HIJO int, @ME_CODIGO int, @MA_GENERICO int, @ME_GEN int, @RE_INCORPORGEN decimal(38,6),
	 @FACTCONV  decimal(28,14), @CONSECUTIVO INT, @re_indicer INT, @fed_retrabajo char(1), @fed_cant decimal(38,6)

--crea una tabla temporal
	exec sp_droptable 'TEMP_RETRABAJO'
	exec SP_GENERATEMP_RETRABAJO


SELECT @CONSECUTIVO=ISNULL(MAX(re_indicer),0)+1 FROM retrabajo
dbcc checkident (TEMP_RETRABAJO, reseed, @CONSECUTIVO) WITH NO_INFOMSGS

exec sp_droptable 'RetrabajoMod'


	print 'Creando tabla RetrabajoMod'

	select fed_indiced
	into dbo.RetrabajoMod
	from factexpdet left outer join factexp
	on factexp.fe_codigo=factexpdet.fe_codigo
	where fed_indiced in (SELECT KAP_INDICED_FACT FROM KARDESPED where (kap_estatus='p'or kap_estatus='n') and kap_factrans=@fe_codigo)
	and factexpdet.fe_codigo=@fe_codigo


ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet

print 'actualizando FED_RETRABAJO'
UPDATE FACTEXPDET
SET FED_RETRABAJO='A'
WHERE FED_RETRABAJO<>'A' and fed_indiced in (select fed_indiced from RetrabajoMod)


DELETE FROM RETRABAJO
WHERE TIPO_FACTRANS='F' and FETR_INDICED in (select fed_indiced from RetrabajoMod)

ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet


exec sp_droptable 'CANTNEGATIVA'	

print 'Generando la tabla CANTNEGATIVA'

SELECT     KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO, 0-dbo.trunc(SUM(KAP_Saldo_FED),6) AS KAP_CANTDESC
INTO dbo.CANTNEGATIVA
FROM         VKARDESPEDN
WHERE KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod)
GROUP BY KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO
HAVING  round(SUM(KAP_Saldo_FED),6) >0


print 'Insertando en la tabla TEMP_RETRABAJO'
	INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN, FETR_NAFTA, PA_ORIGEN)

	SELECT     'F', KAP_FACTRANS, KAP_INDICED_FACT, MA_HIJO, isnull(MAESTRO.MA_NOPARTE, (select max(pid_noparte) from pedimpdet where ma_codigo=CANTNEGATIVA.ma_hijo)), 
		isnull(MAESTRO.MA_NOMBRE, (select max(pid_nombre) from pedimpdet where ma_codigo=CANTNEGATIVA.ma_hijo)), 
		isnull(MAESTRO.MA_NAME,(select max(pid_name) from pedimpdet where ma_codigo=CANTNEGATIVA.ma_hijo)),
		dbo.trunc(KAP_CANTDESC/ISNULL(MAESTRO.EQ_GEN, 1),6), 
		isnull(MAESTRO.TI_CODIGO,(select max(ti_codigo) from pedimpdet where ma_codigo=CANTNEGATIVA.ma_hijo)), 
		isnull(MAESTRO.ME_COM,19), isnull(MAESTRO.MA_GENERICO, (select max(ma_generico) from pedimpdet where ma_codigo=CANTNEGATIVA.ma_hijo)), 
		isnull(MAESTROGEN.ME_COM,19),
		MAESTRO.EQ_GEN AS EQ_GEN, 'N', ROUND(KAP_CANTDESC,6),
		isnull((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=MA_HIJO),'N'),
		isnull(MAESTRO.PA_ORIGEN, 233)
	FROM CANTNEGATIVA LEFT OUTER JOIN FACTEXPDET ON 
		CANTNEGATIVA.KAP_INDICED_FACT = FACTEXPDET.FED_INDICED
		LEFT OUTER JOIN MAESTRO 
		ON CANTNEGATIVA.MA_HIJO=MAESTRO.MA_CODIGO 
		LEFT OUTER JOIN MAESTRO MAESTROGEN ON
		MAESTRO.MA_GENERICO = MAESTROGEN.MA_CODIGO

	select @RE_INDICER= isnull(max(RE_INDICER),0)+1 from RETRABAJO

print 'Insertando en la tabla RETRABAJO'

	INSERT INTO RETRABAJO (RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN, FETR_NAFTA, PA_ORIGEN)

	SELECT @RE_INDICER+RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
		TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, FACTCONV, FETR_RETRABAJODES, RE_INCORPORGEN, FETR_NAFTA, PA_ORIGEN
	FROM TEMP_RETRABAJO


	select @RE_INDICER= isnull(max(RE_INDICER),0) from RETRABAJO

	update consecutivo
	set cv_codigo =  isnull(@RE_INDICER,0) + 1
	where cv_tipo = 'RE'


print 'Borrando Tablas: TEMP_RETRABAJO y CANTNEGATIVA'

exec sp_droptable 'TEMP_RETRABAJO'
exec sp_droptable 'CANTNEGATIVA'	

if exists(select * from kardesped where  KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod) and kap_estatus='N')
delete from kardesped
WHERE KAP_INDICED_FACT IN (SELECT fed_indiced FROM RetrabajoMod)
and kap_estatus='N'

exec sp_droptable 'RetrabajoMod'

print 'Proceso terminado'








GO
