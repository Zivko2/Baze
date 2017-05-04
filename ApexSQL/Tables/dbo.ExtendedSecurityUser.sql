SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExtendedSecurityUser] (
		[Oid]                           [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[IsSystemDefined]               [bit] NULL,
		[BalloonAlertsShownUpTo]        [datetime] NULL,
		[ExternalBarCode]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Initials]                      [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[DisplayName]                   [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[OnBehalfOf]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[InactivityTimeout]             [int] NULL,
		[NewTaskReminderEvery]          [int] NULL,
		[PlayAlertSound]                [bit] NULL,
		[DisableListFiltering]          [bit] NULL,
		[DisableListColumnMoving]       [bit] NULL,
		[DisableListGrouping]           [bit] NULL,
		[DisableListColumnChoosing]     [bit] NULL,
		[EnforceStickyTabs]             [bit] NULL,
		CONSTRAINT [PK_ExtendedSecurityUser]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExtendedSecurityUser]
	WITH NOCHECK
	ADD CONSTRAINT [FK_ExtendedSecurityUser_Oid]
	FOREIGN KEY ([Oid]) REFERENCES [dbo].[SecuritySystemUser] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[ExtendedSecurityUser]
	CHECK CONSTRAINT [FK_ExtendedSecurityUser_Oid]

GO
ALTER TABLE [dbo].[ExtendedSecurityUser] SET (LOCK_ESCALATION = TABLE)
GO
