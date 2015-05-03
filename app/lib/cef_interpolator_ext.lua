require 'lib.cef_interpolator'
require 'lib.cef_log'

--  ///////////////////////////////////////////////////////////////////////////
--  //

function prefix_list_matches_string(i_prefix_list, 
                                    i_string)
    local l_is_in = false

    for _,v in ipairs(i_prefix_list) do
        -- // n.b. i_string is most likely a full variable name xx_xx__yy_yy
        if string.match(i_string, v) ~= nil then
           l_is_in = true
           break
        end 
    end

    return l_is_in
end


function new_Cef_Interpolator_Mapper()

    local m_data = 
    {
        count = 0
    }
    
    local m_read_mixins =
    {
-- //i    mixin =
-- //i    {
-- //i        parser = i_parser,
-- //i        count = 0,
-- //i        offset = m_data.count + 1,
-- //i        var_maps = {}
-- //i        {
-- //i            -- // e.g.
-- //i            -- // var_names => ix of maps (key|values)
-- //i            -- // map = 
-- //i            -- // {
-- //i            -- //     name
-- //i            -- //     offset
-- //i            -- //     sizes
-- //i            -- //     fillval
-- //i            -- //     isfill
-- //i            -- //     read_data = {}
-- //i            -- // }
-- //i        }         
-- //i    }
    }

    function m_data:add_new_file(i_parser,
                                 i_var_prefix_list)

        local l_input_data = i_parser.get_input_data()

        table.insert(m_data, 
                     {
                        filepath = l_input_data.path,      -- // from original PARTA/B
                        tag = l_input_data.tag,            -- // from original PARTA/B
                        vars = {},                         -- // from original PARTA/B
                        mixin =
                        {
                            parser = i_parser,
                            count = 0,
                            offset = m_data.count + 1,
                            var_maps = {}
                        }
                     })

        local l_data = m_data[#m_data]
        local l_mixin = l_data.mixin
        local l_var_maps = l_data.mixin.var_maps
        table.insert(m_read_mixins, l_mixin)

        l_var_maps.__transform_list = {}

        for i, p in ipairs(i_var_prefix_list) do

            local l_var_data, l_name = i_parser:get_var_data_by_prefix(p)
            assert(l_var_data ~= nil, 
                   "Error: input variable prefix not valid => ".. p)

            local l_sizes = l_var_data['SIZES']
            l_sizes = l_sizes ~= nil and tonumber(l_sizes) or 1

            table.insert(l_data.vars, p)

            if l_sizes > 1 then 
                for i=2, l_sizes do
                    table.insert(l_data.vars, 1) -- // for arrays
                end
            end

            local l_fillval = l_var_data['FILLVAL']
            l_fillval = tonumber(l_fillval) ~= nil and tonumber(l_fillval) or l_fillval


            local l_new_var_map = 
            {
                name = l_name,
                offset = m_data.count + 1,
                sizes = l_sizes,
                fillval = l_fillval,
                read_data = {},
                read_is_fill = false,
                ORIGINAL_VAR_DATA = l_var_data,
                extra = i_var_prefix_list[p],    -- // some extra data - optional
            }

            local l_extra = i_var_prefix_list[p]
            if l_extra ~= nil and l_extra.transform == true then
                table.insert(l_var_maps.__transform_list, i)
            end


            table.insert(l_var_maps, l_new_var_map)
            l_var_maps[l_name] = #l_var_maps


            l_mixin.count = l_mixin.count + l_sizes
            m_data.count = m_data.count + l_sizes
        end

        return #m_data
    end

--  ///////////////////////////////////////////////////////////////////////////
--  // used when interpolating to a single resultant output file

    function m_data:get_header_vars(i_args_data)
                                    
        local m_TO_DATA_SET = i_args_data:get_dataset()

        local l_header_vars = {}
        local l_copy_vars = {}
        local l_transform_vars = {}

        local l_from = i_args_data._from
        local l_to = i_args_data._to

        local function rename_transform_var(i_name)
            local l_name = i_name
            local l_varname, 
                  l_dataset = string.match(i_name,
                                           "^(.-)__(.-)$")


            if l_varname and l_dataset then  
                l_varname = string.gsub (l_varname, l_from, l_to)            
                l_varname = string.gsub (l_varname, string.upper(l_from), string.upper(l_to))            
                l_name = l_varname.."__"..l_dataset
            end

            return l_name
        end


        for i,v in ipairs(m_data) do
            print(i,v.tag)
            for j,w in ipairs(v.mixin.var_maps) do
                local l_extra = w.extra
                if l_extra ~= nil then
                    if l_extra.output == true then
                        table.insert(l_copy_vars, w.name)
                        l_copy_vars[w.name] = w.ORIGINAL_VAR_DATA
                    end
                    if l_extra.transform == true then
                        local l_name = rename_transform_var(w.name)
                        table.insert(l_transform_vars, l_name)
                        l_transform_vars[l_name] = w.ORIGINAL_VAR_DATA
                    end
                end
            end
        end

        for _, l_name in ipairs(l_transform_vars) do
            assert(l_copy_vars[l_name] == nil, 
                   "Error, creating duplicate variable meta data".. l_name)

            table.insert(l_copy_vars, l_name)
            l_copy_vars[l_name] = {}

            for k, v in pairs(l_transform_vars[l_name]) do
                l_copy_vars[l_name][k] = v
            end
        end

        local l_varname, 
              l_FROM_DATA_SET = string.match(l_copy_vars[1],
                                             "^(.-)__(.-)$")

        for _, n in ipairs(l_copy_vars) do
            local l_new_var_name = string.gsub(n, 
                                               l_FROM_DATA_SET, 
                                               m_TO_DATA_SET)

            table.insert(l_header_vars, l_new_var_name)
            l_header_vars[l_new_var_name] = {}

            for k, v in pairs(l_copy_vars[n]) do
                l_header_vars[l_new_var_name][k] = string.gsub(v, 
                                                               l_FROM_DATA_SET, 
                                                               m_TO_DATA_SET)
            end
        end
        
        return l_header_vars
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

-- //     function m_data:dump_read_data()
-- // 
-- //         for _, v in ipairs(m_data) do
-- //             print("= ", v.tag)
-- //             local l_var_maps = v.mixin.var_maps
-- // 
-- //             for _, m in ipairs(l_var_maps) do
-- //                 print("-> ", table.concat(m.read_data, ", "))
-- //             end
-- //         end
-- //     end

    function m_data:get_read_data()

        local l_table = {}        

        for _, v in ipairs(m_data) do
            local l_file_data = {}

            table.insert(l_file_data, v.tag)
            local l_var_maps = v.mixin.var_maps

            for _, m in ipairs(l_var_maps) do
                local l_read_data = m.read_data
                if #l_read_data > 1 then
                    table.insert(l_file_data, "[".. table.concat(l_read_data, " ").. "]")
                else
                    table.insert(l_file_data, table.concat(l_read_data, ""))
                end
            end

-- //       print(table.concat(l_file_data, " "))
            table.insert(l_table, table.concat(l_file_data, " "))
        end

        return l_table

    end

--  ///////////////////////////////////////////////////////////////////////////
--  //


    function a_closure()
        local l_iter_data = new___iter_data_func_c(m_data)

-- //         local l_dbug_data = {}

        for l_rec in l_iter_data.get_iter_func_WRAPPED() do

-- //             print(l_count, 
-- //                   unpack(l_rec))

            for _, mixin in ipairs(m_read_mixins) do
                for _, map in ipairs(mixin.var_maps) do
                    for j=1, map.sizes do
                        if type(map.fillval) == "number" then 
                            map.read_data[j] = tonumber(l_rec[map.offset + j-1])
                        else
                            map.read_data[j] = l_rec[map.offset + j-1]
                        end
                        map.read_is_fill = map.read_data[j] == map.fillval
                    end
                end
            end

            coroutine.yield(unpack(m_read_mixins))
-- //             l_count = l_count + 1
        end
    end

    function m_data:get_iter_data()
        return coroutine.wrap(function() return a_closure() end)
    end           




    return m_data
end
























