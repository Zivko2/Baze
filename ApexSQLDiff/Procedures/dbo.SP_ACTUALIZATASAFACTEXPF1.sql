SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE PROCEDURE [dbo].[SP_ACTUALIZATASAFACTEXPF1]   as

SET NOCOUNT ON 

declare @FED_indiced int

	if not exists(select * from arancel where convert(varchar(11),AR_ULTMODIFTIGIE,101)= convert(varchar(11),getdate(),101))
	exec SP_ACTUALIZAARANCELBASETIGIE



	-- actualiza tasas
	UPDATE FACTEXPDET  
	SET FACTEXPDET.FED_RATEIMPFO= ARANCEL.AR_ADVDEF
	FROM  FACTEXPDET INNER JOIN 
	  ARANCEL ON FACTEXPDET.AR_IMPFO = ARANCEL.AR_CODIGO 
	WHERE     FACTEXPDET.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%') AND FED_NAFTA='N'


	UPDATE FACTEXPDET  
	SET FACTEXPDET.FED_RATEIMPFO= 0
	FROM  FACTEXPDET INNER JOIN 
	  ARANCEL ON FACTEXPDET.AR_IMPFO = ARANCEL.AR_CODIGO 
	WHERE     FACTEXPDET.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%') AND FED_NAFTA='S'
	

	if (SELECT CF_SINGENERICOUM FROM CONFIGURACION)='S'
	and exists (SELECT MA_GENERICO FROM FACTEXPDET WHERE MA_GENERICO = 0 AND FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%') AND AR_IMPFO > 0)
	begin
		EXEC SP_ADDGENERICOS
	
		UPDATE FACTEXPDET
		SET     FACTEXPDET.MA_GENERICO= MAESTRO.MA_GENERICO, FACTEXPDET.EQ_GEN= MAESTRO.EQ_GEN, FACTEXPDET.ME_GENERICO= 
		                      MAESTRO_1.ME_COM
		FROM         MAESTRO INNER JOIN
		                      FACTEXPDET ON MAESTRO.MA_CODIGO = FACTEXPDET.MA_CODIGO AND 
		                      MAESTRO.MA_GENERICO <> FACTEXPDET.MA_GENERICO INNER JOIN
		                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE     (FACTEXPDET.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))
	end


	/*--- se actualiza el factor de conversion ---*/


		UPDATE FACTEXPDET
		SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO=FACTEXPDET.AR_EXPMX),0)
		WHERE FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%')

		if exists (SELECT     dbo.FACTEXPDET.EQ_EXPMX
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_AREXPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%')))


			UPDATE dbo.FACTEXPDET
			SET dbo.FACTEXPDET.EQ_EXPMX=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTEXPDET.ME_AREXPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))



		-- ME_AREXPMX igual a Kg
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.FACTEXPDET.ME_AREXPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))
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
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))

		-- sin factor de conversion
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_EXPMX = 1
		WHERE (dbo.FACTEXPDET.EQ_EXPMX=0 OR dbo.FACTEXPDET.EQ_EXPMX IS NULL)


		/* ======================================= EQ_IMPFO =====================================================*/
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTEXPDET.EQ_IMPFO
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%')))


			UPDATE dbo.FACTEXPDET
			SET dbo.FACTEXPDET.EQ_IMPFO=dbo.EQUIVALE.EQ_CANT
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTEXPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTEXPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))



		-- ME_AREXPMX igual a Kg
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = dbo.FACTEXPDET.FED_PES_UNI
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))
			AND dbo.FACTEXPDET.FED_PES_UNI>0 AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		FROM  dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTEXPDET.AR_IMPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))
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
		WHERE (dbo.FACTEXP.FE_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))


	
		-- sin factor de conversion
		UPDATE dbo.FACTEXPDET
		SET dbo.FACTEXPDET.EQ_IMPFO = 1
		WHERE (dbo.FACTEXPDET.EQ_IMPFO=0 OR dbo.FACTEXPDET.EQ_IMPFO IS NULL)

/*

	UPDATE MAESTRO
	SET     MAESTRO.AR_IMPFO=FACTEXPDET.AR_IMPFO, MAESTRO.AR_EXPMX=FACTEXPDET.AR_EXPMX,
	                      MAESTRO.EQ_EXPMX=FACTEXPDET.EQ_EXPMX
	FROM         FACTEXPDET INNER JOIN
	                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (FACTEXPDET.FE_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1N%'))*/
























GO
