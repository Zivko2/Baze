SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_CORRIGEPCKLISTSALDOSFI] (@FI_CODIGO INT)   as


ALTER TABLE PCKLISTDET DISABLE trigger [Update_PcklistDet]


	UPDATE PCKLISTDET
	SET     PLD_SALDO = PLD_CANT_ST - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET 
			    WHERE FACTIMPDET.PLD_INDICED = PCKLISTDET.PLD_INDICED),0)
	WHERE PLD_SALDO <> PLD_CANT_ST - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET 
			    WHERE FACTIMPDET.PLD_INDICED = PCKLISTDET.PLD_INDICED),0)
	AND PLD_INDICED IN (SELECT PLD_INDICED FROM FACTIMPDET WHERE FI_CODIGO=@FI_CODIGO AND PLD_INDICED IS NOT NULL)


	UPDATE PCKLISTDET
	SET     PLD_ENUSO='N'
	WHERE     (PLD_SALDO = PLD_CANT_ST) AND (PLD_ENUSO <> 'N' OR PLD_ENUSO IS NULL)
	AND PLD_INDICED IN (SELECT PLD_INDICED FROM FACTIMPDET WHERE FI_CODIGO=@FI_CODIGO AND PLD_INDICED IS NOT NULL)

	UPDATE PCKLISTDET
	SET     PLD_ENUSO='S'
	WHERE     (PLD_SALDO <> PLD_CANT_ST) AND (PLD_ENUSO <> 'S' OR PLD_ENUSO IS NULL)	
	AND PLD_INDICED IN (SELECT PLD_INDICED FROM FACTIMPDET WHERE FI_CODIGO=@FI_CODIGO AND PLD_INDICED IS NOT NULL)

	UPDATE PCKLIST
	SET PL_ESTATUS='A'
	WHERE PL_CODIGO IN
	(SELECT PL_CODIGO FROM PCKLISTDET WHERE PCKLISTDET.PL_CODIGO=PCKLIST.PL_CODIGO AND
	PLD_ENUSO='N' GROUP BY PL_CODIGO)
	AND PL_CODIGO IN (SELECT PL_CODIGO FROM FACTIMPDET WHERE FI_CODIGO=@FI_CODIGO AND PL_CODIGO IS NOT NULL)


	UPDATE PCKLIST
	SET PL_ESTATUS='C'
	WHERE PL_CODIGO IN
	(SELECT PL_CODIGO FROM PCKLISTDET WHERE PCKLISTDET.PL_CODIGO=PCKLIST.PL_CODIGO 
	GROUP BY PL_CODIGO HAVING SUM(PLD_SALDO) = 0 AND SUM(PLD_CANT_ST)>0)
	AND PL_CODIGO IN (SELECT PL_CODIGO FROM FACTIMPDET WHERE FI_CODIGO=@FI_CODIGO AND PL_CODIGO IS NOT NULL)


ALTER TABLE PCKLISTDET ENABLE trigger [Update_PcklistDet]







GO
