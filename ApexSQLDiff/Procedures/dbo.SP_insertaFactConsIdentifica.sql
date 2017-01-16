SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_insertaFactConsIdentifica] (@fc_codigo int)   as

declare @FCI_codigo int, @CONSECUTIVO int, @ccp_tipo varchar(5), @fc_tipo char(1), @cp_clave varchar(5)




	SELECT    @cp_clave= CLAVEPED.CP_CLAVE
	FROM         CLAVEPED INNER JOIN
	          factcons ON CLAVEPED.CP_CODIGO = factcons.CP_CODIGO
	          WHERE     factcons.fc_codigo = @fc_codigo


	SELECT    @ccp_tipo= CONFIGURACLAVEPED.CCP_TIPO
	FROM         CONFIGURACLAVEPED INNER JOIN
	          factcons ON CONFIGURACLAVEPED.CP_CODIGO = factcons.CP_CODIGO
	          WHERE     factcons.fc_codigo = @fc_codigo

	select @fc_tipo =fc_tipo from factcons where fc_codigo= @fc_codigo



	exec sp_droptable 'identificapermite'

		SELECT     IDE_CODIGO
		into dbo.identificapermite
		FROM         CLAVEPEDIDENTIFICA
		WHERE    (IDE_NIVEL='A' OR IDE_NIVEL='G') 
		AND CP_MOVIMIENTO  in (select fc_tipo from factcons where fc_codigo=@fc_codigo) AND CP_CODIGO in (select cp_codigo from factcons where fc_codigo=@fc_codigo)


		-- permiso para importacion
		if @fc_tipo='E'
		begin

			if @ccp_tipo IN ('IM', 'IT', 'IV', 'VT', 'IA') and
			((SELECT CL_TIPO FROM CLIENTE WHERE CL_EMPRESA = 'S')='M' OR
			(SELECT CL_TIPO FROM CLIENTE WHERE CL_EMPRESA = 'S')='P') and
			(SELECT CL_NOMAQ FROM CLIENTE WHERE CL_EMPRESA = 'S') <>''
			begin

				EXEC SP_GETCONSECUTIVO @TIPO='FCI', @VALUE=@CONSECUTIVO OUTPUT	

				insert into factconsidentifica (fci_codigo, fc_codigo, IDE_CODIGO, FCI_DESC)
				SELECT     @CONSECUTIVO, @fc_codigo, (select IDE_CODIGO from identifica where ide_clave='IM'  and IDE_IDENTPERM='I')
					, REPLACE(CL_IMMEX,'-','')
				FROM         CLIENTE
				WHERE     (CL_EMPRESA = 'S') AND CL_IMMEX IS NOT NULL AND CL_IMMEX<>''

	
			end	

			-- empresa certificada
			if @ccp_tipo IN ('IM', 'IT', 'IV', 'VT', 'IA', 'ED') and
			not exists (select * from factconsidentifica where fc_codigo=@fc_codigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='IC'  and IDE_IDENTPERM='I')) and
			exists (SELECT * FROM CLIENTE WHERE CL_EMPRESA='S' AND CL_EMPCERTIFICADA<>'' AND CL_EMPCERTIFICADA IS NOT NULL)
			begin
				EXEC SP_GETCONSECUTIVO @TIPO='FCI', @VALUE=@CONSECUTIVO OUTPUT	
				insert into factconsidentifica (fci_codigo, fc_codigo, IDE_CODIGO, FCI_DESC)
				select @CONSECUTIVO, @fc_codigo, (select IDE_CODIGO from identifica where ide_clave='IC'  and IDE_IDENTPERM='I'), ''
			end


		end	

		-- deposito fiscal
		if (select cl_tipo from cliente where cl_empresa='S')='D' AND @ccp_tipo IN ('ED', 'SD', 'IR', 'SI')
		begin
			-- autorizacion DF 
			if not exists (select * from factconsidentifica where fc_codigo=@fc_codigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='C5'  and IDE_IDENTPERM='I'))
			begin
				EXEC SP_GETCONSECUTIVO @TIPO='FCI', @VALUE=@CONSECUTIVO OUTPUT	

				insert into factconsidentifica (fci_codigo, fc_codigo, IDE_CODIGO, FCI_DESC)
				select @CONSECUTIVO, @fc_codigo, (select min(IDE_CODIGO) from identifica where ide_clave='C5' and IDE_IDENTPERM='I'), (select cl_rnim from cliente where cl_empresa='S')
			end

			if (select cl_tipo from cliente where cl_empresa='S')='D' AND @ccp_tipo not in ('IR', 'SD', 'SI')
			begin
				-- planta ensambladora
				if not exists (select * from factconsidentifica where fc_codigo=@fc_codigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='PE'  and IDE_IDENTPERM='I'))
				begin
					EXEC SP_GETCONSECUTIVO @TIPO='FCI', @VALUE=@CONSECUTIVO OUTPUT	
					insert into factconsidentifica (fci_codigo, fc_codigo, IDE_CODIGO, FCI_DESC)
					select @CONSECUTIVO, @fc_codigo, (select IDE_CODIGO from identifica where ide_clave='PE'  and IDE_IDENTPERM='I'), (select CL_NOMAQ from cliente where cl_empresa='S')
				end
			end
		end


		-- importaci>n fronteriza
		if @fc_tipo='E' AND @cp_clave='C1'
		begin

			if not exists (select * from factconsidentifica where fc_codigo=@fc_codigo and IDE_CODIGO=(select min(IDE_CODIGO) from identifica where ide_clave='CF'  and IDE_IDENTPERM='I'))
			begin
				EXEC SP_GETCONSECUTIVO @TIPO='FCI', @VALUE=@CONSECUTIVO OUTPUT	
				insert into factconsidentifica (fci_codigo, fc_codigo, IDE_CODIGO, FCI_DESC)
				select @CONSECUTIVO, @fc_codigo, (select min(IDE_CODIGO) from identifica where ide_clave='CF' and IDE_IDENTPERM='I'), (select cl_autfronteriza from cliente where cl_empresa='S')
			end
		end



























GO
