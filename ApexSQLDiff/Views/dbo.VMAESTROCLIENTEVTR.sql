SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































CREATE VIEW dbo.VMAESTROCLIENTEVTR
with encryption as
SELECT     MA_CODIGO, MC_PRECIO
FROM         dbo.MAESTROCLIENTE
WHERE     (MC_VTR = 'S')





GO
