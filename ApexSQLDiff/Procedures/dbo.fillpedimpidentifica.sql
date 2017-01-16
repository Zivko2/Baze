SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE dbo.[fillpedimpidentifica] (@picodigo int)   as

SET NOCOUNT ON 
declare @maximo INT, @PII_codigo int, @remesamin int, @remesamax int, @ccp_tipo varchar(5), @pi_movimiento char(1), @cp_clave varchar(5), @pi_rectifica int



	TRUNCATE TABLE TempPedImpIdentifica



	if exists (select * from PedImpIdentifica where pi_codigo=@picodigo)
	begin
		delete from  PedImpIdentifica where pi_codigo=@picodigo
	end

	SELECT     @maximo= isnull(MAX(PII_CODIGO),0)+1
	FROM         PEDIMPIDENTIFICA



	SELECT    @cp_clave= dbo.CLAVEPED.CP_CLAVE, @pi_rectifica=pi_rectifica
	FROM         dbo.CLAVEPED INNER JOIN
	          dbo.PEDIMP ON dbo.CLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
	          WHERE     dbo.PEDIMP.PI_CODIGO = @picodigo


	SELECT    @ccp_tipo= dbo.CONFIGURACLAVEPED.CCP_TIPO
	FROM         dbo.CONFIGURACLAVEPED INNER JOIN
	          dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
	          WHERE     dbo.PEDIMP.PI_CODIGO = @picodigo


	if @ccp_tipo IN ('RE')-- RECTIFICACION
	begin

		SELECT    @cp_clave= dbo.CLAVEPED.CP_CLAVE
		FROM         dbo.CLAVEPED INNER JOIN
		          dbo.PEDIMP ON dbo.CLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
		          WHERE     dbo.PEDIMP.PI_CODIGO = @pi_rectifica


		SELECT    @ccp_tipo= dbo.CONFIGURACLAVEPED.CCP_TIPO
		FROM         dbo.CONFIGURACLAVEPED INNER JOIN
		          dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
		          WHERE     dbo.PEDIMP.PI_CODIGO = @pi_rectifica



	end

	select @pi_movimiento =pi_movimiento from pedimp where pi_codigo= @picodigo

	dbcc checkident (TempPedImpIdentifica, reseed, @maximo) WITH NO_INFOMSGS



	exec sp_droptable 'identificapermite'

		SELECT     IDE_CODIGO
		into dbo.identificapermite
		FROM         CLAVEPEDIDENTIFICA
		WHERE    (IDE_NIVEL='A' OR IDE_NIVEL='G') 
		AND (CP_MOVIMIENTO  in (select pi_movimiento from pedimp where pi_codigo=@picodigo) OR
			CP_MOVIMIENTO ='A') AND CP_CODIGO in (select cp_codigo from pedimp where pi_codigo=@picodigo)


		-- permiso para importacion
		if @pi_movimiento='E'
		begin
			--insert los permisos
			insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
			SELECT     @picodigo/*dbo.FACTIMP.PI_CODIGO*/, dbo.PERMISO.IDE_CODIGO, CONVERT(varchar(10), dbo.PERMISO.PE_ANIO) + CONVERT(varchar(10), 
			                      dbo.PERMISO.PE_PERMISO)
			FROM         dbo.FACTIMPPERM INNER JOIN
		                      dbo.PERMISO ON dbo.FACTIMPPERM.PE_CODIGO = dbo.PERMISO.PE_CODIGO INNER JOIN
		                      dbo.FACTIMP ON dbo.FACTIMPPERM.FI_CODIGO = dbo.FACTIMP.FI_CODIGO LEFT OUTER JOIN
		                      dbo.IDENTIFICA ON dbo.PERMISO.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
			WHERE      (dbo.FACTIMP.PI_CODIGO = @picodigo OR dbo.FACTIMP.PI_RECTIFICA = @picodigo) AND (dbo.IDENTIFICA.IDE_CLAVE NOT IN ('C1', 'MQ', 'PX', 'IM', 'PS'))
			GROUP BY dbo.FACTIMP.PI_CODIGO, dbo.PERMISO.IDE_CODIGO, dbo.PERMISO.PE_PERMISO, dbo.PERMISO.PE_ANIO

			
			-- los identificadores que vienen desde la factura
			insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, IDED_CODIGO, PII_DESC, IDED_CODIGO2, PII_DESC2, IDED_CODIGO3, PII_DESC3)
	
			SELECT     @picodigo/*dbo.FACTIMP.PI_CODIGO*/, dbo.FACTIMPIDENTIFICA.IDE_CODIGO, dbo.FACTIMPIDENTIFICA.IDED_CODIGO, dbo.FACTIMPIDENTIFICA.FII_DESC,
					dbo.FACTIMPIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPIDENTIFICA.FII_DESC2, dbo.FACTIMPIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPIDENTIFICA.FII_DESC3
			FROM         dbo.FACTIMPIDENTIFICA INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPIDENTIFICA.FI_CODIGO = dbo.FACTIMP.FI_CODIGO  LEFT OUTER JOIN
		                      dbo.IDENTIFICA ON dbo.FACTIMPIDENTIFICA.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
			WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo OR dbo.FACTIMP.PI_RECTIFICA = @picodigo) and
				dbo.FACTIMPIDENTIFICA.IDE_CODIGO in (select IDE_CODIGO from identificapermite) AND (dbo.IDENTIFICA.IDE_CLAVE NOT IN ('MQ', 'PX', 'IM'))
			GROUP BY dbo.FACTIMP.PI_CODIGO, dbo.FACTIMPIDENTIFICA.IDE_CODIGO, dbo.FACTIMPIDENTIFICA.IDED_CODIGO, dbo.FACTIMPIDENTIFICA.FII_DESC, dbo.IDENTIFICA.IDE_CLAVE,
					dbo.FACTIMPIDENTIFICA.IDED_CODIGO2, dbo.FACTIMPIDENTIFICA.FII_DESC2, dbo.FACTIMPIDENTIFICA.IDED_CODIGO3, dbo.FACTIMPIDENTIFICA.FII_DESC3


			insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
	
			SELECT     @picodigo/*dbo.FACTIMP.PI_CODIGO*/, CASE WHEN dbo.IDENTIFICA.IDE_CLAVE IN ('MQ',  'PX') then
					(select IDE_CODIGO from identifica where ide_clave='IM'  and IDE_IDENTPERM='I') 
					else dbo.FACTIMPIDENTIFICA.IDE_CODIGO end, dbo.FACTIMPIDENTIFICA.FII_DESC
			FROM         dbo.FACTIMPIDENTIFICA INNER JOIN
			                      dbo.FACTIMP ON dbo.FACTIMPIDENTIFICA.FI_CODIGO = dbo.FACTIMP.FI_CODIGO  LEFT OUTER JOIN
		                      dbo.IDENTIFICA ON dbo.FACTIMPIDENTIFICA.IDE_CODIGO = dbo.IDENTIFICA.IDE_CODIGO
			WHERE     (dbo.FACTIMP.PI_CODIGO = @picodigo OR dbo.FACTIMP.PI_RECTIFICA = @picodigo) and
				dbo.FACTIMPIDENTIFICA.IDE_CODIGO in (select IDE_CODIGO from identificapermite) AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX', 'IM'))
			GROUP BY dbo.FACTIMP.PI_CODIGO, dbo.FACTIMPIDENTIFICA.IDE_CODIGO, dbo.FACTIMPIDENTIFICA.IDED_CODIGO, dbo.FACTIMPIDENTIFICA.FII_DESC, dbo.IDENTIFICA.IDE_CLAVE


			-- tipo de tasa bajo pps
			if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='PP'  and IDE_IDENTPERM='I')) and
			exists (SELECT FACTIMP.FI_CODIGO FROM FACTIMPDET INNER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
			          WHERE (FID_DEF_TIP = 'S') AND (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo))
			begin
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				select @picodigo, (select IDE_CODIGO from identifica where ide_clave='PP'  and IDE_IDENTPERM='I'), convert(varchar(5),(select CL_ANIOPPS from cliente where cl_empresa='S'))+convert(varchar(10),(select CL_NOPPS from cliente where cl_empresa='S'))
			end

			if (select pi_fec_pag from pedimp where pi_codigo=@picodigo)>='09/25/2006'
			if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='PP'  and IDE_IDENTPERM='I')) and
			exists (SELECT FACTIMP.FI_CODIGO FROM FACTIMPDET INNER JOIN FACTIMP ON FACTIMPDET.FI_CODIGO=FACTIMP.FI_CODIGO
			          WHERE (FID_DEF_TIP = 'R') AND (PI_CODIGO = @picodigo OR PI_RECTIFICA = @picodigo))
			begin
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				select @picodigo, (select IDE_CODIGO from identifica where ide_clave='PP'  and IDE_IDENTPERM='I'), convert(varchar(5),(select CL_ANIOPPS from cliente where cl_empresa='S'))+convert(varchar(10),(select CL_NOPPS from cliente where cl_empresa='S'))
			end


			--Este identificador es aplicable a todas las operaciones virtuales
			if @ccp_tipo IN ( 'IV', 'VT') and
			not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='V1'  and IDE_IDENTPERM='I')) 
			begin
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				SELECT     @picodigo, (select min(IDE_CODIGO) from identifica where ide_clave='V1'  and IDE_IDENTPERM='I'), dbo.CLIENTE.CL_ANIOMAQ + dbo.CLIENTE.CL_NOMAQ
				FROM         dbo.PEDIMP LEFT OUTER JOIN
			                      dbo.CLIENTE ON dbo.PEDIMP.PR_CODIGO = dbo.CLIENTE.CL_CODIGO
				WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo)
			end


			if @ccp_tipo IN ('CN', 'RG') -- cambio de regimen
			begin
				if (select pi_desp_equipo from pedimp where pi_codigo=@picodigo)='S'
				begin
					if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='DE'  and IDE_IDENTPERM='I'))
					begin  -- Cambio de regimen de desperdicios
						insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
						select @picodigo, (select IDE_CODIGO from identifica where ide_clave='DE'  and IDE_IDENTPERM='I'), ''
					end
	
				end
			
				if @cp_clave<>'F5'-- CAMBIO DE REGIMEN 
				   and not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='FI'  and IDE_IDENTPERM='I')) 
				begin
		
					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
					SELECT   @picodigo, (select IDE_CODIGO from identifica where ide_clave='FI' and IDE_IDENTPERM='I'), PI_FT_ACT
					FROM PEDIMP
					WHERE PI_CODIGO=@picodigo
		
				end
		

			end



			-- importacion fronteriza
			if @cp_clave='C1'
			begin
	
				if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='CF'  and IDE_IDENTPERM='I'))
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				select @picodigo, (select min(IDE_CODIGO) from identifica where ide_clave='CF' and IDE_IDENTPERM='I'), (select cl_autfronteriza from cliente where cl_empresa='S')
	
			end

			-- importacion ITN
			if (select CF_CONS_IMP from configuracion)='N'
			begin

				if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='IT'  and IDE_IDENTPERM='I'))
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC, PII_DESC2)
				SELECT     @picodigo, (select min(IDE_CODIGO) from identifica where ide_clave='IT' and IDE_IDENTPERM='I'), CASE WHEN FACTIMP.TN_CODIGO=11 THEN 'OP4' 
				WHEN FACTIMP.TN_CODIGO=1 THEN 'INB' WHEN FACTIMP.TN_CODIGO=10 THEN 'ITN' WHEN FACTIMP.TN_CODIGO=12 THEN 'MD2' END,  CASE WHEN FACTIMP.TN_CODIGO=11 THEN 'AES4-'+FACTIMPITN.ITN_TEXTO ELSE FACTIMPITN.ITN_TEXTO END
				FROM         FACTIMP LEFT OUTER JOIN
				                      FACTIMPITN ON FACTIMP.FI_CODIGO = FACTIMPITN.FI_CODIGO
				WHERE     (FACTIMP.PI_CODIGO = @picodigo) AND (FACTIMP.TN_CODIGO IN (1, 10, 11, 12))
				GROUP BY FACTIMPITN.ITN_TEXTO, FACTIMP.TN_CODIGO
				HAVING      (FACTIMPITN.ITN_TEXTO IS NOT NULL)

			end
		end	
		else
		begin
			if @ccp_tipo IN ('ER')-- EXPORTACION MCIAS TRANSFORMADAS
			begin
				if (select pi_desp_equipo from pedimp where pi_codigo=@picodigo)='S'
				begin
					if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='DE'  and IDE_IDENTPERM='I'))
					begin  -- Cambio de regimen de desperdicios
						insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
						select @picodigo, (select IDE_CODIGO from identifica where ide_clave='DE'  and IDE_IDENTPERM='I'), ''
					end
	
				end


				-- ======================= ST complemento 17 de Desperdicio  ============================= 
				if (select PI_DESP_EQUIPO from pedimp where pi_codigo=@picodigo)='S'
				begin
					if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
					and not exists (select * from TempPEDIMPIDENTIFICA where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
					begin
						insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, IDED_CODIGO, PII_DESC)
					
						SELECT     dbo.PEDIMP.PI_CODIGO, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'),
							(SELECT IDED_CODIGO FROM IDENTIFICADET
							WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I')
							AND IDED_VALOR='17'), '17'
						FROM         dbo.PEDIMP 
						WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo)
	
	
					end
				end
				else
				begin
					-- ======================= ST complemento 99 Pago a la importacion  ============================= 
					if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
					and not exists (select * from TempPEDIMPIDENTIFICA where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
					begin
						insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, IDED_CODIGO, PII_DESC)
					
						SELECT     dbo.PEDIMP.PI_CODIGO, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'),
							(SELECT IDED_CODIGO FROM IDENTIFICADET
							WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I')
							AND IDED_VALOR='99'), '99'
						FROM         dbo.PEDIMP 
						WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo)
	
	
					end

				end

			end



			if @ccp_tipo='IR' --H1
			begin  
				-- ======================= ST complemento 12 Retorno en el mismo estado  ============================= 
				if exists(select * from identificapermite where ide_codigo in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
				and not exists (select * from TempPEDIMPIDENTIFICA where IDE_CODIGO in (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'))
				begin
					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, IDED_CODIGO, PII_DESC)
				
					SELECT     dbo.PEDIMP.PI_CODIGO, (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I'),
						(SELECT IDED_CODIGO FROM IDENTIFICADET
						WHERE IDE_CODIGO IN (SELECT IDE_CODIGO FROM dbo.IDENTIFICA WHERE IDE_CLAVE = 'ST' and IDE_IDENTPERM='I')
						AND IDED_VALOR='12'), '12'
					FROM         dbo.PEDIMP 
					WHERE     (dbo.PEDIMP.PI_CODIGO = @picodigo)


				end
			end

		end


		-- empresa certificada
		if @ccp_tipo IN ('IM', 'IT', 'IV', 'VT', 'IA', 'ED', 'IE', 'ER', 'IR') and
		not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='IC'  and IDE_IDENTPERM='I')) and
		exists (SELECT * FROM CLIENTE WHERE CL_EMPRESA='S' AND CL_EMPCERTIFICADA<>'' AND CL_EMPCERTIFICADA IS NOT NULL)
		begin
			insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
			select @picodigo, (select IDE_CODIGO from identifica where ide_clave='IC'  and IDE_IDENTPERM='I'), ''
		end


		-- deposito fiscal
		if (select cl_tipo from cliente where cl_empresa='S')='D' AND @ccp_tipo IN ('ED', 'SD', 'IR', 'SI')
		begin
			-- autorizacion DF 
			if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='C5'  and IDE_IDENTPERM='I'))
			insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
			select @picodigo, (select min(IDE_CODIGO) from identifica where ide_clave='C5' and IDE_IDENTPERM='I'), (select cl_rnim from cliente where cl_empresa='S')

			if (select cl_tipo from cliente where cl_empresa='S')='D'  and @ccp_tipo not in ('IR', 'SD', 'SI')
			begin
				-- planta ensambladora
				if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='PE'  and IDE_IDENTPERM='I'))
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				select @picodigo, (select IDE_CODIGO from identifica where ide_clave='PE'  and IDE_IDENTPERM='I'), (select CL_NOMAQ from cliente where cl_empresa='S')
			end
		end


		-- si usa premodulacion
		if exists(select * from pedimp where pi_codigo=@picodigo and fc_codigo is not null and fc_codigo>0)
		begin
			-- pedimento consolidado
			if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='PC'  and IDE_IDENTPERM='I')) 
			begin
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				select @picodigo, (select IDE_CODIGO from identifica where ide_clave='PC'  and IDE_IDENTPERM='I'), ''
			end

			-- remesas
			

			delete from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='RC'  and IDE_IDENTPERM='I')

			if not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='RC'  and IDE_IDENTPERM='I')) 
			begin
				exec SP_CALCULAREMESAS @picodigo
	
				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)

				SELECT     @picodigo, (select IDE_CODIGO from identifica where ide_clave='RC'  and IDE_IDENTPERM='I'), remesaini
				FROM         remesa
				WHERE     (remesaini = remesafin) and pi_codigo=@picodigo
				order by remesaini

				insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
				SELECT     @picodigo, (select IDE_CODIGO from identifica where ide_clave='RC'  and IDE_IDENTPERM='I'), CONVERT(varchar(20), remesaini) + '-' + CONVERT(varchar(20), remesafin) 
				FROM         remesa
				WHERE     (remesaini <> remesafin) and pi_codigo=@picodigo
				order by  remesaini

				exec sp_droptable 'remesa'

			end
		end




		if @ccp_tipo IN ('IM', 'IT', 'CN', 'ER', 'IR', 'IV', 'VT')-- IMPORTACION TEMPORAL O CAMBIO DE REGIMEN
		begin
			if (select cl_tipo from cliente where cl_empresa='S')='M' and
			   not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='IM'  and IDE_IDENTPERM='I')) 
			begin
	
				if (SELECT ISNULL(CL_IMMEX,'') FROM CLIENTE WHERE cl_empresa='S')=''

					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
					SELECT   @picodigo, (select IDE_CODIGO from identifica where ide_clave='MQ'  and IDE_IDENTPERM='I'), convert(varchar(5), CL_ANIOMAQ)+convert(varchar(5),CL_NOMAQ)
					FROM CLIENTE
					WHERE   cl_empresa='S'  AND CL_NOMAQ IS NOT NULL AND CL_NOMAQ<>''

				else	

					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
					SELECT   @picodigo, (select IDE_CODIGO from identifica where ide_clave='IM'  and IDE_IDENTPERM='I'), REPLACE(CL_IMMEX,'-','')
					FROM CLIENTE
					WHERE   cl_empresa='S'  AND CL_IMMEX IS NOT NULL AND CL_IMMEX<>''

			end


			if (select cl_tipo from cliente where cl_empresa='S')='P' and
			  not exists (select * from TempPEDIMPIDENTIFICA where pi_codigo=@picodigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='IM'  and IDE_IDENTPERM='I')) 			begin
				if (SELECT ISNULL(CL_IMMEX,'') FROM CLIENTE WHERE cl_empresa='S')=''	

					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
					SELECT   @picodigo, (select IDE_CODIGO from identifica where ide_clave='PX'  and IDE_IDENTPERM='I'), convert(varchar(5), CL_ANIOMAQ)+convert(varchar(5),CL_NOMAQ)
					FROM CLIENTE
					WHERE   cl_empresa='S'  AND CL_NOMAQ IS NOT NULL AND CL_NOMAQ<>''
				else

					insert into TempPEDIMPIDENTIFICA (PI_CODIGO, IDE_CODIGO, PII_DESC)
					SELECT   @picodigo, (select IDE_CODIGO from identifica where ide_clave='IM'  and IDE_IDENTPERM='I'), REPLACE(CL_IMMEX,'-','')
					FROM CLIENTE
					WHERE   cl_empresa='S'  AND CL_IMMEX IS NOT NULL AND CL_IMMEX<>''
	
			end
		end



		INSERT INTO PEDIMPIDENTIFICA(PI_CODIGO, IDE_CODIGO, PII_DESC, PII_DESC2, PII_CODIGO, IDED_CODIGO)

		SELECT     PI_CODIGO, IDE_CODIGO, PII_DESC, PII_DESC2, PII_CODIGO, IDED_CODIGO
		FROM         TEMPPEDIMPIDENTIFICA
		
		
select @PII_codigo= isnull(max(PII_codigo),0) from pedimpidentifica

	update consecutivo
	set cv_codigo =  isnull(@PII_codigo,0) + 1
	where cv_tipo = 'PII'

	exec sp_droptable 'identificapermite'

	EXEC SP_DROPTABLE 'remesa'


GO
