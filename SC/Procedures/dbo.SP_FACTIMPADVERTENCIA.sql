SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_FACTIMPADVERTENCIA] (@FI_CODIGO INT)   as

declare @sinGrupo char(1)


	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects WHERE dbo.sysobjects.name = 'FACTIMPADVERTENCIA')
	begin
		CREATE TABLE [dbo].[FACTIMPADVERTENCIA] (
			[FIN_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[FI_CODIGO] [int] NOT NULL ,
			[FI_COMENTARIO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			CONSTRAINT [IX_FACTIMPADVERTENCIA] UNIQUE  NONCLUSTERED 
			(
				[FIN_CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
	end

	delete from FACTIMPADVERTENCIA where fi_codigo=@FI_CODIGO


	/*  Factores de conversion */

	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTIMPDET.FID_CANT_ST) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.FACTIMPDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTIMPDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.FACTIMPDET.ME_CODIGO <> dbo.FACTIMPDET.ME_GEN) AND (dbo.FACTIMPDET.EQ_GEN = 1)
	and (FACTIMP.FI_CODIGO = @FI_CODIGO) AND isnull(MEDIDA_1.ME_CORTO,'')<>'SET' AND  isnull(MEDIDA_2.ME_CORTO,'')<>'RLL' AND isnull(MEDIDA_1.ME_CORTO,'')<>''


	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTIMPDET.FID_CANT_ST) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.FACTIMPDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTIMPDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.FACTIMPDET.ME_CODIGO = dbo.FACTIMPDET.ME_GEN) AND (dbo.FACTIMPDET.EQ_GEN <> 1)
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)



	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo Gen en KG, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTIMPDET.FID_CANT_ST) + ', UM Generico: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.FACTIMPDET.FID_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.FACTIMPDET.EQ_GEN)
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
	WHERE     dbo.FACTIMPDET.ME_GEN=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.FACTIMPDET.EQ_GEN,6) <> ROUND(dbo.FACTIMPDET.FID_PES_UNI,6))
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)



	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Factor de Conversion erroneo F. Arancelaria Imp. Mx en KG, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTIMPDET.FID_CANT_ST) + ', UM F. Arancelaria: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.FACTIMPDET.FID_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.FACTIMPDET.EQ_IMPMX)
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO
	WHERE     dbo.FACTIMPDET.ME_ARIMPMX=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.FACTIMPDET.EQ_IMPMX,6) <> ROUND(dbo.FACTIMPDET.FID_PES_UNI,6))
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)



	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo VS F. Arancelaria, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTIMPDET.FID_CANT_ST) + ', UM F. Arancelaria:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.FACTIMPDET.ME_GEN = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTIMPDET.ME_ARIMPMX = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.FACTIMPDET.ME_ARIMPMX = dbo.FACTIMPDET.ME_GEN) AND (round(dbo.FACTIMPDET.EQ_GEN,6) <> round(dbo.FACTIMPDET.EQ_IMPMX,6))
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)


	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)

	SELECT     dbo.FACTIMP.FI_CODIGO, 
	                      '* Cantidad Erronea, Con la UM Seleccionada no se permite la Cantidad con punto decimal, No. Parte: ' + dbo.FACTIMPDET.FID_NOPARTE +', UM : ' + MEDIDA_1.ME_CORTO 
	FROM         dbo.FACTIMP INNER JOIN
	                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.FACTIMPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO 
	WHERE     (ME_CLA_PED in ('15', '6', '12', '9')) AND ROUND(FID_CANT_ST, 6) - dbo.Trunc(ROUND(FID_CANT_ST, 6), 0)>0
	--AND (CHARINDEX('.', CONVERT(varchar(50), FID_CANT_ST)) <> 0) 
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)



	/* Costos */
	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Sin Costo Unitario, No. Parte: ' + FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTIMPDET.FID_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.FID_COS_UNI IS NULL OR FACTIMPDET.FID_COS_UNI=0) 
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)

	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Registro sin Cantidad, No. Parte: ' + FACTIMPDET.FID_NOPARTE +' Unidad de Medida: '+ MEDIDA.ME_CORTO 
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.FID_CANT_ST =0 OR FACTIMPDET.FID_CANT_ST IS NULL) 
	and (FACTIMP.FI_CODIGO = @FI_CODIGO)
	
	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Sin Tasa de Importacion Mx, No. Parte: ' + FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTIMPDET.FID_CANT_ST) + ' ' + MEDIDA.ME_CORTO AS Expr1
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMP.FI_CODIGO = @FI_CODIGO) AND (FACTIMPDET.FID_POR_DEF= -1)



	if (SELECT     Count(*)
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.MA_GENERICO = 0 OR
	                      FACTIMPDET.MA_GENERICO IS NULL) AND (FACTIMP.FI_CODIGO = @FI_CODIGO))>0
	set @sinGrupo='S'



	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Sin Grupo Generico, No. Parte: ' + FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTIMPDET.FID_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.MA_GENERICO = 0 OR
	                      FACTIMPDET.MA_GENERICO IS NULL) AND (FACTIMP.FI_CODIGO = @FI_CODIGO)



	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FI_CODIGO, '* Fraccion Exp. USA Incorrecta, No. Parte: ' + FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), FID_CANT_ST)
	FROM       FACTIMPDET
	WHERE   (AR_EXPFO = 0 OR AR_EXPFO IS NULL) AND (FACTIMPDET.FI_CODIGO = @FI_CODIGO) 


	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FI_CODIGO, '* Fraccion Imp. MX Incorrecta, No. Parte: ' + FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), FID_CANT_ST)
	FROM       FACTIMPDET
	WHERE   (AR_IMPMX = 0 OR AR_IMPMX IS NULL) AND (FACTIMPDET.FI_CODIGO = @FI_CODIGO) 

	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Sin Sector (Tipo de tasa PPS), No. Parte: ' + FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTIMPDET.FID_CANT_ST) + ' ' + MEDIDA.ME_CORTO 
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.FID_SEC_IMP = 0 OR
	                      FACTIMPDET.FID_SEC_IMP IS NULL) AND (FACTIMPDET.FID_DEF_TIP = 'S') AND (FACTIMP.FI_CODIGO = @FI_CODIGO)

	
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMP.FI_CODIGO, '* Sin Tratado (Tipo de tasa Bajo Tratado), No. Parte: ' + FACTIMPDET.FID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTIMPDET.FID_CANT_ST) + ' ' + MEDIDA.ME_CORTO
	FROM         FACTIMP INNER JOIN
	                      FACTIMPDET ON FACTIMP.FI_CODIGO = FACTIMPDET.FI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTIMPDET.FID_DEF_TIP = 'P') AND (FACTIMP.FI_CODIGO = @FI_CODIGO) AND (FACTIMPDET.SPI_CODIGO = 0 OR
	                      FACTIMPDET.SPI_CODIGO IS NULL)

	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMPDET.FI_CODIGO, '* Peso Bruto (Kg) Incorrecto en No. Parte: '+ FACTIMPDET.FID_NOPARTE +' PB: ' +convert(varchar(50),FID_PES_BRU)+' mayor que PN: '+ convert(varchar(50),FID_PES_NET)+' y sin Cantidad de Empaque' 
	FROM         FACTIMPDET
	WHERE     (FID_PES_BRU > FID_PES_NET) AND (FID_CANTEMP = 0)
	AND (FACTIMPDET.FI_CODIGO = @FI_CODIGO) 

	if @sinGrupo='S'
	begin
		INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
		VALUES(@FI_CODIGO, '                      ' )

		INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
		VALUES(@FI_CODIGO, '* Nota Importante:  Si existen Numeros de parte sin grupo generico al cerrar el pedimento los saldos no se generaran correctamente.' )

	end
	
	/*Inserta advertencia para los numeros de parte definitivos, el valor MA_NOPARTEDEFINITIVO = 1 significa que esta marcado como definitivo*/
	INSERT INTO FACTIMPADVERTENCIA(FI_CODIGO, FI_COMENTARIO)
	SELECT     FACTIMPDET.FI_CODIGO, '* El No. Parte: '+ FACTIMPDET.FID_NOPARTE +' esta marcado como definitivo' 
	FROM         FACTIMPDET left outer join MAESTRO on FACTIMPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     (MAESTRO.MA_NOPARTEDEFINITIVO = 1) and (FACTIMPDET.FI_CODIGO = @FI_CODIGO) 













GO
