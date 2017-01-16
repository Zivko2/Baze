SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQGENFACTEXP] (@fe_fechaini datetime, @fe_fechafin datetime)   as

SET NOCOUNT ON 
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTEXPDET.EQ_GEN
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_GENERICO AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
				WHERE     (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) and dbo.FACTEXP.FE_ESTATUS IN ('D', 'T'))


			UPDATE dbo.FACTEXPDET
			SET dbo.FACTEXPDET.EQ_GEN=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_GENERICO AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
				WHERE     (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) AND (dbo.FACTEXP.fe_FECHA >= @fe_fechaini)
			and dbo.FACTEXP.FE_ESTATUS IN ('D', 'T')



		-- ME_GENERICO igual a Kg
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_GEN = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) 
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.FACTEXPDET.ME_GENERICO in (select ME_KILOGRAMOS from configuracion) 
			and dbo.FACTEXP.FE_ESTATUS IN ('D', 'T')

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_GEN = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO
		WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) 
			AND (dbo.FACTEXPDET.FED_PES_UNI is null or  dbo.FACTEXPDET.FED_PES_UNI=0) 
			AND dbo.FACTEXPDET.ME_GENERICO in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTEXPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))
			and dbo.FACTEXP.FE_ESTATUS IN ('D', 'T')

		-- en base a maestromedida
		UPDATE dbo.FACTEXPDET
		SET     dbo.FACTEXPDET.EQ_GEN= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTEXPDET INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.fe_CODIGO = dbo.FACTEXP.fe_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTEXPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      MAESTRO_1.ME_COM = dbo.FACTEXPDET.ME_GENERICO
		WHERE (dbo.FACTEXP.fe_FECHA >= @fe_fechaini) AND (dbo.FACTEXP.fe_FECHA <= @fe_fechafin) 
			and dbo.FACTEXP.FE_ESTATUS IN ('D', 'T')

		-- sin factor de conversion
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_GEN = 1
		WHERE (dbo.FACTEXPDET.EQ_GEN=0 OR dbo.FACTEXPDET.EQ_GEN IS NULL)









GO
