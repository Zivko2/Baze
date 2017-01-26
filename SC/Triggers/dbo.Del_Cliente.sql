SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE trigger Del_Cliente on dbo.CLIENTE for DELETE as
begin


   IF EXISTS (SELECT * FROM Dir_Cliente ,deleted WHERE Dir_Cliente.Cl_Codigo = deleted.Cl_Codigo)
      DELETE Dir_Cliente FROM Dir_Cliente ,deleted WHERE Dir_Cliente.Cl_Codigo = deleted.Cl_Codigo


	if not exists (select * from clientedel where cl_codigo in (select cl_codigo from deleted))
	INSERT INTO CLIENTEDEL(CL_CODIGO, CL_RAZON)
	SELECT CL_CODIGO, CL_RAZON FROM DELETED

end

GO
