SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RelacionPagaNoPaga] (
		[PID_PAGACONTRIB]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FID_INDICED]         [int] NOT NULL
) ON [PRIMARY]
GO
