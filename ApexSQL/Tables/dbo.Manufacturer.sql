SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Manufacturer] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Name]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Address]                 [uniqueidentifier] NULL,
		[PhoneNumber1]            [uniqueidentifier] NULL,
		[PhoneNumber2]            [uniqueidentifier] NULL,
		[Website]                 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Note]                    [nvarchar](1000) COLLATE Latin1_General_CI_AS NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_Manufacturer]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Manufacturer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Manufacturer_Address]
	FOREIGN KEY ([Address]) REFERENCES [dbo].[Address] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Manufacturer]
	CHECK CONSTRAINT [FK_Manufacturer_Address]

GO
ALTER TABLE [dbo].[Manufacturer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Manufacturer_PhoneNumber1]
	FOREIGN KEY ([PhoneNumber1]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Manufacturer]
	CHECK CONSTRAINT [FK_Manufacturer_PhoneNumber1]

GO
ALTER TABLE [dbo].[Manufacturer]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Manufacturer_PhoneNumber2]
	FOREIGN KEY ([PhoneNumber2]) REFERENCES [dbo].[PhoneNumber] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Manufacturer]
	CHECK CONSTRAINT [FK_Manufacturer_PhoneNumber2]

GO
CREATE NONCLUSTERED INDEX [iAddress_Manufacturer]
	ON [dbo].[Manufacturer] ([Address])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Manufacturer]
	ON [dbo].[Manufacturer] ([GCRecord])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber1_Manufacturer]
	ON [dbo].[Manufacturer] ([PhoneNumber1])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iPhoneNumber2_Manufacturer]
	ON [dbo].[Manufacturer] ([PhoneNumber2])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Manufacturer] SET (LOCK_ESCALATION = TABLE)
GO
