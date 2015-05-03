require 'lib.cef_parser'
require 'lib.cef_iso_time'
 
-- // require 'libcef_v2'
local libcef_v2 = require 'libcef_v2'

local c_cef_cell_reader_open  = libcef_v2.c_cef_cell_reader_open
local c_cef_cell_reader_next  = libcef_v2.c_cef_cell_reader_next
local c_cef_cell_reader_close = libcef_v2.c_cef_cell_reader_close

--  ///////////////////////////////////////////////////////////////////////////
--  //

s_iter_data = nil

function get_iter_data(i_tag,
                       i_key)
    local l_cef_data = s_iter_data[i_tag]
    local l_value = nil

    if l_cef_data ~= nil then
        l_value = l_cef_data[i_key]
    end

    return l_value
end

function get_iter_meta_data(i_tag,
                            i_var_index,
                            i_key)
-- //     print(i_tag, i_var_index, i_key)

    local l_cef_data = s_iter_data[i_tag]
    local l_value = nil

    if l_cef_data ~= nil then 
        l_value = l_cef_data['var_meta_data'][i_var_index][i_key]
    end

    return l_value
end


--  ///////////////////////////////////////////////////////////////////////////
--  //

function new___iter_data_func_c(i_data)
    local m_fillvars = {}
    local m_data = {}

    local function init()
        local l_iter_data = {}

        for i, v in ipairs(i_data) do
            local l_parser = new_Cef_Parser(v.filepath, v.tag)

            l_iter_data[i] = l_parser:get_c_iter_data(v.vars, 
                                                      v.add_interpolation_separation,
                                                      v.use_averages)
            l_iter_data[v.tag] = l_iter_data[i]
        end

        s_iter_data = l_iter_data
        c_cef_cell_reader_open(l_iter_data)


        for ix, l_cef_data in ipairs(l_iter_data) do
            local l_var_meta = l_cef_data['var_meta_data']

            for i, v in ipairs(l_var_meta) do
                local l_val = tonumber(v["FILLVAL"])

                if l_val == nil then
                    l_val = v["FILLVAL"]
                end

                table.insert(m_fillvars,  l_val)
            end
        end
    end


    function m_data:get_fillvars()
        return unpack(m_fillvars)
    end


    local function a_closure()
        local l_continue = true

        while l_continue ~= false do
            l_continue = coroutine.yield(c_cef_cell_reader_next())              
        end
    end


    function m_data:get_iter_func()
        return coroutine.wrap(function() return a_closure() end)
    end           

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local function a_closure_WRAPPED()
        local l_continue = true

        while l_continue ~= false do
            local l_rec = {c_cef_cell_reader_next()}

            if l_rec ~= nil and l_rec[#l_rec] == 0 then
                l_continue = coroutine.yield(l_rec)
            else
                break
            end
        end
    end

    function m_data:get_iter_func_WRAPPED()
        return coroutine.wrap(function() return a_closure_WRAPPED() end)
    end           

    init()

    return m_data
end
    
