SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [Person].[11] (
		[Name]      [dbo].[Name] NOT NULL,
		[112ID]     [int] NOT NULL,
		CONSTRAINT [PK_PhoneNumberType_PhoneNumberTypeID]
		PRIMARY KEY
		CLUSTERED
		([112ID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Person].[11]
	ADD
	CONSTRAINT [DF_11_4F557289]
	DEFAULT ((0)) FOR [112ID]
GO
ALTER TABLE [Person].[11]
	WITH CHECK
	ADD CONSTRAINT [FK_11_112]
	FOREIGN KEY ([112ID]) REFERENCES [Person].[1123] ([112ID])
ALTER TABLE [Person].[11]
	CHECK CONSTRAINT [FK_11_112]

GO
EXEC sp_addextendedproperty N'MS_Description', N'Name of the telephone number type', 'SCHEMA', N'Person', 'TABLE', N'11', 'COLUMN', N'Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Type of phone number of a person.', 'SCHEMA', N'Person', 'TABLE', N'11', NULL, NULL
GO
ALTER TABLE [Person].[11] SET (LOCK_ESCALATION = TABLE)
GO
