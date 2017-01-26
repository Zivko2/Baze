SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_DELPEDIMPDET]  (@PI_CODIGO INT)  as

begin
	delete from pedimpdet where pi_codigo = @PI_CODIGO
end



GO
