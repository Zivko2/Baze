SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_FactExpDescItalica]   as

		UPDATE FACTEXP
	SET FE_DESCITALICA='S'
	WHERE FE_CODIGO NOT IN (SELECT KAP_FACTRANS AS FE_CODIGO FROM KARDESPED WHERE (KAP_INDICED_PED IS NOT NULL)
				         GROUP BY KAP_FACTRANS)
	AND FE_CODIGO IN (SELECT KAP_FACTRANS AS FE_CODIGO FROM KARDESPED GROUP BY KAP_FACTRANS)



























GO
