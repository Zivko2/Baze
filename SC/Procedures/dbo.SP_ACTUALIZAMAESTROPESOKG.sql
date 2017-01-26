SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAMAESTROPESOKG]   as

SET NOCOUNT ON 

UPDATE dbo.MAESTRO
SET     MA_PESO_KG= MA_PESO_LB/2.20462442018378
WHERE     (MA_INV_GEN = 'I') AND MA_PESO_LB>0
















































GO
