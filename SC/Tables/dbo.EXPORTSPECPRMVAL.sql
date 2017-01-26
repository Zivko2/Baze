SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EXPORTSPECPRMVAL] (
		[EMS_CODIGO]     [int] NOT NULL,
		[PXM_CODIGO]     [int] NOT NULL,
		[PXMV_VALOR]     [varchar](800) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EXPORTSPECPRMVAL]
	ADD
	CONSTRAINT [PK_EXPORTSPECPRMVAL]
	PRIMARY KEY
	CLUSTERED
	([EMS_CODIGO], [PXM_CODIGO], [PXMV_VALOR])
	ON [PRIMARY]
GO
