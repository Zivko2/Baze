SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_GETFACTORFACT] (@ma_codigo int, @codigo int, @campo varchar(50), @Factor  decimal(38,6) OUTPUT)   as

declare @me_codigo int


if @campo='AR_IMPMX' or  @campo='AR_IMPFO' or @campo='AR_EXPMX' or @campo='AR_EXPFO' 
	select @ME_CODIGO=me_codigo from arancel where ar_codigo=@codigo
if @campo='MA_GENERICO' OR @campo='MA_GEN'
	select @ME_CODIGO=me_com from maestro where ma_codigo=@codigo



























GO
