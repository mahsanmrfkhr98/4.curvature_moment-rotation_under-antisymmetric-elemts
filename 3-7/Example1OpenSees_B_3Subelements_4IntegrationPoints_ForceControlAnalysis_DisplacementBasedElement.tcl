# Clear Previous Data
wipe
# units: lb, psi, in
# Define Model Properties: model  BasicBuilder  -ndm  Number_of_Dimensions  -ndf  Nunber_of_DoFs_in_Each_Node
						   model  BasicBuilder  -ndm         2              -ndf              3
						   
# Define Nodes Information
	# Create the actual nodes: node  node#   x[in]  y[in]
					           node    1      0.0    0.0
					           node    2     61.33   0.0
					           node    3    122.66   0.0
                               node    4    184.0    0.0
	
	
	#					    region  Region#  -Type  Target_Nodes 
				   		    region    1      -node    1 2 3 4			   
							
	#						fix  Node#  X_Restrain   Y_Restrain   Rotation_Restrained
						    fix    1         1               1                0
					        fix    4         1               1                0
	
	#                      uniaxialMaterial  Steel01  Material#  Fy[psi]    E[psi]    alpha[-]  
						   uniaxialMaterial  Steel01     1       36000.0  38000000.0   0.03
						   
						   
	#					   section  WFSection2d  Section#  Material#  d[in]  tw[in]  b[in]  tf[in]  Number_of_Web_Fibers  Number_of_Flange_Fibers
                           section  WFSection2d     1         1       24.48   0.605  12.855  0.960            4                     4
						   
	#						  geomTransf  Type[Linear/PDelta]  Transformer#	
	                          geomTransf       Linear               1
                              geomTransf       Linear               2
                              geomTransf       Linear               3
							  
	#                        element  forceBeamColumn  Element#  Left_Node  Right_Node  Number_of_Integration_Points  Section#  Transformer#  -integration  Integration_Type
                             element  dispBeamColumn     1          1           2                    7                  1           1        -integration      Lobatto
                             element  dispBeamColumn     2          2           3                    7                  1           2        -integration      Lobatto
                             element  dispBeamColumn     3          3           4                    7                  1           3        -integration      Lobatto
																
	#        	                   region  Region#  -Type  Target_Elements 
				   			       region    2      -ele        1 2 3

# Define Applied Loads
	#          Linear Loading TimeSeries: timeSeries  Linear  TimeSeries#
								          timeSeries  Linear      1
									 
	#  Plain load pattern associated with the TimeSeries: pattern  Plain  pattern#  Assigned_TimeSeries#  {
												     	  pattern  Plain     1              1             {
	#     nodal loads:																					     load  Node#  X_Value[lb]  Y_Value[lb]  Moment_Value[lb.in]
																												     load    1      0.0          0.0            21000.0
																												     load    4      0.0          0.0            21000.0
																												  }

# Define Analysis Parameters																							  
							system SparseGeneral
							numberer RCM
							constraints Transformation 	
#                 Reminder: integrator LoadControl  Magnitude_of_Load_Increase_in_Each_Step							
							integrator LoadControl                     1.0					
                            test EnergyIncr 0.00001 5000000 0
							algorithm Newton
							analysis Static
							
# Create Output Files
	# Output File for Nodal Info:    recorder  Node     -file  Output_File_Name            -time[?]  -node/Region  Node/Region#     -dof  Target_DoFs  Type
									 recorder  Node     -file  OSDCNode1Rotation.txt                 -node             1            -dof       3       disp
										                                                   
	# Output File for Elements Info: recorder  Element  -file  Output_File_Name            -time[?]  -ele/Region   Element/Region#                     Type
                                     recorder  Element  -file  OSDCElementsCurvatures.txt            -region              2                            section deformation
									 
# Start the Analysis: analyze  Number_of_Steps									 
					  analyze        1000															
																