SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.SP_RANGOS_REGLAORIGEN_FRACCION (@ar_fraccion int, @Regla int )  as

declare @longitud int


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tempRangosReglaOrigen]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[tempRangosReglaOrigen] (
	[ARR_CODIGO] [int] NOT NULL ,
	[AR_CODIGO] [int] NOT NULL ,
	[AR_FRACCION] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ARR_PARTIDAPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ARR_PARTIDAPTF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[arr_perini] [datetime] NOT NULL ,
	[arr_perfin] [datetime] NOT NULL 
) ON [PRIMARY]


--Yolanda Avila
--2010-08-24
--Se ajusto para que solo una 
/*
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tempRangosReglaOrigen]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	drop table [dbo].[tempRangosReglaOrigen]
	
	
	CREATE TABLE [dbo].[tempRangosReglaOrigen] (
		[ARR_CODIGO] [int] NOT NULL ,
		[AR_CODIGO] [int] NOT NULL ,
		[AR_FRACCION] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		[ARR_PARTIDAPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		[ARR_PARTIDAPTF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	) ON [PRIMARY]

	--PARA EL TAMAÑO 10
	set @longitud = 10
	insert into tempRangosReglaOrigen
	select b.arr_codigo, a.ar_codigo, a.ar_fraccion, b.arr_partidapt, b.arr_partidaptf from 
	(SELECT     ARANCEL.AR_FRACCION, arancel.ar_codigo
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	WHERE     (MAESTRO.TI_CODIGO = 14 OR MAESTRO.TI_CODIGO = 16)
	GROUP BY ARANCEL.AR_FRACCION, arancel.ar_codigo) a,
	
	(SELECT     arr_partidapt, arr_partidaptf, arr_codigo
	FROM         REGLAORIGEN
	where spi_codigo in (select spi_codigo from spi where spi_clave='nafta') and
	len(arr_partidapt) = @longitud) b
	
	where substring(a.ar_fraccion,1,@longitud) between b.arr_partidapt and arr_partidaptf
	 and a.ar_codigo not in (select ar_codigo from tempRangosReglaOrigen)
	
	
	--PARA EL TAMAÑO 8
	set @longitud = 8
	insert into tempRangosReglaOrigen
	select b.arr_codigo, a.ar_codigo, a.ar_fraccion, b.arr_partidapt, b.arr_partidaptf from 
	(SELECT     ARANCEL.AR_FRACCION, arancel.ar_codigo
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	WHERE     (MAESTRO.TI_CODIGO = 14 OR MAESTRO.TI_CODIGO = 16)
	GROUP BY ARANCEL.AR_FRACCION, arancel.ar_codigo) a,
	
	
	(SELECT     arr_partidapt, arr_partidaptf, arr_codigo
	FROM         REGLAORIGEN
	where spi_codigo in (select spi_codigo from spi where spi_clave='nafta') and
	len(arr_partidapt) = @longitud) b
	
	where substring(a.ar_fraccion,1,@longitud) between b.arr_partidapt and arr_partidaptf
	 and a.ar_codigo not in (select ar_codigo from tempRangosReglaOrigen)
	
	--PARA EL TAMAÑO 6
	set @longitud = 6
	insert into tempRangosReglaOrigen
	select b.arr_codigo, a.ar_codigo, a.ar_fraccion, b.arr_partidapt, b.arr_partidaptf from 
	(SELECT     ARANCEL.AR_FRACCION, arancel.ar_codigo
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	WHERE     (MAESTRO.TI_CODIGO = 14 OR MAESTRO.TI_CODIGO = 16)
	GROUP BY ARANCEL.AR_FRACCION, arancel.ar_codigo) a,
	
	
	(SELECT     arr_partidapt, arr_partidaptf, arr_codigo
	FROM         REGLAORIGEN
	where spi_codigo in (select spi_codigo from spi where spi_clave='nafta') and
	len(arr_partidapt) = @longitud) b
	
	where substring(a.ar_fraccion,1,@longitud) between b.arr_partidapt and arr_partidaptf
	 and a.ar_codigo not in (select ar_codigo from tempRangosReglaOrigen)
	
	
	--PARA EL TAMAÑO 4
	set @longitud = 4
	insert into tempRangosReglaOrigen
	select b.arr_codigo, a.ar_codigo, a.ar_fraccion, b.arr_partidapt, b.arr_partidaptf from 
	(SELECT     ARANCEL.AR_FRACCION, arancel.ar_codigo
	FROM         MAESTRO INNER JOIN
	                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	WHERE     (MAESTRO.TI_CODIGO = 14 OR MAESTRO.TI_CODIGO = 16)
	GROUP BY ARANCEL.AR_FRACCION,arancel.ar_codigo) a,
	
	
	(SELECT     arr_partidapt, arr_partidaptf, arr_codigo
	FROM         REGLAORIGEN
	where spi_codigo in (select spi_codigo from spi where spi_clave='nafta') and
	len(arr_partidapt) = @longitud) b
	
	where substring(a.ar_fraccion,1,@longitud) between b.arr_partidapt and arr_partidaptf
	 and a.ar_codigo not in (select ar_codigo from tempRangosReglaOrigen)
	*/
insert into tempRangosReglaOrigen
select b.arr_codigo, a.ar_codigo, a.ar_fraccion, b.arr_partidapt, b.arr_partidaptf, 
	(select arr_perini from arancelreglaorigen where arancelreglaorigen.ar_codigo=@ar_fraccion and arancelreglaorigen.arr_codigo=@Regla) as arr_perini,
	(select arr_perfin from arancelreglaorigen where arancelreglaorigen.ar_codigo=@ar_fraccion and arancelreglaorigen.arr_codigo=@Regla) as arr_perfin
from 
	(SELECT ARANCEL.AR_FRACCION, arancel.ar_codigo
	 FROM MAESTRO 
	 INNER JOIN ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO
	 WHERE (MAESTRO.TI_CODIGO = 14 OR MAESTRO.TI_CODIGO = 16)
	 GROUP BY ARANCEL.AR_FRACCION, arancel.ar_codigo) a,
(SELECT arr_partidapt, arr_partidaptf, arr_codigo
 FROM REGLAORIGEN
 where spi_codigo in (select spi_codigo from spi where spi_clave='nafta') 
 and arr_codigo = @Regla
) b

where left(a.ar_fraccion,len(b.arr_partidapt)) between b.arr_partidapt and arr_partidaptf
and a.ar_fraccion +'#'+b.arr_partidapt+'#'+b.arr_partidaptf not in (select ar_fraccion +'#'+arr_partidapt+'#'+arr_partidaptf from tempRangosReglaOrigen)
and a.ar_codigo <> @ar_fraccion





GO
