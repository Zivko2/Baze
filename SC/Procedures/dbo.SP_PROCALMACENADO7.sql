SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_PROCALMACENADO7] (@ERROR int OUTPUT) AS  declare @error1 varchar(8000) exec @Error1=sp_ligacorrectaall 7, 'S' Return @Error1
GO
