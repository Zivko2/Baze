SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE PROCEDURE [dbo].[SP_ACTUALIZAMAESTROPESOLB]   as

SET NOCOUNT ON 

UPDATE dbo.MAESTRO
SET     MA_PESO_LB= MA_PESO_KG*2.20462442018378
WHERE     (MA_INV_GEN = 'I') AND MA_PESO_KG>0
















































GO
