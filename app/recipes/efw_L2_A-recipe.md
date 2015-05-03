#About:

    Product name: efw_L2_A

    Changelog:
        Release: 01
        Date:  2011
        Changes: Initial release 


#CEF Inputs:
    #0  
        File: EFW
            - time_tags__:                      T0
            - E_Vec_xy_ISR2__ [0,1,2]:          Ex,Ey
            - E_bitmask__                       E_bitmask
            - E_quality__                       E_quality

    #1
         File: AUX_POSGSE_1M
            - time_tags__:                      T2
            - sc_v_xyz_gse__[0,1,2]:            Vxi,Vyi,Vzi
    
    #2
        File: FGM
            - time_tags__:                      T1
            - B_vec_xyz_gse__[0,1,2]:           Bxi,Byi,Bzi
        add_interpolation_separation:           true
        
    #3
         File: SP_AUX_LatLong
            - time_tags__:                      T3
            - sc_at${space_craft_id}_lat        Lat                     
            - sc_at${space_craft_id}_long       Long
    
    
    
#Product Function:    
    
    in: Ex, Ey,
        Vxi,Vyi,Vzi,
        Bxi,Byi,Bzi,BSeparation,
        Lat,Long,
        T0, E_bitmask,E_quality

        
        if E_quality < 2 then
            Vxi,Vyi = FILL_VAL, FILL_VAL
        end
                
    6.
        Vxi1,Vyi1,Vzi1 = transform_gse_2_isr2(Vxi,Vyi,Vzi,Lat,Long)    
        
    7.
        Bxi1,Byi1,Bzi1 = transform_gse_2_isr2(Bxi,Byi,Bzi,Lat,Long)    

    8.
        Ez = FILL_VAL
        if E_quality >= 2 then
            Ez = -(Ex*Bxi1 + Ey*Byi1)/Bzi1                                   
        end
        
    9.
        Bt = sqrt(Bxi1^2+Byi1^2+Bzi1^2)                                

        Bt_pow2 = Bt^2
        Bt_pow4 = Bt^4

    10.
        C = 1                                                          
        D = 0.3
        dEz = C*abs(Bxi1/Bzi1) + D*abs(Ex*Bxi1 + Ey*Byi1)/Bzi1^2

    11.
        VBx = (Vyi1*Bzi1 - Vzi1*Byi1) / 1000
        VBy = (Vzi1*Bxi1 - Vxi1*Bzi1) / 1000
        VBz = (Vxi1*Byi1 - Vyi1*Bxi1) / 1000

    12.
        Ex1 = Ex - VBx
        Ey1 = Ey - VBy
        Ez1 = Ez - VBz

    13.
        theta = atan(Bzi1/sqrt(Bxi1^2+Byi1^2))*180/pi                  

    14.
        Ez2=Ez1                                                
        if abs(Bzi1)<2 or abs(theta)<15 then Ez2 = FILL_VAL end


    15.
        -- 2012-03-29 *1000
        Wx1 = 1000 * ((Ey1*Bzi1- Ez1*Byi1)/Bt_pow2)
        Wy1 = 1000 * ((Ez1*Bxi1- Ex1*Bzi1)/Bt_pow2)
        Wz1 = 1000 * ((Ex1*Byi1- Ey1*Bxi1)/Bt_pow2)
        Wx2 = 1000 * ((Ey1*Bzi1- Ez2*Byi1)/Bt_pow2)
        Wy2 = 1000 * ((Ez2*Bxi1- Ex1*Bzi1)/Bt_pow2)
        Wz2 = Wz1

    16.
        dWx1 = 1000 * (abs(dEz*Byi1)/Bt_pow2 + D*abs(Ey1/Bt_pow2 - 2*Bzi1*(Ey1*Bzi1-Ez1*Byi1)/Bt_pow4))
        dWy1 = 1000 * (abs(dEz*Bxi1)/Bt_pow2 + C*abs(Bzi1)/Bt_pow2 + D*abs(-Ex1/Bt_pow2 - 2*Bzi1*(Ez1*Bxi1-Ex1*Bzi1)/Bt_pow4))
        dWz1 = 1000 * (C*abs(Byi1)/Bt_pow2 + D*abs(Bzi1*(Ex1*Byi1-Ey1*Bxi1))/Bt_pow4)
        dWx2 = 1000 * (abs(dEz*Byi1)/Bt_pow2 + D*abs(Ey1/Bt_pow2 - 2*Bzi1*(Ey1*Bzi1-Ez2*Byi1)/Bt_pow4))
        dWy2 = 1000 * (abs(dEz*Bxi1)/Bt_pow2 + C*abs(Bzi1)/Bt_pow2 + D*abs(-Ex1/Bt_pow2 - 2*Bzi1*(Ez2*Bxi1-Ex1*Bzi1)/Bt_pow4))
        dWz2 = dWz1

    17.
        ExGSE,EyGSE,EzGSE = transform_isr2_2_gse(Ex1,Ey1,Ez2,Lat,Long) 
        ExGSE_ex,EyGSE_ex,EzGSE_ex = transform_isr2_2_gse(Ex1,Ey1,Ez1,Lat,Long)  
        BxGSE,ByGSE,BzGSE = transform_isr2_2_gse(Bxi1,Byi1,Bzi1,Lat,Long)        
        
    18.
        WxGSE,WyGSE,WzGSE = transform_isr2_2_gse(Wx2,Wy2,Wz2,Lat,Long)           
        WxGSE_ex,WyGSE_ex,WzGSE_ex = transform_isr2_2_gse(Wx1,Wy1,Wz1,Lat,Long)  
                                  

#Products: 
                              
    Datasets:

        19. - 22.
        L2_E3D_INERT_EX(T0, Ex1,Ey1,Ez1, dEz, E_bitmask, E_quality, Bxi1,Byi1, Bzi1,theta,BSeparation)                        
        L2_E3D_INERT(T0, Ex1,Ey1,Ez2, dEz, E_bitmask, E_quality)                                                              
        L2_V3D_INERT_EX(T0, Wx1, Wy1, Wz1, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bzi1,theta,BSeparation)                      
        L2_V3D_INERT(T0, Wx2, Wy2, Wz2, dWx2,dWy2,dWz2, E_bitmask, E_quality)                                                 

        if E_quality < 2 then
            23. - 26.
            L2_E3D_GSE(T0, FILL_VAL,FILL_VAL,FILL_VAL, FILL_VAL, E_bitmask, E_quality)                                                                
            L2_V3D_GSE(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality)                                            
            L2_E3D_GSE_EX(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, E_bitmask, E_quality, FILL_VAL,FILL_VAL,FILL_VAL) 
            L2_V3D_GSE_EX(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality, FILL_VAL,FILL_VAL,FILL_VAL)             
        else
            23. - 26.
            L2_E3D_GSE(T0, ExGSE,EyGSE,EzGSE, dEz, E_bitmask, E_quality)                                                            
            L2_V3D_GSE(T0, WxGSE, WyGSE, WzGSE, dWx2,dWy2,dWz1, E_bitmask, E_quality)                                               
            L2_E3D_GSE_EX(T0, ExGSE_ex, EyGSE_ex, EzGSE_ex, BxGSE, ByGSE, BzGSE, dEz, E_bitmask, E_quality, Bzi1,theta,BSeparation) 
            L2_V3D_GSE_EX(T0, WxGSE_ex, WyGSE_ex, WzGSE_ex, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bzi1,theta,BSeparation)           
        end
                
