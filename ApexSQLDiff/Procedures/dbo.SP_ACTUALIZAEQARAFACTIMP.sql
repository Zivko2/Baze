SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARAFACTIMP] (@fi_codigo int)   as

SET NOCOUNT ON 
		-- existe en equivalencias


		UPDATE FACTIMPDET
		SET ME_ARIMPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO=FACTIMPDET.AR_IMPMX),0)
		WHERE FI_CODIGO=@fi_codigo

		if exists (SELECT     dbo.FACTIMPDET.EQ_IMPMX
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_ARIMPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO=@fi_codigo))

			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_IMPMX=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_ARIMPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO=@fi_codigo)



		-- ME_ARIMPMX igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)
			AND (dbo.FACTIMPDET.FID_PES_UNI is null or  dbo.FACTIMPDET.FID_PES_UNI=0) 
			AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTIMPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTIMPDET
		SET     dbo.FACTIMPDET.EQ_IMPMX= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTIMPDET INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTIMPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      MAESTRO_1.ME_COM = dbo.FACTIMPDET.ME_ARIMPMX
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)

		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		WHERE (dbo.FACTIMPDET.EQ_IMPMX=0 OR dbo.FACTIMPDET.EQ_IMPMX IS NULL)
		AND (dbo.FACTIMPDET.FI_CODIGO=@fi_codigo)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		WHERE (dbo.FACTIMPDET.EQ_IMPMX<>1 )
		AND dbo.FACTIMPDET.ME_ARIMPMX=dbo.FACTIMPDET.ME_CODIGO
		AND (dbo.FACTIMPDET.FI_CODIGO=@fi_codigo)

/* =========================================================== EQ_EXPFO =====================================================*/
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTIMPDET.EQ_EXPFO
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO=@fi_codigo))


			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_EXPFO=dbo.EQUIVALE.EQ_CANT
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO=@fi_codigo)



		-- ME_ARIMPMX igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)
			AND (dbo.FACTIMPDET.FID_PES_UNI is null or  dbo.FACTIMPDET.FID_PES_UNI=0) 
			AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTIMPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTIMPDET
		SET     dbo.FACTIMPDET.EQ_EXPFO= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTIMPDET INNER JOIN
	                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTIMPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTIMPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO INNER JOIN
	                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO AND MAESTRO_1.ME_COM = dbo.ARANCEL.ME_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO=@fi_codigo)


	
		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		WHERE (dbo.FACTIMPDET.EQ_EXPFO=0 OR dbo.FACTIMPDET.EQ_EXPFO IS NULL)
		AND (dbo.FACTIMPDET.FI_CODIGO=@fi_codigo)

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM dbo.FACTIMPDET INNER JOIN
	                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 
		WHERE (dbo.FACTIMPDET.EQ_EXPFO<>1 )
		AND dbo.ARANCEL.ME_CODIGO=dbo.FACTIMPDET.ME_CODIGO
		AND (dbo.FACTIMPDET.FI_CODIGO=@fi_codigo)




































GO
