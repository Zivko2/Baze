SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DatosOriginalesNoParteRetrabajo] (@FUENTE INT,@DESTINO INT)  as

SET NOCOUNT ON 
/* para tabla maestro */
DECLARE @CS_CODIGO INT, @MA_NOMBRE VARCHAR(150), @MA_NAME VARCHAR(150), @MA_TIP_ENS CHAR(1), @ME_COM INT, @ME_ALM INT, 
@EQ_GEN decimal(28,14), @EQ_IMPMX decimal(28,14), @EQ_ALM decimal(28,14), @EQ_EXPMX decimal(28,14), @EQ_IMPFO decimal(28,14), @EQ_RETRA decimal(28,14), @EQ_DESP decimal(28,14), 
@EQ_EXPFO decimal(28,14), @PA_ORIGEN INT, @PA_PROCEDE INT, @MA_CONSTA CHAR(1), @MA_GENERICO INT, @MA_FAMILIA INT, @MA_EXPENS CHAR(1), 
@MA_DEF_TIP CHAR(1), @MA_PESO_KG decimal(38,6), @MA_PESO_LB decimal(38,6), @MA_GRAV_MP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_EMP decimal(38,6), 
@MA_GRAV_GI decimal(38,6), @MA_GRAV_GI_MX decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_EMP decimal(38,6), 
@MA_COSTO decimal(38,6), @MA_GRAVA_VA CHAR(1), @MA_EST_MAT CHAR(1), @MA_MARCA VARCHAR(30), @MA_COLOR VARCHAR(20), @MA_MODELO VARCHAR(30), 
@MP_CODIGO SMALLINT, @MA_EMP_PEL INT,  @MA_IDENTI VARCHAR(30), @AR_IMPMX INT, @AR_EXPMX INT, @AR_IMPFO INT, @AR_RETRA INT, 
@AR_DESP INT, @AR_EXPFO INT, @CX_CODIGO SMALLINT, @MA_TALLA VARCHAR(15), @MA_ESTILO VARCHAR(40), @cft_tipo char(1),
@MA_DISCHARGE CHAR(1), @SE_CODIGO SMALLINT, @MA_SEC_IMP SMALLINT, @SPI_CODIGO SMALLINT, @MA_REPARA CHAR(1), @MA_GENERA_EMP CHAR(1), 
@MA_EMPAQUE INT, @MA_CANTEMP decimal(38,6), @CC_CODIGO INT, @MA_PELIGROSO CHAR(1), @AR_IMPFOUSA INT, @EQ_IMPFOUSA decimal(28,14), @TV_CODIGO INT, @TCO_CODIGO INT,
@ME_CODIGO INT

/* para  tabla nafta*/
declare @NFT_CODIGO INT, @NFT_CLASE int, @NFT_FABRICA int, @NFT_CRITERIO int, @NFT_NETCOST int, 
@NFT_OTRASINST int, @NFT_COSTOSRESTAR decimal(38,6), @NFT_RESOLUCION char(1), @NFT_VERBIENFUNG char(1), @NFT_CONTROLINV char(1), 
@NFT_ORIGBIENFUNG char(1), @NFT_CONTROLINV2 char(1), @NFT_PERSONAREL char(1), @CL_EMPRESA int, @NFT_FECHA datetime, @NFT_TIPOEXP varchar(2), 
@NFT_FECHACERT datetime, @US_CERTIFICADO smallint, @NFT_VCR decimal(38,6), @US_CODIGO smallint, @NFT_COSTO decimal(38,6), @NFT_PRECIO decimal(38,6), @NFT_VCRXVT decimal(38,6),
@NFT_VCRXCN decimal(38,6), @NFT_COSTOTOTALPT decimal(38,6), @NFT_MINIMIS decimal(38,6), @NFT_CALIFICO char(1), @SPI_NAFTA int, @NFT_PERINI datetime, @NFT_PERFIN datetime

/* para  tabla anexo24*/
 declare @ANX_LARGO decimal(38,6), @ANX_ANCHO decimal(38,6), @ANX_DIAME decimal(38,6), @ANX_ALTURA decimal(38,6), @ANX_VID_YEAR int, @ANX_VID_MES int, @ANX_VID_DIA int,
 @ANX_CONT_REG varchar(20), @TCA_CODIGO smallint, @FUN_CODIGO smallint, @ANX_MATERIAL varchar (150)

/* para  tabla maestrocliente*/
declare @CL_CODIGO int, @MC_NOPARTE varchar(30), @MC_GRAV_UNI decimal(38,6), @MC_NG_UNI decimal(38,6), @MC_PRECIO decimal(38,6), @MC_VTR char(1), @MC_NG_MP decimal(38,6), 
@MC_NG_EMP decimal(38,6), @MC_GRAV_MP decimal(38,6), @MC_GRAV_EMP decimal(38,6), @MC_GRAV_GI decimal(38,6), @MC_GRAV_GI_MX decimal(38,6), @MC_GRAV_MO decimal(38,6), @MC_GRAVA_VA char(1),
@CONSECUTIVO int, @mc_codigo int

/* para  tabla maestroaux*/
declare @FCC_CODIGO smallint, @MAX_FCCQTYAPPROVAL char(1), @MAX_FCCIDENTIFIER varchar(20), @MAX_FCCTRADENAME varchar(30), 
@MAX_FCCPUBLICINSPECTION char(1), @FDA_CODIGO smallint, @FDA_PRODCODE varchar(15), @MAX_FDASTORAGE char(1), 
@PA_FDACOUNTRYCODE int, @MAX_FDAMARKER char(3)

/* para  tabla maestroauxdet*/
declare @MAXD_AFFCODE char(3), @MAXD_AFFQUAL varchar(25), @MAXD_CODIGO int

/* para  tabla maestrosust*/
declare @MA_CODIGOSUST int, @EQ_CANT decimal(28,14)

/* para  tabla maestroprovee*/
declare @MV_NOPART_PR VARCHAR(30), @PR_CODIGO INT, @MV_PRINCIPAL CHAR(1), @mv_codigo int, @MV_COS_UNI decimal(38,6), @PA_CODIGO int, 
		@MV_PES_UNIKG decimal(38,6), @MV_DEF_TIP char(1), @MV_POR_DEF decimal(38,6), @SE_PROVEE int, @SPI_PROVEE int

/* para  tabla maestromedida*/
declare @EQ_CANTIDAD decimal(28,14)

	IF EXISTS (SELECT MA_CODIGO FROM MAESTRO WHERE MA_CODIGO=@FUENTE)
                 AND EXISTS (SELECT MA_CODIGO FROM MAESTRO WHERE MA_CODIGO=@DESTINO)
	BEGIN

	declare cur_copiamaestro cursor for
		SELECT     CS_CODIGO, MA_NOMBRE, MA_NAME, MA_TIP_ENS, ME_COM, ME_ALM, EQ_GEN, EQ_IMPMX, EQ_ALM, EQ_EXPMX, EQ_IMPFO, 
             		         EQ_RETRA, EQ_DESP, EQ_EXPFO, PA_ORIGEN, PA_PROCEDE, MA_CONSTA, MA_GENERICO, MA_FAMILIA, MA_EXPENS, MA_DEF_TIP, 
             		          isnull(MA_PESO_KG,0), isnull(MA_PESO_LB,0),
             		         MA_EST_MAT, MA_MARCA, MA_COLOR, MA_MODELO, MP_CODIGO, MA_EMP_PEL, MA_IDENTI, AR_IMPMX, AR_EXPMX, AR_IMPFO, AR_RETRA, 
             		         AR_DESP, AR_EXPFO, CX_CODIGO, MA_TALLA, MA_ESTILO, MA_DISCHARGE, SE_CODIGO, MA_SEC_IMP, MAESTRO.SPI_CODIGO, MA_REPARA, 
	                      MA_GENERA_EMP, MA_EMPAQUE, MA_CANTEMP, CC_CODIGO, MA_PELIGROSO, AR_IMPFOUSA, EQ_IMPFOUSA
		FROM         dbo.MAESTRO 
		where dbo.MAESTRO.ma_codigo = @FUENTE 
	open cur_copiamaestro

	fetch next from cur_copiamaestro into @CS_CODIGO, @MA_NOMBRE, 
	@MA_NAME, @MA_TIP_ENS, @ME_COM, @ME_ALM, @EQ_GEN, @EQ_IMPMX, @EQ_ALM, @EQ_EXPMX, @EQ_IMPFO, @EQ_RETRA, @EQ_DESP, 
	@EQ_EXPFO, @PA_ORIGEN, @PA_PROCEDE, @MA_CONSTA, @MA_GENERICO, @MA_FAMILIA, @MA_EXPENS, @MA_DEF_TIP, @MA_PESO_KG, @MA_PESO_LB, 
	@MA_EST_MAT, @MA_MARCA, @MA_COLOR, @MA_MODELO, @MP_CODIGO, 
	@MA_EMP_PEL, @MA_IDENTI, @AR_IMPMX, @AR_EXPMX, @AR_IMPFO, @AR_RETRA, @AR_DESP, @AR_EXPFO, @CX_CODIGO, 
	@MA_TALLA, @MA_ESTILO, @MA_DISCHARGE, @SE_CODIGO, @MA_SEC_IMP, @SPI_CODIGO, @MA_REPARA, @MA_GENERA_EMP, @MA_EMPAQUE, 
	@MA_CANTEMP, @CC_CODIGO, @MA_PELIGROSO, @AR_IMPFOUSA, @EQ_IMPFOUSA


	while (@@fetch_status = 0)
	begin

		update maestro
		set CS_CODIGO =@CS_CODIGO, MA_NOMBRE = @MA_NOMBRE,  MA_NAME = @MA_NAME,  MA_TIP_ENS = @MA_TIP_ENS, ME_COM = @ME_COM,
		ME_ALM = @ME_ALM, EQ_GEN = @EQ_GEN, EQ_IMPMX = @EQ_IMPMX, EQ_ALM = @EQ_ALM, EQ_EXPMX = @EQ_EXPMX, EQ_IMPFO = @EQ_IMPFO, 
		EQ_RETRA = @EQ_RETRA, EQ_DESP = @EQ_DESP, EQ_EXPFO = @EQ_EXPFO, PA_ORIGEN = @PA_ORIGEN, PA_PROCEDE = @PA_PROCEDE, 
		MA_CONSTA = @MA_CONSTA, MA_GENERICO = @MA_GENERICO, MA_FAMILIA = @MA_FAMILIA, MA_EXPENS = @MA_EXPENS, 
		MA_DEF_TIP = @MA_DEF_TIP, MA_PESO_KG = @MA_PESO_KG, 
		MA_PESO_LB = @MA_PESO_LB, MA_EST_MAT = @MA_EST_MAT, 
		MA_MARCA = @MA_MARCA, MA_COLOR = @MA_COLOR, MA_MODELO = @MA_MODELO, MP_CODIGO = @MP_CODIGO, MA_EMP_PEL = @MA_EMP_PEL, 
		MA_IDENTI = @MA_IDENTI, AR_IMPMX = @AR_IMPMX, AR_EXPMX = @AR_EXPMX, AR_IMPFO = @AR_IMPFO, AR_RETRA = @AR_RETRA, 
		AR_DESP = @AR_DESP, AR_EXPFO = @AR_EXPFO, CX_CODIGO = @CX_CODIGO, MA_TALLA = @MA_TALLA, 
		MA_ESTILO = @MA_ESTILO, MA_DISCHARGE = @MA_DISCHARGE, SE_CODIGO = @SE_CODIGO, MA_SEC_IMP = MA_SEC_IMP, SPI_CODIGO = @SPI_CODIGO, 
		MA_REPARA = @MA_REPARA, MA_GENERA_EMP = @MA_GENERA_EMP, MA_EMPAQUE = @MA_EMPAQUE, 
		MA_CANTEMP = @MA_CANTEMP, CC_CODIGO = @CC_CODIGO, MA_PELIGROSO = @MA_PELIGROSO, AR_IMPFOUSA = @AR_IMPFOUSA, 
		EQ_IMPFOUSA = @EQ_IMPFOUSA
		where ma_codigo = @destino

	
		delete from maestrocost where ma_codigo=@DESTINO
	
		insert into maestrocost (MA_GRAV_MP,  MA_GRAV_ADD, MA_GRAV_EMP, MA_GRAV_GI, MA_GRAV_GI_MX, MA_GRAV_MO, MA_NG_MP,
		MA_NG_ADD, MA_NG_EMP, MA_COSTO, MA_GRAVA_VA, TV_CODIGO, TCO_CODIGO, MA_CODIGO, spi_codigo, ma_perini, ma_perfin)
	             SELECT isnull(MA_GRAV_MP,0), isnull(MA_GRAV_ADD,0),  isnull(MA_GRAV_EMP,0), isnull(MA_GRAV_GI,0), isnull(MA_GRAV_GI_MX,0), isnull(MA_GRAV_MO,0), isnull(MA_NG_MP,0), 
			isnull(MA_NG_ADD,0), isnull(MA_NG_EMP,0), isnull(MA_COSTO,0), isnull(MA_GRAVA_VA,'S'), TV_CODIGO, TCO_CODIGO, @DESTINO, spi_codigo, ma_perini, ma_perfin
		FROM MAESTROCOST WHERE MA_CODIGO=@FUENTE



	fetch next from cur_copiamaestro into @CS_CODIGO, @MA_NOMBRE, 
	@MA_NAME, @MA_TIP_ENS, @ME_COM, @ME_ALM, @EQ_GEN, @EQ_IMPMX, @EQ_ALM, @EQ_EXPMX, @EQ_IMPFO, @EQ_RETRA, @EQ_DESP, 
	@EQ_EXPFO, @PA_ORIGEN, @PA_PROCEDE, @MA_CONSTA, @MA_GENERICO, @MA_FAMILIA, @MA_EXPENS, @MA_DEF_TIP, @MA_PESO_KG, @MA_PESO_LB, 
	@MA_EST_MAT, @MA_MARCA, @MA_COLOR, @MA_MODELO, @MP_CODIGO, 
	@MA_EMP_PEL, @MA_IDENTI, @AR_IMPMX, @AR_EXPMX, @AR_IMPFO, @AR_RETRA, @AR_DESP, @AR_EXPFO, @CX_CODIGO, 
	@MA_TALLA, @MA_ESTILO, @MA_DISCHARGE, @SE_CODIGO, @MA_SEC_IMP, @SPI_CODIGO, @MA_REPARA, @MA_GENERA_EMP, @MA_EMPAQUE, 
	@MA_CANTEMP, @CC_CODIGO, @MA_PELIGROSO, @AR_IMPFOUSA, @EQ_IMPFOUSA
	end

	close cur_copiamaestro
	deallocate cur_copiamaestro


	/*tabla nafta  --------------------------------------------------------------------------------------------------------------------------*/

	declare cur_copianafta cursor for
		SELECT     NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_COSTOSRESTAR, NFT_RESOLUCION, 
	                      NFT_VERBIENFUNG, NFT_CONTROLINV, NFT_ORIGBIENFUNG, NFT_CONTROLINV2, NFT_PERSONAREL, CL_EMPRESA, NFT_FECHA, NFT_TIPOEXP, 
             		         NFT_FECHACERT, US_CERTIFICADO, NFT_VCR, US_CODIGO, NFT_COSTO, NFT_PRECIO, NFT_VCRXVT, NFT_VCRXCN, 
		         NFT_COSTOTOTALPT, NFT_MINIMIS, NFT_CALIFICO, SPI_CODIGO, NFT_PERINI, NFT_PERFIN
		FROM         dbo.NAFTA  where ma_codigo = @fuente

	open cur_copianafta
	fetch next from cur_copianafta into @NFT_CLASE, @NFT_FABRICA, @NFT_CRITERIO, @NFT_NETCOST, @NFT_OTRASINST,
	 @NFT_COSTOSRESTAR, @NFT_RESOLUCION, @NFT_VERBIENFUNG, @NFT_CONTROLINV, @NFT_ORIGBIENFUNG, 
	@NFT_CONTROLINV2, @NFT_PERSONAREL, @CL_EMPRESA, @NFT_FECHA, @NFT_TIPOEXP, 
	@NFT_FECHACERT, @US_CERTIFICADO, @NFT_VCR, @US_CODIGO, @NFT_COSTO, @NFT_PRECIO, @NFT_VCRXVT, @NFT_VCRXCN, 
		         @NFT_COSTOTOTALPT, @NFT_MINIMIS, @NFT_CALIFICO, @SPI_NAFTA, @NFT_PERINI, @NFT_PERFIN

	while (@@fetch_status = 0)
	begin

		IF EXISTS (SELECT MA_CODIGO FROM NAFTA WHERE MA_CODIGO=@DESTINO and spi_codigo=@SPI_NAFTA and nft_perini=@NFT_PERINI)

			UPDATE NAFTA
			SET  NFT_CLASE = @NFT_CLASE, NFT_FABRICA =@NFT_FABRICA, NFT_CRITERIO = @NFT_CRITERIO, NFT_NETCOST = @NFT_NETCOST, 
			NFT_OTRASINST = @NFT_OTRASINST, NFT_COSTOSRESTAR = @NFT_COSTOSRESTAR, NFT_RESOLUCION = @NFT_RESOLUCION, 
	                          NFT_VERBIENFUNG = @NFT_VERBIENFUNG, NFT_CONTROLINV = @NFT_CONTROLINV, NFT_ORIGBIENFUNG = @NFT_ORIGBIENFUNG, 
			NFT_CONTROLINV2 = @NFT_CONTROLINV2, NFT_PERSONAREL = @NFT_PERSONAREL, CL_EMPRESA =@CL_EMPRESA, 
			NFT_FECHA = @NFT_FECHA, NFT_TIPOEXP =@NFT_TIPOEXP,   NFT_FECHACERT =@NFT_FECHACERT, US_CERTIFICADO = @US_CERTIFICADO, 
			NFT_VCR = @NFT_VCR, US_CODIGO =@US_CODIGO, NFT_COSTO=@NFT_COSTO, NFT_PRECIO=@NFT_PRECIO, NFT_VCRXVT=@NFT_VCRXVT, 
			NFT_VCRXCN=@NFT_VCRXCN, NFT_COSTOTOTALPT=@NFT_COSTOTOTALPT, NFT_MINIMIS=@NFT_MINIMIS, NFT_CALIFICO=@NFT_CALIFICO
			WHERE MA_CODIGO = @DESTINO and spi_codigo=@SPI_NAFTA and nft_perini=@NFT_PERINI
		ELSE
		begin
			EXEC  SP_GETCONSECUTIVO 'NFT', @VALUE = @NFT_CODIGO OUTPUT

			INSERT INTO NAFTA (NFT_CODIGO,MA_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_COSTOSRESTAR, NFT_RESOLUCION, 
	                      NFT_VERBIENFUNG, NFT_CONTROLINV, NFT_ORIGBIENFUNG, NFT_CONTROLINV2, NFT_PERSONAREL, CL_EMPRESA, NFT_FECHA, NFT_TIPOEXP, 
             		         NFT_FECHACERT, US_CERTIFICADO, NFT_VCR, US_CODIGO, NFT_COSTO, NFT_PRECIO, NFT_VCRXVT, NFT_VCRXCN, 
		         NFT_COSTOTOTALPT, NFT_MINIMIS, NFT_CALIFICO, SPI_CODIGO, NFT_PERINI, NFT_PERFIN)
			VALUES (@NFT_CODIGO,@DESTINO, @NFT_CLASE, @NFT_FABRICA, @NFT_CRITERIO, @NFT_NETCOST, @NFT_OTRASINST,
			 @NFT_COSTOSRESTAR, @NFT_RESOLUCION, @NFT_VERBIENFUNG, @NFT_CONTROLINV, @NFT_ORIGBIENFUNG, 
			@NFT_CONTROLINV2, @NFT_PERSONAREL, @CL_EMPRESA, @NFT_FECHA, @NFT_TIPOEXP, 
			@NFT_FECHACERT, @US_CERTIFICADO, @NFT_VCR, @US_CODIGO, @NFT_COSTO, @NFT_PRECIO, @NFT_VCRXVT, @NFT_VCRXCN, 
		             @NFT_COSTOTOTALPT, @NFT_MINIMIS, @NFT_CALIFICO, @SPI_NAFTA, @NFT_PERINI, @NFT_PERFIN)
		end

	fetch next from cur_copianafta into @NFT_CLASE, @NFT_FABRICA, @NFT_CRITERIO, @NFT_NETCOST, @NFT_OTRASINST,
	 @NFT_COSTOSRESTAR, @NFT_RESOLUCION, @NFT_VERBIENFUNG, @NFT_CONTROLINV, @NFT_ORIGBIENFUNG, 
	@NFT_CONTROLINV2, @NFT_PERSONAREL, @CL_EMPRESA, @NFT_FECHA, @NFT_TIPOEXP, 
	@NFT_FECHACERT, @US_CERTIFICADO, @NFT_VCR, @US_CODIGO, @NFT_COSTO, @NFT_PRECIO, @NFT_VCRXVT, @NFT_VCRXCN, 
             @NFT_COSTOTOTALPT, @NFT_MINIMIS, @NFT_CALIFICO, @SPI_NAFTA, @NFT_PERINI, @NFT_PERFIN

	end

	close cur_copianafta
	deallocate cur_copianafta



	/*tabla anexo24  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiaanexo24 cursor for
		SELECT     ANX_LARGO, ANX_ANCHO, ANX_DIAME, ANX_ALTURA, ANX_VID_YEAR, ANX_VID_MES, ANX_VID_DIA, ANX_CONT_REG, TCA_CODIGO, FUN_CODIGO, 
		                      ANX_MATERIAL
		FROM         dbo.ANEXO24
		WHERE MA_CODIGO=@FUENTE

		open cur_copiaanexo24

		fetch next from cur_copiaanexo24 into @ANX_LARGO, @ANX_ANCHO, @ANX_DIAME, @ANX_ALTURA, @ANX_VID_YEAR,
		 @ANX_VID_MES, @ANX_VID_DIA, @ANX_CONT_REG, @TCA_CODIGO, @FUN_CODIGO, @ANX_MATERIAL

		while (@@fetch_status = 0)
		begin

		IF EXISTS (SELECT MA_CODIGO FROM ANEXO24 WHERE MA_CODIGO=@DESTINO)
			UPDATE ANEXO24
			SET ANX_LARGO = @ANX_LARGO, ANX_ANCHO = @ANX_ANCHO, ANX_DIAME = @ANX_DIAME, ANX_ALTURA =@ANX_ALTURA, 
			ANX_VID_YEAR =@ANX_VID_YEAR, ANX_VID_MES =@ANX_VID_MES, ANX_VID_DIA =@ANX_VID_DIA, ANX_CONT_REG =@ANX_CONT_REG, TCA_CODIGO =@TCA_CODIGO, FUN_CODIGO =@FUN_CODIGO, 
		                      ANX_MATERIAL = @ANX_MATERIAL
			WHERE MA_CODIGO=@DESTINO
		ELSE
			INSERT INTO ANEXO24 (MA_CODIGO, ANX_LARGO, ANX_ANCHO, ANX_DIAME, ANX_ALTURA, ANX_VID_YEAR, ANX_VID_MES, ANX_VID_DIA, ANX_CONT_REG, TCA_CODIGO, FUN_CODIGO, 
		                      ANX_MATERIAL)
			VALUES(@DESTINO, @ANX_LARGO, @ANX_ANCHO, @ANX_DIAME, @ANX_ALTURA, @ANX_VID_YEAR,
			 @ANX_VID_MES, @ANX_VID_DIA, @ANX_CONT_REG, @TCA_CODIGO, @FUN_CODIGO, @ANX_MATERIAL)

		fetch next from cur_copiaanexo24 into @ANX_LARGO, @ANX_ANCHO, @ANX_DIAME, @ANX_ALTURA, @ANX_VID_YEAR,
		 @ANX_VID_MES, @ANX_VID_DIA, @ANX_CONT_REG, @TCA_CODIGO, @FUN_CODIGO, @ANX_MATERIAL

		end

		close cur_copiaanexo24
		deallocate cur_copiaanexo24


	/*tabla maestrocliente  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiamaestrocliente cursor for
		     SELECT     CL_CODIGO, MC_NOPARTE, MC_GRAV_UNI, MC_NG_UNI, MC_PRECIO, MC_VTR, MC_NG_MP, MC_NG_EMP, MC_GRAV_MP, MC_GRAV_EMP, 
	                      MC_GRAV_GI, MC_GRAV_GI_MX, MC_GRAV_MO, MC_GRAVA_VA
		FROM         dbo.MAESTROCLIENTE WHERE MA_CODIGO=@FUENTE

		open cur_copiamaestrocliente

		fetch next from cur_copiamaestrocliente into @CL_CODIGO, @MC_NOPARTE, @MC_GRAV_UNI, @MC_NG_UNI, @MC_PRECIO, 
		@MC_VTR, @MC_NG_MP, @MC_NG_EMP, @MC_GRAV_MP, @MC_GRAV_EMP, @MC_GRAV_GI, @MC_GRAV_GI_MX, 
		@MC_GRAV_MO, @MC_GRAVA_VA

		while (@@fetch_status = 0)
		begin

			IF EXISTS (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE MA_CODIGO=@DESTINO)
				delete from maestrocliente where ma_codigo=@destino
			else
				begin
					SELECT @CONSECUTIVO=ISNULL(MAX(MC_CODIGO),0) FROM MAESTROCLIENTE 
		
					SET @CONSECUTIVO=@CONSECUTIVO+1

					insert into maestrocliente(MA_CODIGO, MC_CODIGO, CL_CODIGO, MC_NOPARTE, MC_GRAV_UNI, MC_NG_UNI, MC_PRECIO, MC_VTR, MC_NG_MP, MC_NG_EMP, MC_GRAV_MP, MC_GRAV_EMP, 
			             		         MC_GRAV_GI, MC_GRAV_GI_MX, MC_GRAV_MO, MC_GRAVA_VA)
					values (@DESTINO, @CONSECUTIVO, @CL_CODIGO, @MC_NOPARTE, @MC_GRAV_UNI, @MC_NG_UNI, @MC_PRECIO, 
					@MC_VTR, @MC_NG_MP, @MC_NG_EMP, @MC_GRAV_MP, @MC_GRAV_EMP, @MC_GRAV_GI, @MC_GRAV_GI_MX, 
					@MC_GRAV_MO, @MC_GRAVA_VA)
				end

		fetch next from cur_copiamaestrocliente into @CL_CODIGO, @MC_NOPARTE, @MC_GRAV_UNI, @MC_NG_UNI, @MC_PRECIO, 
		@MC_VTR, @MC_NG_MP, @MC_NG_EMP, @MC_GRAV_MP, @MC_GRAV_EMP, @MC_GRAV_GI, @MC_GRAV_GI_MX, 
		@MC_GRAV_MO, @MC_GRAVA_VA

		end

		close cur_copiamaestrocliente
		deallocate cur_copiamaestrocliente

		select @mc_codigo= max(mc_codigo) from maestrocliente

		update consecutivo
		set cv_codigo =  isnull(@mc_codigo,0) + 1
		where cv_tipo = 'MC'


	/*tabla maestroaux  --------------------------------------------------------------------------------------------------------------------------*/
		
		declare cur_copiaMaestroAux cursor for
		SELECT     FCC_CODIGO, MAX_FCCQTYAPPROVAL, MAX_FCCIDENTIFIER, MAX_FCCTRADENAME, MAX_FCCPUBLICINSPECTION, 
			FDA_CODIGO, FDA_PRODCODE, MAX_FDASTORAGE, PA_FDACOUNTRYCODE, MAX_FDAMARKER
		FROM         dbo.MAESTROAUX
		WHERE MA_CODIGO=@FUENTE

		open cur_copiaMaestroAux
	
		fetch next from cur_copiaMaestroAux into @FCC_CODIGO, @MAX_FCCQTYAPPROVAL, @MAX_FCCIDENTIFIER, @MAX_FCCTRADENAME, 
			@MAX_FCCPUBLICINSPECTION, @FDA_CODIGO, @FDA_PRODCODE, @MAX_FDASTORAGE, @PA_FDACOUNTRYCODE, @MAX_FDAMARKER

		while (@@fetch_status = 0)
		begin

			IF EXISTS (SELECT MA_CODIGO FROM MAESTROAUX WHERE MA_CODIGO=@DESTINO)
				update maestroaux
				set FCC_CODIGO=@FCC_CODIGO, MAX_FCCQTYAPPROVAL=@MAX_FCCQTYAPPROVAL, MAX_FCCIDENTIFIER=@MAX_FCCIDENTIFIER, 
				MAX_FCCTRADENAME=@MAX_FCCTRADENAME, MAX_FCCPUBLICINSPECTION=@MAX_FCCPUBLICINSPECTION, 
				FDA_CODIGO =@FDA_CODIGO, FDA_PRODCODE=@FDA_PRODCODE, MAX_FDASTORAGE=@MAX_FDASTORAGE, 
				PA_FDACOUNTRYCODE=@PA_FDACOUNTRYCODE, MAX_FDAMARKER=@MAX_FDAMARKER
				where ma_codigo=@destino
			else
				insert into maestroaux (MA_CODIGO, FCC_CODIGO, MAX_FCCQTYAPPROVAL, MAX_FCCIDENTIFIER, MAX_FCCTRADENAME, MAX_FCCPUBLICINSPECTION, 
				FDA_CODIGO, FDA_PRODCODE, MAX_FDASTORAGE, PA_FDACOUNTRYCODE, MAX_FDAMARKER)
				values(@DESTINO, @FCC_CODIGO, @MAX_FCCQTYAPPROVAL, @MAX_FCCIDENTIFIER, @MAX_FCCTRADENAME, 
				@MAX_FCCPUBLICINSPECTION, @FDA_CODIGO, @FDA_PRODCODE, @MAX_FDASTORAGE, @PA_FDACOUNTRYCODE, @MAX_FDAMARKER)

		fetch next from cur_copiaMaestroAux into @FCC_CODIGO, @MAX_FCCQTYAPPROVAL, @MAX_FCCIDENTIFIER, @MAX_FCCTRADENAME, 
			@MAX_FCCPUBLICINSPECTION, @FDA_CODIGO, @FDA_PRODCODE, @MAX_FDASTORAGE, @PA_FDACOUNTRYCODE, @MAX_FDAMARKER

		end

		close cur_copiaMaestroAux
		deallocate cur_copiaMaestroAux

	/*tabla maestroauxdet  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiamaestroauxdet cursor for
		SELECT     MAXD_AFFCODE, MAXD_AFFQUAL, MAXD_CODIGO
		FROM         dbo.MAESTROAUXDET
		open cur_copiamaestroauxdet
		fetch next from cur_copiamaestroauxdet into @MAXD_AFFCODE, @MAXD_AFFQUAL, @MAXD_CODIGO

		while (@@fetch_status = 0)
		begin

			IF EXISTS (SELECT *  FROM MAESTROAUXDET WHERE MA_CODIGO=@DESTINO)
				update maestroauxdet
				set MAXD_AFFCODE =@MAXD_AFFCODE, MAXD_AFFQUAL=@MAXD_AFFQUAL, MAXD_CODIGO=@MAXD_CODIGO
				where ma_codigo=@destino
			else
			
				begin

					SELECT @CONSECUTIVO=ISNULL(MAX(MAXD_CODIGO),0) FROM MAESTROAUXDET 

					SET @CONSECUTIVO=@CONSECUTIVO+1

					INSERT INTO MAESTROAUXDET (MAXD_CODIGO, MA_CODIGO, MAXD_AFFCODE, MAXD_AFFQUAL)
					VALUES (@CONSECUTIVO, @DESTINO, @MAXD_AFFCODE, @MAXD_AFFQUAL)

				end
		fetch next from cur_copiamaestroauxdet into @MAXD_AFFCODE, @MAXD_AFFQUAL, @MAXD_CODIGO

		end

		close cur_copiaMaestroAuxdet
		deallocate cur_copiaMaestroAuxdet

		select @maxd_codigo= max(maxd_codigo) from maestroauxdet

		update consecutivo
		set cv_codigo =  isnull(@maxd_codigo,0) + 1
		where cv_tipo = 'MAXD'


	/*tabla maestrosust  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiamaestrosust cursor for

		SELECT     MA_CODIGOSUST, EQ_CANT
		FROM         dbo.MAESTROSUST
		WHERE MA_CODIGO =@FUENTE
		open cur_copiamaestrosust
	
		fetch next from cur_copiamaestrosust into @MA_CODIGOSUST, @EQ_CANT

		while (@@fetch_status = 0)
		begin

		IF EXISTS (SELECT MA_CODIGO FROM MAESTROSUST WHERE MA_CODIGO=@DESTINO)		
			update maestrosust
			set MA_CODIGOSUST =@MA_CODIGOSUST, EQ_CANT=@EQ_CANT
			where ma_codigo=@destino
		ELSE
			INSERT INTO MAESTROSUST (MA_CODIGO, MA_CODIGOSUST, EQ_CANT)
			VALUES (@DESTINO, @MA_CODIGOSUST, @EQ_CANT)
			

		fetch next from cur_copiamaestrosust into @MA_CODIGOSUST, @EQ_CANT

		end
		
		close cur_copiaMaestrosust
		deallocate cur_copiaMaestrosust

	/*tabla maestroprovee  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiamaestroprovee cursor for
			SELECT     MV_NOPART_PR, PR_CODIGO, MV_PRINCIPAL, MV_COS_UNI, PA_CODIGO, 
			MV_PES_UNIKG, MV_DEF_TIP, SE_CODIGO, SPI_CODIGO
			FROM         dbo.MAESTROPROVEE where ma_codigo=@fuente
		open cur_copiamaestroprovee

		fetch next from cur_copiamaestroprovee into @MV_NOPART_PR, @PR_CODIGO, @MV_PRINCIPAL, @MV_COS_UNI, @PA_CODIGO, 
		@MV_PES_UNIKG, @MV_DEF_TIP, @SE_PROVEE, @SPI_PROVEE

		while (@@fetch_status = 0)
		begin
			IF EXISTS (SELECT MA_CODIGO FROM dbo.MAESTROPROVEE WHERE MA_CODIGO=@DESTINO and PR_CODIGO=@PR_CODIGO)		
			update maestroprovee
			set MV_NOPART_PR = @MV_NOPART_PR,
			PR_CODIGO=@PR_CODIGO, MV_PRINCIPAL=@MV_PRINCIPAL where ma_codigo=@destino
			else
			begin

				SELECT @CONSECUTIVO=ISNULL(MAX(MV_CODIGO),0) FROM MAESTROPROVEE
			
				SET @CONSECUTIVO=@CONSECUTIVO+1

				insert into maestroprovee (MV_CODIGO, MA_CODIGO, MV_NOPART_PR, PR_CODIGO, MV_PRINCIPAL, MV_COS_UNI, PA_CODIGO, 
				MV_PES_UNIKG, MV_DEF_TIP, SE_CODIGO, SPI_CODIGO)

				values (@CONSECUTIVO, @DESTINO, @MV_NOPART_PR, @PR_CODIGO, @MV_PRINCIPAL, @MV_COS_UNI, @PA_CODIGO, 
				@MV_PES_UNIKG, @MV_DEF_TIP, @SE_PROVEE, @SPI_PROVEE)
			end
		fetch next from cur_copiamaestroprovee into @MV_NOPART_PR, @PR_CODIGO, @MV_PRINCIPAL, @MV_COS_UNI, @PA_CODIGO, 
		@MV_PES_UNIKG, @MV_DEF_TIP, @SE_PROVEE, @SPI_PROVEE
		end

		select @mv_codigo= max(mv_codigo) from maestroprovee

		update consecutivo
		set cv_codigo =  isnull(@mv_codigo,0) + 1
		where cv_tipo = 'MV'

		
		close cur_copiamaestroprovee
		deallocate cur_copiamaestroprovee


	/*tabla maestromedida  --------------------------------------------------------------------------------------------------------------------------*/

		declare cur_copiamaestromedida cursor for
		SELECT    ME_CODIGO, EQ_CANTIDAD, EQ_IMPMX, EQ_EXPFO
		FROM         dbo.MAESTROMEDIDA where ma_codigo=@fuente
		open cur_copiamaestromedida

		fetch next from cur_copiamaestromedida into @ME_CODIGO, @EQ_CANTIDAD, @EQ_IMPMX, @EQ_EXPFO

		while (@@fetch_status = 0)
		begin
			IF EXISTS (SELECT MA_CODIGO FROM dbo.MAESTROMEDIDA WHERE MA_CODIGO=@DESTINO)				
				UPDATE MAESTROMEDIDA
				SET ME_CODIGO =@ME_CODIGO, EQ_CANTIDAD =@EQ_CANTIDAD, 
				EQ_IMPMX =@EQ_IMPMX, EQ_EXPFO=@EQ_EXPFO WHERE MA_CODIGO=@DESTINO
			ELSE 
				INSERT INTO MAESTROMEDIDA (MA_CODIGO, ME_CODIGO, EQ_CANTIDAD, EQ_IMPMX, EQ_EXPFO)
				VALUES (@DESTINO, @ME_CODIGO, @EQ_CANTIDAD, @EQ_IMPMX, @EQ_EXPFO)
			
		fetch next from cur_copiamaestromedida into @ME_CODIGO, @EQ_CANTIDAD, @EQ_IMPMX, @EQ_EXPFO
		end

		close cur_copiamaestromedida
		deallocate cur_copiamaestromedida
		
	END


GO
