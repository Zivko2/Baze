SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ADDGENERICOS]   as

declare @maximo int, @MA_CODIGO INT

exec sp_droptable 'MaestroTemp'

CREATE TABLE [dbo].[MaestroTemp] (
	[MA_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[MA_NOPARTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[MA_INV_GEN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MaestroTemp_MA_INV_GEN] DEFAULT ('I'),
	[TI_CODIGO] [smallint] NOT NULL ,
	[MA_NOMBRE] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[MA_NAME] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[ME_COM] [int] NOT NULL ,
	[PA_ORIGEN] [int] NOT NULL ,
	[PA_PROCEDE] [int] NOT NULL ,
	[MA_GENERICO] [int] NOT NULL CONSTRAINT [DF_MaestroTemp_MA_GENERICO] DEFAULT (0),
	[AR_IMPMX] [int] NULL ,
	[AR_EXPMX] [int] NULL ,
	CONSTRAINT [PK_MaestroTemp] PRIMARY KEY  CLUSTERED 
	(
		[MA_NOPARTE],
		[MA_INV_GEN]
	)  ON [PRIMARY] 
) ON [PRIMARY]

--select @maximo=isnull(max(ma_codigo),0)+1 from maestro
select @maximo=isnull(cv_codigo,0)+1 from consecutivo where cv_tabla='maestro'

dbcc checkident (maestrotemp, reseed, @maximo) WITH NO_INFOMSGS



-- ASIGNAR PRIMERO IDENTITY
	insert into maestrotemp (ma_noparte, ma_nombre, ma_name, ar_impmx, ar_expmx, me_com, ti_codigo, pa_origen, pa_procede, ma_inv_gen)
	SELECT     REPLACE(REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''), ' ', '') + dbo.MEDIDA.ME_CORTO, MAX(dbo.MAESTRO.MA_NOMBRE), MAX(dbo.MAESTRO.MA_NAME), 
	                      dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_IMPMX, dbo.RELMEDIDASAAI.ME_COMERCIAL, MAX(dbo.MAESTRO.TI_CODIGO), 154, 154, 'G'
	FROM         dbo.RELMEDIDASAAI INNER JOIN
	                      dbo.MAESTRO ON dbo.RELMEDIDASAAI.ME_CODIGO = dbo.MAESTRO.ME_COM INNER JOIN
	                      dbo.MEDIDA ON dbo.RELMEDIDASAAI.ME_COMERCIAL = dbo.MEDIDA.ME_CODIGO LEFT OUTER JOIN
	                      dbo.ARANCEL ON dbo.MAESTRO.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
	WHERE REPLACE(REPLACE(dbo.ARANCEL.AR_FRACCION, '.', ''), ' ', '') + dbo.MEDIDA.ME_CORTO  NOT IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN='G')
	GROUP BY dbo.ARANCEL.AR_FRACCION, dbo.MEDIDA.ME_CORTO, dbo.MAESTRO.AR_IMPMX, dbo.RELMEDIDASAAI.ME_COMERCIAL
	HAVING      (dbo.ARANCEL.AR_FRACCION IS NOT NULL)



	insert into maestro (ma_codigo, ma_noparte, ma_nombre, ma_name, ar_impmx, ar_expmx, me_com, ti_codigo, pa_origen, pa_procede, ma_inv_gen)
	select ma_codigo, ma_noparte, ma_nombre, ma_name, ar_impmx, ar_expmx, me_com, ti_codigo, pa_origen, pa_procede, ma_inv_gen 
	from maestrotemp
	where ma_noparte is not null
	

	INSERT INTO MAESTROCOST(MA_CODIGO, TCO_CODIGO, TV_CODIGO, MA_COSTO)
	SELECT MA_CODIGO, (SELECT TCO_COMPRA FROM dbo.CONFIGURACION),  (SELECT TV_CODIGO FROM TVALORA WHERE TV_CLAVE = '1'), 0
	FROM MAESTRO
	 WHERE MA_INV_GEN='G' AND MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCOST)



ALTER TABLE MAESTRO DISABLE TRIGGER [Update_Maestro]

	-- se actualiza relacion
	UPDATE dbo.MAESTRO
	SET     dbo.MAESTRO.MA_GENERICO= MAESTRO_1.MA_CODIGO
	FROM         dbo.RELMEDIDASAAI INNER JOIN
	                      dbo.MAESTRO MAESTRO_1 ON dbo.RELMEDIDASAAI.ME_COMERCIAL = MAESTRO_1.ME_COM INNER JOIN
	                      dbo.MAESTRO ON dbo.RELMEDIDASAAI.ME_CODIGO = dbo.MAESTRO.ME_COM AND MAESTRO_1.AR_IMPMX = dbo.MAESTRO.AR_IMPMX
	WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (MAESTRO_1.MA_INV_GEN = 'G') AND
	dbo.MAESTRO.MA_GENERICO<> MAESTRO_1.MA_CODIGO

	exec SP_ACTUALIZAEQGENALL

	UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.ME_GEN= MAESTRO_1.ME_COM, dbo.BOM_STRUCT.FACTCONV= dbo.MAESTRO.EQ_GEN
	FROM         dbo.MAESTRO INNER JOIN
	                      dbo.BOM_STRUCT ON dbo.MAESTRO.MA_CODIGO = dbo.BOM_STRUCT.BST_HIJO INNER JOIN
	                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
	WHERE dbo.BOM_STRUCT.ME_GEN<> MAESTRO_1.ME_COM OR dbo.BOM_STRUCT.FACTCONV<> dbo.MAESTRO.EQ_GEN


ALTER TABLE MAESTRO ENABLE TRIGGER [Update_Maestro]

exec sp_droptable 'MaestroTemp'

select @MA_CODIGO= max(MA_CODIGO) from MAESTRO

if exists(select * from maestrorefer) and (select isnull(max(ma_codigo),0) from maestrorefer)>@MA_CODIGO
select @MA_CODIGO= isnull(max(MA_CODIGO),0) from MAESTROREFER


	update consecutivo
	set cv_codigo =  isnull(@MA_CODIGO,0) + 1
	where cv_tipo = 'MA'



































GO
