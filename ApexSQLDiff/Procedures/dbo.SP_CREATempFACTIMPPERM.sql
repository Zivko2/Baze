SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_CREATempFACTIMPPERM] (@user int)   as

declare @user1 varchar(50)

select @user1=convert(varchar(50),@user)

EXEC('exec sp_droptable ''TempFACTIMPPERM'+@user+'')

exec('CREATE TABLE [dbo].[TempFACTIMPPERM'+@user1+'] (
	[FIR_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[FID_INDICED] [int] NOT NULL ,
	[FI_CODIGO] [int] NOT NULL ,
	[PE_CODIGO] [int] NULL ,
	[PED_INDICED] [int] NULL ,
	[FIP_ESTATUSAFECTA] [smallint] NULL ,
	[CPE_CODIGO] [int] NULL ,
	[EQ_CANT] decimal(38,6) NULL 
) ON [PRIMARY]')

exec('ALTER TABLE [dbo].[TempFACTIMPPERM'+@user1+'] ADD 
	CONSTRAINT [DF_TempFACTIMPPERM'+@user1+'_FIP_ESTATUSAFECTA] DEFAULT (0) FOR [FIP_ESTATUSAFECTA],
	CONSTRAINT [IX_TempFACTIMPPERM'+@user1+'] UNIQUE  NONCLUSTERED 
	(
		[FIR_CODIGO]
	)  ON [PRIMARY] ')






GO
