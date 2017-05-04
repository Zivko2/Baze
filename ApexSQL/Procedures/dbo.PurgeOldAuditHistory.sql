SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Create Procedure PurgeOldAuditHistory
CREATE PROCEDURE [dbo].[PurgeOldAuditHistory]
AS 
BEGIN

	-- Clear out all but ObjectCreated, ObjectChanged and ObjectDeleted that is older than 30 days.
	UPDATE	[AuditDataItemPersistent]
	SET		GCRecord = 1
	WHERE	(ModifiedOn < DATEADD(DAY, -30, GetDate()) AND OperationType NOT IN('ObjectCreated', 'ObjectChanged', 'ObjectDeleted')) 
			

	UPDATE [XPWeakReference]
	SET		GCRecord = 1
	WHERE	Oid IN (SELECT NewObject FROM AuditDataItemPersistent WHERE GCRecord IS NOT NULL) 
			 OR
			Oid IN (SELECT OldObject FROM AuditDataItemPersistent WHERE GCRecord IS NOT NULL)

	UPDATE	[XPWeakReference]
	SET		GCRecord = 1
	WHERE	EXISTS(SELECT 1 FROM AuditDataItemPersistent WHERE XPWeakReference.Oid = AuditDataItemPersistent.AuditedObject)
			AND NOT EXISTS(SELECT 1 FROM AuditDataItemPersistent WHERE AuditDataItemPersistent.GCRecord IS NULL AND XPWeakReference.Oid = AuditDataItemPersistent.AuditedObject)

	DELETE FROM [AuditDataItemPersistent] WHERE GCRecord IS NOT NULL

	DELETE FROM dbo.[AuditedObjectWeakReferencevv] WHERE Oid IN (SELECT Oid FROM [XPWeakReference] WHERE GCRecord IS NOT NULL)

	DELETE FROM [XPWeakReference] WHERE GCRecord IS NOT NULL

END
GO
