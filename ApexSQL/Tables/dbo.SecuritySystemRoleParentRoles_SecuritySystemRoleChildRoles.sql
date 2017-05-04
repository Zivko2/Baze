SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles] (
		[ChildRoles]              [uniqueidentifier] NULL,
		[ParentRoles]             [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles_ChildRoles]
	FOREIGN KEY ([ChildRoles]) REFERENCES [dbo].[SecuritySystemRole] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	CHECK CONSTRAINT [FK_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles_ChildRoles]

GO
ALTER TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles_ParentRoles]
	FOREIGN KEY ([ParentRoles]) REFERENCES [dbo].[SecuritySystemRole] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	CHECK CONSTRAINT [FK_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles_ParentRoles]

GO
CREATE NONCLUSTERED INDEX [iChildRoles_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	ON [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles] ([ChildRoles])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iChildRolesParentRoles_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	ON [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles] ([ChildRoles], [ParentRoles])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iParentRoles_SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles]
	ON [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles] ([ParentRoles])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemRoleParentRoles_SecuritySystemRoleChildRoles] SET (LOCK_ESCALATION = TABLE)
GO
