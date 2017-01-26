SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE dbo.SP_GETFRACCARA ( @TIPO VARCHAR(1))   as

BEGIN
  SELECT  AR_CODIGO, AR_OFICIAL, AR_FRACCION
  FROM ARANCEL
  WHERE AR_TIPO = @TIPO

END



























GO
