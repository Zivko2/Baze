SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_FILLPAISARA] @arcodigo int    as

SET NOCOUNT ON 
declare @pais int

	SELECT @pais=(PA_CODIGO) FROM ARANCEL 	WHERE (AR_CODIGO = @arcodigo)

	if @pais = (SELECT CF_PAIS_MX FROM CONFIGURACION)

		exec SP_FILLPAISARAMX @arcodigo
	else
		exec SP_FILLPAISARAUS @arcodigo






































GO
