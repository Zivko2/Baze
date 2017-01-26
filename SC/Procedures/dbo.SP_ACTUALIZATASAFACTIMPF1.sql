SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE PROCEDURE [dbo].[SP_ACTUALIZATASAFACTIMPF1]   as

SET NOCOUNT ON 

declare @fid_indiced int


	if not exists(select * from arancel where convert(varchar(11),AR_ULTMODIFTIGIE,101)= convert(varchar(11),getdate(),101))
	exec SP_ACTUALIZAARANCELBASETIGIE



	-- actualiza tasas

/*	UPDATE FACTIMPDET  
	SET FACTIMPDET.FID_POR_DEF= ARANCEL.AR_ADVDEF, FACTIMPDET.SPI_CODIGO=0, 
	FACTIMPDET.FID_SEC_IMP=0 
	FROM  FACTIMPDET INNER JOIN 
	  ARANCEL ON FACTIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO 
	WHERE     (FACTIMPDET.FID_DEF_TIP = 'G') AND FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')
	
	UPDATE FACTIMPDET  
	SET FACTIMPDET.FID_POR_DEF= ARANCEL.AR_PORCENT_8VA, FACTIMPDET.SPI_CODIGO=0, 
	FACTIMPDET.FID_SEC_IMP=0 
	FROM  FACTIMPDET INNER JOIN 
	  ARANCEL ON FACTIMPDET.AR_IMPMX = ARANCEL.AR_CODIGO 
	WHERE     (FACTIMPDET.FID_DEF_TIP = 'R') AND FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')
	
	UPDATE FACTIMPDET  
	SET FACTIMPDET.FID_POR_DEF= PAISARA.PAR_BEN, FACTIMPDET.FID_SEC_IMP=0, FACTIMPDET.SPI_CODIGO=22 
	FROM FACTIMPDET INNER JOIN 
	PAISARA ON FACTIMPDET.AR_IMPMX = PAISARA.AR_CODIGO AND FACTIMPDET.PA_CODIGO = PAISARA.PA_CODIGO 
	WHERE (FACTIMPDET.FID_DEF_TIP = 'P') AND FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')
	AND FACTIMPDET.PA_CODIGO =233

	UPDATE FACTIMPDET  
	SET FACTIMPDET.FID_POR_DEF= PAISARA.PAR_BEN, FACTIMPDET.FID_SEC_IMP=0
	FROM FACTIMPDET INNER JOIN 
	PAISARA ON FACTIMPDET.AR_IMPMX = PAISARA.AR_CODIGO AND FACTIMPDET.SPI_CODIGO = PAISARA.SPI_CODIGO 
	WHERE (FACTIMPDET.FID_DEF_TIP = 'P') AND FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')
	AND FACTIMPDET.PA_CODIGO <>233

*/

	UPDATE FACTIMPDET
	SET     FACTIMPDET.FID_SEC_IMP= (SELECT SE_CODIGO FROM CONFIGURACION)
	FROM         FACTIMPDET
	WHERE     (FACTIMPDET.FID_DEF_TIP = 'S') AND (FACTIMPDET.FID_SEC_IMP = 0 OR
	                      FACTIMPDET.FID_SEC_IMP IS NULL) AND (FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))

	UPDATE FACTIMPDET
	SET     FACTIMPDET.FID_SEC_IMP= MAESTRO.MA_SEC_IMP
	FROM         FACTIMPDET INNER JOIN
	                      MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (FACTIMPDET.FID_DEF_TIP = 'S') AND (FACTIMPDET.FID_SEC_IMP = 0 OR
	                      FACTIMPDET.FID_SEC_IMP IS NULL) AND (MAESTRO.MA_SEC_IMP > 0) AND (FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
	
/*	UPDATE FACTIMPDET  
	SET   FACTIMPDET.FID_POR_DEF= SECTORARA.SA_PORCENT, FACTIMPDET.SPI_CODIGO=0 
	FROM  FACTIMPDET INNER JOIN 
	 SECTORARA ON FACTIMPDET.AR_IMPMX = SECTORARA.AR_CODIGO AND 
	 FACTIMPDET.FID_SEC_IMP = SECTORARA.SE_CODIGO 
	WHERE (FACTIMPDET.FID_DEF_TIP = 'S') AND FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%') */




	if (SELECT CF_SINGENERICOUM FROM CONFIGURACION)='S'
	and exists (SELECT MA_GENERICO FROM FACTIMPDET WHERE MA_GENERICO = 0 AND FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%') AND AR_IMPMX > 0)
	begin
		EXEC SP_ADDGENERICOS
	
		UPDATE FACTIMPDET
		SET     FACTIMPDET.MA_GENERICO= MAESTRO.MA_GENERICO, FACTIMPDET.EQ_GEN= MAESTRO.EQ_GEN, FACTIMPDET.ME_GEN= 
		                      MAESTRO_1.ME_COM
		FROM         MAESTRO INNER JOIN
		                      FACTIMPDET ON MAESTRO.MA_CODIGO = FACTIMPDET.MA_CODIGO AND 
		                      MAESTRO.MA_GENERICO <> FACTIMPDET.MA_GENERICO INNER JOIN
		                      MAESTRO MAESTRO_1 ON MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE     (FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
	end

	/*--	se actualizan factores de conversion */

		UPDATE FACTIMPDET
		SET ME_ARIMPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO=FACTIMPDET.AR_IMPMX),0)
		WHERE FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')

		if exists (SELECT     dbo.FACTIMPDET.EQ_IMPMX
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_ARIMPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')))

			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_IMPMX=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_ARIMPMX AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))



		-- ME_ARIMPMX igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.ME_ARIMPMX in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
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
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))

		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		WHERE (dbo.FACTIMPDET.EQ_IMPMX=0 OR dbo.FACTIMPDET.EQ_IMPMX IS NULL)
		AND (dbo.FACTIMPDET.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_IMPMX = 1
		WHERE (dbo.FACTIMPDET.EQ_IMPMX<>1 )
		AND dbo.FACTIMPDET.ME_ARIMPMX=dbo.FACTIMPDET.ME_CODIGO
		AND (dbo.FACTIMPDET.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))

		/* ===================== EQ_EXPFO =====================================================*/
		-- existe en equivalencias
		if exists (SELECT     dbo.FACTIMPDET.EQ_EXPFO
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')))


			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_EXPFO=dbo.EQUIVALE.EQ_CANT
				FROM         dbo.EQUIVALE INNER JOIN
				                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
				                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN
				                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO AND dbo.EQUIVALE.ME_CODIGO2 = dbo.ARANCEL.ME_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))



		-- ME_ARIMPMX igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.ARANCEL.ME_CODIGO in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO INNER JOIN ARANCEL ON
		      dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 			
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
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
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))


	
		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		WHERE (dbo.FACTIMPDET.EQ_EXPFO=0 OR dbo.FACTIMPDET.EQ_EXPFO IS NULL)
		AND (dbo.FACTIMPDET.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_EXPFO = 1
		FROM dbo.FACTIMPDET INNER JOIN
	                      dbo.ARANCEL ON dbo.FACTIMPDET.AR_EXPFO = dbo.ARANCEL.AR_CODIGO 
		WHERE (dbo.FACTIMPDET.EQ_EXPFO<>1 )
		AND dbo.ARANCEL.ME_CODIGO=dbo.FACTIMPDET.ME_CODIGO
		AND (dbo.FACTIMPDET.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))


	/* se actualiza eq_gen*/

	if exists (SELECT     dbo.FACTIMPDET.EQ_GEN
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')))


			UPDATE dbo.FACTIMPDET
			SET dbo.FACTIMPDET.EQ_GEN=dbo.EQUIVALE.EQ_CANT
			FROM         dbo.EQUIVALE INNER JOIN
			                      dbo.FACTIMPDET ON dbo.EQUIVALE.ME_CODIGO2 = dbo.FACTIMPDET.ME_GEN AND 
			                      dbo.EQUIVALE.ME_CODIGO1 = dbo.FACTIMPDET.ME_CODIGO INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
				WHERE     (dbo.FACTIMP.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')) 



		-- me_gen igual a Kg
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = dbo.FACTIMPDET.FID_PES_UNI
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')) 
			AND dbo.FACTIMPDET.FID_PES_UNI>0 AND dbo.FACTIMPDET.ME_GEN in (select ME_KILOGRAMOS from configuracion) 

		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		FROM  dbo.FACTIMPDET INNER JOIN
                      dbo.FACTIMP ON dbo.FACTIMPDET.FI_CODIGO = dbo.FACTIMP.FI_CODIGO
		WHERE (dbo.FACTIMP.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')) 
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
		WHERE (dbo.FACTIMP.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')) 

		-- sin factor de conversion
		UPDATE dbo.FACTIMPDET
		SET dbo.FACTIMPDET.EQ_GEN = 1
		WHERE (dbo.FACTIMPDET.EQ_GEN=0 OR dbo.FACTIMPDET.EQ_GEN IS NULL)



/*
	UPDATE MAESTRO
	SET     MAESTRO.AR_IMPMX=FACTIMPDET.AR_IMPMX, MAESTRO.AR_EXPMX=FACTIMPDET.AR_IMPMX,
		         MAESTRO.MA_SEC_IMP=FACTIMPDET.FID_SEC_IMP, 
	                      MAESTRO.MA_DEF_TIP=FACTIMPDET.FID_DEF_TIP, 
	                      MAESTRO.SPI_CODIGO=FACTIMPDET.SPI_CODIGO, MAESTRO.EQ_IMPMX=FACTIMPDET.EQ_IMPMX,
		MAESTRO.EQ_GEN=FACTIMPDET.EQ_GEN
	FROM         FACTIMPDET INNER JOIN
	                      MAESTRO ON FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%'))
*/


	UPDATE FACTIMPDET
	SET FID_POR_DEF=dbo.GetAdvalorem(FACTIMPDET.AR_IMPMX, FACTIMPDET.PA_CODIGO, FACTIMPDET.FID_DEF_TIP, FACTIMPDET.FID_SEC_IMP, FACTIMPDET.SPI_CODIGO)
	WHERE FACTIMPDET.FI_CODIGO  in (select fi_codigo from FolioFile1 where FileType like 'FIL1S%')
























GO
