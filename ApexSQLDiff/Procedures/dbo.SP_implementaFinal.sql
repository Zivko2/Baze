SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_implementaFinal]   as

SET NOCOUNT ON 
	exec sp_ImplementaInsert  /* Inserta en la tabla pedimento de importacion y detalle lo generado en la tabla implementarel*/
	exec sp_ImplementaInsertdet
	exec sp_ImplementaInsertcontrib



























GO
