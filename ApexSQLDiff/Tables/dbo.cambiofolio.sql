SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[cambiofolio] (
		[PI_FOLIO]         [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_INDICED]      [int] NOT NULL,
		[PID_SALDOGEN]     [float] NOT NULL,
		[MA_CODIGO]        [int] NOT NULL,
		[PID_NOPARTE]      [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PID_CAN_GEN]      [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cambiofolio] SET (LOCK_ESCALATION = TABLE)
GO
