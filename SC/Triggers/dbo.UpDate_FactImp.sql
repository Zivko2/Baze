SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















Create Trigger [UpDate_FactImp] On dbo.FactImp 
For UpDate
As
Declare @PiCodigo Int,@Fi_Tipo Char(1),@Fi_Estatus Char(1),@Fi_Cancelado Char(1),
@CodigoFactura Int,@Pi_Rectifica Int,@Fc_Codigo Int,@Fi_Con_Ped Char(1) 

If UpDate(Pi_Codigo) Or UpDate(Pi_Rectifica) Or UpDate(Fi_Tipo) Or UpDate(Fi_Cancelado) 
Begin
	Declare Cur_facturaImp Cursor For
	Select Fi_Estatus,Pi_Codigo,Fi_Cancelado,Fi_Tipo,Fi_Codigo     
	From Inserted
		
	Open Cur_facturaImp
	Fetch Next From Cur_facturaImp
	Into @Fi_Estatus,@PiCodigo,@Fi_Cancelado,@Fi_Tipo,@CodigoFactura 
		
	While (@@Fetch_Status = 0) 
	Begin
		Select @Pi_Rectifica = Pi_Rectifica,
		@Fc_Codigo = Fc_Codigo   --- La variable @fc_codigo toma valor
		From FactImp 
		Where Fi_Codigo = @CodigoFactura

---									Modificación	02/Julio/2010
--- Sustitución del procedimiento almacenado spActualizaEstatusFactImp, para evitar error con SQL Server 2005 al 
--- deshabilitarse el trigger de actualización actual, en el mismo.

		If UpDate (Pi_Codigo) Or Update(Fi_Cancelado) Or UpDate(Fi_Tipo)
		Begin
			--- Exec Sp_ActualizaEstatusFactImp @CodigoFactura
			
			--- Se ejecutan los UpDate
			If @Fi_Cancelado = 'S'
				UpDate FactImp 
				Set Fi_Estatus = 'A'
				Where Fi_Codigo = @CodigoFactura -- A	= Cancelada 
				And Fi_estatus <> 'A'
			Else
				If @Fi_Cancelado = 'N'
				Begin
					If @Fi_Tipo = 'T' 
						Begin
							---- La variable @fi_con_ped toma valor
							Select @Fi_Con_Ped = Case When Pi_Codigo < 0 And Pi_Rectifica < 0 
												Then 
													'N' 
												Else 
													'S' 
												End
							From FactImp 
							Where Fi_Codigo = @CodigoFactura
		
							If @Fi_Con_Ped = 'N'
								UpDate FactImp 
								Set Fi_Estatus = 'T' 
								Where Fi_Codigo = @CodigoFactura -- T = Transformadores sin integrar
								And Fi_Estatus <> 'T'
							Else
								UpDate FactImp 
								Set Fi_Estatus = 'L' 
								Where Fi_Codigo = @CodigoFactura -- L = Transformadores - integrada
								And Fi_Estatus <> 'L'
						End
					Else
						If @Fi_Tipo <> 'T'
							Begin
								If @Fi_Con_Ped = 'N' 
									Begin
										UpDate FactImp 
										Set Fi_Estatus = 'S' 
										Where Fi_codigo = @CodigoFactura -- S = Sin Pedimento 
										And Fi_Estatus <> 'S'
									End
								Else
									If @Fi_Con_Ped = 'S'  
										UpDate FactImp 
										Set Fi_Estatus = 'C' 
										Where Fi_Codigo = @CodigoFactura --- C	 = Con Pedimento
										And Fi_Estatus <> 'C'
							End
				End

		End	

				
		If UpDate (Pi_Codigo) And (@PiCodigo = -1)
			Begin
				If Exists(Select * From AlmacenDesp Where Fetr_Codigo = @CodigoFactura And Tipo_Ent_Sal ='E')
					Delete From AlmacenDesp 
					Where Fetr_Codigo = @CodigoFactura 
					And Tipo_Ent_Sal ='E'
	
				If Exists(Select * From FactImpDet Where Fi_Codigo = @CodigoFactura)
					UpDate FactImpDet
					Set Pid_IndicedLiga = -1
					Where Fi_Codigo = @CodigoFactura

			End
	
		If UpDate(Pi_Rectifica) And @Pi_Rectifica=-1
			Begin
				If Exists(Select Fi_Codigo From Factimp Where Pi_Rectifica = @Pi_Rectifica And Fi_Codigo Not In
				(Select Fi_Codigo From dbo.FactImp Where Pi_Codigo = @PiCodigo))					
					UpDate FactImp
					Set Pi_Rectifica = -1
					Where Pi_Rectifica = @Pi_Rectifica And Fi_Codigo Not In
					(Select Fi_Codigo From dbo.FactImp Where Pi_Codigo = @PiCodigo)
	
				If Exists(Select * From FactImpdet Where Fi_Codigo = @CodigoFactura)
						UpDate FactimpDet
						Set Pid_IndicedLigar1=-1
						Where Fi_Codigo = @CodigoFactura
			End
	
		Fetch Next From Cur_FacturaImp 
		Into @Fi_Estatus,@PiCodigo,@Fi_Cancelado,@Fi_Tipo,@CodigoFactura
	End
	
	Close Cur_FacturaImp
	DealLocate Cur_FacturaImp
	
End


GO
