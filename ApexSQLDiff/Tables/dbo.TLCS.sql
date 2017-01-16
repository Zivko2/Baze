SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TLCS] (
		[FRACCION]       [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EUA]            [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_EUA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CANADA]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_CAN]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COLOMBIA]       [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_COL]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[VENEZUELA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_VEN]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CHILE]          [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_CHI]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BOLIVIA]        [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_BOL]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[COSTA_RICA]     [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_CRC]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NICARAGUA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_NIC]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ISRAEL]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_ISR]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[EUROPA]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_EUR]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[URUGUAY]        [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_URU]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PARAGUAY]       [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_PAR]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ECUADOR]        [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_ECU]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PERU]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_PER]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[ARGENTINA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_ARG]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[BRASIL]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_BRA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[CUBA]           [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_CUB]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[SALVADOR]       [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_SAL]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[PANAMA]         [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_PAN]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[HONDURAS]       [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_HON]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[GUATEMALA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[NOTAS_GUA]      [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TLCS] SET (LOCK_ESCALATION = TABLE)
GO
