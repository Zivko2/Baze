-- Create Table CaptureOutputLog
Print 'Create Table CaptureOutputLog'
GO
CREATE TABLE [tSQLt].[CaptureOutputLog] (
		[Id]             [int] IDENTITY(1, 1) NOT NULL,
		[OutputText]     ntext COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
-- Add Primary Key PK__CaptureO__3214EC07CF7B0506 to CaptureOutputLog
Print 'Add Primary Key PK__CaptureO__3214EC07CF7B0506 to CaptureOutputLog'
GO
ALTER TABLE [tSQLt].[CaptureOutputLog]
	ADD
	CONSTRAINT [PK__CaptureO__3214EC07CF7B0506]
	PRIMARY KEY
	CLUSTERED
	([Id])
	ON [PRIMARY]
GO
