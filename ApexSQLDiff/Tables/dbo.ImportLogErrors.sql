SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ImportLogErrors] (
		[IdLog]           [bigint] IDENTITY(1, 1) NOT NULL,
		[IdError]         [int] NULL,
		[Fecha]           [datetime] NOT NULL,
		[Descripcion]     [varchar](300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Padre]           [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Hijo]            [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[Division]        [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[FechaInicio]     [datetime] NOT NULL,
		[FechaFinal]      [datetime] NOT NULL,
		[Cantidad]        [decimal](28, 14) NOT NULL,
		[Consecutivo]     [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportLogErrors]
	ADD
	CONSTRAINT [PK_ImportLogErrors]
	PRIMARY KEY
	CLUSTERED
	([IdLog])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportLogErrors]
	ADD
	CONSTRAINT [DF_ImportLogErrors_Fecha]
	DEFAULT (getdate()) FOR [Fecha]
GO
ALTER TABLE [dbo].[ImportLogErrors] SET (LOCK_ESCALATION = TABLE)
GO
