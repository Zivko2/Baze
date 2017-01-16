SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQGENFI] (@fi_codigo int)   as

SET NOCOUNT ON 
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTIMPDET.EQ_GEN
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO <= @fi_codigo))


			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_GEN=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO <= @fi_codigo) 



		-- me_gen igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO>= @fi_codigo) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.ME_GEN in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO >= @fi_codigo) 
			AND (dbo.FACTIMPDET.FID_PES_UNI is null or  dbo.FACTIMPDET.FID_PES_UNI=0) 
			AND dbo.FACTIMPDET.ME_GEN in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTIMPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTIMPDET
		SET     dbo.FACTIMPDET.EQ_GEN= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTIMPDET INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTIMPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      MAESTRO_1.ME_COM = dbo.FACTIMPDET.ME_GEN
		WHERE (dbo.FACTIMP.FI_CODIGO >= @fi_codigo) 

		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		WHERE (dbo.FACTIMPDET.EQ_GEN=0 OR dbo.FACTIMPDET.EQ_GEN IS NULL)




































GO
