SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[SP_FACTEXPADVERTENCIA] (@FE_CODIGO INT)   as

declare @sinGrupo char(1)


	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects WHERE dbo.sysobjects.name = 'FACTEXPADVERTENCIA')
	begin
		CREATE TABLE [dbo].[FACTEXPADVERTENCIA] (
			[FEN_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[FE_CODIGO] [int] NOT NULL ,
			[FE_COMENTARIO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			CONSTRAINT [IX_FACTEXPADVERTENCIA] UNIQUE  NONCLUSTERED 
			(
				[FEN_CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
	end

	delete from FACTEXPADVERTENCIA where FE_codigo=@FE_CODIGO



	/* Factor de conversion */
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Posible Factor de Conversion erroneo, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTEXPDET.FED_CANT) + ', UM No. Parte:' + MEDIDA_1.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_2.ME_CORTO,'')
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA MEDIDA_1 ON FACTEXPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTEXPDET.ME_GENERICO = MEDIDA_2.ME_CODIGO
	WHERE     (FACTEXPDET.ME_CODIGO <> FACTEXPDET.ME_GENERICO) AND (FACTEXPDET.EQ_GEN = 1)
	and (FACTEXP.FE_CODIGO = @FE_CODIGO) AND  isnull(MEDIDA_2.ME_CORTO,'')<>'SET' AND  isnull(MEDIDA_1.ME_CORTO,'')<>'RLL' AND  isnull(MEDIDA_2.ME_CORTO,'')<>''
		


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Posible Factor de Conversion erroneo, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTEXPDET.FED_CANT) + ', UM No. Parte:' + MEDIDA_1.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_2.ME_CORTO,'')
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA MEDIDA_1 ON FACTEXPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTEXPDET.ME_GENERICO = MEDIDA_2.ME_CODIGO
	WHERE     (FACTEXPDET.ME_CODIGO = FACTEXPDET.ME_GENERICO) AND (FACTEXPDET.EQ_GEN <> 1)
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)



	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)

	SELECT     dbo.FACTEXP.FE_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo Gen en KG, No. Parte: ' + dbo.FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTEXPDET.FED_CANT) + ', UM Generico: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.FACTEXPDET.FED_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.FACTEXPDET.EQ_GEN)
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
	WHERE     dbo.FACTEXPDET.ME_GENERICO=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.FACTEXPDET.EQ_GEN,6) <> round(dbo.FACTEXPDET.FED_PES_UNI,6))
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)

	SELECT     dbo.FACTEXP.FE_CODIGO, 
	                      '* Factor de Conversion erroneo F. Arancelaria Exp. Mx. en KG, No. Parte: ' + dbo.FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.FACTEXPDET.FED_CANT) + ', UM F. Arancelaria: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.FACTEXPDET.FED_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.FACTEXPDET.EQ_EXPMX)
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
	WHERE     dbo.FACTEXPDET.ME_AREXPMX=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.FACTEXPDET.EQ_EXPMX,6) <> round(dbo.FACTEXPDET.FED_PES_UNI,6))
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)



	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Factor de Conversion erroneo Grupo VS Fraccion, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTEXPDET.FED_CANT) + ', UM F. Arancelaria:' + MEDIDA_1.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_2.ME_CORTO,'')
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA MEDIDA_1 ON FACTEXPDET.ME_AREXPMX = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.FACTEXPDET.ME_GENERICO = MEDIDA_2.ME_CODIGO
	WHERE     (FACTEXPDET.ME_AREXPMX = FACTEXPDET.ME_GENERICO) AND (round(FACTEXPDET.EQ_GEN,6) <> round(dbo.FACTEXPDET.EQ_EXPMX,6))
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)


	/*Costos */
	
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Sin Costo Unitario, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO 
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTEXPDET.FED_COS_UNI IS NULL OR FACTEXPDET.FED_COS_UNI=0) 
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)

	
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Registro sin Cantidad, No. Parte: ' + FACTEXPDET.FED_NOPARTE +' Unidad de Medida: '+ MEDIDA.ME_CORTO 
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTEXPDET.FED_CANT =0 OR FACTEXPDET.FED_CANT IS NULL) 
	and (FACTEXP.FE_CODIGO = @FE_CODIGO)
	

	if (select fe_tipo from factexp where fe_codigo=@FE_CODIGO)='V'
	begin
		INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
		SELECT     FACTEXP.FE_CODIGO, '* Sin Tasa de Importacion Mx, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
		                      FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO AS Expr1
		FROM         FACTEXP INNER JOIN
		                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
		WHERE     (FACTEXP.FE_CODIGO = @FE_CODIGO) AND (FACTEXPDET.FED_POR_DEF= -1)


		INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
		SELECT     FACTEXP.FE_CODIGO, '* Sin Sector (Tipo de tasa PPS), No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
		                      FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO 
		FROM         FACTEXP INNER JOIN
		                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
		WHERE     (FACTEXPDET.FED_SEC_IMP = 0 OR
		                      FACTEXPDET.FED_SEC_IMP IS NULL) AND (FACTEXPDET.FED_DEF_TIP = 'S') AND (FACTEXP.FE_CODIGO = @FE_CODIGO)
	
		
		INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
		SELECT     FACTEXP.FE_CODIGO, '* Sin Tratado (Tipo de tasa Bajo Tratado), No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
		                      FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO
		FROM         FACTEXP INNER JOIN
		                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
		                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
		WHERE     (FACTEXPDET.FED_DEF_TIP = 'P') AND (FACTEXP.FE_CODIGO = @FE_CODIGO) AND (FACTEXPDET.SPI_CODIGO = 0 OR
		                      FACTEXPDET.SPI_CODIGO IS NULL)



	end

	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FE_CODIGO, '* Fraccion Imp. USA Incorrecta, No. Parte: ' + FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), FED_CANT)
	FROM       FACTEXPDET
	WHERE   (AR_IMPFO = 0 OR AR_IMPFO IS NULL) AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FE_CODIGO, '* Fraccion Exp. MX Incorrecta, No. Parte: ' + FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), FED_CANT)
	FROM       FACTEXPDET
	WHERE   (AR_EXPMX = 0 OR AR_EXPMX IS NULL) AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Fraccion Mat. Originario Incorrecta, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	FACTEXPDET.FED_CANT)
	FROM         FACTEXPDET LEFT OUTER JOIN
	                      ARANCEL ON FACTEXPDET.AR_ORIG = ARANCEL.AR_CODIGO
	WHERE    (LEFT(ARANCEL.AR_FRACCION, 3) <> '980' OR FACTEXPDET.AR_ORIG=0)
	AND (FACTEXPDET.FED_NG_USA>0) AND (FACTEXPDET.FED_NAFTA<>'S') AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Fraccion Empaque Originario Incorrecta, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	FACTEXPDET.FED_CANT)
	FROM         FACTEXPDET LEFT OUTER JOIN
	                      ARANCEL ON FACTEXPDET.AR_NG_EMP = ARANCEL.AR_CODIGO
	WHERE    (LEFT(ARANCEL.AR_FRACCION, 3) <> '980' OR FACTEXPDET.AR_NG_EMP=0)
	AND (FACTEXPDET.FED_NG_EMP>0) AND (FACTEXPDET.FED_NAFTA<>'S') AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 

	if (SELECT     Count(*)
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTEXPDET.MA_GENERICO = 0 OR
	                      FACTEXPDET.MA_GENERICO IS NULL) AND (FACTEXP.FE_CODIGO = @FE_CODIGO))>0
	set @sinGrupo='S'



	
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXP.FE_CODIGO, '* Sin Grupo Generico, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO 
	FROM         FACTEXP INNER JOIN
	                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (FACTEXPDET.MA_GENERICO = 0 OR
	                      FACTEXPDET.MA_GENERICO IS NULL) AND (FACTEXP.FE_CODIGO = @FE_CODIGO)


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Costo Unitario no Coincide con la suma de la division de costos en No. Parte: '+ FACTEXPDET.FED_NOPARTE+',  Costo Unit: '+CONVERT(varchar(50), FACTEXPDET.FED_COS_UNI)+', Suma de division: '+ 
	                      CONVERT(varchar(50), ROUND(ISNULL(FACTEXPDET.FED_GRA_MP + FACTEXPDET.FED_GRA_ADD + FACTEXPDET.FED_GRA_EMP + FACTEXPDET.FED_GRA_GI + FACTEXPDET.FED_GRA_GI_MX
	                       + FACTEXPDET.FED_GRA_MO + FACTEXPDET.FED_NG_MP + FACTEXPDET.FED_NG_ADD + FACTEXPDET.FED_NG_EMP, 0), 6)) 
	FROM         FACTEXPDET INNER JOIN
	                      CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE     (FACTEXPDET.FED_TIP_ENS <> 'C') AND (ROUND(FACTEXPDET.FED_COS_UNI, 6) 
	                      <> ROUND(ISNULL(FACTEXPDET.FED_GRA_MP + FACTEXPDET.FED_GRA_ADD + FACTEXPDET.FED_GRA_EMP + FACTEXPDET.FED_GRA_GI + FACTEXPDET.FED_GRA_GI_MX
	                       + FACTEXPDET.FED_GRA_MO + FACTEXPDET.FED_NG_MP + FACTEXPDET.FED_NG_ADD + FACTEXPDET.FED_NG_EMP, 0), 6)) AND 
	                      (CONFIGURATIPO.CFT_TIPO = 'S' OR
	                      CONFIGURATIPO.CFT_TIPO = 'P')
	AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Costo Unitario de Mat. Orig. no puede ser menor que el Costo unit. no grav. USA, No. Parte: '+ FACTEXPDET.FED_NOPARTE+', Mat. Orig.: '+CONVERT(varchar(50), FACTEXPDET.FED_NG_MP)+', Costo unit. no grav. USA: '+ CONVERT(varchar(50), FACTEXPDET.FED_NG_USA)
	FROM         FACTEXPDET INNER JOIN
	                      CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE     (FACTEXPDET.FED_NG_MP < FACTEXPDET.FED_NG_USA)
	AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Peso Bruto (Kg) Incorrecto en No. Parte: '+ FACTEXPDET.FED_NOPARTE +' PB: ' +convert(varchar(50),FED_PES_BRU)+' mayor que PN: '+ convert(varchar(50),FED_PES_NET)+' y sin Cantidad de Empaque' 
	FROM         FACTEXPDET
	WHERE     (FED_PES_BRU > FED_PES_NET) AND (FED_CANTEMP = 0)
	AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	if exists(SELECT DI_DESTFIN FROM FACTEXP WHERE FACTEXP.FE_CODIGO = @FE_CODIGO AND (DI_DESTFIN IS NULL OR DI_DESTFIN=0))
	begin

		INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)	
		VALUES(@FE_CODIGO, '* La factura no tiene asignado el Domicilio del Destino final, esta falta de informacion generara un pedimento de Salida en Azul' )
	end
	else
		INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)	
		SELECT     FACTEXP.FE_CODIGO, '* El destino Final del detalle no coincide con la caratula, No. Parte: ' + FACTEXPDET.FED_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                  FACTEXPDET.FED_CANT) + ' ' + MEDIDA.ME_CORTO 
		FROM         dbo.FACTEXPDET INNER JOIN
		                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
		                      dbo.DIR_CLIENTE ON dbo.FACTEXP.DI_DESTFIN = dbo.DIR_CLIENTE.DI_INDICE  LEFT OUTER JOIN
		                      MEDIDA ON FACTEXPDET.ME_CODIGO = MEDIDA.ME_CODIGO
		WHERE     (dbo.FACTEXP.FE_CODIGO = @FE_CODIGO)
		AND dbo.FACTEXPDET.FED_DESTNAFTA<> (CASE 
		when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
		 when dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
		then 'N'  WHEN 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
		then 'U' when 	  dbo.DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
		then 'A'  else 'F' end)

	/*Inserta advertencia para los numeros de parte definitivos, el valor MA_NOPARTEDEFINITIVO = 1 significa que esta marcado como definitivo*/
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)	
	SELECT     FACTEXPDET.FE_CODIGO, '* El No. Parte: '+ FACTEXPDET.FED_NOPARTE +' esta marcado como definitivo' 
	FROM         FACTEXPDET left outer join MAESTRO on FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO
	WHERE     MAESTRO.MA_NOPARTEDEFINITIVO = 1 and (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 


	--Valida si no tiene tipo de costo, Manuel G. 14-Sep-2010	
	INSERT INTO FACTEXPADVERTENCIA(FE_CODIGO, FE_COMENTARIO)
	SELECT     FACTEXPDET.FE_CODIGO, '* Sin tipo de Costo, No. Parte: '+ FACTEXPDET.FED_NOPARTE +' Cantidad: ' +convert(varchar(50),FED_CANT)
	FROM         FACTEXPDET
	WHERE     (TCO_CODIGO <=0 or TCO_CODIGO is null)
	AND (FACTEXPDET.FE_CODIGO = @FE_CODIGO) 












GO
