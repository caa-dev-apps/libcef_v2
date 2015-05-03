local l_parent_folder = arg[0]:gsub('[^\\/]+$', '').. "/../"

package.path = package.path .. ';'   .. l_parent_folder .. '?.lua'
package.cpath = package.cpath .. ';' .. l_parent_folder .. '/bin/?.so'
package.cpath = package.cpath .. ';' .. l_parent_folder .. '/bin/?.dll'

require 'lib.cef_interpolator'
require 'lib.cef_iso_time'
require 'lib.cef_header'
require 'lib.cef_writer'
require 'lib.cef_utils'
require 'lib.cef_log'

-- luajit required (slightly different api for standard lua)
local bit = require 'bit'
local band = bit.band

local libcef_v2 = require 'libcef_v2'

--  ///////////////////////////////////////////////////////////////////////////
--  //        
--  //        A3. C*_CP_CIS-HIA_ONBOARD_MOMENTS_ISR2_INERT 
--  //        
--  //        These datasets (two) are based on C*_CP_CIS-HIA_ONBOARD_MOMENTS 
--  //        and contains several new vectors in ISR2/GSE in inertial frame. 
--  //        This is available for C1 and C3.
--  //        

--  ///////////////////////////////////////////////////////////////////////////
--  //

--  // Math functions:
--  // math.abs, math.acos, math.asin, math.atan, math.atan2,
--  // math.ceil, math.cos, math.cosh, math.deg, math.exp, math.floor, 
--  // math.fmod, math.frexp, math.huge, math.ldexp, math.log, math.log10,
--  // math.max, math.min, math.modf, math.pi, math.pow, math.rad,
--  // math.random, math.randomseed, math.sin, math.sinh, math.sqrt,
--  // math.tan, math.tanh

local sqrt = math.sqrt
local abs = math.abs
local atan = math.atan
local pi = math.pi

function main_interpolator_peace_A1(i_cef_filepath_HIA_ONBOARD_MOMENTS,         -- // HIA_ONBOARD_MOMENTS
                                    i_cef_filepath_FGM_5VPS,                    -- // FGM_5VPS
                                    i_cef_filepath_AUX_PosGSE_1M,               -- // AUX_PosGSE_1M
                                    i_cef_filepath_AUX_LatLong,                 -- // AUX_LatLong
                                    i_out_folder)
                                     
    local m_file_data = get_file_data(i_cef_filepath_HIA_ONBOARD_MOMENTS)
    set_fill_val(FILL_VAL)

    local m_cef_writer_factory = new_cef_writer_factory(i_out_folder, m_file_data)
    local m_cef_writer_HIA_ONBOARD_MOMENTS_ISR2_INERT   = m_cef_writer_factory:open("HIA_ONBOARD_MOMENTS_ISR2_INERT")
    
    local m_data =
    {
      {
          filepath = i_cef_filepath_HIA_ONBOARD_MOMENTS,
          tag = "HIA_ONBOARD_MOMENTS",
          vars =
          {
              "time_tags__",                                                    -- // T0
              "velocity_gse__",                                                 -- // Rx
              1,                                                                -- // Ry
              1,                                                                -- // Rz
              "velocity_isr2__",                                                -- // Sx
              1,                                                                -- // Sy
              1                                                                 -- // Sz
          }                                             
      },                                                
      {                                                 
          filepath = i_cef_filepath_FGM_5VPS,           
          tag = "FGM_5VPS",                             
          use_averages = true,                                                  -- // Bnumber number of values used for average value
          vars =                                        
          {                                             
              "time_tags__",                                                    -- // T1
              "B_vec_xyz_gse__",                                                -- // Bx
              1,                                                                -- // By
              1                                                                 -- // Bz
          }                                             
      },                                                
      {                                                 
          filepath = i_cef_filepath_AUX_PosGSE_1M,      
          tag = "AUX_POSGSE_1M",                        
          vars =                                        
          {                                             
              "time_tags__",                                                    -- // T2
              "sc_v_xyz_gse__",                                                 -- // Wx
              1,                                                                -- // Wy
              1                                                                 -- // Wz
          }                                             
      },                                                
      {                                                 
          filepath = i_cef_filepath_AUX_LatLong,        
          tag = "AUX_Lat_Long",                         
          vars =                                        
          {                                             
              "time_tags__",                                                    -- // T3 ???????????????????
              "sc_at".. m_file_data.spacecraft.. "_lat",                        -- // sc_at".. n.. "_lat
              "sc_at".. m_file_data.spacecraft.. "_long"                        -- // sc_at".. n.. "_long
          }
      },
    }

--  ///////////////////////////////////////////////////////////////////////////
--  //

    function process_peace_A1(Rx,Ry,Rz,Sx,Sy,Sz,
                              Bx0,By0,Bz0,Bnumber,                              -- // 0 postfix added for sync with notes
                              Wx0,Wy0,Wz0,                                      -- // 0 postfix added for sync with notes
                              Lat,Long,
                              T0)
        local Bx1,By1,Bz1 = transform_gse_2_isr2(Bx0,By0,Bz0,Lat,Long)          -- // 2c.

        local Bt0 = is_fill(Bx0,By0,Bz0) or                                     -- // 2d. Calculate unit vector of B
                   sqrt(Bx0^2+By0^2+Bz0^2)
        local bx0 = is_fill(Bx0,Bt0) or
                    Bx0/Bt0
        local by0 = is_fill(By0,Bt0) or
                    By0/Bt0
        local bz0 = is_fill(Bz0,Bt0) or
                    Bz0/Bt0
        
        local Bt1 = is_fill(Bx1,By1,Bz1) or                              
                   sqrt(Bx1^2+By1^2+Bz1^2)
        local bx1 = is_fill(Bx1,Bt1) or
                    Bx1/Bt1
        local by1 = is_fill(By1,Bt1) or
                    By1/Bt1
        local bz1 = is_fill(Bz1,Bt1) or
                    Bz1/Bt1

                    
        -- // Calculate the velocity in GSE in inertial frame                            
        local R1x = is_fill(Rx,Wx0) or                                          -- // 3
                    Rx - Wx0                                                    -- // Calculate the velocity in GSE in inertial frame,
        local R1y = is_fill(Ry,Wy0) or                                          -- // R1 vector with components: R1x, R1y, R1z (from Rx, Ry, Rz)
                    Ry - Wy0
        local R1z = is_fill(Rz,Wz0) or
                    Rz - Wz0

                    
        local Wx1,Wy1,Wz1 = transform_gse_2_isr2(Wx0,Wy0,Wz0,Lat,Long)          -- // 4c. Calculate spacecraft velocity in ISR2

                                                                            
        local S1x = is_fill(Sx,Wx1) or                                          -- // 4d. Calculate the velocity in ISR2 in inertial frame
                    Sx - Wx1
        local S1y = is_fill(Sy,Wy1) or
                    Sy - Wy1
        local S1z = is_fill(Sz,Wz1) or
                    Sz - Wz1
                    
                    
        local RR = R1x*bx0 + R1y*by0 + R1z*bz0
                    
        local R1parX = is_fill(RR,bx0) or                                      -- // 5a. Calculate parallel component of velocity in 
                       RR*bx0                                                  -- // GSE/ISR2 in inertial frame, called R1par (GSE) 
        local R1parY = is_fill(RR,by0) or                                      -- // and V1par (ISR2), with components:
                       RR*by0
        local R1parZ = is_fill(RR,bz0) or
                       RR*bz0
                   
        local SS = S1x*bx1 + S1y*by1 + S1z*bz1
        
        local S1parX = is_fill(SS,bx1) or
                       SS*bx1
        local S1parY = is_fill(SS,by1) or
                       SS*by1
        local S1parZ = is_fill(SS,bz1) or
                       SS*bz1

                       
        local R1px = is_fill(R1x,R1parX) or                                     -- // 5b. Calculate perpendicular component of velocity 
                     R1x - R1parX                                               -- // in GSE/ISR2 in inertial frame, called R1p (GSE) 
        local R1py = is_fill(R1y,R1parY) or                                     -- // and V1p (ISR2), with components:
                     R1y - R1parY         
        local R1pz = is_fill(R1z,R1parZ) or
                     R1z - R1parZ         
                     
        local S1px = is_fill(S1x,S1parX) or
                     S1x - S1parX         
        local S1py = is_fill(S1y,S1parY) or
                     S1y - S1parY         
        local S1pz = is_fill(S1z,S1parZ) or
                     S1z - S1parZ         

                     
                                                                                -- // 6. Calculate E-field in GSE/ISR2 (inertial frame)
        local E1x = is_fill(R1py,Bz0,R1pz,By0) or                               -- // 6a. Calculate the electric field of the drift 
                    R1py*Bz0 - R1pz*By0                                         -- // velocity in GSE/ISR2 in inertial frame, called E1 
        local E1y = is_fill(R1pz,Bx0,R1px,Bz0) or                               -- // (GSE) and E2 (ISR2), with components:
                    R1pz*Bx0 - R1px*Bz0 
        local E1z = is_fill(R1px,By0,R1py,Bx0) or
                    R1px*By0 - R1py*Bx0 
        local E2x = is_fill(S1py,Bz1,S1pz,By1) or
                    S1py*Bz1 - S1pz*By1 
        local E2y = is_fill(S1pz,Bx1,S1px,Bz1) or
                    S1pz*Bx1 - S1px*Bz1 
        local E2z = is_fill(S1px,By1,S1py,Bx1) or
                    S1px*By1 - S1py*Bx1 
                    

        -- // 7. Create new variables
        -- // Note variable names follow the CIS naming convention
        -- //     
                    
        R1x,R1y,R1z,                                        -- // velocity_gse _inert                             
        S1x,S1y,S1z,                                        -- // velocity_isr2_inert                             
        R1px,R1py,R1pz,                                     -- // velocity_perp_gse _inert                        
        S1px,S1py,S1pz,                                     -- // velocity_perp _isr2_inert                       
        R1parX,R1parY,R1parZ,                               -- // velocity_par_gse_inert                          
        S1parX,S1parY,S1parZ,                               -- // velocity_par_isr2_inert                         
        E1x,E1y,E1z,                                        -- // Efield_gse_inert                                
        E2x,E2y,E2z,                                        -- // Efield _isr2_inert         
        Rx,Ry,Rz,Sx,Sy,Sz,
        Bx0,By0,Bz0,Bnumber,
        Wx0,Wy0,Wz0,                    
        Lat,Long = to_3_decimal_places                                                    
        {                                                                   
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
        }                                                

        -- // OUTPUT
        -- // Dataset name: C1_CP_CIS-HIA_ONBOARD_MOMENTS_ISR2_INERT
        -- // Variables: all from sections 1 and 7
        -- // Metadata for variables of sections 7 require editing although the 
        -- // metadata of velocity_gse and velocity_isr2 give a good start
        -- // 8. Write new dataset 
        
        m_cef_writer_HIA_ONBOARD_MOMENTS_ISR2_INERT:writeln(T0,
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
                                                            )
    end
                    

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local l_record_count = 0
    local l_timer = new_Timer("timer: ")
    
    local l_iter_data = new___iter_data_func_c(m_data)
    
    -- // ugly after thought... sorry.. order matters! .careful!
    -- // '_' => don't care... nil
    local T0_fill, Rx_fill, Ry_fill, Rz_fill, Sx_fill, Sy_fill, Sz_fill, 
          _, Bx_fill, By_fill, Bz_fill, 
          _, Wx_fill, Wy_fill, Wz_fill, 
          _, Lat_fill, Long_fill = l_iter_data:get_fillvars()

    for T0,Rx,Ry,Rz,Sx,Sy,Sz,
        T1,Bx,By,Bz,Bnumber,
        T2,Wx,Wy,Wz,
        T3,Lat,Long
        in l_iter_data.get_iter_func() do

        if Rx == nil then break end

-- //        print(T0,Rx,Ry,Rz,Sx,Sy,Sz)
-- //        print(T1,Bx,By,Bz,Bnumber)
-- //        print(T2,Wx,Wy,Wz)
-- //        print(T3,Lat,Long)
-- //        print()
        
        Rx,Ry,Rz = normalise_fillvals(Rx,Ry,Rz, Rx_fill)
        Sx,Sy,Sz = normalise_fillvals(Sx,Sy,Sz, Sx_fill)
        Bx,By,Bz = normalise_fillvals(Bx,By,Bz, Bx_fill)
        Wx,Wy,Wz = normalise_fillvals(Wx,Wy,Wz, Wx_fill)
        Lat,Long = normalise_fillvals(Lat,Long, Lat_fill)

        process_peace_A1(Rx,Ry,Rz,Sx,Sy,Sz,         -- // 1a
                         Bx,By,Bz,Bnumber,          -- // 2a 
                         Wx,Wy,Wz,                  -- // 3a
                         Lat,Long,                  -- // 6a
                         T0)                        -- // 1-

        l_record_count = l_record_count + 1

        if l_record_count % 100000 == 0 then
                l_timer.now()

                print(l_record_count, 
                      T0, T1, T2, T3)
                end
-- //        if l_record_count > 10 then
-- //            break
-- //        end
        end

    l_timer.stop()
    print("count:", l_record_count)
    m_cef_writer_factory:close(l_record_count)
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

main_interpolator_peace_A1(arg[1],                     -- // HIA_ONBOARD_MOMENTS
                           arg[2],                     -- // FGM_5VPS
                           arg[3],                     -- // AUX_PosGSE_PosGSE_1M
                           arg[4],                     -- // AUX_LatLong
                           arg[5])           

