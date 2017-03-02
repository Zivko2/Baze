SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_CORRIGEPCKLISTSALDOS]   as


ALTER TABLE PCKLISTDET DISABLE trigger [Update_PcklistDet]

	UPDATE PCKLISTDET
	SET     PLD_SALDO = PLD_CANT_ST - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET 
			    WHERE FACTIMPDET.PLD_INDICED = PCKLISTDET.PLD_INDICED),0)
	WHERE PLD_SALDO <> PLD_CANT_ST - isnull((SELECT SUM(FACTIMPDET.FID_CANT_ST) FROM FACTIMPDET 
			    WHERE FACTIMPDET.PLD_INDICED = PCKLISTDET.PLD_INDICED),0)

	UPDATE PCKLISTDET
	SET     PLD_SALDO = PLD_CANT_ST
	WHERE PCKLISTDET.PLD_INDICED NOT IN (SELECT PLD_INDICED FROM FACTIMPDET WHERE PLD_INDICED IS NOT NULL)


	UPDATE PCKLISTDET
	SET     PLD_ENUSO='N'
	WHERE     (PLD_SALDO = PLD_CANT_ST) AND (PLD_ENUSO <> 'N' OR PLD_ENUSO IS NULL)
	

	UPDATE PCKLIST
	SET PL_ESTATUS='A'
	WHERE PL_CODIGO IN
	(SELECT PL_CODIGO FROM PCKLISTDET WHERE PLD_ENUSO='N' GROUP BY PL_CODIGO )


	UPDATE PCKLISTDET
	SET     PLD_ENUSO='S'
	WHERE     (PLD_SALDO <> PLD_CANT_ST) AND (PLD_ENUSO <> 'S' OR PLD_ENUSO IS NULL)	

	UPDATE PCKLIST
	SET PL_ESTATUS='C'
	WHERE PL_CODIGO IN
	(SELECT PL_CODIGO FROM PCKLISTDET GROUP BY PL_CODIGO HAVING SUM(PLD_SALDO) = 0 AND SUM(PLD_CANT_ST)>0)


ALTER TABLE PCKLISTDET ENABLE trigger [Update_PcklistDet]























GO