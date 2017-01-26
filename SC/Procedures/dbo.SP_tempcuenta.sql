SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_tempcuenta]   as

declare @Fecha varchar(10)

	SET @Fecha = convert(VARCHAR(10),getdate(),101)

	update factimp
	set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
	where fi_cuentadet<>(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)

	update factexp
	set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	where fe_cuentadet<>(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)

	update pedimp
	set pi_cuentadet=(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)
	where pi_cuentadet<>(select isnull(count(pedimpdet.pi_codigo),0) from pedimpdet where pedimpdet.pi_codigo =pedimp.pi_codigo)

	update pedimp
	set pi_cuentadetb=(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)
	where pi_cuentadetb<>(select isnull(count(pedimpdetb.pi_codigo),0) from pedimpdetb where pedimpdetb.pi_codigo =pedimp.pi_codigo)



	-------------------------------- actualiza el MA_ENUSO en el catalogo maestro ----------------------------------------------------------------

/*	if exists (select * from factimpdet)
	begin
		-- esto por si la empresa es nueva con el sistema
		if exists(select * from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo where fi_fecha <GETDATE() - 182)
		UPDATE MAESTRO
		SET MA_ENUSO='N'
		FROM MAESTRO LEFT OUTER JOIN
		CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE (CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T')) AND MA_CODIGO NOT IN
		(SELECT     dbo.FACTIMPDET.MA_CODIGO
		FROM         dbo.FACTIMP INNER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.FACTIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.FACTIMP.FI_FECHA >= GETDATE() - 182) AND (dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T'))
		GROUP BY dbo.FACTIMPDET.MA_CODIGO)
		    AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION<>convert(VARCHAR(10),getdate(),101))
		AND MA_ENUSO<>'N'
	end
	else
	begin
		-- esto por si la empresa es nueva con el sistema
		if exists(select * from pedimpdet inner join vpedimp on pedimpdet.pi_codigo=vpedimp.pi_codigo where pi_fec_ent <GETDATE() - 182)
		UPDATE MAESTRO
		SET MA_ENUSO='N'
		FROM MAESTRO LEFT OUTER JOIN
		CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE (CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T')) AND MA_CODIGO NOT IN
		(SELECT     PEDIMPDET.MA_CODIGO
		FROM         VPEDIMP INNER JOIN
		                   PEDIMPDET ON VPEDIMP.PI_CODIGO = PEDIMPDET.PI_CODIGO INNER JOIN
		                      dbo.CONFIGURATIPO ON PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (VPEDIMP.PI_FEC_ENT >= GETDATE() - 182) AND (dbo.CONFIGURATIPO.CFT_TIPO IN ('E', 'L', 'M', 'O', 'R', 'T'))
		GROUP BY PEDIMPDET.MA_CODIGO)
		    AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION<>convert(VARCHAR(10),getdate(),101))
		AND MA_ENUSO<>'N'
	end
		-- esto por si la empresa es nueva con el sistema
		if exists(select * from factexpdet inner join factexp on factexpdet.fe_codigo=factexp.fe_codigo where fe_fecha <GETDATE() - 182)
		begin
			UPDATE MAESTRO
			SET MA_ENUSO='N'
			FROM MAESTRO LEFT OUTER JOIN
			CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
			WHERE (CONFIGURATIPO.CFT_TIPO IN ('P')) AND MA_CODIGO NOT IN
			(SELECT     dbo.FACTEXPDET.MA_CODIGO
			FROM         dbo.FACTEXP INNER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.FACTEXP.FE_FECHA >= GETDATE() - 182) AND (dbo.CONFIGURATIPO.CFT_TIPO IN ('P'))
			GROUP BY dbo.FACTEXPDET.MA_CODIGO)
			    AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION<>convert(VARCHAR(10),getdate(),101))
			AND MA_ENUSO<>'N'
		
		
			UPDATE MAESTRO
			SET MA_ENUSO='N'
			FROM MAESTRO LEFT OUTER JOIN
			CONFIGURATIPO  ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
			WHERE (CONFIGURATIPO.CFT_TIPO IN ('S')) AND MA_CODIGO NOT IN
			(SELECT     dbo.FACTEXPDET.MA_CODIGO
			FROM         dbo.FACTEXP INNER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.FACTEXP.FE_FECHA >= GETDATE() - 182) AND (dbo.CONFIGURATIPO.CFT_TIPO IN ('S'))
			GROUP BY dbo.FACTEXPDET.MA_CODIGO)
			    AND MA_CODIGO not in (select ma_codigo from MAESTROALM WHERE MAA_FECHAREVISION<>convert(VARCHAR(10),getdate(),101))
			--AND MA_CODIGO NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT GROUP BY BSU_SUBENSAMBLE)
			AND MA_ENUSO<>'N'
		end*/



	insert into MAESTROALM(MA_CODIGO, MAA_FECHAREVISION)
	SELECT     MA_CODIGO, @fecha  from maestro 
	where ma_codigo not in (select ma_codigo from MAESTROALM)



























GO
