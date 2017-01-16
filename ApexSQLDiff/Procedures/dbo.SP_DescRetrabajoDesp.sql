SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



/* insercion  del desperdicio generado por el retrabajo  en el almacen de desperdicio */
CREATE PROCEDURE dbo.SP_DescRetrabajoDesp (@CodigoFactura Int)   as

SET NOCOUNT ON 

DECLARE @fed_indiced int, @fe_tipo char(1), @ma_codigo int, @ma_hijo int, @ti_hijo int, @ade_cant decimal(38,6), @me_com int, @ade_saldo decimal(38,6), @ma_peso_kg decimal(38,6)



DECLARE cur_retrabajodesp CURSOR FOR

SELECT     dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXP.FE_TIPO, dbo.FACTEXPDET.MA_CODIGO, dbo.RETRABAJO.MA_HIJO, 
                      dbo.RETRABAJO.TI_HIJO, SUM(dbo.FACTEXPDET.FED_CANT * dbo.RETRABAJO.RE_INCORPOR) AS ADE_CANT, dbo.MAESTRO.ME_COM, 
                      SUM(dbo.FACTEXPDET.FED_CANT * dbo.RETRABAJO.RE_INCORPOR) AS ADE_SALDO
FROM         dbo.FACTEXP INNER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
                      dbo.RETRABAJO ON dbo.FACTEXPDET.FED_INDICED = dbo.RETRABAJO.FETR_INDICED LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.RETRABAJO.MA_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE dbo.FACTEXPDET.ADE_CODIGO NOT IN (SELECT ADE_CODIGO FROM ALMACENDESP WHERE  ADE_GENERADOPOR='R')
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.MA_CODIGO, dbo.RETRABAJO.MA_HIJO, 
                      dbo.FACTEXPDET.FED_RETRABAJO, dbo.CONFIGURATIPO.CFT_TIPO, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_DISCHARGE, 
                      dbo.RETRABAJO.FETR_RETRABAJODES, dbo.FACTEXP.FE_TIPO, dbo.RETRABAJO.TI_HIJO
HAVING      (dbo.FACTEXPDET.FED_RETRABAJO = 'R' OR
                      dbo.FACTEXPDET.FED_RETRABAJO = 'D') AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND (dbo.RETRABAJO.FETR_RETRABAJODES = 'S') AND 
                      (SUM(dbo.FACTEXPDET.FED_CANT * dbo.RETRABAJO.RE_INCORPOR) > 0)

open cur_retrabajodesp


fetch next from cur_retrabajodesp into  @fed_indiced, @fe_tipo, @ma_codigo, @ma_hijo, @ti_hijo, @ade_cant, @me_com, @ade_saldo


WHILE (@@FETCH_STATUS = 0) 
BEGIN
		select @ma_peso_kg=isnull(ma_peso_kg,0) from maestro where ma_codigo=@ma_hijo

		INSERT INTO  ALMACENDESP (FETR_CODIGO, FETR_INDICED, FETR_TIPO, MA_PADRE, MA_HIJO, TI_CODIGO,
		ADE_CANT,  ME_CODIGO, ADE_SALDO, ADE_ENUSO, ADE_GENERADOPOR, TIPO_ENT_SAL, PI_CODIGO, PID_INDICED, ADE_PESO_UNIKG)

		values 
		(@codigofactura, @fed_indiced, @fe_tipo, @ma_codigo, @ma_hijo, @ti_hijo, @ade_cant, @me_com, @ade_saldo, 'N', 'R', 'S', 0,0, isnull(@ma_peso_kg,0))

			

fetch next from cur_retrabajodesp into  @fed_indiced, @fe_tipo, @ma_codigo, @ma_hijo, @ti_hijo, @ade_cant, @me_com, @ade_saldo

END


CLOSE cur_retrabajodesp
DEALLOCATE cur_retrabajodesp



























GO
