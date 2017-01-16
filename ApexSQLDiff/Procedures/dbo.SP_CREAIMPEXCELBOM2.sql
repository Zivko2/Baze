SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO












CREATE PROCEDURE [dbo].[SP_CREAIMPEXCELBOM2]   as



if exists (SELECT name FROM dbo.sysobjects WHERE dbo.sysobjects.name = N'IMPEXCELBOM2')
drop table IMPEXCELBOM2


CREATE TABLE [DBO].[IMPEXCELBOM2] (
	[ORDEN] [int] IDENTITY (1, 1) NOT NULL ,
	[NOPARTEPADRE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[NOPARTE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[CANTIDAD] [decimal](38, 6) NULL ,
	[DESPERDICIO] [decimal](38, 6) NULL ,
	[MERMA] [decimal](38, 6) NULL ,
	[FECHAINI] [datetime] NULL ,
	[FECHAFIN] [datetime] NULL 
) ON [PRIMARY]








GO
