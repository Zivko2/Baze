SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















































CREATE PROCEDURE [dbo].[ActualizaFeDescItalica] (@fe_codigo int)   as




		if exists (SELECT     KAP_FACTRANS FROM KARDESPED WHERE (KAP_INDICED_PED IS NOT NULL)
				         AND KAP_FACTRANS=@fe_codigo
				         GROUP BY KAP_FACTRANS)
		UPDATE FACTEXP
		SET FE_DESCITALICA='N'
		WHERE FE_CODIGO=@fe_codigo
	else
		UPDATE FACTEXP
		SET FE_DESCITALICA='S'
		WHERE FE_CODIGO=@fe_codigo


	UPDATE FACTEXP 
	SET FE_FECHADESCARGA=GETDATE(), FE_DESCMANUAL='S', FE_DESCARGADA='S'
	WHERE FE_CODIGO=@fe_codigo































GO
