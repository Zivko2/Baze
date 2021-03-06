SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPEXCELCERTORIG] (@CMP_CODIGO int)   as

SET NOCOUNT ON 
DECLARE @NOPARTE VARCHAR(30), @ma_codigo int, @PROVEE INT, @FECHAFIN DATETIME, @FECHAINI DATETIME

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=124

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

	SELECT     @FECHAINI=CMP_IFECHA, @FECHAFIN=CMP_VFECHA, @PROVEE=PR_CODIGO
	FROM         CERTORIGMP
	WHERE     (CMP_CODIGO = @CMP_CODIGO)
	
	--Manuel G. 23-Dic-2010 para distinguir los que realmente no existen con los que estan obsoletos
	IF EXISTS (SELECT NOPARTE FROM IMPEXCELFACTEXP
	WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
	(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO ) )
	  begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
	
		SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'')+' PORQUE NO SE ENCUENTRA EN EL CATALOGO MAESTRO', 124
		 FROM IMPEXCELFACTEXP
		WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO ) 


		--Los elimina para que no tenga que validarlos con el resto de las validaciones Manuel G. 23-Dic-2010
		delete from IMPEXCELFACTEXP
		WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO ) 

	  end

	--Manuel G. 23-Dic-2010 para distinguir los que existen pero estan obsoletos
	IF EXISTS (SELECT NOPARTE FROM IMPEXCELFACTEXP
	WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') IN
	(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT <> 'A') )
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
		
			SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'')+' PORQUE NO SE ENCUENTRA ACTIVO EN EL CATALOGO MAESTRO', 124
			 FROM IMPEXCELFACTEXP
			WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') IN
			(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
			                                             AND MA_EST_MAT <> 'A') 
			delete from impexcelfactexp
			WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') IN
			(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
			                                             AND MA_EST_MAT <> 'A') 
		end
	

	IF EXISTS (SELECT * FROM         dbo.CERTORIGMP LEFT OUTER JOIN
	                dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO
		 WHERE CMP_IFECHA=@FECHAINI AND CMP_VFECHA=@FECHAFIN AND dbo.CERTORIGMP.CMP_ESTATUS='V' AND
		dbo.CERTORIGMP.PR_CODIGO= @PROVEE AND dbo.CERTORIGMPDET.MA_CODIGO IN (SELECT MA_CODIGO
			FROM MAESTRO WHERE MA_INV_GEN='I' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN 
			(SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)))
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
			SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'')+' PORQUE YA EXISTE EN EL CERTIFICADO', 124
			 FROM MAESTRO WHERE MA_CODIGO IN
			(SELECT dbo.CERTORIGMPDET.MA_CODIGO FROM dbo.CERTORIGMP LEFT OUTER JOIN
			                dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO
				 WHERE CMP_IFECHA=@FECHAINI AND CMP_VFECHA=@FECHAFIN AND dbo.CERTORIGMP.CMP_ESTATUS='V' AND
				dbo.CERTORIGMP.PR_CODIGO= @PROVEE AND dbo.CERTORIGMPDET.MA_CODIGO IN (SELECT MA_CODIGO
					FROM MAESTRO WHERE MA_INV_GEN='I' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN 
					(SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)))
			delete from impexcelfactexp
			where NOPARTE+'-'+isnull(NOPARTEAUX,'') IN 
			(			SELECT MA_NOPARTE+'-'+isnull(MA_NOPARTEAUX,'')
			 FROM MAESTRO WHERE MA_CODIGO IN
			(SELECT dbo.CERTORIGMPDET.MA_CODIGO FROM dbo.CERTORIGMP LEFT OUTER JOIN
			                dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO
				 WHERE CMP_IFECHA=@FECHAINI AND CMP_VFECHA=@FECHAFIN AND dbo.CERTORIGMP.CMP_ESTATUS='V' AND
				dbo.CERTORIGMP.PR_CODIGO= @PROVEE AND dbo.CERTORIGMPDET.MA_CODIGO IN (SELECT MA_CODIGO
					FROM MAESTRO WHERE MA_INV_GEN='I' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN 
					(SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)))
			)

		end
		
	--Yolanda Avila
	--2010-10-12
	--Se agrego esta parte para que verifique el tipo de material de los No.Parte que se desean agregar al certificado
	--Para que solo permita insertar detalles que correspondan de acuerdo al Tipo de Documento del Certificado de Origen
		--------- MP
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
		SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'')+' PORQUE EL TIPO DE MATERIAL NO CORRESPONDE AL TIPO DE DOCUMENTO ASIGNADO AL CERTIFICADO DE ORIGEN', 124
		FROM IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'M'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE ( CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T') 
		        OR (CONFIGURATIPO.CFT_TIPO IN ('S') AND MAESTRO.MA_TIP_ENS IN ('C', 'A'))
		       )
		AND MAESTRO.MA_INV_GEN ='I' )

		delete from IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'M'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE ( CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T') 
		        OR (CONFIGURATIPO.CFT_TIPO IN ('S') AND MAESTRO.MA_TIP_ENS IN ('C', 'A'))
		       )
		AND MAESTRO.MA_INV_GEN ='I' )
		
		--------- PT
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
		SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'')+' PORQUE EL TIPO DE MATERIAL NO CORRESPONDE AL TIPO DE DOCUMENTO ASIGNADO AL CERTIFICADO DE ORIGEN', 124
		FROM IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'P'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE CONFIGURATIPO.CFT_TIPO IN ('S', 'P') AND MAESTRO.MA_INV_GEN ='I'
		AND MAESTRO.MA_TIP_ENS <>'C')

		delete from IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'P'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE CONFIGURATIPO.CFT_TIPO IN ('S', 'P') AND MAESTRO.MA_INV_GEN ='I'
		AND MAESTRO.MA_TIP_ENS <>'C')
		
		-----------MAQ
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA)
		SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'')+' PORQUE EL TIPO DE MATERIAL NO CORRESPONDE AL TIPO DE DOCUMENTO ASIGNADO AL CERTIFICADO DE ORIGEN', 124
		FROM IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'Q'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE CONFIGURATIPO.CFT_TIPO IN ('X', 'Q', 'H') AND MAESTRO.MA_INV_GEN ='I')
		
		delete from IMPEXCELFACTEXP
		WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'Q'
		and NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
		(SELECT maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) 
		FROM  MAESTRO 
		LEFT OUTER JOIN CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE CONFIGURATIPO.CFT_TIPO IN ('X', 'Q', 'H') AND MAESTRO.MA_INV_GEN ='I')
		
		
		
		



/* se ejecutan los procedimientos para llenar el detalle */
		INSERT INTO CERTORIGMPDET(CMP_CODIGO, MA_CODIGO, CMP_CLASE, CMP_FABRICA, CMP_CRITERIO, CMP_NETCOST, 
		                      CMP_OTRASINST, CMP_FRACCION, CMP_FRACCIONALT, PR_CODIGO, PA_CLASE, CMP_NOPARTE, CMP_NOPARTEAUX)
		SELECT     @CMP_CODIGO, dbo.MAESTRO.MA_CODIGO, 'NFT_CLASE'=case when MAX(dbo.NAFTA.NFT_CLASE) is null
		then (case when MAX(dbo.MAESTRO.TI_CODIGO) in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		then 1 else 2 end) else MAX(dbo.NAFTA.NFT_CLASE) end,
		'NFT_FABRICA'=case when MAX(dbo.NAFTA.NFT_FABRICA) is null
		then (case when MAX(dbo.MAESTRO.TI_CODIGO) in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		then 0 else 1 end) else MAX(dbo.NAFTA.NFT_FABRICA) end, 
		'NFT_CRITERIO'=case when MAX(dbo.NAFTA.NFT_CRITERIO) is null
		then (case when MAX(dbo.MAESTRO.TI_CODIGO) in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S')
		then 1 else 2 end) else MAX(dbo.NAFTA.NFT_CRITERIO) end,
		'NFT_NETCOST'=case when MAX(dbo.NAFTA.NFT_NETCOST) is null
		then 0 else MAX(dbo.NAFTA.NFT_NETCOST) end,
		'NFT_OTRASINST'=case when MAX(dbo.NAFTA.NFT_OTRASINST) is null
		then 5 else MAX(dbo.NAFTA.NFT_OTRASINST) end, max(left(replace(isnull(ARANCEL_1.AR_FRACCION,0),'.',''),6)), max(left(replace(isnull(ARANCEL_2.AR_FRACCION,0),'.',''),6)),
		@PROVEE, maestro.pa_origen, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
		FROM         dbo.MAESTRO INNER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') LEFT OUTER JOIN
		                      dbo.NAFTA ON dbo.MAESTRO.MA_CODIGO = dbo.NAFTA.MA_CODIGO LEFT OUTER JOIN dbo.ARANCEL ARANCEL_1 ON
			        dbo.MAESTRO.AR_EXPMX = ARANCEL_1.AR_CODIGO LEFT OUTER JOIN dbo.ARANCEL ARANCEL_2 ON			        dbo.MAESTRO.AR_IMPFO = ARANCEL_2.AR_CODIGO

		WHERE dbo.MAESTRO.MA_INV_GEN='I' AND dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(dbo.IMPEXCELFACTEXP.NOPARTEAUX,'')  NOT IN
		(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_CODIGO IN
		(SELECT dbo.CERTORIGMPDET.MA_CODIGO FROM dbo.CERTORIGMP LEFT OUTER JOIN
	                dbo.CERTORIGMPDET ON dbo.CERTORIGMP.CMP_CODIGO = dbo.CERTORIGMPDET.CMP_CODIGO
		 WHERE CMP_IFECHA=@FECHAINI AND CMP_VFECHA=@FECHAFIN /*AND PR_CODIGO= @PROVEE*/))
		
		--Yolanda Avila	
		--2010-10-12
		and (dbo.MAESTRO.MA_INV_GEN='I' AND dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(dbo.IMPEXCELFACTEXP.NOPARTEAUX,'')  NOT IN
			     (
				SELECT imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'')
				FROM IMPEXCELFACTEXP imp
				WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'M'
				and imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'') NOT IN
				(SELECT ma.MA_NOPARTE+'-'+rtrim(ltrim(isnull(ma.MA_NOPARTEAUX,''))) 
				FROM  MAESTRO ma
				LEFT OUTER JOIN CONFIGURATIPO ON MA.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
				WHERE ( CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T') 
				        OR (CONFIGURATIPO.CFT_TIPO IN ('S') AND MA.MA_TIP_ENS IN ('C', 'A'))
				       )
				AND MA.MA_INV_GEN ='I' )
				union		
				--------- PT
				SELECT imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'')
				FROM IMPEXCELFACTEXP imp
				WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'P'
				and imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'') NOT IN
				(SELECT ma.MA_NOPARTE+'-'+rtrim(ltrim(isnull(ma.MA_NOPARTEAUX,''))) 
				FROM  MAESTRO ma
				LEFT OUTER JOIN CONFIGURATIPO ON MA.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
				WHERE CONFIGURATIPO.CFT_TIPO IN ('S', 'P') AND MA.MA_INV_GEN ='I'
				AND MA.MA_TIP_ENS <>'C')
				union
				-----------MAQ
				SELECT imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'')
				FROM IMPEXCELFACTEXP imp
				WHERE (select cmp_tipo FROM CERTORIGMP WHERE CMP_CODIGO = @CMP_CODIGO ) = 'Q'
				and imp.NOPARTE+'-'+isnull(imp.NOPARTEAUX,'') NOT IN
				(SELECT ma.MA_NOPARTE+'-'+rtrim(ltrim(isnull(ma.MA_NOPARTEAUX,''))) 
				FROM  MAESTRO ma
				LEFT OUTER JOIN CONFIGURATIPO ON MA.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
				WHERE CONFIGURATIPO.CFT_TIPO IN ('X', 'Q', 'H') AND MA.MA_INV_GEN ='I')
				
   		            )
		  )

		GROUP BY dbo.MAESTRO.MA_CODIGO, maestro.pa_origen, MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX




	TRUNCATE TABLE IMPEXCELFACTEXP

GO
