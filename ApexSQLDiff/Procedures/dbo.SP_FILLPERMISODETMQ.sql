SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_FILLPERMISODETMQ] @pecodigo INT    as

SET NOCOUNT ON 
EXEC SP_FILLPERMISODETHE @pecodigo
EXEC SP_FILLPERMISODETEQ @pecodigo
EXEC SP_FILLPERMISODETCO @pecodigo

RETURN 0



























GO
