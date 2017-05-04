SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Stocktake].[BatchAndLineStatusInformation]
AS
SELECT        dbo.Batch.BatchNumber, dbo.Batch.BatchStatus, dbo.BatchLineItem.LineNumber, dbo.BatchLineItem.BatchLineItemStatus
FROM            dbo.BatchLineItem INNER JOIN
                         dbo.Batch ON dbo.BatchLineItem.Batch = dbo.Batch.Oid
GO
