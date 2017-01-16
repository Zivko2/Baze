SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tempRangosReglaOrigen] (
		[ARR_CODIGO]         [int] NOT NULL,
		[AR_CODIGO]          [int] NOT NULL,
		[AR_FRACCION]        [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ARR_PARTIDAPT]      [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[ARR_PARTIDAPTF]     [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[arr_perini]         [datetime] NOT NULL,
		[arr_perfin]         [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempRangosReglaOrigen] SET (LOCK_ESCALATION = TABLE)
GO
