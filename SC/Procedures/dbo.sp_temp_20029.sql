SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_temp_20029]   as


		UPDATE IMPORTSPECDET
	SET IMD_DEFAULTCHAR=LTRIM(RTRIM(IMD_DEFAULTCHAR))
	
	
	UPDATE MAESTRO
	SET MA_NOPARTEAUX=LTRIM(RTRIM(MA_NOPARTEAUX))
	WHERE MA_NOPARTEAUX='     ' AND MA_NOPARTE + LTRIM(RTRIM(MA_NOPARTEAUX)) NOT IN
	(SELECT     M1.MA_NOPARTE + LTRIM(RTRIM(M1.MA_NOPARTEAUX))
	 FROM         MAESTRO M1
	 GROUP BY M1.MA_NOPARTE + LTRIM(RTRIM(M1.MA_NOPARTEAUX))
	 HAVING      (COUNT(*) > 1))
	
	
	UPDATE FACTIMPDET
	SET FID_NOPARTEAUX=MA_NOPARTEAUX
	FROM FACTIMPDET INNER JOIN MAESTRO ON FACTIMPDET.MA_CODIGO=MAESTRO.MA_CODIGO
	WHERE rtrim(FID_NOPARTEAUX)='' OR FID_NOPARTEAUX IS NULL
	
	
	UPDATE FACTEXPDET
	SET FED_NOPARTEAUX=MA_NOPARTEAUX
	FROM FACTEXPDET INNER JOIN MAESTRO ON FACTEXPDET.MA_CODIGO=MAESTRO.MA_CODIGO
	WHERE rtrim(FED_NOPARTEAUX)='' OR FED_NOPARTEAUX IS NULL

	
	UPDATE PEDIMPDET
	SET PID_NOPARTEAUX=MA_NOPARTEAUX
	FROM PEDIMPDET INNER JOIN MAESTRO ON PEDIMPDET.MA_CODIGO=MAESTRO.MA_CODIGO
	WHERE rtrim(PID_NOPARTEAUX)='' OR PID_NOPARTEAUX IS NULL
	
	
	UPDATE LISTAEXPDET
	SET LED_NOPARTEAUX=MA_NOPARTEAUX
	FROM LISTAEXPDET INNER JOIN MAESTRO ON LISTAEXPDET.MA_CODIGO=MAESTRO.MA_CODIGO
	WHERE rtrim(LED_NOPARTEAUX)='' OR LED_NOPARTEAUX IS NULL
	
	
	UPDATE PCKLISTDET
	SET PLD_NOPARTEAUX=MA_NOPARTEAUX
	FROM PCKLISTDET INNER JOIN MAESTRO ON PCKLISTDET.MA_CODIGO=MAESTRO.MA_CODIGO
	WHERE rtrim(PLD_NOPARTEAUX)='' OR PLD_NOPARTEAUX IS NULL
	
	
	UPDATE BOM_STRUCT
	SET BST_NOPARTEAUX=MA_NOPARTEAUX
	FROM BOM_STRUCT INNER JOIN MAESTRO ON BOM_STRUCT.BST_HIJO=MAESTRO.MA_CODIGO
	WHERE rtrim(BST_NOPARTEAUX)='' OR BST_NOPARTEAUX IS NULL
	
	
	UPDATE BOM_STRUCT
	SET BSU_NOPARTEAUX=MA_NOPARTEAUX
	FROM BOM_STRUCT INNER JOIN MAESTRO ON BOM_STRUCT.BSU_SUBENSAMBLE=MAESTRO.MA_CODIGO
	WHERE rtrim(BSU_NOPARTEAUX)='' OR BSU_NOPARTEAUX IS NULL


	UPDATE NAFTA
	SET     NAFTA.NFT_NOPARTEAUX= MAESTRO.MA_NOPARTEAUX
	FROM         NAFTA INNER JOIN
	                      MAESTRO ON NAFTA.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE rtrim(NFT_NOPARTEAUX)='' OR NFT_NOPARTEAUX IS NULL

GO