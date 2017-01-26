SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_PCKLISTADVERTENCIA] (@PL_CODIGO INT)   as

declare @sinGrupo char(1)


	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects WHERE dbo.sysobjects.name = 'PCKLISTADVERTENCIA')
	begin
		CREATE TABLE [dbo].[PCKLISTADVERTENCIA] (
			[PLN_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[PL_CODIGO] [int] NOT NULL ,
			[PL_COMENTARIO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			CONSTRAINT [IX_PCKLISTADVERTENCIA] UNIQUE  NONCLUSTERED 
			(
				[PLN_CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
	end

	delete from PCKLISTADVERTENCIA where PL_codigo=@PL_CODIGO


	/*  Factores de conversion */

	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PCKLISTDET.PLD_CANT_ST) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PCKLISTDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PCKLISTDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PCKLISTDET.ME_CODIGO <> dbo.PCKLISTDET.ME_GEN) AND (dbo.PCKLISTDET.EQ_GEN = 1)
	and (PCKLIST.PL_CODIGO = @PL_CODIGO) AND  isnull(MEDIDA_1.ME_CORTO,'')<>'SET' AND  isnull(MEDIDA_2.ME_CORTO,'')<>'RLL' AND  isnull(MEDIDA_1.ME_CORTO,'')<>''


	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PCKLISTDET.PLD_CANT_ST) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PCKLISTDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PCKLISTDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PCKLISTDET.ME_CODIGO = dbo.PCKLISTDET.ME_GEN) AND (dbo.PCKLISTDET.EQ_GEN <> 1)
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)



	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo Gen en KG, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PCKLISTDET.PLD_CANT_ST) + ', UM Generico: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.PCKLISTDET.PLD_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.PCKLISTDET.EQ_GEN)
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO
	WHERE     dbo.PCKLISTDET.ME_GEN=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (dbo.PCKLISTDET.EQ_GEN <> ROUND(dbo.PCKLISTDET.PLD_PES_UNI,6))
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)



	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Factor de Conversion erroneo F. Arancelaria en KG, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PCKLISTDET.PLD_CANT_ST) + ', UM Generico: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.PCKLISTDET.PLD_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.PCKLISTDET.EQ_IMPMX)
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO
	WHERE     dbo.PCKLISTDET.ME_ARIMPMX=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (dbo.PCKLISTDET.EQ_IMPMX <> ROUND(dbo.PCKLISTDET.PLD_PES_UNI,6))
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)



	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo VS F. Arancelaria, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PCKLISTDET.PLD_CANT_ST) + ', UM F. Arancelaria:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PCKLISTDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PCKLISTDET.ME_ARIMPMX = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PCKLISTDET.ME_ARIMPMX = dbo.PCKLISTDET.ME_GEN) AND (dbo.PCKLISTDET.EQ_GEN <> dbo.PCKLISTDET.EQ_IMPMX)
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)



	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)

	SELECT     dbo.PCKLIST.PL_CODIGO, 
	                      '* Cantidad Erronea, Con la UM Seleccionada no se permite la Cantidad con punto decimal, No. Parte: ' + dbo.PCKLISTDET.PLD_NOPARTE +', UM : ' + MEDIDA_1.ME_CORTO 
	FROM         dbo.PCKLIST INNER JOIN
	                      dbo.PCKLISTDET ON dbo.PCKLIST.PL_CODIGO = dbo.PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PCKLISTDET.ME_CODIGO = MEDIDA_1.ME_CODIGO 
	WHERE     (ME_CLA_PED in ('15', '6', '12', '9')) --AND (CHARINDEX('.', CONVERT(varchar(50), PLD_CANT_ST)) <> 0) 
	AND ROUND(PLD_CANT_ST, 6) - dbo.Trunc(ROUND(PLD_CANT_ST, 6), 0)>0
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)



	/* Costos */
	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Sin Costo Unitario, No. Parte: ' + PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PCKLISTDET.PLD_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.PLD_COS_UNI IS NULL OR PCKLISTDET.PLD_COS_UNI=0) 
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)

	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Registro sin Cantidad, No. Parte: ' + PCKLISTDET.PLD_NOPARTE +' Unidad de Medida: '+ MEDIDA.ME_CORTO 
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.PLD_CANT_ST =0 OR PCKLISTDET.PLD_CANT_ST IS NULL) 
	and (PCKLIST.PL_CODIGO = @PL_CODIGO)
	
	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Sin Tasa de Importacion Mx, No. Parte: ' + PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PCKLISTDET.PLD_CANT_ST) + ' ' + MEDIDA.ME_CORTO AS Expr1
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLIST.PL_CODIGO = @PL_CODIGO) AND (PCKLISTDET.PLD_POR_DEF= -1)



	if (SELECT     Count(*)
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.MA_GENERICO = 0 OR
	                      PCKLISTDET.MA_GENERICO IS NULL) AND (PCKLIST.PL_CODIGO = @PL_CODIGO))>0
	set @sinGrupo='S'



	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Sin Grupo Generico, No. Parte: ' + PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PCKLISTDET.PLD_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.MA_GENERICO = 0 OR
	                      PCKLISTDET.MA_GENERICO IS NULL) AND (PCKLIST.PL_CODIGO = @PL_CODIGO)




	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Sin Sector (Tipo de tasa PPS), No. Parte: ' + PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PCKLISTDET.PLD_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.PLD_SEC_IMP = 0 OR
	                      PCKLISTDET.PLD_SEC_IMP IS NULL) AND (PCKLISTDET.PLD_DEF_TIP = 'S') AND (PCKLIST.PL_CODIGO = @PL_CODIGO)

	
	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLIST.PL_CODIGO, '* Sin Tratado (Tipo de tasa Bajo Tratado), No. Parte: ' + PCKLISTDET.PLD_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PCKLISTDET.PLD_CANT_ST) + ' ' + MEDIDA.ME_CORTO
	FROM         PCKLIST INNER JOIN
	                      PCKLISTDET ON PCKLIST.PL_CODIGO = PCKLISTDET.PL_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PCKLISTDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PCKLISTDET.PLD_DEF_TIP = 'P') AND (PCKLIST.PL_CODIGO = @PL_CODIGO) AND (PCKLISTDET.SPI_CODIGO = 0 OR
	                      PCKLISTDET.SPI_CODIGO IS NULL)

	INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
	SELECT     PCKLISTDET.PL_CODIGO, '* Peso Bruto (Kg) Incorrecto en No. Parte: '+ PCKLISTDET.PLD_NOPARTE +' PB: ' +convert(varchar(50),PLD_PES_BRU)+' mayor que PN: '+ convert(varchar(50),PLD_PES_NET)+' y sin Cantidad de Empaque' 
	FROM         PCKLISTDET
	WHERE     (PLD_PES_BRU > PLD_PES_NET) AND (PLD_CANTEMP = 0)
	AND (PCKLISTDET.PL_CODIGO = @PL_CODIGO) 

	if @sinGrupo='S'
	begin
		INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
		VALUES(@PL_CODIGO, '                      ' )

		INSERT INTO PCKLISTADVERTENCIA(PL_CODIGO, PL_COMENTARIO)
		VALUES(@PL_CODIGO, '* Nota Importante:  Si existen Numeros de parte sin grupo generico al cerrar el pedimento los saldos no se generaran correctamente.' )

	end
















GO
