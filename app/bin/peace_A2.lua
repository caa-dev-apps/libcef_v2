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

-- // A2. 
-- // C*_CP_CIS-CODIF_HS_H1_MOMENTS_ISR2_INERT
-- // C*_CP_CIS-CODIF_LS_H1_MOMENTS_ISR2_INERT

function main_interpolator_peace_A1(i_cef_filepath_H1_MOMENTS,                  -- // CIS-CODIF_HS_H1_MOMENTS || CP_CIS-CODIF_LS_H1_MOMENTS
                                    i_cef_filepath_FGM_5VPS,                    -- // FGM_5VPS
                                    i_cef_filepath_AUX_PosGSE_1M,               -- // AUX_PosGSE_1M
                                    i_cef_filepath_AUX_LatLong,                 -- // AUX_LatLong
                                    i_out_folder)
                                     
    local m_file_data = get_file_data(i_cef_filepath_H1_MOMENTS)
    set_fill_val(FILL_VAL)

    local m_cef_writer_factory = new_cef_writer_factory(i_out_folder, m_file_data)

-- //    local m_cef_writer_L3_E3D_INERT_EX = m_cef_writer_factory:open("L3_E3D_INERT_EX")
-- //    local m_cef_writer_L3_E3D_INERT    = m_cef_writer_factory:open("L3_E3D_INERT")
-- //    local m_cef_writer_L3_V3D_INERT_EX = m_cef_writer_factory:open("L3_V3D_INERT_EX")
-- //    local m_cef_writer_L3_V3D_INERT    = m_cef_writer_factory:open("L3_V3D_INERT")
-- //    local m_cef_writer_L3_E3D_GSE      = m_cef_writer_factory:open("L3_E3D_GSE")
-- //    local m_cef_writer_L3_V3D_GSE      = m_cef_writer_factory:open("L3_V3D_GSE")
-- //    local m_cef_writer_L3_E3D_GSE_EX   = m_cef_writer_factory:open("L3_E3D_GSE_EX")
-- //    local m_cef_writer_L3_V3D_GSE_EX   = m_cef_writer_factory:open("L3_V3D_GSE_EX")
-- //    local m_cef_writer_L3_EV3D_INERT_EX = m_cef_writer_factory:open("L3_EV3D_INERT_EX")
-- //    local m_cef_writer_L3_EV3D_INERT    = m_cef_writer_factory:open("L3_EV3D_INERT")
-- //    local m_cef_writer_L3_EV3D_GSE      = m_cef_writer_factory:open("L3_EV3D_GSE")
-- //    local m_cef_writer_L3_EV3D_GSE_EX   = m_cef_writer_factory:open("L3_EV3D_GSE_EX")

    local m_cef_writer_H1_MOMENTS_ISR2_INERT   = m_cef_writer_factory:open("H1_MOMENTS_ISR2_INERT")
    
    local m_data =
    {
      {
          filepath = i_cef_filepath_H1_MOMENTS,
          tag = "H1_MOMENTS",
          vars =
          {
              "time_tags__",                                                    -- // T0
-- //         "Data_Velocity_GSE__",                                            -- // Vx
              "velocity__",                                                     -- // Vx
              1,                                                                -- // Vy
              1                                                                 -- // Vz
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

    function process_peace_A2(Vx,Vy,Vz,
                              Bx0,By0,Bz0,Bnumber,                              -- // 0 postfix added for sync with notes
                              Wx0,Wy0,Wz0,                                      -- // 0 postfix added for sync with notes
                              Lat,Long,
                              T0)
        
        -- // Calculate the velocity in GSE in inertial frame, called V1, with components:                            
        local V1x = is_fill(Vx,Wx0) or                                          -- // 3c 
                    Vx - Wx0                                                    -- // Calculate the velocity in GSE in inertial frame,
        local V1y = is_fill(Vy,Wy0) or                                          -- //  called V1, with components:
                    Vy - Wy0
        local V1z = is_fill(Vz,Wz0) or
                    Vz - Wz0                    
                    
        local Bt = is_fill(Bx0,By0,Bz0) or                                      -- // 4a. Calculate unit vector of B
                   sqrt(Bx0^2+By0^2+Bz0^2)
        local bx0 = is_fill(Bx0,Bt) or
                    Bx0/Bt
        local by0 = is_fill(By0,Bt) or
                    By0/Bt
        local bz0 = is_fill(Bz0,Bt) or
                    Bz0/Bt

        local VV = is_fill(V1x,bx0,V1y,by0,V1z,bz0) or
                   V1x*bx0 + V1y*by0 + V1z*bz0

        local V1parX = is_fill(VV,bx0) or                                       -- // 4b. Calculate parallel component of V1, called 
                       VV*bx0                                                   -- //  V1par, with components:
        local V1parY = is_fill(VV,by0) or
                       VV*by0
        local V1parZ = is_fill(VV,bz0) or
                       VV*bz0

        local V1px = is_fill(V1x,V1parX) or                                     -- // 4c. Calculate perpendicular component of V1 in GSE in 
                     V1x-V1parX                                                 -- //  inertial frame, called V1p, with components:
        local V1py = is_fill(V1y,V1parY) or                                 
                     V1y-V1parY                                             
        local V1pz = is_fill(V1z,V1parZ) or                                 
                     V1z-V1parZ                                             
                                                                            
        -- // 5. Calculate E-field in GSE (inertial frame)
        local E1x = is_fill(V1py,Bz0,V1pz,By0) or                               -- // 5a Calculate the electric field of the drift velocity 
                    V1py*Bz0 - V1pz*By0                                         -- //  in GSE in inertial frame, called E1, with components:
        local E1y = is_fill(V1pz,Bx0,V1px,Bz0) or                           
                    V1pz*Bx0 - V1px*Bz0                                     
        local E1z = is_fill(V1px,By0,V1py,Bx0) or                           
                    V1px*By0 - V1py*Bx0                                     
                                                                                -- // 6. Transform vectors from GSE into ISR2 (inertial frame)                              
                                                                                -- // 6b. Apply cef2cef (note: CL_SP_AUX dataset is needed)
        local V2x,V2y,V2z = transform_gse_2_isr2(V1x,V1y,V1z,Lat,Long)          -- // 6b. i.
        local V2px,V2py,V2pz = transform_gse_2_isr2(V1px,V1py,V1pz,Lat,Long)    -- // 6b. ii.
        local E2x,E2y,E2z = transform_gse_2_isr2(E1x,E1y,E1z,Lat,Long)          -- // 6b. iii.
        local V2parX,V2parY,V2parZ = transform_gse_2_isr2(V1parX,V1parY,V1parZ) -- // 6b. iv.
                                                                            
        -- // 7. Create new variables                              
        -- // Note variable names follow the CIS naming convention                               
                                                                            
        V1x,V1y,V1z,                                                            -- // velocity_gse_inert       
        V2x,V2y,V2z,                                                            -- // velocity_isr2_inert      
        V1px,V1py,V1pz,                                                         -- // velocity_perp_gse_inert   
        V2px,V2py,V2pz,                                                         -- // velocity_perp_isr2_inert  
        V1parX,V1parY,V1parZ,                                                   -- // velocity_par_gse_inert
        V2parX,V2parY,V2parZ,                                                   -- // velocity_par_isr2_inert  
        E1x,E1y,E1z,                                                            -- // Efield_gse_inert         
        E2x,E2y,E2z,                                                            -- // Efield _isr2_inert       
        Vx,Vy,Vz,                                                               
        Bx0,By0,Bz0,Bnumber,                                                           
        Wx0,Wy0,Wz0,                                                                
        Lat,Long = to_3_decimal_places                                                      
            {                                
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
            }


    --  //
    --  ///////////////////////////////////////////////////////////////////////////

    -- // Dataset name: C1_CP_H1_MOMENTS_ISR2_INERT
    -- // Variables: all from sections 1 and 7
    -- // Metadata for variables of sections 7 require editing although the metadata of Data_Velocity_GSE gives a good start
        m_cef_writer_H1_MOMENTS_ISR2_INERT:writeln(T0,                          -- // 8. Write new dataset 
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
                                                   Lat,Long)                           


    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local l_record_count = 0
    local l_timer = new_Timer("timer: ")
    
    local l_iter_data = new___iter_data_func_c(m_data)
    
    -- // ugly after thought... sorry.. order matters! .careful!
    -- // '_' => don't care... nil
    local T0_fill, Vx_fill, Vy_fill, Vz_fill, 
          _, Bx_fill, By_fill, Bz_fill, 
          _, Wx_fill, Wy_fill, Wz_fill, 
          _, Lat_fill, Long_fill = l_iter_data:get_fillvars()

    for T0,Vx,Vy,Vz,
        T1,Bx,By,Bz,Bnumber,
        T2,Wx,Wy,Wz,
        T3,Lat,Long
        in l_iter_data.get_iter_func() do

        if Vx == nil then break end

        Vx,Vy,Vz = normalise_fillvals(Vx,Vy,Vz, Vx_fill)
        Bx,By,Bz = normalise_fillvals(Bx,By,Bz, Bx_fill)
        Wx,Wy,Wz = normalise_fillvals(Wx,Wy,Wz, Wx_fill)
        Lat,Long = normalise_fillvals(Lat,Long, Lat_fill)

        process_peace_A2(Vx,Vy,Vz,                  -- // 1a
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
                
--//        if l_record_count > 1000000 then
--//            break
--//        end
        end

    l_timer.stop()
    print("count:", l_record_count)
    m_cef_writer_factory:close(l_record_count)
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

main_interpolator_peace_A1(arg[1],                     -- // H1_MOMENTS
                           arg[2],                     -- // FGM_5VPS
                           arg[3],                     -- // AUX_PosGSE_PosGSE_1M_PosGSE_1M
                           arg[4],                     -- // AUX_LatLong
                           arg[5])           

                            