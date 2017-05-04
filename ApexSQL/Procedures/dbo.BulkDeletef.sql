SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- Alter Procedure BulkDeletef
CREATE PROCEDURE [dbo].[BulkDeletef]
  @ObjectType VARCHAR(250),
  @OidList AS dbo.OidList READONLY
AS
BEGIN
  -- Adding a comment to cause a change for database upgrade process testing
  SET NOCOUNT ON;

	DECLARE @ItemOidList AS dbo.OidList	
	
	IF @ObjectType = 'WantListItem' BEGIN
		UPDATE WantListItem 
		SET GCRecord = CONVERT(BIGINT, ROUND(((1999999999 - 10000000 -1) * RAND() + 10000000), 0))
		WHERE	Oid IN (SELECT Oid FROM @OidList)
		--Also note that if we udpate the want list, we need to reset the Item Calculated values
		INSERT INTO @ItemOidList SELECT Item FROM WantListItem WHERE Oid IN (SELECT Oid FROM @OidList)
	END ELSE BEGIN
		RAISERROR (N'"%s" is not implemented in procedure BulkDelete'
			, 16
			, 1
			, @ObjectType);
	END  

	IF EXISTS(SELECT * FROM @ItemOidList) BEGIN
		
		EXEC Staged.ResetCachedItemProperties @ItemOidList = @ItemOidList
	END

END
GO
