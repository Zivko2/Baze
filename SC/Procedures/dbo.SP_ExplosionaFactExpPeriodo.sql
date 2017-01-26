SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* hace la explosion por un rango de fechas* -- solo las que son de mp */
CREATE PROCEDURE [dbo].[SP_ExplosionaFactExpPeriodo]  (@fechaini varchar(10), @fechafin varchar(10))   as

SET NOCOUNT ON 
DECLARE @FE_CODIGO INT, @CFF_TIPO CHAR(2), @fe_fecha datetime, @fe_folio varchar(30), @fecha varchar(10)


declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(KAP_CODIGO)+1,0) FROM KARDESPED 
	select @fecha=convert(varchar(10),getdate(),101)


	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP
	
/*====== Llenando bom_desctemp ====*/

	
	DECLARE CUR_FACTEXPDESC CURSOR FOR
	

		SELECT     dbo.FACTEXP.FE_CODIGO, dbo.CONFIGURATFACT.CFF_TIPO
		FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
		                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
		                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO ON 
		                      dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
		GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FECHA, dbo.CONFIGURATFACT.CFF_TIPO, dbo.FACTEXP.FE_CANCELADO, 
		                      dbo.FACTEXP.FE_DESCARGADA, dbo.CONFIGURATFACT.CFF_TRAT, dbo.CONFIGURATFACT.CFF_TIPODESCARGA
		HAVING      (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.FACTEXP.FE_DESCARGADA = 'N') 
				AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') and (dbo.FACTEXP.FE_FECHA >= @fechaini) AND (dbo.FACTEXP.FE_FECHA <= @fechafin)
		ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
	
	
	OPEN CUR_FACTEXPDESC
	
	FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


		print '<========== Llenando tabla Bom_DescTemp' + convert(varchar(11), @FE_CODIGO) + + convert(varchar(50), @fe_fecha) + '==========>' 


		EXEC SP_DescExplosionFactExp @FE_CODIGO, 1, 'N'

	
		FETCH NEXT FROM CUR_FACTEXPDESC INTO @FE_CODIGO, @CFF_TIPO
	
	END
	
	CLOSE CUR_FACTEXPDESC
	DEALLOCATE CUR_FACTEXPDESC



























GO
