SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_ActualizaPaisOrigenPT_TycoJuarez]    as

SET NOCOUNT ON 
UPDATE MAESTRO
SET  pa_origen = 154
where ma_noparte in (select maestro0#ma_noparte
		     from [TempImport141]
		     where maestro0#ti_codigo=14
		     group by maestro0#ma_noparte
		    )	































GO
