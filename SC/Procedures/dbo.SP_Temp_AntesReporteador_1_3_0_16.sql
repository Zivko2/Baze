SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.SP_Temp_AntesReporteador_1_3_0_16    as

declare @bus_codigo int


insert into BUSQUEDACAMPOS(BUS_CODIGO,BSC_SELECCION,BSC_AGRUPACION,BSC_DESCRIPCION,BUF_CODIGO,BSC_SECCION,BSC_LONGITUD)
SELECT BUS_CODIGO,BUS_MOSTRAR,BUF_AGRUPACION,ISNULL(BUF_FORMULATITLE,BUS_FORMULANAME),BUF_CODIGO,BUF_SECCION,BUF_LONGITUD
from BUSQUEDAFORMULA
where BUF_TIPO = 'I'

UPDATE BUSQUEDAFORMULA SET BUF_TIPO = 'C' WHERE BUF_TIPO = 'I'

UPDATE BUSQUEDAFORMULA
SET     BUS_FORMULASTRING= REPLACE(BUS_FORMULASTRING, '#PAIS', '#VPAIS') 
WHERE     (BUS_FORMULASTRING LIKE '%#PAIS%')

UPDATE BUSQUEDAFORMULA
SET     BUS_FORMULASTRING= REPLACE(BUS_FORMULASTRING, '#MEDIDA', '#VMEDIDA') 
WHERE     (BUS_FORMULASTRING LIKE '%#MEDIDA%')

UPDATE PlntExpFormula
SET     PXF_FORMULASTRING= REPLACE(PXF_FORMULASTRING, '#PAIS', '#VPAIS') 
WHERE     (PXF_FORMULASTRING LIKE '%#PAIS%')

UPDATE PlntExpFormula
SET     PXF_FORMULASTRING= REPLACE(PXF_FORMULASTRING, '#MEDIDA', '#VMEDIDA') 
WHERE     (PXF_FORMULASTRING LIKE '%#MEDIDA%')



declare cur_tablasfaltantes cursor for
	SELECT     BUS_CODIGO
	FROM         BUSQUEDASEL
open cur_tablasfaltantes
	FETCH NEXT FROM cur_tablasfaltantes INTO @bus_codigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		INSERT INTO BUSQUEDASELDET(BUS_CODIGO, BSD_TABLA, BSD_SELECTED)

		
		select @bus_codigo, imr_tabla, 'N'
		from importtablesdetcont
		where imr_tmaster in (SELECT IMPORTTABLES.IMT_TABLA
				     FROM BUSQUEDASEL INNER JOIN IMPORTTABLES ON BUSQUEDASEL.BUS_FORMA = IMPORTTABLES.IMT_CODIGO
				     WHERE BUS_CODIGO=@bus_codigo)
		AND imr_tabla NOT IN (SELECT BSD_TABLA FROM BUSQUEDASELDET WHERE BUS_CODIGO=@bus_codigo)
		union
		select @bus_codigo, imr_tabla, 'N'
		from importtablesdetcont
		where imr_tmaster in (select imr_tabla from importtablesdetcont
		                                  where imr_tmaster in (SELECT IMPORTTABLES.IMT_TABLA
								     FROM BUSQUEDASEL INNER JOIN IMPORTTABLES 
								     ON BUSQUEDASEL.BUS_FORMA = IMPORTTABLES.IMT_CODIGO
								     WHERE BUS_CODIGO=@bus_codigo))
		AND imr_tabla NOT IN (SELECT BSD_TABLA FROM BUSQUEDASELDET WHERE BUS_CODIGO=@bus_codigo)


	FETCH NEXT FROM cur_tablasfaltantes INTO @bus_codigo

END

CLOSE cur_tablasfaltantes
DEALLOCATE cur_tablasfaltantes

	UPDATE PlntExpDet
	SET     PlntExpDet.PXT_SELECTED='S'
	FROM         PlntExpFormula INNER JOIN
	                      PlntExpSecc ON PlntExpFormula.PXS_CODIGO = PlntExpSecc.PXS_CODIGO INNER JOIN
	                      PlntExpDet ON PlntExpSecc.PXP_CODIGO = PlntExpDet.PXP_CODIGO
	WHERE     (PlntExpFormula.PXF_FORMULASTRING LIKE '%PEDIMPDET.PID_SALDOGEN%') AND (PlntExpDet.PXT_TBLNAME = 'PIDESCARGA')
	
	UPDATE PlntExpFormula
	SET     PXF_FORMULASTRING= REPLACE(PXF_FORMULASTRING, 'PEDIMPDET.PID_SALDOGEN', 'PIDESCARGA.PID_SALDOGEN') 
	WHERE     (PXF_FORMULASTRING LIKE '%PEDIMPDET.PID_SALDOGEN%')
	
	
	UPDATE BUSQUEDASELDET
	SET     BSD_SELECTED= 'S'
	FROM BUSQUEDASELDET INNER JOIN BUSQUEDAFORMULA ON BUSQUEDAFORMULA.BUS_CODIGO=BUSQUEDASELDET.BUS_CODIGO
	WHERE     (BUS_FORMULASTRING LIKE '%PEDIMPDET.PID_SALDOGEN%')
	AND BSD_TABLA='PIDESCARGA'
	
	UPDATE BUSQUEDAFORMULA
	SET     BUS_FORMULASTRING= REPLACE(BUS_FORMULASTRING, 'PEDIMPDET.PID_SALDOGEN', 'PIDESCARGA.PID_SALDOGEN') 
	WHERE     (BUS_FORMULASTRING LIKE '%PEDIMPDET.PID_SALDOGEN%')


	UPDATE BUSQUEDASEL
	SET     BUS_FILTRO=REPLACE(BUS_FILTRO, 'PEDIMPDET.PID_SALDOGEN', 'PIDESCARGA.PID_SALDOGEN') 
	WHERE BUS_FILTRO LIKE '%PEDIMPDET.PID_SALDOGEN%'

	UPDATE PlntExpSecc
	SET     PXS_FILTRO=REPLACE(PXS_FILTRO, 'PEDIMPDET.PID_SALDOGEN', 'PIDESCARGA.PID_SALDOGEN') 
	WHERE PXS_FILTRO LIKE '%PEDIMPDET.PID_SALDOGEN%'



GO
