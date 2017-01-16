SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_COSTOSBAJOSBASE] (@MA_CODIGO INT, @TIPO CHAR(1))   as


		-- solo toma los ultimos 6 meses
	IF @TIPO='P' --Actualizando Costos mas bajos base Pais
	begin
		UPDATE dbo.CLASIFICATLC
		SET     BST_COS_UNI= isnull((SELECT MIN(FID_COS_UNI)
		                      FROM FACTIMPDET INNER JOIN
		                           FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		                      WHERE FACTIMP.FI_FECHA>=getdate()-182.496
		                            AND MA_CODIGO = dbo.CLASIFICATLC.BST_HIJO
		                            AND PA_CODIGO = dbo.CLASIFICATLC.PA_CODIGO),0)
		FROM         dbo.CLASIFICATLC
		WHERE     (BST_PT = @MA_CODIGO) AND
		                          (isnull((SELECT MIN(FID_COS_UNI)
		                      FROM FACTIMPDET INNER JOIN
		                           FACTIMP ON FACTIMPDET.FI_CODIGO = FACTIMP.FI_CODIGO
		                      WHERE FACTIMP.FI_FECHA>=getdate()-182.496
		                            AND MA_CODIGO = dbo.CLASIFICATLC.BST_HIJO
		                            AND PA_CODIGO = dbo.CLASIFICATLC.PA_CODIGO),0) > 0)
	end

	IF @TIPO='N' --Actualizando Ultimos costos base No. Parte
	begin
		UPDATE dbo.CLASIFICATLC
		SET     dbo.CLASIFICATLC.BST_COS_UNI= dbo.FACTIMPDET.FID_COS_UNI, 
		            dbo.CLASIFICATLC.PA_CODIGO= dbo.CLASIFICATLC.PA_CODIGO
		FROM         dbo.CLASIFICATLC INNER JOIN
		                      dbo.FACTIMPDET ON dbo.CLASIFICATLC.BST_HIJO = dbo.FACTIMPDET.MA_CODIGO
		WHERE     (dbo.FACTIMPDET.FID_INDICED IN
		                          (SELECT     MAX(FACTIMPDET1.FID_INDICED)
		                            FROM          FACTIMPDET FACTIMPDET1
		                            WHERE      FACTIMPDET1.MA_CODIGO = dbo.CLASIFICATLC.BST_HIJO)) AND (dbo.FACTIMPDET.FID_COS_UNI > 0) AND 
		                      (dbo.FACTIMPDET.PA_CODIGO = @MA_CODIGO)	
	end




































GO
