SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE PROCEDURE [dbo].[SP_ACTUALIZAEQARAFACTEXP] (@FE_codigo int)   as

SET NOCOUNT ON 
		-- existe en equivalencias


		UPDATE FACTEXPDET
		SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO=FACTEXPDET.AR_EXPMX),0)
		WHERE FE_CODIGO=@FE_codigo

		if exists (SELECT     dbo.FACTEXPDET.EQ_EXPMX
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_AREXPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO=@FE_codigo))


			UPDATE dbo.FACTEXPDET
			SET dbo.FACTEXPDET.EQ_EXPMX=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_AREXPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO=@FE_codigo)



		-- ME_AREXPMX igual a Kg
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)
			AND (dbo.FACTEXPDET.FED_PES_UNI is null or  dbo.FACTEXPDET.FED_PES_UNI=0) 
			AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTEXPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTEXPDET
		SET     dbo.FACTEXPDET.EQ_EXPMX= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTEXPDET INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTEXPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      MAESTRO_1.ME_COM = dbo.FACTEXPDET.ME_AREXPMX
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)

		-- sin factor de conversion
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		WHERE (dbo.FACTEXPDET.EQ_EXPMX=0 OR dbo.FACTEXPDET.EQ_EXPMX IS NULL)


/* =========================================================== EQ_IMPFO =====================================================*/
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTEXPDET.EQ_IMPFO
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO=@FE_codigo))


			UPDATE dbo.FACTEXPDET
			SET dbo.FACTEXPDET.EQ_IMPFO=dbo.EQUIVALE.EQ_CANT
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO=@FE_codigo)



		-- ME_AREXPMX igual a Kg
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)
			AND (dbo.FACTEXPDET.FED_PES_UNI is null or  dbo.FACTEXPDET.FED_PES_UNI=0) 
			AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 
			AND dbo.FACTEXPDET.ME_CODIGO not in (SELECT ME_CODIGO1 FROM EQUIVALE
			WHERE     ME_CODIGO2 in (select ME_KILOGRAMOS from configuracion))


		-- en base a maestromedida
		UPDATE dbo.FACTEXPDET
		SET     dbo.FACTEXPDET.EQ_IMPFO= dbo.MAESTROMEDIDA.EQ_CANTIDAD
		FROM         dbo.MAESTRO MAESTRO_1 INNER JOIN
	                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO INNER JOIN
	                      dbo.FACTEXPDET INNER JOIN
	                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
	                      dbo.MAESTROMEDIDA ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO AND 
	                      dbo.FACTEXPDET.ME_CODIGO = dbo.MAESTROMEDIDA.ME_CODIGO ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROMEDIDA.MA_CODIGO INNER JOIN
	                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO AND MAESTRO_1.ME_COM = dbo.ARANCEL.ME_CODIGO
		WHERE (dbo.FACTEXP.FE_CODIGO=@FE_codigo)


	
		-- sin factor de conversion
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		WHERE (dbo.FACTEXPDET.EQ_IMPFO=0 OR dbo.FACTEXPDET.EQ_IMPFO IS NULL)




































GO
