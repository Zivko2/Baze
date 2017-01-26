SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[ImportarControlRetrabajo]  as

Declare @CR_Fecha datetime, @CR_Cantidad decimal(38,6), @MA_Codigo int , @MA_CodigoEspecial int, @MA_CodigoComponente int,
		@CRI_CantidadIncorporacion decimal(38,6), @MA_TIP_ENS char(1), @BSTCodigo int, @CR_Codigo int

Declare @CR_Nuevos table(CR_ID int identity(1,1) not null,
						 CRI_Codigo int not null,
						 CRI_Fecha datetime not null,
						 CRI_CantidadDescarga decimal(38,6) not null, 
						 MA_CodigoPT int not null,							
						 MA_CodigoComponente int not null,
						 CRI_CantidadIncorporacion decimal(38,6) not null,
						 MA_TIP_ENS char(1),
						 CR_Codigo int null
						 primary key clustered (CR_ID))
--Verifica que no existan todos los No. de Parte
if not exists(
select  ControlRetrabajoImportacion.CRI_NoPartePT
from ControlRetrabajoImportacion
	left outer join Maestro on ControlRetrabajoImportacion.CRI_NoPartePT = Maestro.MA_NoParte
						   and isnull(ControlRetrabajoImportacion.CRI_NoParteAuxPT,'') = Maestro.MA_NoparteAux
where maestro.ma_codigo is null
union
select  ControlRetrabajoImportacion.CRI_NoParteComponente
from ControlRetrabajoImportacion
	left outer join Maestro MaestroComp on ControlRetrabajoImportacion.CRI_NoParteComponente = MaestroComp.MA_NoParte
							and isNull(ControlRetrabajoImportacion.CRI_NoParteAuxComponente,'') = MaestroComp.MA_NoparteAux
where maestrocomp.ma_codigo is null)
	begin

			insert into @CR_Nuevos (CRI_Codigo, CRI_Fecha, CRI_CantidadDescarga, MA_CodigoPT, MA_CodigoComponente, CRI_CantidadIncorporacion, MA_TIP_ENS, CR_Codigo)
			select ControlRetrabajoImportacion.CRI_Codigo, ControlRetrabajoImportacion.CRI_Fecha, ControlRetrabajoImportacion.CRI_CantidadDescargar, Maestro.MA_Codigo,
			MaestroComponente.ma_codigo, ControlRetrabajoImportacion.CRI_CantidadIncorporacion, maestroComponente.MA_TIP_ENS, 0
			from ControlRetrabajoImportacion
				left outer join Maestro on ControlRetrabajoImportacion.CRI_NoPartePT = Maestro.MA_NoParte
									   and isnull(ControlRetrabajoImportacion.CRI_NoParteAuxPT,'') = Maestro.MA_NoparteAux
				left outer join ControlRetrabajo on Maestro.MA_Codigo = ControlRetrabajo.MA_Codigo 
											and ControlRetrabajo.CR_Fecha = ControlRetrabajoImportacion.CRI_Fecha
				left outer join Maestro MaestroComponente on ControlRetrabajoImportacion.CRI_NoParteComponente = MaestroComponente.MA_Noparte
														and isNull(ControlRetrabajoImportacion.CRI_NoParteAuxComponente,'') = MaestroComponente.MA_NoparteAux
			where ControlRetrabajo.CR_Codigo is null


			--No existen en CR
			Declare Cur_CRNuevos cursor for
			select CRI_Fecha, CRI_CantidadDescarga, MA_CodigoPT, MA_CodigoComponente, CRI_CantidadIncorporacion, MA_TIP_ENS 
			from @CR_Nuevos order by CRI_Fecha
			open cur_CRNuevos
			FETCH NEXT FROM cur_CRNuevos INTO @CR_Fecha, @CR_Cantidad, @MA_Codigo, @MA_CodigoComponente, @CRI_CantidadIncorporacion, @MA_TIP_ENS
			WHILE (@@FETCH_STATUS = 0) 
				BEGIN
					set @MA_CodigoEspecial = null
					select @MA_CodigoEspecial = MA_CodigoEspecial from ControlRetrabajo where CR_Fecha = @CR_Fecha and Ma_Codigo = @MA_Codigo
					if (@MA_CodigoEspecial is null)
						begin
							exec GenerarNoParteRetrabajo @MA_Codigo, @CONSECUTIVO = @MA_CodigoEspecial OUTPUT
							insert into ControlRetrabajo(CR_Fecha, CR_Cantidad, CR_Saldo, MA_codigo, MA_CodigoEspecial)
							values(@CR_Fecha, @CR_Cantidad, @CR_Cantidad, @MA_Codigo, @MA_CodigoEspecial)
						end
					exec stpGrabaStruct @MA_CodigoComponente, @MA_CodigoEspecial, '01/01/1999', '01/01/9999', 'N' , @MA_TIP_ENS, 0, @bst_codigo = @BSTCodigo output
					update bom_struct set BST_Incorpor = @CRI_CantidadIncorporacion where bst_codigo = @BSTCodigo
					FETCH NEXT FROM cur_CRNuevos INTO @CR_Fecha, @CR_Cantidad, @MA_Codigo, @MA_CodigoComponente, @CRI_CantidadIncorporacion, @MA_TIP_ENS
				END
			close cur_CRNuevos
			deallocate cur_CRNuevos


			--Si Existen en CR y no estan en BOM especial
			delete from @CR_Nuevos
			insert into @CR_Nuevos (CRI_Codigo, CRI_Fecha, CRI_CantidadDescarga, MA_CodigoPT, MA_CodigoComponente, CRI_CantidadIncorporacion, MA_TIP_ENS, CR_Codigo)
			select  ControlRetrabajoImportacion.CRI_Codigo, ControlRetrabajoImportacion.CRI_Fecha, ControlRetrabajoImportacion.CRI_CantidadDescargar,
					Maestro.MA_Codigo, MaestroComp.MA_Codigo, ControlRetrabajoImportacion.CRI_CantidadIncorporacion,
					MaestroComp.MA_TIP_ENS, ControlRetrabajo.CR_Codigo
			from ControlRetrabajoImportacion
				left outer join Maestro on ControlRetrabajoImportacion.CRI_NoPartePT = Maestro.MA_NoParte
									   and isnull(ControlRetrabajoImportacion.CRI_NoParteAuxPT,'') = Maestro.MA_NoparteAux
				left outer join Maestro MaestroComp on ControlRetrabajoImportacion.CRI_NoParteComponente = MaestroComp.MA_NoParte
									   and isnull(ControlRetrabajoImportacion.CRI_NoParteAuxComponente,'') = MaestroComp.MA_NoParteAux
				inner join ControlRetrabajo on Maestro.MA_Codigo = ControlRetrabajo.MA_Codigo 
											and ControlRetrabajo.CR_Fecha = ControlRetrabajoImportacion.CRI_Fecha
				left outer join Maestro MaestroEsp on ControlRetrabajo.MA_CodigoEspecial = MaestroEsp.Ma_Codigo
				left outer join Bom_Struct on MaestroEsp.MA_Codigo = Bom_struct.BSU_Subensamble
										and MaestroComp.MA_Codigo = Bom_Struct.BST_Hijo
			where bom_struct.bsu_subensamble is null	

			Declare Cur_CRNuevosBOM cursor for
			select CRI_Fecha, CRI_CantidadDescarga, MA_CodigoPT, MA_CodigoComponente, CRI_CantidadIncorporacion, MA_TIP_ENS, CR_Codigo
			from @CR_Nuevos order by CRI_Fecha
			open cur_CRNuevosBOM
			FETCH NEXT FROM cur_CRNuevosBOM INTO @CR_Fecha, @CR_Cantidad, @MA_Codigo, @MA_CodigoComponente, @CRI_CantidadIncorporacion, @MA_TIP_ENS, @CR_Codigo
			WHILE (@@FETCH_STATUS = 0) 
				BEGIN
					select @MA_CodigoEspecial = MA_CodigoEspecial from ControlRetrabajo where cr_codigo = @CR_Codigo
					exec stpGrabaStruct @MA_CodigoComponente, @MA_CodigoEspecial, '01/01/1999', '01/01/9999', 'N' , @MA_TIP_ENS, 0, @bst_codigo = @BSTCodigo output
					update bom_struct set BST_Incorpor = @CRI_CantidadIncorporacion where bst_codigo = @BSTCodigo
					FETCH NEXT FROM cur_CRNuevosBOM INTO @CR_Fecha, @CR_Cantidad, @MA_Codigo, @MA_CodigoComponente, @CRI_CantidadIncorporacion, @MA_TIP_ENS, @CR_Codigo
				END
			close cur_CRNuevosBOM
			deallocate cur_CRNuevosBOM
	end
GO
