SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* cancela la descarga del permiso al borrar un factura o al cancelar la afectacion*/
CREATE PROCEDURE dbo.SP_DescargaCancelaPermiso (@CodigoFactura Int)   as

SET NOCOUNT ON 

		exec  sp_droptable 'indicedPer'

		SELECT KARDESPERMISO.PED_INDICED, FI_CODIGO, PE_CODIGO, KAR_CODIGO
		INTO dbo.indicedPer
		FROM KARDESPERMISO INNER JOIN PERMISODET ON KARDESPERMISO.PED_INDICED=PERMISODET.PED_INDICED
		WHERE FI_CODIGO=@CodigoFactura AND KARDESPERMISO.PED_INDICED IS NOT NULL and KARDESPERMISO.KAR_FACTIMP='S'
		GROUP BY KARDESPERMISO.PED_INDICED, FI_CODIGO, PE_CODIGO, KAR_CODIGO

		UPDATE FACTIMPPERM
		SET FIP_ESTATUSAFECTA=0, FIP_CANT =0, FIP_VALOR =0
		WHERE FI_CODIGO=@CodigoFactura


		if exists (SELECT name FROM dbo.sysobjects WHERE dbo.sysobjects.name = N'indicedPer')
		begin
			DELETE FROM KARDESPERMISO WHERE kar_codigo in (select kar_codigo from indicedPer)
	
			UPDATE dbo.PERMISODET
			SET     dbo.PERMISODET.PED_SALDO= round(dbo.VPERMISOSALDO.KAR_SALDO,6),
			dbo.PERMISODET.PED_SALDOCOSTOT= round(dbo.VPERMISOSALDO.KAR_SALDOCOSTOT,6)
			FROM         dbo.PERMISODET INNER JOIN
			                      dbo.VPERMISOSALDO ON dbo.PERMISODET.PED_INDICED = dbo.VPERMISOSALDO.PED_INDICED 
			WHERE (round(dbo.PERMISODET.PED_SALDO,6) <> round(dbo.VPERMISOSALDO.KAR_SALDO,6)
			        or round(dbo.PERMISODET.PED_SALDOCOSTOT,6) <> round(dbo.VPERMISOSALDO.KAR_SALDOCOSTOT,6))
				and dbo.PERMISODET.PED_INDICED IN (SELECT PED_INDICED FROM indicedPer)
		
			UPDATE PERMISODET
			SET PED_ENUSO = 'N'
			FROM PERMISODET 
			WHERE PERMISODET.PED_SALDO = PERMISODET.PED_CANT AND PERMISODET.PED_ENUSO <> 'N' 
			AND PERMISODET.PED_INDICED IN (SELECT PED_INDICED FROM indicedPer)
	
			UPDATE PERMISODET
			SET PED_ENUSOCOSTOT = 'N'
			FROM PERMISODET 
			WHERE PERMISODET.PED_SALDOCOSTOT = PERMISODET.PED_COSTOT AND PERMISODET.PED_ENUSO <> 'N' 
			AND PERMISODET.PED_INDICED IN (SELECT PED_INDICED FROM indicedPer)



			-- los saldos totales en la caratula
			UPDATE dbo.PERMISO
			SET     dbo.PERMISO.PE_SALDO= round(dbo.VPERMISOSALDOTOT.KAR_SALDO,6),
			dbo.PERMISO.PE_SALDOCOSTOT= round(dbo.VPERMISOSALDOTOT.KAR_SALDOCOSTOT,6)
			FROM         dbo.PERMISO INNER JOIN
			                      dbo.VPERMISOSALDOTOT ON dbo.PERMISO.PE_CODIGO = dbo.VPERMISOSALDOTOT.PE_CODIGO 
			WHERE (round(dbo.PERMISO.PE_SALDO,6) <> round(dbo.VPERMISOSALDOTOT.KAR_SALDO,6)
			        or round(dbo.PERMISO.PE_SALDOCOSTOT,6) <> round(dbo.VPERMISOSALDOTOT.KAR_SALDOCOSTOT,6))
				and dbo.PERMISO.PE_CODIGO IN (SELECT PE_CODIGO FROM indicedPer)


			UPDATE PERMISO
			SET PE_ESTATUS='A'
			WHERE PE_SALDO >0	
			AND PE_CODIGO IN 
			(SELECT     PERMISODET.PE_CODIGO
			FROM         KARDESPERMISO INNER JOIN
			                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
			WHERE  (KARDESPERMISO.KAR_TIPO = 'C') 
			AND FI_CODIGO IN (SELECT FI_CODIGO FROM indicedPer)
			GROUP BY PERMISODET.PE_CODIGO)



			UPDATE PERMISO
			SET PE_ESTATUS='A'
			WHERE PE_SALDOCOSTOT >0	
			AND PE_CODIGO IN 
			(SELECT     PERMISODET.PE_CODIGO
			FROM         KARDESPERMISO INNER JOIN
			                      PERMISODET ON KARDESPERMISO.PED_INDICED = PERMISODET.PED_INDICED
			WHERE  (KARDESPERMISO.KAR_TIPO = 'V') 
			AND FI_CODIGO IN (SELECT FI_CODIGO FROM indicedPer)
			GROUP BY PERMISODET.PE_CODIGO)

	
		end


	exec  sp_droptable 'indicedPer'



	update permisodet
	set ped_enuso='N'
	where ped_cant = ped_saldo
	
	
	update permisodet
	set ped_enusocostot='N'
	where ped_costot = ped_saldocostot



















GO