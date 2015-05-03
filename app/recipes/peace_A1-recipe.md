#About:

    Product name: peace-A1

    Changelog:
        Release: 01
        Date:  2 May 2012
        Changes: Initial release 


#CEF Inputs:
    #0  
        File: PEA_MOMENTS
            - time_tags__:                      T0
            - Data_Velocity_GSE__ [0,1,2]:      Vx,Vy,Vz

    #1
        File: FGM_5VPS
            - time_tags__:                      T1
            - B_vec_xyz_gse__[0,1,2]:           Bx0,By0,Bz0
        use_averages:                           true
        
    #2
         File: AUX_POSGSE_1M
            - time_tags__:                      T2
            - sc_v_xyz_gse__[0,1,2]:            Wx0,Wy0,Wz0
    
    #3
         File: SP_AUX_LatLong
            - time_tags__:                      T3
            - sc_at${space_craft_id}_lat        Lat                     
            - sc_at${space_craft_id}_long       Long
    
    
    
#Product Function:    
    
    in: Vx,Vy,Vz,
        Bx0,By0,Bz0,Bnumber,                              
        Wx0,Wy0,Wz0,                                      
        Lat,Long,
        T0
    
    
    3. Calculate the velocity in GSE in inertial frame

        V1x = Vx - Wx0                                                    
        V1y = Vy - Wy0
        V1z = Vz - Wz0
                              
    4a. Calculate unit vector of B

        Bt = sqrt(Bx0^2+By0^2+Bz0^2)
        bx0 = Bx0/Bt
        by0 = By0/Bt
        bz0 = Bz0/Bt
                              
    4b. Calculate parallel component of V1, called 
        
        VV = V1x*bx0 + V1y*by0 + V1z*bz0

        V1parX = VV*bx0                                                  
        V1parY = VV*by0
        V1parZ = VV*bz0

    4c. Calculate perpendicular component of V1 in GSE in inertial frame, called V1p, with components:
    
        V1px = V1x-V1parX                                                 
        V1py = V1y-V1parY 
        V1pz = V1z-V1parZ 
                     
    5. Calculate E-field in GSE (inertial frame)
                                       
        E1x = V1py*Bz0 - V1pz*By0                                         
        E1y = V1pz*Bx0 - V1px*Bz0 
        E1z = V1px*By0 - V1py*Bx0 
                    
    6. Transform vectors from GSE into ISR2 (inertial frame)                              
    6b. Apply cef2cef (note: CL_SP_AUX dataset is needed)
        
        V2x,V2y,V2z          = transform_gse_2_isr2(V1x,V1y,V1z,Lat,Long)          
        V2px,V2py,V2pz       = transform_gse_2_isr2(V1px,V1py,V1pz,Lat,Long)    
        E2x,E2y,E2z          = transform_gse_2_isr2(E1x,E1y,E1z,Lat,Long)          
        V2parX,V2parY,V2parZ = transform_gse_2_isr2(V1parX,V1parY,V1parZ) 
                              

#Products: 
                              
    8.  Datasets:
            C?_CP_PEA_MOMENTS_ISR2_INERT:
                T0, 
                V1x,V1y,V1z,                                
                V2x,V2y,V2z,                                
                V1px,V1py,V1pz,                                
                V2px,V2py,V2pz,
                V1parX,V1parY,V1parZ,
                V2parX,V2parY,V2parZ,
                E1x,E1y,E1z,
                E2x,E2y,E2z,
                Vx,Vy,Vz,
                Bx0,By0,Bz0,Bnumber,
                Wx0,Wy0,Wz0,        
                Lat,Long

                
#Notes:                
    - CEH Files:
        7. Create new variables                              
           Note variable names follow the PEACE naming convention                               
            
            V1x,V1y,V1z,                    Data_Velocity_GSE_inert      
            V2x,V2y,V2z,                    Data_Velocity_ISR2_inert     
            V1px,V1py,V1pz,                 Data_PerpVelocity_GSE_inert    
            V2px,V2py,V2pz,                 Data_PerpVelocity_ISR2_inert  
            V1parX,V1parY,V1parZ,           Data_ParVelocity_GSE_inert
            V2parX,V2parY,V2parZ,           Data_ParVelocity_ISR2_inert  
            E1x,E1y,E1z,                    Data_Efield_GSE_inert         
            E2x,E2y,E2z,                    Data_Efield_ISR2_inert       

        
                