SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE dbo.SP_SetTransferDischStat (@CodigoFactura Int, @sDischStatus Varchar(1))  as

SET NOCOUNT ON 

	UPDATE TRANSFER SET TR_DESCARGADA = @sDischStatus WHERE TR_CODIGO = @CodigoFactura

RETURN 0






GO
