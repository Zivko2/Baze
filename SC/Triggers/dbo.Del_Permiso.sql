SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE trigger Del_Permiso on dbo.PERMISO for DELETE as
begin


   IF EXISTS (SELECT * FROM PermisoDet ,deleted WHERE PermisoDet.pe_codigo = deleted.pe_codigo)
      DELETE PermisoDet FROM PermisoDet ,deleted WHERE PermisoDet.pe_codigo = deleted.pe_codigo

   IF EXISTS (SELECT * FROM PermisoAgencia ,deleted WHERE PermisoAgencia.pe_codigo = deleted.pe_codigo)
      DELETE PermisoAgencia FROM PermisoAgencia ,deleted WHERE PermisoAgencia.pe_codigo = deleted.pe_codigo


   IF EXISTS (SELECT * FROM PermisoClientes ,deleted WHERE PermisoClientes.pe_codigo = deleted.pe_codigo)
      DELETE PermisoClientes FROM PermisoClientes ,deleted WHERE PermisoClientes.pe_codigo = deleted.pe_codigo

   IF EXISTS (SELECT * FROM PermisoGral ,deleted WHERE PermisoGral.pe_codigo = deleted.pe_codigo)
      DELETE PermisoGral FROM PermisoGral ,deleted WHERE PermisoGral.pe_codigo = deleted.pe_codigo

   IF EXISTS (SELECT * FROM PermisoPorcentaje ,deleted WHERE PermisoPorcentaje.pe_codigo = deleted.pe_codigo)
      DELETE PermisoPorcentaje FROM PermisoPorcentaje ,deleted WHERE PermisoPorcentaje.pe_codigo = deleted.pe_codigo

   IF EXISTS (SELECT * FROM PermisoPT ,deleted WHERE PermisoPT.pe_codigo = deleted.pe_codigo)
      DELETE PermisoPT FROM PermisoPT ,deleted WHERE PermisoPT.pe_codigo = deleted.pe_codigo

   IF EXISTS (SELECT * FROM PermisoVentas ,deleted WHERE PermisoVentas.pe_codigo = deleted.pe_codigo)
      DELETE PermisoVentas FROM PermisoVentas ,deleted WHERE PermisoVentas.pe_codigo = deleted.pe_codigo

	declare @consecutivo int

	SELECT @consecutivo = isnull(MAX(PE_CODIGO),0)+1 FROM PERMISO

	update consecutivo
	set cv_codigo = @consecutivo
	where cv_tipo ='PE'
end































GO
