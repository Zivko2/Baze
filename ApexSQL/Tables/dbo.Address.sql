SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Address] (
		[Oid]                     [uniqueidentifier] NOT NULL ROWGUIDCOL,
		[Street]                  [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[City]                    [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[StateProvince]           [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[ZipPostal]               [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
		[Country]                 [uniqueidentifier] NULL,
		[OptimisticLockField]     [int] NULL,
		[GCRecord]                [int] NULL,
		CONSTRAINT [PK_Address]
		PRIMARY KEY
		CLUSTERED
		([Oid])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Address]
	WITH NOCHECK
	ADD CONSTRAINT [FK_Address_Country]
	FOREIGN KEY ([Country]) REFERENCES [dbo].[Country] ([Oid])
	NOT FOR REPLICATION
ALTER TABLE [dbo].[Address]
	CHECK CONSTRAINT [FK_Address_Country]

GO
CREATE NONCLUSTERED INDEX [iCountry_Address]
	ON [dbo].[Address] ([Country])
	ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iGCRecord_Address]
	ON [dbo].[Address] ([GCRecord])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[Address] SET (LOCK_ESCALATION = TABLE)
GO
