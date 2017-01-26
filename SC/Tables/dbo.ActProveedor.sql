SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ActProveedor] (
		[PI_CODIGO]         [int] NOT NULL,
		[PI_FOLIO]          [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[CP_CODIGO]         [smallint] NULL,
		[AGT_CODIGO]        [int] NOT NULL,
		[PI_FEC_PAGR1]      [datetime] NULL,
		[PR_CODIGO]         [int] NULL,
		[CL_RAZON]          [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[DI_PR]             [int] NULL,
		[PI_MOVIMIENTO]     [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
