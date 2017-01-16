SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* Actualiza los numeros de parte deacuerdo al grupo generico  -- forma actualizacion de datos*/
CREATE PROCEDURE dbo.SP_UPDATE_RELNPGENERICO (@DESCING INTEGER, @DESCESP INTEGER, @PAORIGEN INTEGER, @PAPROCEDE INTEGER, @AR INTEGER, @RATE INTEGER, @CONST INTEGER, @UM INTEGER, @EQGEN INTEGER, @CONFECHA CHAR(1), @FECHA Varchar(25)) with encryption as
SET NOCOUNT ON 

	if @CONFECHA='N'
	begin

		IF @DESCESP=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_NOMBRE= ISNULL(.MAESTRO_1.MA_NOMBRE, dbo.MAESTRO.MA_NOMBRE) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @DESCING=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_NAME= ISNULL(MAESTRO_1.MA_NAME, dbo.MAESTRO.MA_NAME) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @PAORIGEN=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.PA_ORIGEN= ISNULL(MAESTRO_1.PA_ORIGEN, dbo.MAESTRO.PA_ORIGEN) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @PAPROCEDE=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.PA_PROCEDE= ISNULL(MAESTRO_1.PA_PROCEDE, dbo.MAESTRO.PA_PROCEDE) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @AR=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPMX= ISNULL(MAESTRO_1.AR_IMPMX,  dbo.MAESTRO.AR_IMPMX) ,
		dbo.MAESTRO.AR_EXPMX= ISNULL(MAESTRO_1.AR_EXPMX,  dbo.MAESTRO.AR_EXPMX) ,
		dbo.MAESTRO.AR_IMPFO= ISNULL(MAESTRO_1.AR_IMPFO,  dbo.MAESTRO.AR_IMPFO),
	 	dbo.MAESTRO.AR_RETRA= ISNULL(MAESTRO_1.AR_RETRA,  dbo.MAESTRO.AR_RETRA),
	 	dbo.MAESTRO.AR_DESP= ISNULL(MAESTRO_1.AR_DESP,  dbo.MAESTRO.AR_DESP),
	 	dbo.MAESTRO.AR_EXPFO= ISNULL(MAESTRO_1.AR_EXPFO,  dbo.MAESTRO.AR_EXPFO)
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @RATE=1
		begin
/*			UPDATE dbo.MAESTRO
			SET     --dbo.MAESTRO.MA_DEF_TIP= ISNULL(MAESTRO_1.MA_DEF_TIP, dbo.MAESTRO.MA_DEF_TIP), 
		             --dbo.MAESTRO.MA_POR_DEF= ISNULL(MAESTRO_1.MA_POR_DEF, dbo.MAESTRO.MA_POR_DEF), 
			dbo.MAESTRO.MA_RATEIMPFO= ISNULL(MAESTRO_1.MA_RATEIMPFO, dbo.MAESTRO.MA_RATEIMPFO),
			dbo.MAESTRO.MA_RATERETRA= ISNULL(MAESTRO_1.MA_RATERETRA, dbo.MAESTRO.MA_RATERETRA),
			dbo.MAESTRO.MA_RATEDESP= ISNULL(MAESTRO_1.MA_RATEDESP, dbo.MAESTRO.MA_RATEDESP),
			dbo.MAESTRO.MA_RATEEXPFO= ISNULL(MAESTRO_1.MA_RATEEXPFO, dbo.MAESTRO.MA_RATEEXPFO)
			FROM         dbo.MAESTRO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
			WHERE dbo.MAESTRO.MA_GENERICO<>0
*/

			-- actualiza tasas
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= ARANCEL.AR_ADVDEF,*/ MAESTRO.SPI_CODIGO=0, 
			MAESTRO.MA_SEC_IMP=0 
			FROM  MAESTRO INNER JOIN 
			  ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO 
			WHERE     (MAESTRO.MA_DEF_TIP = 'G') 
			
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= ARANCEL.AR_PORCENT_8VA, */ MAESTRO.SPI_CODIGO=0, 
			MAESTRO.MA_SEC_IMP=0 
			FROM  MAESTRO INNER JOIN 
			  ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO 
			WHERE     (MAESTRO.MA_DEF_TIP = 'R') 
		
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= PAISARA.PAR_BEN,*/ MAESTRO.MA_SEC_IMP=0, MAESTRO.SPI_CODIGO=22 
			FROM MAESTRO INNER JOIN 
			PAISARA ON MAESTRO.AR_IMPMX = PAISARA.AR_CODIGO AND MAESTRO.PA_ORIGEN = PAISARA.PA_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'P') 
			AND MAESTRO.PA_ORIGEN =233
		
		
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= PAISARA.PAR_BEN,*/ MAESTRO.MA_SEC_IMP=0
			FROM MAESTRO INNER JOIN 
			PAISARA ON MAESTRO.AR_IMPMX = PAISARA.AR_CODIGO AND MAESTRO.SPI_CODIGO = PAISARA.SPI_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'P') 
			AND MAESTRO.PA_ORIGEN <>233
		
		
		
			UPDATE MAESTRO
			SET     MAESTRO.MA_SEC_IMP= (SELECT SE_CODIGO FROM CONFIGURACION)
			FROM         MAESTRO
			WHERE     (MAESTRO.MA_DEF_TIP = 'S') AND (MAESTRO.MA_SEC_IMP = 0 OR
			                      MAESTRO.MA_SEC_IMP IS NULL) 
		
		
			UPDATE MAESTRO  
			SET   /*MAESTRO.MA_POR_DEF= SECTORARA.SA_PORCENT,*/ MAESTRO.SPI_CODIGO=0 
			FROM  MAESTRO INNER JOIN 
			 SECTORARA ON MAESTRO.AR_IMPMX = SECTORARA.AR_CODIGO AND 
			 MAESTRO.MA_SEC_IMP = SECTORARA.SE_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'S') 
		
		
		end
	
		IF @CONST=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_CONSTA= ISNULL(MAESTRO_1.MA_CONSTA, dbo.MAESTRO.MA_CONSTA) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @UM=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.ME_COM= ISNULL(MAESTRO_1.ME_COM, dbo.MAESTRO.ME_COM) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0
	
	
		IF @EQGEN=1
		EXEC SP_ACTUALIZAEQGENALL
	end
	else -- usando fecha
	begin
		IF @DESCESP=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_NOMBRE= ISNULL(.MAESTRO_1.MA_NOMBRE, dbo.MAESTRO.MA_NOMBRE) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @DESCING=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_NAME= ISNULL(MAESTRO_1.MA_NAME, dbo.MAESTRO.MA_NAME) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @PAORIGEN=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.PA_ORIGEN= ISNULL(MAESTRO_1.PA_ORIGEN, dbo.MAESTRO.PA_ORIGEN) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @PAPROCEDE=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.PA_PROCEDE= ISNULL(MAESTRO_1.PA_PROCEDE, dbo.MAESTRO.PA_PROCEDE) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @AR=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.AR_IMPMX= ISNULL(MAESTRO_1.AR_IMPMX,  dbo.MAESTRO.AR_IMPMX) ,
		dbo.MAESTRO.AR_EXPMX= ISNULL(MAESTRO_1.AR_EXPMX,  dbo.MAESTRO.AR_EXPMX) ,
		dbo.MAESTRO.AR_IMPFO= ISNULL(MAESTRO_1.AR_IMPFO,  dbo.MAESTRO.AR_IMPFO),
	 	dbo.MAESTRO.AR_RETRA= ISNULL(MAESTRO_1.AR_RETRA,  dbo.MAESTRO.AR_RETRA),
	 	dbo.MAESTRO.AR_DESP= ISNULL(MAESTRO_1.AR_DESP,  dbo.MAESTRO.AR_DESP),
	 	dbo.MAESTRO.AR_EXPFO= ISNULL(MAESTRO_1.AR_EXPFO,  dbo.MAESTRO.AR_EXPFO)
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @RATE=1
		begin
/*			UPDATE dbo.MAESTRO
			SET     --dbo.MAESTRO.MA_DEF_TIP= ISNULL(MAESTRO_1.MA_DEF_TIP, dbo.MAESTRO.MA_DEF_TIP), 
		             --dbo.MAESTRO.MA_POR_DEF= ISNULL(MAESTRO_1.MA_POR_DEF, dbo.MAESTRO.MA_POR_DEF), 
			dbo.MAESTRO.MA_RATEIMPFO= ISNULL(MAESTRO_1.MA_RATEIMPFO, dbo.MAESTRO.MA_RATEIMPFO),
			dbo.MAESTRO.MA_RATERETRA= ISNULL(MAESTRO_1.MA_RATERETRA, dbo.MAESTRO.MA_RATERETRA),
			dbo.MAESTRO.MA_RATEDESP= ISNULL(MAESTRO_1.MA_RATEDESP, dbo.MAESTRO.MA_RATEDESP),
			dbo.MAESTRO.MA_RATEEXPFO= ISNULL(MAESTRO_1.MA_RATEEXPFO, dbo.MAESTRO.MA_RATEEXPFO)
			FROM         dbo.MAESTRO LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
			WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
*/

			-- actualiza tasas
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= ARANCEL.AR_ADVDEF,*/ MAESTRO.SPI_CODIGO=0, 
			MAESTRO.MA_SEC_IMP=0 
			FROM  MAESTRO INNER JOIN 
			  ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO 
			WHERE     (MAESTRO.MA_DEF_TIP = 'G') 
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
			
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= ARANCEL.AR_PORCENT_8VA,*/ MAESTRO.SPI_CODIGO=0, 
			MAESTRO.MA_SEC_IMP=0 
			FROM  MAESTRO INNER JOIN 
			  ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO 
			WHERE     (MAESTRO.MA_DEF_TIP = 'R') 
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
		
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= PAISARA.PAR_BEN,*/ MAESTRO.MA_SEC_IMP=0, MAESTRO.SPI_CODIGO=22 
			FROM MAESTRO INNER JOIN 
			PAISARA ON MAESTRO.AR_IMPMX = PAISARA.AR_CODIGO AND MAESTRO.PA_ORIGEN = PAISARA.PA_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'P') 
			AND MAESTRO.PA_ORIGEN =233
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA		
		
			UPDATE MAESTRO  
			SET /*MAESTRO.MA_POR_DEF= PAISARA.PAR_BEN,*/ MAESTRO.MA_SEC_IMP=0
			FROM MAESTRO INNER JOIN 
			PAISARA ON MAESTRO.AR_IMPMX = PAISARA.AR_CODIGO AND MAESTRO.SPI_CODIGO = PAISARA.SPI_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'P') 
			AND MAESTRO.PA_ORIGEN <>233
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA		
		
		
			UPDATE MAESTRO
			SET     MAESTRO.MA_SEC_IMP= (SELECT SE_CODIGO FROM CONFIGURACION)
			FROM         MAESTRO
			WHERE     (MAESTRO.MA_DEF_TIP = 'S') AND (MAESTRO.MA_SEC_IMP = 0 OR
			                      MAESTRO.MA_SEC_IMP IS NULL) 
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA		

		
			UPDATE MAESTRO  
			SET   /*MAESTRO.MA_POR_DEF= SECTORARA.SA_PORCENT,*/ MAESTRO.SPI_CODIGO=0 
			FROM  MAESTRO INNER JOIN 
			 SECTORARA ON MAESTRO.AR_IMPMX = SECTORARA.AR_CODIGO AND 
			 MAESTRO.MA_SEC_IMP = SECTORARA.SE_CODIGO 
			WHERE (MAESTRO.MA_DEF_TIP = 'S') 
			and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA		
		

		end
	
		IF @CONST=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.MA_CONSTA= ISNULL(MAESTRO_1.MA_CONSTA, dbo.MAESTRO.MA_CONSTA) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @UM=1
		UPDATE dbo.MAESTRO
		SET     dbo.MAESTRO.ME_COM= ISNULL(MAESTRO_1.ME_COM, dbo.MAESTRO.ME_COM) 
		FROM         dbo.MAESTRO LEFT OUTER JOIN
		                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
		WHERE dbo.MAESTRO.MA_GENERICO<>0 and convert(varchar(11),dbo.MAESTRO.MA_ULTIMAMODIF,101)=@FECHA
	
	
		IF @EQGEN=1
		EXEC SP_ACTUALIZAEQGENMODIF @FECHA


	end


GO
