SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_CopiaCodBarrasArancel (@codFuente integer, @codDestino integer)   as

SET NOCOUNT ON 
declare @ptrval2 varbinary(16), @long integer, @ptrval1 varbinary(16)

select @ptrval1 = textptr(RA_BARCODE) from RANGOARA where RA_CODIGO = @codFuente
select @ptrval2 = textptr(RA_BARCODE), @long = datalength(RA_BARCODE)   from RANGOARA where RA_CODIGO = @codDestino
updatetext RANGOARA.RA_BARCODE @ptrval2 0 @long  RANGOARA.RA_BARCODE @ptrval1



























GO
