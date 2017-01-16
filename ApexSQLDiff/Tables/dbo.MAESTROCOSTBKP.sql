SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MAESTROCOSTBKP] (
		[MAC_CODIGO]        [int] NOT NULL,
		[TCO_CODIGO]        [smallint] NOT NULL,
		[MA_CODIGO]         [int] NOT NULL,
		[MA_GRAV_MP]        [float] NOT NULL,
		[MA_GRAV_ADD]       [float] NOT NULL,
		[MA_GRAV_EMP]       [float] NOT NULL,
		[MA_GRAV_GI]        [float] NOT NULL,
		[MA_GRAV_GI_MX]     [float] NOT NULL,
		[MA_GRAV_MO]        [float] NOT NULL,
		[MA_NG_MP]          [float] NOT NULL,
		[MA_NG_ADD]         [float] NOT NULL,
		[MA_NG_EMP]         [float] NOT NULL,
		[MA_COSTO]          [float] NOT NULL,
		[MA_GRAVA_VA]       [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[MA_NG_USA]         [float] NOT NULL,
		[TV_CODIGO]         [int] NOT NULL,
		[DV_CODIGO]         [smallint] NULL,
		[SPI_CODIGO]        [int] NOT NULL,
		[MA_PERINI]         [datetime] NOT NULL,
		[MA_PERFIN]         [datetime] NOT NULL,
		[MA_NG_MX]          [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MAESTROCOSTBKP] SET (LOCK_ESCALATION = TABLE)
GO
