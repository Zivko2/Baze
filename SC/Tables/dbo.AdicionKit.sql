SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdicionKit] (
		[Model]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Kit]              [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Net and Post]     [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Cost]             [float] NULL,
		[MP_Grav_ADD]      [float] NULL
) ON [PRIMARY]
GO
