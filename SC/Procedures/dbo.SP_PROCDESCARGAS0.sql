SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [SP_PROCDESCARGAS0] (@ERROR int OUTPUT) AS    begin tran exec CopiaFactExpVToFactImpV 1981, S, IntradeHreynosa, IntradeHarvard   commit tran Return @@Error
GO
