SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

GO
-- Create table [dbo].[Testt]
Print 'Create table [dbo].[Testt]'
GO
CREATE TABLE [dbo].[Testt] (
		[broj]      [int] NULL,
		[nesto]     [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[Testt] SET (LOCK_ESCALATION = TABLE)
GO
