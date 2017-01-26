SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_REVORIGEN] (@RV_CODIGO INT)   as

SET NOCOUNT ON 
Declare @CE decimal(38,6), @CDV decimal(38,6), @CO decimal(38,6), @CDR decimal(38,6), @PCO decimal(38,6), @ME decimal(38,6)


	-- todos los valores se sacan de la revision de origen contribucion
	SELECT @CE=isnull(SUM(RVC_MONTO),0)
	FROM VREVORIGENVERDEINCORR
	WHERE RV_CODIGO=@RV_CODIGO



	SELECT @CDV=isnull(SUM(RVC_MONTO),0)
	FROM VREVORIGENVERDECORR
	WHERE RV_CODIGO=@RV_CODIGO

	SELECT @CO=isnull(SUM(RVC_MONTO),0)
	FROM VREVORIGENROJOINCORR
	WHERE RV_CODIGO=@RV_CODIGO
	
	SELECT @CDR=isnull(SUM(RVC_MONTO),0)
	FROM VREVORIGENROJOCORR
	WHERE RV_CODIGO=@RV_CODIGO


if exists (select * FROM VREVORIGENVERDECORR
WHERE RV_CODIGO=@RV_CODIGO)

	UPDATE REVORIGENREP
	SET RV_CE=@CE
	WHERE RV_CODIGO=@RV_CODIGO
else
	UPDATE REVORIGENREP
	SET RV_CE=0
	WHERE RV_CODIGO=@RV_CODIGO


if exists (select * FROM VREVORIGENVERDEINCORR
WHERE RV_CODIGO=@RV_CODIGO)

	UPDATE REVORIGENREP
	set RV_CDV=@CDV
	WHERE RV_CODIGO=@RV_CODIGO
else
	UPDATE REVORIGENREP
	set RV_CDV=0
	WHERE RV_CODIGO=@RV_CODIGO


if exists (select * FROM VREVORIGENROJOCORR
WHERE RV_CODIGO=@RV_CODIGO)

	UPDATE REVORIGENREP
	set RV_CO=@CO
	WHERE RV_CODIGO=@RV_CODIGO
else
	UPDATE REVORIGENREP
	set RV_CO=0
	WHERE RV_CODIGO=@RV_CODIGO


if exists (select * FROM VREVORIGENROJOINCORR
WHERE RV_CODIGO=@RV_CODIGO)

	UPDATE REVORIGENREP
	set RV_CDR=@CDR
	WHERE RV_CODIGO=@RV_CODIGO
else
	UPDATE REVORIGENREP
	set RV_CDR=0
	WHERE RV_CODIGO=@RV_CODIGO


/*=======================================*/

	/* ME = Margen de error. 

	CE = Monto total de contribuciones y cuotas compensatorias pagadas por el importador de manera espont~nea, 
	conforme a la fracci>n V del art-culo 98 de esta Ley, en el ejercicio inmediato anterior. 

	CDV = Monto total de contribuciones y cuotas compensatorias declaradas por el importador en los pedimentos 
	que no fueron objeto de reconocimiento aduanero, segundo reconocimiento, verificaci>n de mercanc-as en
	 transporte o visitas domiciliarias, en el ejercicio inmediato anterior. 


	PCO = Porcentaje de contribuciones y cuotas compensatorias omitidas. 

	CO = Monto total de las contribuciones y cuotas compensatorias omitidas detectadas con motivo del
	 reconocimiento aduanero, segundo reconocimiento, verificaci>n de mercanc-as en transporte 
	o visitas domiciliarias, en el ejercicio inmediato anterior. 

	CDR = Monto total de contribuciones y cuotas compensatorias declaradas por el importador en los 
	pedimentos que fueron objeto de reconocimiento aduanero, segundo reconocimiento, verificaci>n de
	 mercanc-as en transporte o visitas domiciliarias, en el ejercicio inmediato anterior. 
	*/
	if (@CE+@CDV) >0 
	set @ME=(@CE/(@CE+@CDV))*100
	else
	set @ME=0

	if (@CO+@CDR) > 0
	set @PCO=(@CO/(@CO+@CDR))*100
	else
	set @PCO=0


	IF @PCO>@ME
		UPDATE REVORIGENREP
		SET RV_MONTO=((@PCO-@ME)/100)*(@CDV+@CE)
		WHERE RV_CODIGO=@RV_CODIGO	
	ELSE
		UPDATE REVORIGENREP
		SET RV_MONTO=0
		WHERE RV_CODIGO=@RV_CODIGO



























GO
