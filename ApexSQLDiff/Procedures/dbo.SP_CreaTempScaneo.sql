SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[SP_CreaTempScaneo] (@uservar varchar(50))   as



exec('exec sp_droptable ''TempScaneo'+@uservar+'''')
exec('CREATE TABLE [dbo].[TempScaneo'+@uservar+'] (
		[ORDEN] [int] IDENTITY (1, 1) NOT NULL ,
		[NOPARTE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[CANTIDAD] decimal(38,6) NULL ,
		[COSTO] decimal(38,6) NULL ,
		[PESO] decimal(38,6) NULL , 
		[ORIGEN] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
		[OBSERVA] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	 CONSTRAINT [IX_TempScaneo'+@uservar+'] UNIQUE NONCLUSTERED 
	(
		[ORDEN] ASC
	)WITH FILLFACTOR = 90 ON [PRIMARY]
	) ON [PRIMARY]')






GO
