SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[XPObjectType] (
		[OID]              [int] IDENTITY(1, 1) NOT FOR REPLICATION NOT NULL,
		[TypeName]         [nvarchar](254) COLLATE Latin1_General_CI_AS NULL,
		[AssemblyName]     [nvarchar](254) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_XPObjectType]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iTypeName_XPObjectType]
	ON [dbo].[XPObjectType] ([TypeName])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[XPObjectType] SET (LOCK_ESCALATION = TABLE)
GO
