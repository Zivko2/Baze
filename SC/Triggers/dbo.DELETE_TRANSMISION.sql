SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE TRIGGER [DELETE_TRANSMISION] ON [dbo].[TRANSMISION] 
FOR DELETE 
AS


  IF EXISTS (SELECT * FROM TransmisionDet, Deleted  WHERE  TransmisionDet.Trm_Codigo = Deleted.Trm_Codigo)
     DELETE TransmisionDet FROM TransmisionDet, Deleted  WHERE TransmisionDet.Trm_Codigo = Deleted.Trm_Codigo


  IF EXISTS (SELECT * FROM TransmisionRel, Deleted  WHERE  TransmisionRel.Trm_Codigo = Deleted.Trm_Codigo)
     DELETE TransmisionRel FROM TransmisionRel, Deleted  WHERE TransmisionRel.Trm_Codigo = Deleted.Trm_Codigo




























GO
