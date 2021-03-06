SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































/* insercion de materia prima */

CREATE PROCEDURE [dbo].[SP_FILLPERMISODET]  @pecodigo int   as

SET NOCOUNT ON 
DECLARE @PED_INDICED INT,@PE_CODIGO INT, @PED_REGISTROTIPO SMALLINT, @MA_GENERICO INT , @MA_NOPARTE varchar(30), 
	@PED_NOMBRE VARCHAR(150), @TI_CODIGO INT, @ME_COM INT , @AR_IMPMX INT , @PED_ID_SUBORD INT , @VALUE INT, 
	@CONSECUTIVO INT, @SE_CODIGO INT, @PED_COSTO decimal(38,6)

DELETE FROM PERMISODET WHERE PE_CODIGO=@pecodigo AND PED_REGISTROTIPO=1 AND PED_ID_SUBORD<>0


	EXEC SP_FILLPERMISOMP  @pecodigo


CREATE TABLE [dbo].[#PERMISOTEMPORAL]
(	
	PE_CODIGO INT,
	PED_REGISTROTIPO SMALLINT,
	MA_GENERICO INT,
	MA_NOPARTE VARCHAR(30),
	PED_NOMBRE VARCHAR(150),
	PED_OBSERVA TEXT,
	TI_CODIGO SMALLINT,
	ME_COM INT,
	AR_IMPMX INT,
	AR_EXPMX INT,
	PED_ID_SUBORD INT,
	PED_CONSECUTIVO INT IDENTITY (1, 1) NOT NULL ,
	PED_COSTO decimal(38,6)
)


	SELECT @CONSECUTIVO=ISNULL(MAX(PED_CONSECUTIVO),0) FROM PERMISODET  WHERE PE_CODIGO=@pecodigo AND PED_REGISTROTIPO=1 AND PED_ID_SUBORD=@PED_ID_SUBORD

	SET @CONSECUTIVO=@CONSECUTIVO+1
	dbcc checkident (#PERMISOTEMPORAL, @CONSECUTIVO, reseed) WITH NO_INFOMSGS


	INSERT INTO #PERMISOTEMPORAL(PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE,
		PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_COSTO)

	SELECT     PERMISODET.PE_CODIGO, PERMISODET.PED_REGISTROTIPO, MAESTROCATEG_1.CPE_CODIGO, CATEGPERMISO.CPE_CORTO, 
	                      CATEGPERMISO.CPE_DESC, CATEGPERMISO.TI_CODIGO, CATEGPERMISO.ME_CODIGO, CATEGPERMISO.AR_CODIGO, 
	                      PERMISODET.PED_INDICED AS PED_ID_SUBORD, CATEGPERMISO.CPE_COSTO AS PED_COSTO
	FROM         MAESTROCATEG MAESTROCATEG_1 INNER JOIN
	                      PERMISODET INNER JOIN
	                      MAESTROCATEG ON PERMISODET.MA_GENERICO = MAESTROCATEG.CPE_CODIGO INNER JOIN
	                      TempBOM_CALCULABASE ON MAESTROCATEG.MA_CODIGO = TempBOM_CALCULABASE.BST_PT ON 
	                      MAESTROCATEG_1.MA_CODIGO = TempBOM_CALCULABASE.BST_HIJO INNER JOIN
	                      CATEGPERMISO ON MAESTROCATEG_1.CPE_CODIGO = CATEGPERMISO.CPE_CODIGO
	WHERE CATEGPERMISO.IDE_CODIGO IS NULL OR  CATEGPERMISO.IDE_CODIGO IN 
		(SELECT IDE_CODIGO FROM IDENTIFICA WHERE IDE_CLAVE='MQ' OR IDE_CLAVE='PX')
	GROUP BY TempBOM_CALCULABASE.BST_DISCH, PERMISODET.PED_ID_SUBORD, PERMISODET.PED_REGISTROTIPO, 
	                      PERMISODET.PED_INDICED, PERMISODET.PE_CODIGO, MAESTROCATEG_1.CPE_CODIGO, CATEGPERMISO.CPE_CORTO, 
	                      CATEGPERMISO.CPE_DESC, CATEGPERMISO.TI_CODIGO, CATEGPERMISO.ME_CODIGO, CATEGPERMISO.AR_CODIGO, 
	                      CATEGPERMISO.CPE_COSTO
	HAVING      (PERMISODET.PED_REGISTROTIPO = 1) AND (PERMISODET.PED_ID_SUBORD = 0) AND (PERMISODET.PE_CODIGO = @pecodigo) AND 
	                      (TempBOM_CALCULABASE.BST_DISCH = 'S') AND (MAESTROCATEG_1.CPE_CODIGO IS NOT NULL)

	

/*	DECLARE CUR_PEDIMPTEMP CURSOR FOR
	SELECT     dbo.PERMISODET.PE_CODIGO, dbo.PERMISODET.PED_REGISTROTIPO, MAESTRO1.MA_CODIGO, MAESTRO1.MA_NOPARTE, 
             		         MAESTRO1.MA_NOMBRE, MAESTRO1.TI_CODIGO, MAESTRO1.ME_COM, MAESTRO1.AR_IMPMX, 
	                      dbo.PERMISODET.PED_INDICED AS PED_ID_SUBORD, VMAESTROCOST.MA_COSTO AS PED_COSTO
	FROM         dbo.PERMISODET LEFT OUTER JOIN
             		         dbo.MAESTRO MAESTRO_2 LEFT OUTER JOIN
	                      dbo.TempBOM_CALCULABASE ON MAESTRO_2.MA_CODIGO = dbo.TempBOM_CALCULABASE.BST_PT LEFT OUTER JOIN
             		         dbo.MAESTRO MAESTRO_1 ON dbo.TempBOM_CALCULABASE.BST_HIJO = MAESTRO_1.MA_CODIGO ON 
	                      dbo.PERMISODET.MA_GENERICO = MAESTRO_2.MA_GENERICO LEFT OUTER JOIN
             		         dbo.MAESTRO MAESTRO1 ON MAESTRO_1.MA_GENERICO = MAESTRO1.MA_CODIGO LEFT OUTER JOIN 
		         VMAESTROCOST ON MAESTRO1.MA_CODIGO=VMAESTROCOST.MA_CODIGO
	GROUP BY dbo.TempBOM_CALCULABASE.BST_DISCH, dbo.PERMISODET.PED_ID_SUBORD, dbo.PERMISODET.PED_REGISTROTIPO, 
             		         dbo.PERMISODET.PED_INDICED, dbo.PERMISODET.PE_CODIGO, MAESTRO1.MA_CODIGO, MAESTRO1.MA_NOPARTE, MAESTRO1.MA_NOMBRE, 
	                      MAESTRO1.TI_CODIGO, MAESTRO1.ME_COM, MAESTRO1.AR_IMPMX, MAESTRO1.MA_INV_GEN, MAESTRO1.MA_EST_MAT, VMAESTROCOST.MA_COSTO
	HAVING      (dbo.PERMISODET.PED_REGISTROTIPO = 1) AND (dbo.PERMISODET.PED_ID_SUBORD = 0) AND (MAESTRO1.MA_CODIGO IS NOT NULL) AND 
             		         (dbo.PERMISODET.PE_CODIGO = @pecodigo) AND (MAESTRO1.MA_INV_GEN = 'G') AND (dbo.TempBOM_CALCULABASE.BST_DISCH = 'S')



	OPEN CUR_PEDIMPTEMP
		
	FETCH NEXT FROM CUR_PEDIMPTEMP INTO @PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE , @PED_NOMBRE, 
						@TI_CODIGO, @ME_COM, @AR_IMPMX , @PED_ID_SUBORD, @PED_COSTO
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	SELECT @CONSECUTIVO=ISNULL(MAX(PED_CONSECUTIVO),0) FROM PERMISODET  WHERE PE_CODIGO=@pecodigo AND PED_REGISTROTIPO=1 AND PED_ID_SUBORD=@PED_ID_SUBORD

	SET @CONSECUTIVO=@CONSECUTIVO+1

		INSERT INTO #PERMISOTEMPORAL(PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE,
			PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_CONSECUTIVO, PED_COSTO)
		VALUES
			(@PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE, @PED_NOMBRE, @TI_CODIGO, @ME_COM, @AR_IMPMX, @PED_ID_SUBORD, @CONSECUTIVO, @PED_COSTO)

		FETCH NEXT FROM CUR_PEDIMPTEMP INTO @PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE , @PED_NOMBRE, 
							@TI_CODIGO, @ME_COM, @AR_IMPMX , @PED_ID_SUBORD, @PED_COSTO

	END


	CLOSE CUR_PEDIMPTEMP
	DEALLOCATE CUR_PEDIMPTEMP*/


/*==================================*/


	DECLARE CUR_PERMISO CURSOR FOR

	SELECT PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE, PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_COSTO FROM #PERMISOTEMPORAL
	GROUP BY PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE, PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_CONSECUTIVO, PED_COSTO

	OPEN CUR_PERMISO
	FETCH NEXT FROM CUR_PERMISO INTO @PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE, @PED_NOMBRE, @TI_CODIGO, @ME_COM, 
					     @AR_IMPMX, @PED_ID_SUBORD, @PED_COSTO
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		EXEC SP_GETCONSECUTIVO 'PED', @VALUE = @PED_INDICED OUTPUT

		SELECT @CONSECUTIVO=ISNULL(MAX(PED_CONSECUTIVO),0) FROM PERMISODET WHERE PE_CODIGO=@pecodigo
		AND PED_REGISTROTIPO=1 AND PED_ID_SUBORD=@PED_ID_SUBORD

		SET @CONSECUTIVO=@CONSECUTIVO+1


		SELECT @SE_CODIGO = SE_CODIGO FROM PERMISODET WHERE PED_INDICED = @PED_ID_SUBORD

		INSERT INTO PERMISODET(PED_INDICED, PE_CODIGO, PED_REGISTROTIPO, MA_GENERICO, MA_NOPARTE,
				PED_NOMBRE, TI_CODIGO, ME_COM, AR_IMPMX, PED_ID_SUBORD, PED_CONSECUTIVO, PED_COSTO)
		VALUES
			(@PED_INDICED, @PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE, @PED_NOMBRE, @TI_CODIGO, @ME_COM, @AR_IMPMX, @PED_ID_SUBORD, @CONSECUTIVO, @PED_COSTO)

		UPDATE PERMISODET
		SET SE_CODIGO = @SE_CODIGO
		WHERE PE_CODIGO =@PE_CODIGO AND PED_ID_SUBORD = @PED_ID_SUBORD


		FETCH NEXT FROM CUR_PERMISO INTO @PE_CODIGO, @PED_REGISTROTIPO, @MA_GENERICO, @MA_NOPARTE , @PED_NOMBRE, 
							@TI_CODIGO, @ME_COM, @AR_IMPMX , @PED_ID_SUBORD, @PED_COSTO
	END

	CLOSE CUR_PERMISO
	DEALLOCATE CUR_PERMISO

	DELETE #PERMISOTEMPORAL


TRUNCATE TABLE TempBOM_CALCULABASE



select @Ped_indiced= max(ped_indiced) from permisodet

	update consecutivo
	set cv_codigo =  isnull(@ped_indiced,0) + 1
	where cv_tipo = 'PED'






























GO
