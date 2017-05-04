SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles] (
		[Roles]                   [uniqueidentifier] NULL,
		[Users]                   [uniqueidentifier] NULL,
		[OID]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[OptimisticLockField]     [int] NULL,
		CONSTRAINT [PK_SecuritySystemUserUsers_SecuritySystemRoleRoles]
		PRIMARY KEY
		CLUSTERED
		([OID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemUserUsers_SecuritySystemRoleRoles_Roles]
	FOREIGN KEY ([Roles]) REFERENCES [dbo].[SecuritySystemRole] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles]
	CHECK CONSTRAINT [FK_SecuritySystemUserUsers_SecuritySystemRoleRoles_Roles]

GO
ALTER TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles]
	WITH NOCHECK
	ADD CONSTRAINT [FK_SecuritySystemUserUsers_SecuritySystemRoleRoles_Users]
	FOREIGN KEY ([Users]) REFERENCES [dbo].[SecuritySystemUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles]
	CHECK CONSTRAINT [FK_SecuritySystemUserUsers_SecuritySystemRoleRoles_Users]

GO
CREATE NONCLUSTERED INDEX [iRoles_SecuritySystemUserUsers_SecuritySystemRoleRoles]
	ON [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles] ([Roles])
	ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [iRolesUsers_SecuritySystemUserUsers_SecuritySystemRoleRoles]
	ON [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles] ([Roles], [Users])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iUsers_SecuritySystemUserUsers_SecuritySystemRoleRoles]
	ON [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles] ([Users])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[SecuritySystemUserUsers_SecuritySystemRoleRoles] SET (LOCK_ESCALATION = TABLE)
GO
