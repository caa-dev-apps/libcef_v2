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

-- // require 'libcef_v2'
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


function main_interpolator_l3_part_b(i_cef_filepath_EFW_L3,         -- // EFW_L3_E
                                     i_cef_filepath_AUX_PosGSE,     -- // AUX_PosGSE_PosGSE_1M
                                     i_cef_filepath_FGM,            -- // FGM_Full
                                     i_cef_filepath_AUX_LatLong,    -- // AUX_LatLong
                                     i_out_folder)

    local m_file_data = get_file_data(i_cef_filepath_EFW_L3)
    set_fill_val(FILL_VAL)

    local m_cef_writer_factory = new_cef_writer_factory(i_out_folder, m_file_data)

    local m_cef_writer_L3_E3D_INERT_EX = m_cef_writer_factory:open("L3_E3D_INERT_EX")
    local m_cef_writer_L3_E3D_INERT    = m_cef_writer_factory:open("L3_E3D_INERT")
    local m_cef_writer_L3_V3D_INERT_EX = m_cef_writer_factory:open("L3_V3D_INERT_EX")
    local m_cef_writer_L3_V3D_INERT    = m_cef_writer_factory:open("L3_V3D_INERT")
    local m_cef_writer_L3_E3D_GSE      = m_cef_writer_factory:open("L3_E3D_GSE")
    local m_cef_writer_L3_V3D_GSE      = m_cef_writer_factory:open("L3_V3D_GSE")
    local m_cef_writer_L3_E3D_GSE_EX   = m_cef_writer_factory:open("L3_E3D_GSE_EX")
    local m_cef_writer_L3_V3D_GSE_EX   = m_cef_writer_factory:open("L3_V3D_GSE_EX")

-- // 1 Sept 2011
-- // Merge E3D/V3D outputs => EV3D

    local m_cef_writer_L3_EV3D_INERT_EX = m_cef_writer_factory:open("L3_EV3D_INERT_EX")
    local m_cef_writer_L3_EV3D_INERT    = m_cef_writer_factory:open("L3_EV3D_INERT")
    local m_cef_writer_L3_EV3D_GSE      = m_cef_writer_factory:open("L3_EV3D_GSE")
    local m_cef_writer_L3_EV3D_GSE_EX   = m_cef_writer_factory:open("L3_EV3D_GSE_EX")

    local m_data =
    {
      {
          filepath = i_cef_filepath_EFW_L3,
          tag = "EFW",
          vars =
          {
              "time_tags__",                            -- // TO
              "E_Vec_xy_ISR2__",                        -- // Ex
              1,                                        -- // Ey       !n.b. the 1 forces an inc from prev value
              "E_sigma__",                              -- // E_sigma   **NEW**
              "E_bitmask__",                            -- // E_bitmask
              "E_quality__"                             -- // E_quality
          }
      },
      {
          filepath = i_cef_filepath_AUX_PosGSE,
          tag = "AUX_PosGSE",
          vars =
          {
              "time_tags__",                            -- // T1
              "sc_v_xyz_gse__",                         -- // Vx
              1,                                        -- // Vy
              1                                         -- // Vz
          }
      },
      {
          filepath = i_cef_filepath_FGM,
          tag = "FGM",
          use_averages = true,                          -- // Bnumber number of values used for average value
          vars =
          {
              "time_tags__",                            -- // T2
              "B_vec_xyz_gse__",                        -- // Bx
              1,                                        -- // By
              1                                         -- // Bz
          }
      },
      {
          filepath = i_cef_filepath_AUX_LatLong,
          tag = "AUX_Lat_Long",
          vars =
          {
              "time_tags__",                                    -- // T3 ???????????????????
              "sc_at".. m_file_data.spacecraft.. "_lat",        -- // sc_at".. n.. "_lat
              "sc_at".. m_file_data.spacecraft.. "_long"        -- // sc_at".. n.. "_long
          }
      },
    }

--  ///////////////////////////////////////////////////////////////////////////
--  //

    function process_efw_l3_v2(Ex, Ey,
                               Vxi,Vyi,Vzi,
                               Bxi,Byi,Bzi,Bnumber,
                               Lat,Long,
                               T0, E_sigma, E_bitmask,E_quality)

        -- // Harri & Yuri request 2012-05-01 (E_quality < 2 tests)
        local E_quality_number = tonumber(E_quality)
        
        if E_quality_number < 2 then
            Vxi,Vyi = FILL_VAL, FILL_VAL
        end
        
        local Vxi1,Vyi1,Vzi1 = transform_gse_2_isr2(Vxi,Vyi,Vzi,Lat,Long)    -- // (6)
        local Bxi1,Byi1,Bzi1 = transform_gse_2_isr2(Bxi,Byi,Bzi,Lat,Long)    -- // (7)

        local BF_ = is_fill(Bxi1,Byi1,Bzi1)                                  -- // intermediate

        local Ez = FILL_VAL
        if E_quality_number >= 2 then
            Ez = is_fill(BF_,Ex,Ey) or
                 -(Ex*Bxi1 + Ey*Byi1)/Bzi1                                   -- // (8)
        end                   
                   
        local Bt = BF_ or
                   sqrt(Bxi1^2+Byi1^2+Bzi1^2)                                -- // (9)

        local Bt_pow2 = Bt^2    
        local Bt_pow4 = Bt^4

        local C = 1                                                          -- // (10)
        local D = 0.3
        local dEz = is_fill(BF_,Ex,Ey) or
                    C*abs(Bxi1/Bzi1) + D*abs(Ex*Bxi1 + Ey*Byi1)/Bzi1^2


        local VBx = is_fill(Vyi1,Bzi1,Vzi1,Byi1) or                          -- // (11)
                    (Vyi1*Bzi1 - Vzi1*Byi1) / 1000

        local VBy = is_fill(Vzi1,Bxi1,Vxi1,Bzi1) or 
                    (Vzi1*Bxi1 - Vxi1*Bzi1) / 1000

        local VBz = is_fill(Vxi1,Byi1,Vyi1,Bxi1) or
                    (Vxi1*Byi1 - Vyi1*Bxi1) / 1000


        local Ex1 = is_fill(Ex,VBx) or                                       -- // (12)
                    Ex - VBx

        local Ey1 = is_fill(Ey,VBy) or
                    Ey - VBy

        local Ez1 = is_fill(Ez,VBz) or
                    Ez - VBz


        local theta = is_fill(Bzi1,Bxi1,Byi1) or
                      atan(Bzi1/sqrt(Bxi1^2+Byi1^2))*180/pi                  -- // (13)

        local Ez2=Ez1                                                        -- // (14)
        if abs(Bzi1)<2 or abs(theta)<15 then Ez2 = FILL_VAL end


		-- 2012-03-29 *1000
        local Wx1 = is_fill(BF_,Ey1,Ez1) or                                  -- // (15)
                    1000 * ((Ey1*Bzi1- Ez1*Byi1)/Bt_pow2)
        local Wy1 = is_fill(BF_,Ez1,Ex1) or
                    1000 * ((Ez1*Bxi1- Ex1*Bzi1)/Bt_pow2)
        local Wz1 = is_fill(BF_,Ex1,Ey1) or
                    1000 * ((Ex1*Byi1- Ey1*Bxi1)/Bt_pow2)
        local Wx2 = is_fill(BF_,Ey1,Ez2) or
                    1000 * ((Ey1*Bzi1- Ez2*Byi1)/Bt_pow2)
        local Wy2 = is_fill(BF_,Ez2,Ex1) or
                    1000 * ((Ez2*Bxi1- Ex1*Bzi1)/Bt_pow2)
        local Wz2 = Wz1


        local dWx1 = is_fill(BF_,dEz,Ey1,Ez1) or                            -- // (16)
                     1000 * (abs(dEz*Byi1)/Bt_pow2 + D*abs(Ey1/Bt_pow2 - 2*Bzi1*(Ey1*Bzi1-Ez1*Byi1)/Bt_pow4))
        local dWy1 = is_fill(BF_,dEz,Ex1,Ez1) or
                     1000 * (abs(dEz*Bxi1)/Bt_pow2 + C*abs(Bzi1)/Bt_pow2 + D*abs(-Ex1/Bt_pow2 - 2*Bzi1*(Ez1*Bxi1-Ex1*Bzi1)/Bt_pow4))
        local dWz1 = is_fill(BF_,Ex1,Ey1) or
                     1000 * (C*abs(Byi1)/Bt_pow2 + D*abs(Bzi1*(Ex1*Byi1-Ey1*Bxi1))/Bt_pow4)
        local dWx2 = is_fill(BF_,dEz,Ey1,Ez2) or
                     1000 * (abs(dEz*Byi1)/Bt_pow2 + D*abs(Ey1/Bt_pow2 - 2*Bzi1*(Ey1*Bzi1-Ez2*Byi1)/Bt_pow4))
        local dWy2 = is_fill(BF_,dEz,Ex1,Ez2) or
                     1000 * (abs(dEz*Bxi1)/Bt_pow2 + C*abs(Bzi1)/Bt_pow2 + D*abs(-Ex1/Bt_pow2 - 2*Bzi1*(Ez2*Bxi1-Ex1*Bzi1)/Bt_pow4))
        local dWz2 = dWz1


        local ExGSE,EyGSE,EzGSE = transform_isr2_2_gse(Ex1,Ey1,Ez2,Lat,Long)           -- // 17. 
        local ExGSE_ex,EyGSE_ex,EzGSE_ex = transform_isr2_2_gse(Ex1,Ey1,Ez1,Lat,Long)  -- // 17a 
        local BxGSE,ByGSE,BzGSE = transform_isr2_2_gse(Bxi1,Byi1,Bzi1,Lat,Long)        -- // 17b 
        local WxGSE,WyGSE,WzGSE = transform_isr2_2_gse(Wx2,Wy2,Wz2,Lat,Long)           -- // 18. 
        local WxGSE_ex,WyGSE_ex,WzGSE_ex = transform_isr2_2_gse(Wx1,Wy1,Wz1,Lat,Long)  -- // 18a. 
                                  

        BxGSE, ByGSE, BzGSE, Bxi1, Byi1, Bzi1, E_bitmask, E_quality, 
        Ex1, Ey1, Ez1, ExGSE, EyGSE, EzGSE, ExGSE_ex, EyGSE_ex, EzGSE_ex, Ez2, 
        Wx1, Wx2, Wy1, Wy2, Wz1, Wz2, WxGSE, WyGSE, WzGSE, WxGSE_ex, WyGSE_ex, WzGSE_ex, 
        dEz, dWx1, dWy1, dWz1, dWx2, dWy2, dWz2, theta, Bnumber = to_3_decimal_places{
            BxGSE, ByGSE, BzGSE, Bxi1, Byi1, Bzi1, E_bitmask, E_quality, 
            Ex1, Ey1, Ez1, ExGSE, EyGSE, EzGSE, ExGSE_ex, EyGSE_ex, EzGSE_ex, Ez2, 
            Wx1, Wx2, Wy1, Wy2, Wz1, Wz2, WxGSE, WyGSE, WzGSE, WxGSE_ex, WyGSE_ex, WzGSE_ex, 
            dEz, dWx1, dWy1, dWz1, dWx2, dWy2, dWz2, theta, Bnumber }

    --  //
    --  ///////////////////////////////////////////////////////////////////////////

        m_cef_writer_L3_E3D_INERT_EX:writeln(T0, Ex1,Ey1,Ez1, dEz, E_bitmask, E_quality, Bxi1,Byi1, Bzi1,theta,Bnumber,E_sigma)                           -- // 19
        m_cef_writer_L3_E3D_INERT:writeln(T0, Ex1,Ey1,Ez2, dEz, E_bitmask, E_quality,E_sigma)                                                             -- // 20
        m_cef_writer_L3_V3D_INERT_EX:writeln(T0, Wx1, Wy1, Wz1, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bzi1,theta,Bnumber,E_sigma)                         -- // 21
        m_cef_writer_L3_V3D_INERT:writeln(T0, Wx2, Wy2, Wz2, dWx2,dWy2,dWz2, E_bitmask, E_quality,E_sigma)                                                -- // 22

        -- // sept 2011
        m_cef_writer_L3_EV3D_INERT_EX:writeln(T0, Ex1,Ey1,Ez1, Wx1, Wy1, Wz1, dEz, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bxi1,Byi1, Bzi1,theta,Bnumber,E_sigma)
        m_cef_writer_L3_EV3D_INERT:writeln   (T0, Ex1,Ey1,Ez2, Wx2, Wy2, Wz2, dEz, dWx2,dWy2,dWz2, E_bitmask, E_quality,E_sigma)
        
        if E_quality_number < 2 then
            m_cef_writer_L3_E3D_GSE:writeln(T0, FILL_VAL,FILL_VAL,FILL_VAL, FILL_VAL, E_bitmask, E_quality,E_sigma)                                                                  -- // 23
            m_cef_writer_L3_V3D_GSE:writeln(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality,E_sigma)                                              -- // 24
            m_cef_writer_L3_E3D_GSE_EX:writeln(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, E_bitmask, E_quality, FILL_VAL,FILL_VAL,FILL_VAL,E_sigma)   -- // 25
            m_cef_writer_L3_V3D_GSE_EX:writeln(T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality, FILL_VAL,FILL_VAL,FILL_VAL,E_sigma)               -- // 26
            
            m_cef_writer_L3_EV3D_GSE:writeln     (T0, FILL_VAL,FILL_VAL,FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality,E_sigma)
            m_cef_writer_L3_EV3D_GSE_EX:writeln  (T0, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL, FILL_VAL,FILL_VAL,FILL_VAL, E_bitmask, E_quality, FILL_VAL,FILL_VAL,FILL_VAL,E_sigma)
        else
            m_cef_writer_L3_E3D_GSE:writeln(T0, ExGSE,EyGSE,EzGSE, dEz, E_bitmask, E_quality,E_sigma)                                                         -- // 23
            m_cef_writer_L3_V3D_GSE:writeln(T0, WxGSE, WyGSE, WzGSE, dWx2,dWy2,dWz1, E_bitmask, E_quality,E_sigma)                                            -- // 24
            m_cef_writer_L3_E3D_GSE_EX:writeln(T0, ExGSE_ex, EyGSE_ex, EzGSE_ex, BxGSE, ByGSE, BzGSE, dEz, E_bitmask, E_quality, Bzi1,theta,Bnumber,E_sigma)  -- // 25
            m_cef_writer_L3_V3D_GSE_EX:writeln(T0, WxGSE_ex, WyGSE_ex, WzGSE_ex, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bzi1,theta,Bnumber,E_sigma)            -- // 26
           
            m_cef_writer_L3_EV3D_GSE:writeln     (T0, ExGSE,EyGSE,EzGSE, WxGSE, WyGSE, WzGSE,dEz,dWx2,dWy2,dWz1, E_bitmask, E_quality,E_sigma)
            m_cef_writer_L3_EV3D_GSE_EX:writeln  (T0, ExGSE_ex, EyGSE_ex, EzGSE_ex, WxGSE_ex, WyGSE_ex, WzGSE_ex, BxGSE, ByGSE, BzGSE, dEz, dWx1,dWy1,dWz1, E_bitmask, E_quality, Bzi1,theta,Bnumber,E_sigma)
        end
        
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local l_record_count = 0
    local l_timer = new_Timer("timer: ")


    local l_iter_data = new___iter_data_func_c(m_data)
    
    -- // ugly after thought... sorry.. order matters! .careful!
    -- // '_' => don't care... nil
    local T0_fill, Ex_fill, Ey_fill, _, _, _,
          _, Vxi_fill, Vyi_fill, Vzi_fill, 
          _, Bxi_fill, Byi_fill, Bzi_fill, 
          _, Lat_fill, Long_fill = l_iter_data:get_fillvars()

    for T0,Ex,Ey,E_sigma,E_bitmask,E_quality,
        T1,Vxi,Vyi,Vzi,
        T2,Bxi,Byi,Bzi,Bnumber,
        T3,Lat,Long
        in l_iter_data.get_iter_func() do

	    if Ex == nil then break end

-- // 		-- check bit 14 of E_bitmask (0..15)
-- // 		if band(E_bitmask, 0x4000) == 0 then
-- // 			Ex, Ey      = normalise_fillvals(Ex, Ey,      Ex_fill)
-- // 			Vxi,Vyi,Vzi = normalise_fillvals(Vxi,Vyi,Vzi, Vxi_fill)
-- // 			Bxi,Byi,Bzi = normalise_fillvals(Bxi,Byi,Bzi, Bxi_fill)
-- // 			Lat,Long    = normalise_fillvals(Lat,Long,    Lat_fill)
-- // 		else
-- // 			--//print('.')
-- // 			Ex, Ey      = Ex_fill, Ey_fill
-- // 			Vxi,Vyi,Vzi = Vxi_fill, Vyi_fill, Vzi_fill
-- // 			Bxi,Byi,Bzi = Bxi_fill, Byi_fill, Bzi_fill
-- // 			Lat,Long    = Lat_fill, Long_fill
-- // 		end

        -- // Set back to original state 2012.05.01
        -- // sets fill val of all numbers to FILL_VAL => -1e31
        Ex, Ey      = normalise_fillvals(Ex, Ey,      Ex_fill)
        Vxi,Vyi,Vzi = normalise_fillvals(Vxi,Vyi,Vzi, Vxi_fill)
        Bxi,Byi,Bzi = normalise_fillvals(Bxi,Byi,Bzi, Bxi_fill)
        Lat,Long    = normalise_fillvals(Lat,Long,    Lat_fill)
		
        process_efw_l3_v2(Ex, Ey,
                          Vxi,Vyi,Vzi,
                          Bxi,Byi,Bzi,Bnumber,
                          Lat,Long,
                          T0, E_sigma, E_bitmask,E_quality)


        l_record_count = l_record_count + 1

        if l_record_count % 100000 == 0 then
            l_timer.now()

            print(l_record_count, 
                  T0, T1, T2, T3)
        end

--//        if l_record_count > 1000 then
--//            break
--//        end


    end

    l_timer.stop()
    print("count:", l_record_count)
    m_cef_writer_factory:close(l_record_count)
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

main_interpolator_l3_part_b(arg[1],                     -- // EFW_L3_E
                            arg[2],                     -- // AUX_PosGSE_PosGSE_1M
                            arg[3],                     -- // FGM_Full
                            arg[4],                     -- // AUX_LatLong
                            arg[5])           


