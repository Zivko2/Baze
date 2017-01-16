SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_generaTempConciliaDesp] (@FechaIniPed varchar(11), @FechaFinPed varchar(11))  as


			exec sp_droptable 'tempConciliaDesp'
		
		CREATE TABLE [dbo].[tempConciliaDesp] (
			[CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[PID_INDICED] [int] NOT NULL ,
			[MA_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[PI_CODIGO] [int] NULL ,
			[PATENTE_FOLIO] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[MA_CODIGO] [int] NULL ,
			[PID_SALDOGEN] decimal(38,6) NULL ,
			[PI_FEC_ENT] [datetime] NULL ,
			[pid_fechavence] [datetime] NULL ,
			[FED_SALDOGEN] decimal(38,6) NULL ,
			[END_SALDOGEN] decimal(38,6) NULL ,
			CONSTRAINT [IX_tempConciliaDesp] UNIQUE  NONCLUSTERED 
			(
				[CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY]

		
		insert into tempConciliaDesp(PID_INDICED, PID_SALDOGEN, PI_FEC_ENT, pid_fechavence, MA_CODIGO, PI_CODIGO, MA_NOPARTE, PATENTE_FOLIO, FED_SALDOGEN, END_SALDOGEN )
		SELECT     dbo.PIDescarga.pid_indiced, dbo.PIDescarga.PID_SALDOGEN, dbo.VPEDIMP.PI_FEC_ENT, dbo.PIDescarga.pid_fechavence, dbo.PIDescarga.MA_CODIGO, 
		                      dbo.PIDescarga.PI_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.VPEDIMP.PATENTE_FOLIO, 0, 0
		FROM         dbo.PIDescarga INNER JOIN
		                      dbo.MAESTRO ON dbo.PIDescarga.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
		                      dbo.VPEDIMP ON dbo.PIDescarga.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO
		WHERE     (dbo.PIDescarga.PI_ACTIVOFIJO = 'N') AND (dbo.PIDescarga.PID_SALDOGEN > 0)
		AND dbo.VPEDIMP.PI_FEC_ENT >=@FechaIniPed AND dbo.VPEDIMP.PI_FEC_ENT <=@FechaFinPed



























GO
