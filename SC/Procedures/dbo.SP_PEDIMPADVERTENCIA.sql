SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























CREATE PROCEDURE [dbo].[SP_PEDIMPADVERTENCIA] (@PI_CODIGO INT)   as

declare @sinGrupo char(1)


	if not exists (SELECT dbo.sysobjects.name FROM dbo.sysobjects WHERE dbo.sysobjects.name = 'PEDIMPADVERTENCIA')
	begin
		CREATE TABLE [dbo].[PEDIMPADVERTENCIA] (
			[PIN_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
			[PI_CODIGO] [int] NOT NULL ,
			[PI_COMENTARIO] [varchar] (1100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			CONSTRAINT [IX_PEDIMPADVERTENCIA] UNIQUE  NONCLUSTERED 
			(
				[PIN_CODIGO]
			)  ON [PRIMARY] 
		) ON [PRIMARY]
	end

	delete from PEDIMPADVERTENCIA where PI_codigo=@PI_CODIGO


	/*  Factores de conversion */

	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_GENERICO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PEDIMPDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PEDIMPDET.ME_CODIGO <> dbo.PEDIMPDET.ME_GENERICO) AND (dbo.PEDIMPDET.EQ_GENERICO = 1)
	and (PEDIMP.PI_CODIGO = @PI_CODIGO) AND  isnull(MEDIDA_1.ME_CORTO,'')<>'SET' AND  isnull(MEDIDA_2.ME_CORTO,'')<>'RLL' AND  isnull(MEDIDA_1.ME_CORTO,'')<>''


	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Posible Factor de Conversion erroneo, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ', UM No. Parte:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_GENERICO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PEDIMPDET.ME_CODIGO = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PEDIMPDET.ME_CODIGO = dbo.PEDIMPDET.ME_GENERICO) AND (dbo.PEDIMPDET.EQ_GENERICO <> 1)
	and (PEDIMP.PI_CODIGO = @PI_CODIGO) 



/*	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo Gen en KG, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ', UM Generico: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.PEDIMPDET.PID_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.PEDIMPDET.EQ_GENERICO)
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
	WHERE     dbo.PEDIMPDET.ME_GENERICO=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.PEDIMPDET.EQ_GENERICO,6) <> ROUND(dbo.PEDIMPDET.PID_PES_UNI,6))
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)



	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Factor de Conversion erroneo F. Arancelaria Imp. Mx en KG, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ', UM F. Arancelaria: KG, Peso Unitario Kg:'+CONVERT(varchar(50),dbo.PEDIMPDET.PID_PES_UNI)+' <> Factor de Conversion: '+CONVERT(varchar(50),dbo.PEDIMPDET.EQ_IMPMX)
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
	WHERE     dbo.PEDIMPDET.ME_ARIMPMX=(SELECT ME_KILOGRAMOS FROM CONFIGURACION) AND (round(dbo.PEDIMPDET.EQ_IMPMX,6) <> ROUND(dbo.PEDIMPDET.PID_PES_UNI,6))
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)
*/


	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Factor de Conversion erroneo Grupo VS F. Arancelaria, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ', UM F. Arancelaria:' + MEDIDA_2.ME_CORTO + ', UM Generico:' + isnull(MEDIDA_1.ME_CORTO,'')
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_GENERICO = MEDIDA_1.ME_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_2 ON dbo.PEDIMPDET.ME_ARIMPMX = MEDIDA_2.ME_CODIGO
	WHERE     (dbo.PEDIMPDET.ME_ARIMPMX = dbo.PEDIMPDET.ME_GENERICO) AND (round(dbo.PEDIMPDET.EQ_GENERICO,6) <> round(dbo.PEDIMPDET.EQ_IMPMX,6))
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)


	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)

	SELECT     dbo.PEDIMP.PI_CODIGO, 
	                      '* Cantidad Erronea, Con la UM Seleccionada no se permite la Cantidad con punto decimal, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ', UM : ' + MEDIDA_1.ME_CORTO 
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      dbo.MEDIDA MEDIDA_1 ON dbo.PEDIMPDET.ME_CODIGO = MEDIDA_1.ME_CODIGO 
	WHERE     (ME_CLA_PED in ('15', '6', '12', '9')) --AND (CHARINDEX('.', CONVERT(varchar(50), PID_CANT)) <> 0) 
	AND ROUND(PID_CANT, 6) - dbo.Trunc(ROUND(PID_CANT, 6), 0)>0
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)



	/* Costos */
	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Sin Costo Unitario, No. Parte: ' + PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PEDIMPDET.PID_CANT) + ' ' + MEDIDA.ME_CORTO 
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.PID_COS_UNI IS NULL OR PEDIMPDET.PID_COS_UNI=0) and PEDIMPDET.PID_IMPRIMIR='S'
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)

	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Registro sin Cantidad, No. Parte: ' + PEDIMPDET.PID_NOPARTE +' Unidad de Medida: '+ MEDIDA.ME_CORTO 
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.PID_CANT =0 OR PEDIMPDET.PID_CANT IS NULL) 
	and (PEDIMP.PI_CODIGO = @PI_CODIGO)
	
	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Sin Tasa de Importacion Mx, No. Parte: ' + PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PEDIMPDET.PID_CANT) + ' ' + MEDIDA.ME_CORTO AS Expr1
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMP.PI_CODIGO = @PI_CODIGO) AND (PEDIMPDET.PID_POR_DEF= -1) and PEDIMPDET.PID_IMPRIMIR='S'



	if (SELECT     Count(*)
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.MA_GENERICO = 0 OR
	                      PEDIMPDET.MA_GENERICO IS NULL) AND (PEDIMP.PI_CODIGO = @PI_CODIGO))>0
	set @sinGrupo='S'



/*	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Sin Grupo Generico, No. Parte: ' + PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PEDIMPDET.PID_CANT) + ' ' + MEDIDA.ME_CORTO 
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.MA_GENERICO = 0 OR
	                      PEDIMPDET.MA_GENERICO IS NULL) AND (PEDIMP.PI_CODIGO = @PI_CODIGO)



	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PI_CODIGO, '* Fraccion Exp. USA Incorrecta, No. Parte: ' + PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), PID_CANT)
	FROM       PEDIMPDET
	WHERE   (AR_EXPFO = 0 OR AR_EXPFO IS NULL) AND (PEDIMPDET.PI_CODIGO = @PI_CODIGO) 

*/
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PI_CODIGO, '* Fraccion Imp. MX Incorrecta, No. Parte: ' + PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), PID_CANT)
	FROM       PEDIMPDET
	WHERE   (AR_IMPMX = 0 OR AR_IMPMX IS NULL) AND (PEDIMPDET.PI_CODIGO = @PI_CODIGO) and PEDIMPDET.PID_IMPRIMIR='S'

	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Sin Sector (Tipo de tasa PPS), No. Parte: ' + PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PEDIMPDET.PID_CANT) + ' ' + MEDIDA.ME_CORTO 
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.PID_SEC_IMP = 0 OR
	                      PEDIMPDET.PID_SEC_IMP IS NULL) AND (PEDIMPDET.PID_DEF_TIP = 'S') AND (PEDIMP.PI_CODIGO = @PI_CODIGO) and PEDIMPDET.PID_IMPRIMIR='S'

	
	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     PEDIMP.PI_CODIGO, '* Sin Tratado (Tipo de tasa Bajo Tratado), No. Parte: ' + PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      PEDIMPDET.PID_CANT) + ' ' + MEDIDA.ME_CORTO
	FROM         PEDIMP INNER JOIN
	                      PEDIMPDET ON PEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
	                      MEDIDA ON PEDIMPDET.ME_CODIGO = MEDIDA.ME_CODIGO
	WHERE     (PEDIMPDET.PID_DEF_TIP = 'P') AND (PEDIMP.PI_CODIGO = @PI_CODIGO) AND (PEDIMPDET.SPI_CODIGO = 0 OR
	                      PEDIMPDET.SPI_CODIGO IS NULL) and PEDIMPDET.PID_IMPRIMIR='S'


	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     dbo.PEDIMP.PI_CODIGO, '* Sin Fecha de Vencimiento, No. Parte: ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad: ' + CONVERT(varchar(50), 
	                      dbo.PEDIMPDET.PID_CANT) + ' ' + dbo.MEDIDA.ME_CORTO
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO INNER JOIN
	                      dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED LEFT OUTER JOIN
	                      dbo.MEDIDA ON dbo.PEDIMPDET.ME_CODIGO = dbo.MEDIDA.ME_CODIGO
	WHERE     (dbo.PIDescarga.PID_FECHAVENCE IS NULL)



	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT     dbo.PEDIMP.PI_CODIGO, '* UM Generico = UM Tarifa, Incosistencia en Cantidades ' + dbo.PEDIMPDET.PID_NOPARTE + ' Cantidad Grupo: ' + CONVERT(varchar(50), 
	                      Round(dbo.PEDIMPDET.PID_CAN_GEN,6)) +' Cantidad Tarifa: ' + CONVERT(varchar(50),Round(dbo.PEDIMPDET.PID_CAN_AR,6))
	FROM         dbo.PEDIMP INNER JOIN
	                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO INNER JOIN
	                      dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED 
	WHERE     dbo.PEDIMPDET.ME_GENERICO = dbo.PEDIMPDET.ME_ARIMPMX AND ROUND(dbo.PEDIMPDET.PID_CAN_GEN,6)<>ROUND(dbo.PEDIMPDET.PID_CAN_AR,6)

	INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
	SELECT  pedimp.pi_codigo, '* Sin Tipo de Costo, No. Parte: ' + pedimpdet.pid_noparte + ' Cantidad: ' + CONVERT(varchar(50), PID_CANT)
	FROM pedimp
		INNER JOIN pedimpdet ON pedimp.pi_codigo = pedimpdet.pi_codigo
	WHERE pedimp.pi_codigo = @PI_CODIGO AND (pedimpdet.TCO_CODIGO <= 0 OR pedimpdet.TCO_CODIGO IS NULL) 
	--Se agrego validacion ya que el tipo de costo no se maneja en pedimentos corrientes.
	AND PI_TIPO <> 'C'





	if @sinGrupo='S'
	begin
		INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
		VALUES(@PI_CODIGO, '                      ' )

		INSERT INTO PEDIMPADVERTENCIA(PI_CODIGO, PI_COMENTARIO)
		VALUES(@PI_CODIGO, '* Nota Importante:  Si existen Numeros de parte sin grupo generico el saldo se generara en base a la unidad de medida del Numero de parte en cuestion.' )

	end
















GO
