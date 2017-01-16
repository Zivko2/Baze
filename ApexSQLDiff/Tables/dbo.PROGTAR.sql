SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PROGTAR] (
		[PTA_CODIGO]               [int] NOT NULL,
		[PTA_NOMBRE]               [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_USUARIO]              [int] NOT NULL,
		[PTA_DESCRIPCION]          [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_MAIL]                 [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_NOTIFICA]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_AUTOBORRAR]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_ENCASO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_ALENTRAR]             [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_PRIORIDAD]            [int] NOT NULL,
		[PTA_AGRUPACION]           [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_ONETIME]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_OCURRE]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_CADA]                 [int] NOT NULL,
		[PTA_LUNES]                [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_MARTES]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_MIERCOLES]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_JUEVES]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_VIERNES]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_SABADO]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_DOMINGO]              [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_DIAMES]               [smallint] NULL,
		[PTA_SEMANA]               [smallint] NULL,
		[PTA_DIASEMANA]            [smallint] NULL,
		[PTA_PORDIA]               [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_PORSEMANA]            [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[PTA_SEMANANO]             [smallint] NULL,
		[PTA_FRECUENCIADIARIA]     [smallint] NULL,
		[PTA_HORAINICIO]           [datetime] NULL,
		[PTA_HORAFIN]              [datetime] NULL,
		[PTA_FRECUENCIACADA]       [int] NULL,
		[PTA_DINICIO]              [datetime] NULL,
		[PTA_DFIN]                 [datetime] NULL,
		[PTA_ULTIMAEJEC]           [datetime] NULL,
		[PTA_HORAEJEC]             [datetime] NULL,
		[PTA_FECHAEJEC]            [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROGTAR]
	ADD
	CONSTRAINT [PK_PROGTAR]
	PRIMARY KEY
	CLUSTERED
	([PTA_NOMBRE])
	WITH FILLFACTOR=90
	ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROGTAR] SET (LOCK_ESCALATION = TABLE)
GO
