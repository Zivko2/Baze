SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CREATABLALOG] (@TAG INT)   as

declare @TAGT varchar(50)

select @TAGT=convert(varchar(50),@TAG)

exec('if not exists (select * from sysobjects where name=''sysusrlog'+@TAGT+''')
	CREATE TABLE [dbo].[sysusrlog'+@TAGT+'](
		[sysusrlog_id] [int] IDENTITY(1,1) NOT NULL,
		[user_id] [smallint] NOT NULL,
		[mov_id] [smallint] NOT NULL,
		[referencia] [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[frmtag] [smallint] NOT NULL,
		[fechahora] [datetime] NOT NULL,
	 CONSTRAINT [IX_sysusrlog'+@TAGT+'] UNIQUE NONCLUSTERED 
	(
		[sysusrlog_id] ASC
	)WITH FILLFACTOR = 90 ON [PRIMARY]
	) ON [PRIMARY]')

exec('if exists (select * from dbo.sysobjects where id = object_id(N''[dbo].[INSERT_SYSUSRLOG'+@TAGT+']'') and OBJECTPROPERTY(id, N''IsTrigger'') = 1)
drop trigger [dbo].[INSERT_SYSUSRLOG'+@TAGT+']')


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INSERT_SYSUSRLOG'+@TAGT+']') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
exec('CREATE TRIGGER [INSERT_SYSUSRLOG'+@TAGT+'] ON dbo.sysusrlog'+@TAGT+'
	FOR INSERT, UPDATE
	AS 
	
	declare @diasantes varchar(25)
	
		SELECT     @diasantes = convert(varchar(25), getdate() - max(EM_DIASMANTLOG),101)
		FROM         dbo.CONFIGURACION 
		GROUP BY EM_DIASMANTLOG 
	
	 
		exec sp_fillsysusrlogHist @diasantes,'+@TAGT+'')




exec('if not exists (select * from sysobjects where name=''sysusrlog'+@TAGT+'Hist'')
	CREATE TABLE [dbo].[sysusrlog'+@TAGT+'Hist](
		[sysusrlog_id] [int] NOT NULL,
		[user_id] [smallint] NOT NULL,
		[mov_id] [smallint] NOT NULL,
		[referencia] [varchar](1100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[frmtag] [smallint] NOT NULL,
		[fechahora] [datetime] NOT NULL,
	 CONSTRAINT [IX_sysusrlog'+@TAGT+'Hist] UNIQUE NONCLUSTERED 
	(
		[sysusrlog_id] ASC
	)WITH FILLFACTOR = 90 ON [PRIMARY]
	) ON [PRIMARY]')


















GO
