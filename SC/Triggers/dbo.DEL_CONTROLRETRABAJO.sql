SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE trigger DEL_CONTROLRETRABAJO on dbo.CONTROLRETRABAJO  for DELETE as
SET NOCOUNT ON
begin
 /*Se borra info de Estructura especial*/
     DELETE bom_struct FROM bom_struct, Deleted  WHERE bom_struct.bsu_subensamble = Deleted.MA_CodigoEspecial

  /* Se borra el No. Parte especial */
    DELETE Maestro FROM Maestro, Deleted  WHERE maestro.Ma_Codigo = Deleted.MA_CodigoEspecial

END


GO
