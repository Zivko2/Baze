SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[DEL_CONSULTAPARAMETROS] on dbo.CONSULTAPARAMETROS  for DELETE as
SET NOCOUNT ON
begin
 /*Se borra info de detalles*/
     DELETE ConsultaParametrosDet FROM ConsultaParametrosDet, Deleted  WHERE ConsultaParametrosDet.CPA_Codigo = Deleted.CPA_Codigo

  /* Se borra info de titulos*/
     DELETE ConsultaParametrosTitulos FROM ConsultaParametrosTitulos, Deleted  WHERE ConsultaParametrosTitulos.CPA_Codigo = Deleted.CPA_Codigo

END


GO
