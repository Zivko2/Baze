SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSFACTEXPALL]   as

--SET NOCOUNT ON 




	ALTER TABLE [FACTEXP]  DISABLE TRIGGER [UPDATE_FACTEXP]

declare @fe_tipo char(1), @feddescargado int, @fccodigo int, @sDischStatus char(1), @cancelada char(1), @picodigo int,
@fe_con_ped char(1)


		UPDATE FACTEXP
		SET PI_CODIGO=-1 WHERE
		PI_CODIGO NOT IN (SELECT PI_CODIGO FROM PEDIMP)



		update factexp
		set fe_descargada='N' 
		where fe_descargada<>'N'  and FE_FECHADESCARGA is NULL

		update factexp
		set fe_descargada='S' 
		where FE_FECHADESCARGA is not NULL


			-- A = Cancelada 
			update factexp 
			set fe_estatus = 'A' 
			where fe_estatus <> 'A' and fe_cancelado='S'

			-- T = Transformadores - sin congelar
			update factexp 
			set fe_estatus = 'T' 
			where fe_estatus <> 'T'  and fe_tipo='T' and fe_cancelado<>'S' and fe_descargada='N'

			-- T = Transformadores - congelada
			update factexp 
			set fe_estatus = 'L' 
			where fe_estatus <> 'L'  and fe_tipo='T' and fe_cancelado<>'S' and fe_descargada='S'



			-- N =  aviso traslado - sin descargar
			update factexp 
			set fe_estatus = 'N' 
			where fe_estatus <> 'N'  and fe_tipo='S' and fe_cancelado<>'S' and fe_descargada='N'

			-- V = aviso traslado - descargada
			update factexp 
			set fe_estatus = 'V' 
			where fe_estatus <> 'V'  and fe_tipo='S' and fe_cancelado<>'S' and fe_descargada='S'



			-- S = Descargada - Sin Pedimento
			update factexp 
			set fe_estatus = 'S' 
			where fe_estatus <> 'S' and pi_codigo<=0 and pi_trans<=0
			and fe_cancelado<>'S' and fe_descargada='S'

			-- C	 = Descarga Con Pedimento
			update factexp 
			set fe_estatus = 'C' 
			where  fe_estatus <> 'C' 
			and pi_codigo>0 and fe_cancelado<>'S' and fe_descargada='S'


			--D	= Sin Descargar, Sin Pedimento
			update factexp 
			set fe_estatus = 'D' 
			where  fe_estatus <> 'D' 
			and fe_cancelado<>'S'  and fe_descargada<>'S' and pi_codigo<=0 and pi_trans<=0

			-- P	= Sin Descargar, Con Pedimento 
			update factexp 
			set fe_estatus = 'P' 
			where  fe_estatus <> 'P' 
			and fe_cancelado<>'S' and fe_descargada<>'S' and (pi_codigo>0 or pi_trans>0)

	ALTER TABLE [FACTEXP]  ENABLE TRIGGER [UPDATE_FACTEXP]


GO
