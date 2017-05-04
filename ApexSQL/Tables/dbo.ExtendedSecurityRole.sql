SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtendedSecurityRole] (
		[Oid]                  [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Description]          [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[InternalRoleName]     [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_ExtendedSecurityRole]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExtendedSecurityRole]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ExtendedSecurityRole_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[SecuritySystemRole] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ExtendedSecurityRole]
	CHECK CONSTRAINT [FK_ExtendedSecurityRole_Oid]

GO
ALTER TABLE [dbo].[ExtendedSecurityRole] SET (LOCK_ESCALATION = TABLE)
GO
