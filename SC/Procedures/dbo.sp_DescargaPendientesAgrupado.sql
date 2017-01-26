SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* hace la descarga por un rango de fechas* -- solo las que son de mp */
CREATE PROCEDURE [dbo].[sp_DescargaPendientesAgrupado]  as


declare @fe_fecha datetime, @FechaActual varchar(10), @hora varchar(7), @FE_CODIGO int

  SET @FechaActual = convert(varchar(10), getdate(),101)


	DECLARE CUR_FACTEXPPEND CURSOR FOR
			
		SELECT     TOP 100 PERCENT dbo.FACTEXP.FE_CODIGO
		FROM         dbo.FACTEXP INNER JOIN
		                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
		WHERE     (dbo.FACTEXPDET.FED_NOMBRE LIKE 'ASPIRADORA%')
		GROUP BY dbo.FACTEXP.FE_CODIGO, dbo.FACTEXP.FE_FECHA
		HAVING      (dbo.FACTEXP.FE_FECHA <= CONVERT(DATETIME, '2002-09-30 00:00:00', 102))
		AND (dbo.FACTEXP.FE_FECHA >= CONVERT(DATETIME, '2000-09-20 00:00:00', 102))
		ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
				
	
	OPEN CUR_FACTEXPPEND
	
	FETCH NEXT FROM CUR_FACTEXPPEND INTO @FE_CODIGO
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @fe_fecha=fe_fecha from factexp where fe_codigo=@FE_CODIGO
	set @hora=right(getdate(),07)

	print '<========== Descargando' + convert(varchar(50), @FE_CODIGO) + ' ' + convert(varchar(50), @fe_fecha) +',  '+ @hora+ '==========>' 

	
			exec sp_DescPendientesAgrupado @FE_CODIGO, 'UEPS', @FechaActual, 'N'
	
		FETCH NEXT FROM CUR_FACTEXPPEND INTO @FE_CODIGO
	
	END
	
	CLOSE CUR_FACTEXPPEND
	DEALLOCATE CUR_FACTEXPPEND
GO
