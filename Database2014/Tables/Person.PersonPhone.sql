SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [Person].[PersonPhone] (
		[BusinessEntityID]     [int] NOT NULL,
		[PhoneNumber]          [dbo].[Phone] NOT NULL,
		[ModifiedDate]         [datetime] NOT NULL,
		[PersonPhoneID]        [int] IDENTITY(1, 1) NOT NULL,
		[112ID]                [int] NOT NULL,
		CONSTRAINT [UQ_PK_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID_75B1A6E5]
		UNIQUE
		NONCLUSTERED
		([BusinessEntityID], [PhoneNumber], [112ID])
		ON [PRIMARY],
		CONSTRAINT [PK_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID]
		PRIMARY KEY
		CLUSTERED
		([PersonPhoneID])
	ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Person].[PersonPhone]
	ADD
	CONSTRAINT [DF_PersonPhone_23DEA4D]
	DEFAULT ((0)) FOR [112ID]
GO
ALTER TABLE [Person].[PersonPhone]
	ADD
	CONSTRAINT [DF_PersonPhone_ModifiedDate]
	DEFAULT (getdate()) FOR [ModifiedDate]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Default constraint value of GETDATE()', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'CONSTRAINT', N'DF_PersonPhone_ModifiedDate'
GO
ALTER TABLE [Person].[PersonPhone]
	WITH CHECK
	ADD CONSTRAINT [FK_PersonPhone_Person_BusinessEntityID]
	FOREIGN KEY ([BusinessEntityID]) REFERENCES [Person].[Person] ([BusinessEntityID])
ALTER TABLE [Person].[PersonPhone]
	CHECK CONSTRAINT [FK_PersonPhone_Person_BusinessEntityID]

GO
EXEC sp_addextendedproperty N'MS_Description', N'Foreign key constraint referencing Person.BusinessEntityID.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'CONSTRAINT', N'FK_PersonPhone_Person_BusinessEntityID'
GO
ALTER TABLE [Person].[PersonPhone]
	WITH CHECK
	ADD CONSTRAINT [FK_PersonPhone_PhoneNumberType_PhoneNumberTypeID]
	FOREIGN KEY ([112ID]) REFERENCES [Person].[11] ([112ID])
ALTER TABLE [Person].[PersonPhone]
	CHECK CONSTRAINT [FK_PersonPhone_PhoneNumberType_PhoneNumberTypeID]

GO
CREATE NONCLUSTERED INDEX [IX_PersonPhone_PhoneNumber]
	ON [Person].[PersonPhone] ([PhoneNumber])
	ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nonclustered index.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'INDEX', N'IX_PersonPhone_PhoneNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Business entity identification number. Foreign key to Person.BusinessEntityID.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'COLUMN', N'BusinessEntityID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date and time the record was last updated.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'COLUMN', N'ModifiedDate'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Telephone number identification number.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', 'COLUMN', N'PhoneNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Telephone number and type of a person.', 'SCHEMA', N'Person', 'TABLE', N'PersonPhone', NULL, NULL
GO
ALTER TABLE [Person].[PersonPhone] SET (LOCK_ESCALATION = TABLE)
GO
