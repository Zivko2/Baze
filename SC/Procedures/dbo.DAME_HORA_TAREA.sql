SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[DAME_HORA_TAREA]   as

SELECT convert(CHAR(10),CURRENT_TIMESTAMP, 108)  AS [Hora Actual], convert(CHAR(10),CURRENT_TIMESTAMP,101) AS [Fecha];



GO
