SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE TRIGGER [Del_cargo] ON [dbo].[CARGO] 
FOR DELETE 
AS



   IF EXISTS (SELECT * FROM CargoDet ,deleted WHERE CargoDet.car_codigo = deleted.car_codigo)
      DELETE CargoDet FROM CargoDet ,deleted WHERE CargoDet.car_codigo = deleted.car_codigo


   IF EXISTS (SELECT * FROM CargoRelArancel ,deleted WHERE CargoRelArancel.car_codigo = deleted.car_codigo)
      DELETE CargoRelArancel FROM CargoRelArancel ,deleted WHERE CargoRelArancel.car_codigo = deleted.car_codigo
































GO
