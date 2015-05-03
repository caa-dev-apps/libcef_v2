#About:

    Product name: peace-A3

    Changelog:
        Release: 01
        Date:  2 May 2012
        Changes: Initial release 


#CEF Inputs:
    #0  
        File: HIA_ONBOARD_MOMENTS
            - time_tags__:                      T0
            - velocity_gse__ [0,1,2]:           Rx,Ry,Rz
            - velocity_isr2__[0,1,2]:           Sx,Sy,Sz

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
    
    in: Rx,Ry,Rz,Sx,Sy,Sz,
        Bx0,By0,Bz0,Bnumber,                              
        Wx0,Wy0,Wz0,                                      
        Lat,Long,
        T0
    
    2c.
        Bx1,By1,Bz1 = transform_gse_2_isr2(Bx0,By0,Bz0,Lat,Long)          
        
    2d. Calculate unit vector of B
    
        Bt0 = sqrt(Bx0^2+By0^2+Bz0^2)
        bx0 = Bx0/Bt0
        by0 = By0/Bt0
        bz0 = Bz0/Bt0
        
        Bt1 = sqrt(Bx1^2+By1^2+Bz1^2)
        bx1 = Bx1/Bt1
        by1 = By1/Bt1
        bz1 = Bz1/Bt1

    3. Calculate the velocity in GSE in inertial frame                            
    
        R1x = Rx - Wx0                                                    
        R1y = Ry - Wy0
        R1z = Rz - Wz0

    4c. Calculate spacecraft velocity in ISR2        
                    
        Wx1,Wy1,Wz1 = transform_gse_2_isr2(Wx0,Wy0,Wz0,Lat,Long)          

    4d. Calculate the velocity in ISR2 in inertial frame        
                                                                            
        S1x = Sx - Wx1
        S1y = Sy - Wy1
        S1z = Sz - Wz1
                    
    5a. Calculate parallel component of velocity in GSE/ISR2 in inertial frame, called R1par (GSE) and V1par (ISR2), with components:
    
        RR = R1x*bx0 + R1y*by0 + R1z*bz0
                    
        R1parX = RR*bx0                                            
        R1parY = RR*by0
        R1parZ = RR*bz0
                   
        SS = S1x*bx1 + S1y*by1 + S1z*bz1
        
        S1parX = SS*bx1
        S1parY = SS*by1
        S1parZ = SS*bz1

    5b. Calculate perpendicular component of velocity in GSE/ISR2 in inertial frame, called R1p (GSE) and V1p (ISR2), with components:
    
        R1px = R1x - R1parX                                         
        R1py = R1y - R1parY         
        R1pz = R1z - R1parZ         
                     
        S1px = S1x - S1parX         
        S1py = S1y - S1parY         
        S1pz = S1z - S1parZ         

    6. Calculate E-field in GSE/ISR2 (inertial frame)
    6a. Calculate the electric field of the drift velocity in GSE/ISR2 in inertial frame, called E1 (GSE) and E2 (ISR2), with components:
                                                                                
        E1x = R1py*Bz0 - R1pz*By0                                  
        E1y = R1pz*Bx0 - R1px*Bz0 
        E1z = R1px*By0 - R1py*Bx0 
        
        E2x = S1py*Bz1 - S1pz*By1 
        E2y = S1pz*Bx1 - S1px*Bz1 
        E2z = S1px*By1 - S1py*Bx1 
                    

#Products: 
                              
    8.  Datasets:
            C?_CP_CIS-HIA_ONBOARD_MOMENTS_ISR2_INERT:
                T0,            
                R1x,R1y,R1z,
                S1x,S1y,S1z,
                R1px,R1py,R1pz,
                S1px,S1py,S1pz,
                R1parX,R1parY,R1parZ,
                S1parX,S1parY,S1parZ,
                E1x,E1y,E1z,
                E2x,E2y,E2z,
                Rx,Ry,Rz,Sx,Sy,Sz,
                Bx0,By0,Bz0,Bnumber,            
                Wx0,Wy0,Wz0,                      
                Lat,Long            
            
            

#Notes:                
    - CEH Files:
        7. Create new variables                              
           Note variable names follow the CIS naming convention                               
            
            R1x,R1y,R1z,                    velocity_gse_inert                             
            S1x,S1y,S1z,                    velocity_isr2_inert                             
            R1px,R1py,R1pz,                 velocity_perp_gse _inert                        
            S1px,S1py,S1pz,                 velocity_perp _isr2_inert                       
            R1parX,R1parY,R1parZ,           velocity_par_gse_inert                          
            S1parX,S1parY,S1parZ,           velocity_par_isr2_inert                         
            E1x,E1y,E1z,                    Efield_gse_inert                                
            E2x,E2y,E2z,                    Efield _isr2_inert         

