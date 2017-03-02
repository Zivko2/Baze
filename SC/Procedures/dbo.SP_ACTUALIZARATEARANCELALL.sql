SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE PROCEDURE [dbo].[SP_ACTUALIZARATEARANCELALL]   as

SET NOCOUNT ON 

/*
	--General
	UPDATE MAESTRO
	SET MAESTRO.MA_POR_DEF=ISNULL(ARANCEL.AR_ADVDEF,-1)
	FROM MAESTRO, ARANCEL
	WHERE MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO AND MA_DEF_TIP='G'
	
	
	--Preferencial
	UPDATE MAESTRO
	SET MAESTRO.MA_POR_DEF=ISNULL(PAISARA.PAR_BEN,-1)
	FROM MAESTRO, PAISARA
	WHERE MAESTRO.SPI_CODIGO = PAISARA.SPI_CODIGO AND 
	    MAESTRO.PA_ORIGEN = PAISARA.PA_CODIGO AND 
	    MAESTRO.AR_IMPMX = PAISARA.AR_CODIGO AND MA_DEF_TIP='P'
	
	
	--Sectorial
	UPDATE MAESTRO
	SET MAESTRO.MA_POR_DEF=ISNULL(SECTORARA.SA_PORCENT,-1)
	FROM MAESTRO, SECTORARA
	WHERE MAESTRO.AR_IMPMX = SECTORARA.AR_CODIGO AND 
	    MAESTRO.MA_SEC_IMP = SECTORARA.SE_CODIGO AND MA_DEF_TIP='S'
	
	
	--Regla Octava
	UPDATE MAESTRO
	SET MAESTRO.MA_POR_DEF=ISNULL(ARANCEL.AR_PORCENT_8VA,-1)
	FROM MAESTRO, ARANCEL
	WHERE MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO AND MA_DEF_TIP='R'
	
	
	
	-- USA 
	
	UPDATE MAESTRO
	SET MAESTRO.MA_RATEIMPFO= ISNULL(AR_ADVDEF,-1)
	FROM MAESTRO, ARANCEL
	WHERE MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	*/
	
	
	






























GO