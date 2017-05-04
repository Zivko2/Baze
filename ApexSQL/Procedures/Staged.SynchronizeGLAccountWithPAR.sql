SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Staged].[SynchronizeGLAccountWithPAR]
AS

BEGIN

	INSERT INTO GLAccount (Oid, AccountID, AccountNumber, Name, Description) 
	SELECT NEWID(), ParGLAccount.AccountNumber COLLATE DATABASE_DEFAULT, 
		ParGLAccount.AccountNumberFormatted COLLATE DATABASE_DEFAULT,
		ParGLAccount.Description COLLATE DATABASE_DEFAULT, 
		NULL
	FROM	[PNGBRANCH_FOR_APEX].[Par].[Apex].[GlAccount] ParGLAccount
	WHERE   ParGLAccount.AccountNumber COLLATE DATABASE_DEFAULT Not IN (SELECT AccountID FROM GLAccount)

	UPDATE GLAccount 
		SET Name = ParGLAccount.Description COLLATE DATABASE_DEFAULT,
			AccountNumber = ParGLAccount.AccountNumberFormatted COLLATE DATABASE_DEFAULT
		FROM GLAccount GLA 
				INNER JOIN [PNGBRANCH_FOR_APEX].[Par].[Apex].[GlAccount] ParGLAccount ON CONVERT(VARCHAR(100), ParGLAccount.AccountNumberFormatted) COLLATE DATABASE_DEFAULT = GLA.AccountID
		WHERE GLA.AccountNumber <> ParGLAccount.AccountNumberFormatted COLLATE DATABASE_DEFAULT 
				OR GLA.Name <> ParGLAccount.Description COLLATE DATABASE_DEFAULT 

	--attempt to replicate the random generator that XPO uses to mark a record deleted
	UPDATE GLAccount SET GCRecord = CONVERT(BIGINT, ROUND(((1999999999 - 10000000 -1) * RAND() + 10000000), 0)) 
	WHERE AccountID NOT IN (SELECT AccountNumber COLLATE DATABASE_DEFAULT from [PNGBRANCH_FOR_APEX].[Par].[Apex].[GlAccount])

END
GO
