SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_ligacorrecta] (@picodigo int)   as

SET NOCOUNT ON 
declare @pi_movimiento char(1)

select @pi_movimiento=pi_movimiento from pedimp where pi_codigo=@picodigo

if @pi_movimiento='E'
begin
	if @picodigo in 
	             (SELECT     dbo.FACTIMP.PI_CODIGO
		FROM         dbo.FACTIMP INNER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTIMP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
		WHERE     (dbo.FACTIMPDET.PID_INDICEDLIGA = - 1 OR
		                      dbo.FACTIMPDET.PID_INDICEDLIGA IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('S', 'B')) 
		GROUP BY dbo.FACTIMP.PI_CODIGO
		UNION
		SELECT     dbo.FACTIMP.PI_RECTIFICA
		FROM         dbo.FACTIMP INNER JOIN
		                      dbo.FACTIMPDET ON dbo.FACTIMP.FI_CODIGO = dbo.FACTIMPDET.FI_CODIGO INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTIMP.PI_RECTIFICA = dbo.PEDIMP.PI_CODIGO
		WHERE     (dbo.FACTIMPDET.PID_INDICEDLIGAR1 = - 1 OR
		                      dbo.FACTIMPDET.PID_INDICEDLIGAR1 IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('N', 'T')) 
			AND (dbo.FACTIMP.PI_CODIGO is not null and dbo.FACTIMP.PI_CODIGO<>-1)
		GROUP BY dbo.FACTIMP.PI_RECTIFICA
		UNION
		select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
			where pi_movimiento='E' and pid_indiced not in (select pid_indicedliga from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo where factimp.pi_codigo=pedimpdet.pi_codigo) 
			and pedimp.pi_estatus<>'R'
			and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
					FROM         dbo.CONFIGURACLAVEPED INNER JOIN
					                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
					WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN')
					or  (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
			and pedimpdet.pid_imprimir='S' and pedimp.pi_tipo ='C'
			group by pedimpdet.pi_codigo

		union
			select pedimpdet.pi_codigo from pedimpdet inner join pedimp on pedimpdet.pi_codigo=pedimp.pi_codigo
			where pi_movimiento='E' and pid_indiced not in (select pid_indicedligar1 from factimpdet inner join factimp on factimpdet.fi_codigo=factimp.fi_codigo where factimp.pi_rectifica=pedimpdet.pi_codigo) 
			and pedimpdet.pi_codigo IN (SELECT     dbo.PEDIMP.PI_CODIGO
							FROM         dbo.CONFIGURACLAVEPED INNER JOIN
							                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO LEFT OUTER JOIN
							                      dbo.CONFIGURACLAVEPED CONFIGURACLAVEPED_1 ON dbo.PEDIMP.CP_RECTIFICA = CONFIGURACLAVEPED_1.CP_CODIGO
							WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE') AND (CONFIGURACLAVEPED_1.CCP_TIPO <> 'CN') AND (CONFIGURACLAVEPED_1.CCP_TIPO <> 'RG'))
			and pedimpdet.pi_codigo NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
					FROM         dbo.CONFIGURACLAVEPED INNER JOIN
					                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
					WHERE     ((dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S')))
			and pedimpdet.pid_imprimir='S'
			group by pedimpdet.pi_codigo
		UNION
		select pi_codigo from pedimp where pi_codigo not in (select pi_codigo from pedimpdet)) and not 
		@picodigo in (select pi_codigo from pedimp where pi_ediciondet='S' and  pi_codigo=@picodigo)

		update pedimp
		set pi_ligacorrecta='N'
		where pi_codigo= @picodigo
	else 
		update pedimp
		set pi_ligacorrecta='S'
		where pi_codigo= @picodigo

end
else
begin

	if @picodigo in (SELECT     dbo.FACTEXP.PI_CODIGO
			FROM         dbo.FACTEXP INNER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
			                      dbo.PEDIMP ON dbo.FACTEXP.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.FACTEXPDET.PID_INDICEDLIGA = - 1 OR
			                      dbo.FACTEXPDET.PID_INDICEDLIGA IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('L')) 
	
				AND dbo.FACTEXP.PI_CODIGO NOT IN 
					(SELECT     dbo.PEDIMP.PI_CODIGO
					FROM         dbo.CONFIGURACLAVEPED INNER JOIN
					                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
					WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
			GROUP BY dbo.FACTEXP.PI_CODIGO
	
			UNION

			SELECT     dbo.FACTEXP.PI_RECTIFICA
			FROM         dbo.FACTEXP INNER JOIN
			                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
			                      dbo.PEDIMP ON dbo.FACTEXP.PI_RECTIFICA = dbo.PEDIMP.PI_CODIGO
			WHERE     (dbo.FACTEXPDET.PID_INDICEDLIGAR1 = - 1 OR
			                      dbo.FACTEXPDET.PID_INDICEDLIGAR1 IS NULL) AND (dbo.PEDIMP.PI_ESTATUS IN ('O', 'N')) 
			AND (dbo.FACTEXP.PI_CODIGO is not null and dbo.FACTEXP.PI_CODIGO<>-1) AND
	
				dbo.FACTEXP.PI_RECTIFICA NOT IN (SELECT     dbo.PEDIMP.PI_CODIGO
				FROM         dbo.CONFIGURACLAVEPED INNER JOIN
				                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO
				WHERE     (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN') OR (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RG' AND dbo.PEDIMP.PI_DESP_EQUIPO='S'))
			GROUP BY dbo.FACTEXP.PI_RECTIFICA
			UNION
			select pi_codigo from pedimp where pi_codigo not in (select pi_codigo from pedimpdet)) and not 
		@picodigo in (select pi_codigo from pedimp where pi_ediciondet='S' and  pi_codigo=@picodigo)
		update pedimp
		set pi_ligacorrecta='N'
		where pi_codigo= @picodigo
	else
		update pedimp
		set pi_ligacorrecta='S'
		where pi_codigo= @picodigo
end


	if(select pi_ediciondet from pedimp where pi_codigo=@picodigo)<>'S'
	update pedimp
	set pi_ligacorrecta='N'
	FROM         CONFIGURACLAVEPED INNER JOIN
	                      PEDIMP ON CONFIGURACLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO LEFT OUTER JOIN
	                      CONFIGURACLAVEPED CONFIGURACLAVEPED_1 ON PEDIMP.CP_RECTIFICA = CONFIGURACLAVEPED_1.CP_CODIGO
	WHERE     (CONFIGURACLAVEPED.CCP_TIPO <> 'CN') AND (CONFIGURACLAVEPED_1.CCP_TIPO <> 'CN') and 
		      (((CONFIGURACLAVEPED.CCP_TIPO = 'RG') OR (CONFIGURACLAVEPED_1.CCP_TIPO = 'RG')) AND dbo.PEDIMP.PI_DESP_EQUIPO<>'S')
	AND pi_codigo= @picodigo AND PI_CODIGO IN
		(SELECT     PI_CODIGO
		FROM         dbo.VRELERRORFACTURAPED
		GROUP BY PI_CODIGO
		HAVING (round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)>2 OR
		round(SUM(ISNULL(PID_CTOT_DLS, 0)),6) - round(SUM(ISNULL(FID_COS_TOT, 0)),6)<-2)
		AND SUM(FID_COS_TOT) IS NOT NULL)



GO
