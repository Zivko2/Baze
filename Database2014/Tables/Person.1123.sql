SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING OFF
GO
CREATE TABLE [Person].[1123] (
		[PhoneNumberTypeID]     [int] IDENTITY(1, 1) NOT NULL,
		[ModifiedDate]          [datetime] NOT NULL,
		[112ID]                 [int] NOT NULL,
		CONSTRAINT [UQ_PK_112_64D35736]
		UNIQUE
		NONCLUSTERED
		([PhoneNumberTypeID])
		ON [PRIMARY],
		CONSTRAINT [PK_112]
		PRIMARY KEY
		CLUSTERED
		([112ID])
	WITH (IGNORE_DUP_KEY = ON, ALLOW_ROW_LOCKS = OFF, ALLOW_PAGE_LOCKS = OFF)
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Person].[1123]
	ADD
	CONSTRAINT [DF_112_38ABD1BC]
	DEFAULT ((0)) FOR [112ID]
GO
ALTER TABLE [Person].[1123]
	ADD
	CONSTRAINT [DF_PhoneNumberType_ModifiedDate_112]
	DEFAULT (getdate()) FOR [ModifiedDate]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Person', 'TABLE', N'1123', 'CONSTRAINT', N'DF_PhoneNumberType_ModifiedDate_112'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Person', 'TABLE', N'1123', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary key for telephone number type records.', 'SCHEMA', N'Person', 'TABLE', N'1123', 'COLUMN', N'PhoneNumberTypeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of phone number of a person.', 'SCHEMA', N'Person', 'TABLE', N'1123', NULL, NULL
GO
ALTER TABLE [Person].[1123] SET (LOCK_ESCALATION = TABLE)
GO
