SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























-- inserta los materiales de la tabla ORDTRABAJOEXPLO a la orden de compra seleccionada
CREATE PROCEDURE [dbo].[SP_GENERAORDCOMPRADET] (@OT_CODIGO int, @OR_CODIGO INT)   as

SET NOCOUNT ON 
declare @MA_CODIGO int, @FechaActual datetime, @maximo int,@ORD_INDICED int, @OTD_INDICED int, @OTD_CANT decimal(38,6)

  SET @FechaActual = convert(varchar(10), getdate(),101)



--generacion de la tabla
if not exists (select * from dbo.sysobjects where name='TempOrdCompraDet')
begin
CREATE TABLE [dbo].[TempOrdCompraDet] (
	[ORD_INDICED] [int] IDENTITY (1, 1) NOT NULL ,
	[OR_CODIGO] [int] NOT NULL ,
	[ORD_CANT_ST] decimal(38,6) NULL ,
	[ORD_COS_UNI] decimal(38,6) NULL ,
	[ORD_COS_TOT] decimal(38,6) NULL ,
	[ORD_NOMBRE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempOrdCompraDet_ORD_NOPARTE] DEFAULT (''),
	[ORD_SALDO] decimal(38,6) NULL ,
	[ORD_ENUSO] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TempOrdCompraDet_ORD_ENUSO] DEFAULT ('N'),
	[ORD_ENVIO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_FEC_EST] [smalldatetime] NULL ,
	[ORD_FECHA] [smalldatetime] NULL ,
	[MA_CODIGO] [int] NOT NULL ,
	[ME_CODIGO] [int] NULL ,
	[TI_CODIGO] [int] NOT NULL ,
	[MA_EMPAQUE] [int] NULL ,
	[ORD_CANTEMP] decimal(38,6) NULL ,
	[TCO_CODIGO] [smallint] NULL ,
	[ORD_OBSERVA] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_REQUISICION] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_FEC_REQUERIDA] [datetime] NULL ,
	[ORD_FEC_ARRIBO] [datetime] NULL ,
	[ORD_FEC_ENV] [datetime] NULL ,
	[ORD_REQD_INDICED] [int] NULL ,
	[OT_CODIGO] [int] NULL ,
	[OTD_INDICED] [int] NULL ,
	[OT_FOLIO] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[OTD_SALDOUSAORDTRAB] decimal(38,6) NULL ,
	[PD_FOLIO] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[ORD_NOPARTEPROVEE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_TempOrdCompraDet_ORD_NOPARTEPROVEE] DEFAULT (''),
	CONSTRAINT [PK_TempOrdCompraDet] PRIMARY KEY  NONCLUSTERED 
	(
		[ORD_INDICED]
	)  ON [PRIMARY] 
) ON [PRIMARY]

end

	TRUNCATE TABLE TempOrdCompraDet

	select @ord_indiced=max(ORD_INDICED)+1 from TempOrdCompraDet

	dbcc checkident (TempOrdCompraDet, reseed, @ord_indiced) WITH NO_INFOMSGS


-- insercion
insert into TempOrdCompraDet (OR_CODIGO,ORD_CANT_ST,ORD_COS_UNI,ORD_COS_TOT,ORD_NOMBRE,ORD_NAME,ORD_NOPARTE,
	                          MA_CODIGO,ME_CODIGO,TI_CODIGO,TCO_CODIGO,OT_CODIGO,OTD_INDICED, ORD_SALDO, OTD_SALDOUSAORDTRAB, OT_FOLIO)

SELECT @OR_CODIGO, 'cantidad'= case 
	when dbo.MAESTROALM.MAA_SIZELOTE is null or dbo.MAESTROALM.MAA_SIZELOTE=0   then ceiling(ORDTRABAJOEXPLO.OTE_CANTPO)  
	when dbo.MAESTROALM.MAA_SIZELOTE >= ORDTRABAJOEXPLO.OTE_CANTPO then ceiling(dbo.MAESTROALM.MAA_SIZELOTE)
	when dbo.MAESTROALM.MAA_SIZELOTE < ORDTRABAJOEXPLO.OTE_CANTPO then 
	ceiling(dbo.MAESTROALM.MAA_SIZELOTE) * case 
                                   when dbo.Entero(CEILING(ORDTRABAJOEXPLO.OTE_CANTPO),ceiling(dbo.MAESTROALM.MAA_SIZELOTE))>0
                                   then CEILING (ORDTRABAJOEXPLO.OTE_CANTPO/ceiling(dbo.MAESTROALM.MAA_SIZELOTE))
				   else Ceiling(ORDTRABAJOEXPLO.OTE_CANTPO)/ceiling(dbo.MAESTROALM.MAA_SIZELOTE)			
				  end
	end,
isnull(dbo.VMAESTROCOST.MA_COSTO,0), 
             isnull(SUM(ORDTRABAJOEXPLO.OTE_CANTPO * dbo.VMAESTROCOST.MA_COSTO),0) AS CostoTotal, 
                      dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_CODIGO, 
                      dbo.ORDTRABAJOEXPLO.ME_CODIGO, dbo.MAESTRO.TI_CODIGO, dbo.VMAESTROCOST.TCO_CODIGO, dbo.ORDTRABAJOEXPLO.OT_CODIGO, 
	         dbo.ORDTRABAJOEXPLO.OTD_INDICED, ceiling(ORDTRABAJOEXPLO.OTE_CANTPO) AS Saldo, 
                      ceiling(ORDTRABAJOEXPLO.OTE_CANTPO),(select ot_folio from ordTrabajo where ot_codigo= @OT_CODIGO)
FROM         dbo.MAESTROALM RIGHT OUTER JOIN
                      dbo.MAESTRO ON dbo.MAESTROALM.MA_CODIGO = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
                      dbo.ORDTRABAJOEXPLO LEFT OUTER JOIN
                      dbo.VMAESTROCOST ON dbo.ORDTRABAJOEXPLO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO ON 
                      dbo.MAESTRO.MA_CODIGO = dbo.ORDTRABAJOEXPLO.MA_CODIGO
GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.ORDTRABAJOEXPLO.OTD_INDICED, dbo.ORDTRABAJOEXPLO.OT_CODIGO, 
                      dbo.VMAESTROCOST.TCO_CODIGO, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, dbo.VMAESTROCOST.MA_COSTO, 
                      dbo.ORDTRABAJOEXPLO.ME_CODIGO, dbo.MAESTRO.TI_CODIGO, dbo.MAESTROALM.MAA_SIZELOTE, ORDTRABAJOEXPLO.OTE_CANTPO


	if exists (select * from OrdCompraDet left outer join OrdCompra on OrdCompraDet.or_codigo=OrdCompra.or_codigo where OTD_INDICED in (select OTD_INDICED from TempOrdCompraDet) and or_estatus='E')
	delete from OrdCompraDet where OTD_INDICED in (select OTD_INDICED from TempOrdCompraDet) 

	insert into OrdCompraDet(ORD_INDICED, OR_CODIGO,ORD_CANT_ST,ORD_COS_UNI,ORD_COS_TOT,ORD_NOMBRE,ORD_NAME,ORD_NOPARTE,
	                          MA_CODIGO,ME_CODIGO,TI_CODIGO,TCO_CODIGO,OT_CODIGO,OTD_INDICED, ORD_SALDO, OTD_SALDOUSAORDTRAB, OT_FOLIO)

	select ORD_INDICED, OR_CODIGO,ORD_CANT_ST,ORD_COS_UNI,ORD_COS_TOT,ORD_NOMBRE,ORD_NAME,ORD_NOPARTE,
	                          MA_CODIGO,ME_CODIGO,TI_CODIGO,TCO_CODIGO,OT_CODIGO,OTD_INDICED, ORD_SALDO, OTD_SALDOUSAORDTRAB, OT_FOLIO 
	from TempOrdCompraDet



/*	INSERT INTO KARDESORDTRABAJO (ORD_INDICED, OTD_INDICED, ORD_CANTDESC)

	SELECT     dbo.TempImpOrdTrabajo.OT_IDENTITY, dbo.TempImpOrdTrabajo.OTD_INDICED, SUM(dbo.TempImpOrdTrabajo.BST_INCORPOR * dbo.TempImpOrdTrabajo.OTD_CANT * dbo.VMAESTROCOST.MA_COSTO)  
	FROM         dbo.TempImpOrdTrabajo LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.TempImpOrdTrabajo.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.TempImpOrdTrabajo.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	GROUP BY dbo.TempImpOrdTrabajo.OTD_INDICED,  dbo.TempImpOrdTrabajo.OT_IDENTITY
*/	

select @ORD_INDICED=max(ord_indiced) from ordCompraDet

update consecutivo
set cv_codigo =  isnull(@ORD_INDICED,0) + 1
where cv_tipo = 'ORD'



























GO
