SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PAISharvard] (
		[PA_CODIGO]         [int] NOT NULL,
		[PA_CORTO]          [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_NOMBRE]         [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_NAME]           [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_CLA_PED]        [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_ISO]            [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_SAAIM3]         [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PA_IATA]           [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[SPI_CODIGO]        [smallint] NULL,
		[PA_CODPERMISO]     [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PAISharvard] SET (LOCK_ESCALATION = TABLE)
GO
