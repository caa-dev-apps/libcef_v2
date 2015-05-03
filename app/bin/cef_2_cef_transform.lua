local l_parent_folder = arg[0]:gsub('[^\\/]+$', '').. "/../"

package.path = package.path .. ';'   .. l_parent_folder .. '?.lua'
package.cpath = package.cpath .. ';' .. l_parent_folder .. '/bin/?.so'
package.cpath = package.cpath .. ';' .. l_parent_folder .. '/bin/?.dll'


-- // require 'lib.cef_header_T'
require 'lib.cef_parser'
require 'lib.cef_log'
require 'lib.cef_writer_T'
require 'lib.cef_utils'

-- // require 'libcef_v2'
local libcef_v2 = require 'libcef_v2'

require 'lib.cef_2_cef_transform_args'
require 'lib.cef_interpolator_ext'

--  ///////////////////////////////////////////////////////////////////////////
--  //

function cef_2_cef_transform()
    local m_args_data = parse_args_cef_2_cef()           -- // command line args

    console_log(m_args_data, "m_args_data")

    local m_in_parser = new_Cef_Parser(m_args_data._in, "_in")
    local m_aux_parser = new_Cef_Parser(m_args_data._aux, "_aux")
    local m_file_data = get_file_data(m_args_data._in)  -- // for the stx/etx

    local m_cef_writer_factory = new_cef_writer_factory_T(m_args_data._out, 
                                                          m_file_data)

    local m_cef_interpolator_mapper = new_Cef_Interpolator_Mapper()
    local m_transform_func = nil
    local m_in_list = nil
    local f_process = nil

    local m_aux_list = 
    {
       "time_tags__",                                    -- // Time
       "sc_at".. m_file_data.spacecraft.. "_lat",        -- // sc_at".. n.. "_lat
       "sc_at".. m_file_data.spacecraft.. "_long"        -- // sc_at".. n.. "_long
    }

    -- // which vars to read
    local function format_in_list()
        local l_from_var_names = m_in_parser:get_var_names_list_by_coords(m_args_data._from)
        local l_list = m_in_parser:get_var_names_list() -- // in order
        local l_in_list = { }

        for i,v in ipairs(l_list) do
            local l_extra = nil
            local l_to_transform = prefix_list_matches_string(l_from_var_names, v)

            -- // none
            -- // replace       -vars = replace
            -- // all           -vars = all
            -- // list          -varlist
            -- // ini           -use imgination!

            if m_args_data._vars == "all" then
                l_extra = { output=true, transform = l_to_transform}  
            elseif m_args_data._vars == "replace" then
                l_extra = { output = (not l_to_transform), transform = l_to_transform} 
            elseif m_args_data._varlist ~= nil and
                prefix_list_matches_string(m_args_data._varlist, v) == true then
                l_extra = { output=true, transform = l_to_transform} 
            elseif i == 1 then                          -- // "time_tags__"
                l_extra = { output=true, transform = false } 
            elseif l_to_transform == true then       
                l_extra = { output=false, transform = true } 
            end

            if l_extra ~= nil then 
                table.insert(l_in_list, v) 
                if l_extra.transform == true then l_extra.transform_data = {} end
                l_in_list[v] = l_extra
            end
            end

        return l_in_list
    end


    local function format_transform_from_2_to()
        local l_transform_func = nil
        
        if m_args_data._from == "gse" then
            if m_args_data._to == "isr2" then       l_transform_func = libcef_v2.c_transform_gse_2_isr2
            elseif m_args_data._to == "sr2" then    l_transform_func = libcef_v2.c_transform_gse_2_sr2
            end
        elseif m_args_data._from == "isr2" then     l_transform_func = libcef_v2.c_transform_isr2_2_gse
        elseif m_args_data._from == "sr2"  then     l_transform_func = libcef_v2.c_transform_sr2_2_gse
        end

        -- // x',y,'z' = l_transform_func => (x,y,z,lat,long)
        return l_transform_func
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local function process_closure(i_cef_writer_factory)
        print("DATASET = ", m_args_data:get_dataset())

        local l_header_vars = 
            m_cef_interpolator_mapper:get_header_vars(m_args_data)

        console_log(l_header_vars,  "l_header_vars")

        local m_cef_writer_DATASET_ID = i_cef_writer_factory:open(m_args_data:get_dataset())
        m_cef_writer_DATASET_ID:init_header(m_args_data,
                                            l_header_vars)

        local m_outdata = {}
        local m_outdatacount = 0

        local function f_process(i_in_data, 
                                 i_aux_data)

            local l_in_var_maps = i_in_data.var_maps
            local l_aux_var_maps = i_aux_data.var_maps
            local m_transform_list = l_in_var_maps.__transform_list
            local m_aux_read_is_fill = false
            m_outdatacount = 0

            for _,v in ipairs(i_aux_data.var_maps) do
                if v.read_is_fill == true then 
                    m_aux_read_is_fill = true 
                    break 
                end
            end

            local function write_out(i_data)
                for _, d in ipairs(i_data) do
                    m_outdatacount = m_outdatacount + 1
                    if type(d) == "number" then
                        m_outdata[m_outdatacount] = tostring(math.floor(d * 1000 + 0.5) / 1000)
                    else
                        m_outdata[m_outdatacount] = d
                    end
                end
            end

            local function write_input_data_out(i_var_maps)
                for i, v in ipairs(i_var_maps) do
                    if v.extra ~= nil and v.extra.output == true then write_out(v.read_data) end
                end
            end

            local function write_transform_data_out(i_var_maps)
                for i, ix in ipairs(m_transform_list) do write_out(i_var_maps[ix].extra.transform_data) end
            end

            --  ///////////////////////////////////////////////////////////////////////////
            --  //

            local function transform()
                for i, ix in ipairs(m_transform_list) do
                    local l_map = l_in_var_maps[ix]
                    
                    if l_map.read_is_fill == true or m_aux_read_is_fill == true then
                        l_map.extra.transform_data = 
                        {
                            l_map.fillval,
                            l_map.fillval,
                            l_map.fillval
                        }
                    else
                        local l_read_data = l_map.read_data           
                        local l_lat = i_aux_data.var_maps[2].read_data[1]
                        local l_long = i_aux_data.var_maps[3].read_data[1]

                        local x,y,z, status = m_transform_func(l_read_data[1],
                                                               l_read_data[2],
                                                               l_read_data[3],
                                                               l_lat,
                                                               l_long)
                        l_map.extra.transform_data = 
                        {
                            x,y,z
                        }
                    end
                end
            end

            transform()


            write_input_data_out(l_in_var_maps)
            write_input_data_out(l_aux_var_maps)
            write_transform_data_out(l_in_var_maps)

-- //             print("=> ", table.concat(m_outdata, ", "))

            m_cef_writer_DATASET_ID:writelist(m_outdata)

            return m_outdata
        end

        return f_process
    end

    local function init_data()
        m_in_list = format_in_list()
        m_transform_func = format_transform_from_2_to()

        m_cef_interpolator_mapper:add_new_file(m_in_parser,
                                               m_in_list)

        m_cef_interpolator_mapper:add_new_file(m_aux_parser,
                                               m_aux_list)

        f_process = process_closure(m_cef_writer_factory)
    end

--  //
--  ///////////////////////////////////////////////////////////////////////////
--  //  console_log(i_in_data,  "i_in_data")
--  //  console_log(i_aux_data, "i_aux_data")

    init_data()


    local l_record_count = 0
    local l_max_lines    = m_args_data._maxlines or 1e9
    print("MAX_LINES     = ", l_max_lines)

    local l_out_data = nil

    for l_in_data, 
        l_aux_data in m_cef_interpolator_mapper:get_iter_data() do

-- //         console_log(l_in_data,  "l_in_data")
-- //         console_log(l_aux_data, "l_aux_data")

        l_out_data = f_process(l_in_data,
                               l_aux_data)
    
        if l_record_count % 1000 == 0 then
            local l_read_data = m_cef_interpolator_mapper:get_read_data()

            print(l_record_count,
                  l_read_data[1],
                  "\n",
                  l_read_data[2])
            print("=", 
                  table.concat(l_out_data, ", "))
        end

-- //       os.exit(-1)
-- //         if l_record_count > 100000 then
-- //             break
-- //         end

        if l_record_count > l_max_lines then
            break
        end

        l_record_count = l_record_count + 1
    end

    m_cef_writer_factory:close(l_record_count)
end

cef_2_cef_transform()
