SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
























CREATE PROCEDURE [dbo].[SP_CreaPIDescarga]   as


if not exists (select * from dbo.sysobjects where name='PIDescarga')
CREATE TABLE [dbo].[PIDescarga] (
	[PI_CODIGO] [int] NOT NULL ,
	[PID_INDICED] [int] NOT NULL ,
	[PID_SALDOGEN] decimal(38,6) NOT NULL CONSTRAINT [DF_PIDescarga_PID_SALDOGEN] DEFAULT (0),
	[MA_CODIGO] [int] NULL ,
	[MA_GENERICO] [int] NULL ,
	[PI_FEC_ENT] [datetime] NULL ,
	[pid_fechavence] [datetime] NULL ,
	[PI_ACTIVOFIJO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIDescarga_PI_ACTIVOFIJO] DEFAULT ('N'),
	[PID_SALDOINCORRECTO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIDescarga_PID_SALDOINCORRECTO] DEFAULT ('N'),
	[PID_CONGELASUBMAQ] decimal(38,6) NOT NULL CONSTRAINT [DF_PIDescarga_PID_CONGELASUBMAQ] DEFAULT (0),
	[PI_DEFINITIVO] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PIDescarga_PI_DEFINITIVO] DEFAULT ('N'),
	[DI_DEST_ORIGEN] [int] NULL ,
	CONSTRAINT [PK_PIDescarga] PRIMARY KEY  CLUSTERED 
	(
		[PID_INDICED]
	)  ON [PRIMARY] 
) ON [PRIMARY]



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[INSERT_PIDESCARGA]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[INSERT_PIDESCARGA]

exec ('CREATE TRIGGER [INSERT_PIDESCARGA] ON dbo.PIDescarga 
FOR INSERT, UPDATE
AS

declare @pi_codigo int, @pi_tipo char(1), @cp_codigo int 


	if update(pid_saldogen)
	begin
		select @cp_codigo=cp_codigo, @pi_codigo=pi_codigo  from pedimp where pi_codigo in
		(select pi_codigo from inserted)

		exec SP_ACTUALIZAESTATUSPEDIMP @pi_codigo, @cp_codigo
	end')



























GO
