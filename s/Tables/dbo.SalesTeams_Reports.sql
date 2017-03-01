-- Create Table SalesTeams_Reports
Print 'Create Table SalesTeams_Reports'
GO
CREATE TABLE [dbo].[SalesTeams_Reports] (
		[Relation_Id]           [int] IDENTITY(1, 1) NOT NULL,
		[SalesTeam_Id]          [int] NOT NULL,
		[TerritoryLevel_Id]     [int] NOT NULL,
		[Report_Id]             [int] NOT NULL,
		[Settings]              ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CONSTRAINT [IX_SalesTeams_Reports]
		UNIQUE
		NONCLUSTERED
		([SalesTeam_Id], [TerritoryLevel_Id], [Report_Id])
		ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
-- Add Primary Key PK_SalesTeams_Reports to SalesTeams_Reports
Print 'Add Primary Key PK_SalesTeams_Reports to SalesTeams_Reports'
GO
ALTER TABLE [dbo].[SalesTeams_Reports]
	ADD
	CONSTRAINT [PK_SalesTeams_Reports]
	PRIMARY KEY
	CLUSTERED
	([Relation_Id])
	ON [PRIMARY]
GO
