SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ORDTRABAJO] (
		[OT_CODIGO]             [int] NOT NULL,
		[OT_FOLIO]              [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OT_FECHA]              [datetime] NOT NULL,
		[OT_PEDIDO]             [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CL_CODIGO]             [int] NOT NULL,
		[OT_TIPO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OT_ESTATUS]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OT_ESTATUSSURT]        [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OT_FECHAINI]           [datetime] NULL,
		[OT_FECHAFIN]           [datetime] NULL,
		[US_CODIGO]             [int] NULL,
		[OT_COMENTA]            [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OT_CANCELADO]          [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[OT_REFERENCIAUSA]      [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[OT_FECHARECPEDIDO]     [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDTRABAJO]
	ADD
	CONSTRAINT [PK_ORDTRABAJO]
	PRIMARY KEY
	NONCLUSTERED
	([OT_FOLIO])
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORDTRABAJO]
	ADD
	CONSTRAINT [DF_ORDTRABAJO_OT_CANCELADO]
	DEFAULT ('N') FOR [OT_CANCELADO]
GO
ALTER TABLE [dbo].[ORDTRABAJO]
	ADD
	CONSTRAINT [DF_ORDTRABAJO_OT_ESTATUS]
	DEFAULT ('N') FOR [OT_ESTATUS]
GO
ALTER TABLE [dbo].[ORDTRABAJO]
	ADD
	CONSTRAINT [DF_ORDTRABAJO_OT_ESTATUSSURT]
	DEFAULT ('N') FOR [OT_ESTATUSSURT]
GO
ALTER TABLE [dbo].[ORDTRABAJO]
	ADD
	CONSTRAINT [DF_ORDTRABAJO_OT_TIPO]
	DEFAULT ('P') FOR [OT_TIPO]
GO
ALTER TABLE [dbo].[ORDTRABAJO] SET (LOCK_ESCALATION = TABLE)
GO
