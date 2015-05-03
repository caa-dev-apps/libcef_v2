require "lib.cef_utils"

require 'lib.cef_iso_time'

--  ///////////////////////////////////////////////////////////////////////////
--  //

TYPE_NULL = 0
TYPE_ATTRIBUTE = 1
TYPE_META = 2
TYPE_VARIABLE = 3

--  ///////////////////////////////////////////////////////////////////////////
--  //

local s_DEBUG = {}

function new_Cef_Parser(i_cef_filepath, i_tag)
    s_DEBUG[i_tag] = 0

    local m_cef_filepath = i_cef_filepath

    local m_tag = string.format("%-12s", i_tag)

    local m_current_type = TYPE_ATTRIBUTE
    local m_current_subject = ""
    local m_line_count = 0
    local m_header_line_count = 0

    local m_cef_header_data = 
    {
        attributes = { },
        meta = { },
        variables = { }
    }

    local m_parser_data = 
    {
    }

    local m_input_data =
    {
        path = i_cef_filepath,
        tag = i_tag
    }

    local m_attributes = m_cef_header_data.attributes
    local m_meta = m_cef_header_data.meta
    local m_vars = m_cef_header_data.variables
    local m_variable_sizes = {}


    -- // n.b. consts are size 0
--  local function init_variable_sizes()
--      m_variable_sizes = {}
--        
--        for _, l_name in ipairs(m_vars) do
--            local l_var = m_vars[l_name]
--            local l_cef_sizes = l_var['SIZES']
--
--            local l_sizes_number = (l_cef_sizes ~= nil) and tonumber(l_cef_sizes) or 1
--
--            local l_is_const = (l_var['DATA'] ~= nil)
--            if l_is_const == true then l_sizes_number = 0 end
--
--            table.insert(m_variable_sizes, tonumber(l_sizes_number))
--
--        end
--
--    end
	
    -- // n.b. consts are size 0
    local function init_variable_sizes()
        m_variable_sizes = {}
        
        for _, l_name in ipairs(m_vars) do
            local l_var = m_vars[l_name]
            local l_cef_sizes = l_var['SIZES']

            local l_sizes_number = 1
--//		l_cef_sizes ~= nil) and tonumber(l_cef_sizes) or 1
			if l_cef_sizes ~= nil then
				for n in string.gmatch(l_cef_sizes, "[^, \t$]+") do
					l_sizes_number = l_sizes_number * tonumber(n)
				end
			end
			
--//		print(l_cef_sizes, "\t\t", l_sizes_number);
			
            local l_is_const = (l_var['DATA'] ~= nil)
            if l_is_const == true then l_sizes_number = 0 end

            table.insert(m_variable_sizes, tonumber(l_sizes_number))

        end

    end
	
	
    local function get_var_index(i_var_name)
        local l_index = 0
        
        for i, l_name in ipairs(m_vars) do
            if l_name == i_var_name then 
                l_index = i
                break
            end
        end

        return l_index
    end

    local function addKeyValue(i_key,
                               i_value)
        m_line_count = m_line_count + 1

        if m_current_type == TYPE_ATTRIBUTE then
            m_attributes[i_key] = i_value
        elseif m_current_type == TYPE_META then
            local l_map = {}
            l_map[i_key] = i_value
            table.insert(m_meta[m_current_subject], l_map)
        elseif m_current_type == TYPE_VARIABLE then
            m_vars[m_current_subject][i_key] = i_value
        end
    end

    local function new_type(i_type, i_map, i_name)
        m_current_type = i_type
        m_current_subject = i_name

        if(i_map ~= nil) then
            i_map[i_name] = {}
        end
    end

    local function formatKeyValue(i_line)
        local l_eq = i_line:find("=")

        if l_eq ~= nil then
            local l_key = i_line:sub(1, l_eq - 1);
            local l_value = i_line:sub(l_eq + 1);

            l_key = string_strip_whitespace(l_key)
            l_value = string_strip_whitespace(l_value)

            if #l_key and #l_value then
                if l_key:find("START_META") == 1 then
                    new_type(TYPE_META, m_meta, l_value)
                elseif l_key:find("START_VARIABLE") == 1 then
                    new_type(TYPE_VARIABLE, m_vars, l_value)
                    table.insert(m_vars, l_value)
                elseif l_key:find("END_META") == 1 or
                       l_key:find("END_VARIABLE") == 1 then
                    new_type(TYPE_ATTRIBUTE, nil, "")
                else
                    addKeyValue(l_key,
                                l_value)
                end
            end
        end
    end

    local function get_vars_per_record()
        local l_count = 0

        for _, s in ipairs(m_variable_sizes) do
            l_count = l_count + s
        end

        return l_count
    end

    local function do_parse()
        local l_file = io.open(m_cef_filepath, "r+t")

        local l_count = 0
        if l_file ~= nil then
            for l_line in l_file:lines() do
               
                m_header_line_count = m_header_line_count + 1
                -- // remove whitespace        
                l_line = string_strip_whitespace(l_line)

                if l_line:find("DATA_UNTIL") == 1 then
                    break
                elseif #l_line > 0 and l_line:find("!") ~= 1 then
                    formatKeyValue(l_line)
                end

                l_count = l_count + 1
            end

            init_variable_sizes()

            l_file:close()
        else
            print("Error: Unable to open ".. m_cef_filepath)
            print("Exiting... !")
            os.exit(-1)
        end
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //


-- // 1. Read EFW_L2_E:                               T0,Ex,Ey, E_bitmask, E_quality
-- // 2. Read AUX_PosGSE_1M:                          T1,Px,Py,Pz,Vx,Vy,Vz
-- // 3. Read FGM_Full:                               T2,Bx,By,Bz, Px2,Py2,Pz2
-- // 4. Interpolate (2) on T0 timeline:              T0,Vxi,Vyi,Vzi
-- // 5. Interpolate (3) on T0 timeline:              T0,Bxi,Byi,Bzi
-- // 6. Transform (4) to ISR2:                       T0,Vxi1,Vyi1,Vzi1
-- // 7. Transform (5) to ISR2:                       T0,Bxi1,Byi1,Bzi1

    -- // vars are not necessarily in order
-- //     function m_parser_data:get_offsets(i_var_names)
-- //         local l_offsets = {}
-- //         local l_last_offset = nil
-- // 
-- //         for i, n in ipairs(i_var_names) do
-- //             local l_offset = 1
-- //             local l_match = false
-- // 
-- //             if type(n) == "number" then
-- //                 if l_last_offset ~= nil then
-- //                     l_offset = l_last_offset + 1
-- //                     table.insert(l_offsets, l_offset)
-- //                     l_match = true
-- //                     l_last_offset = l_offset
-- //                 else
-- //                     print("x", "error: get_offsets: numerical value instead of var name = ", n)
-- //                 end
-- //             else
-- //                 for ix, name in ipairs(m_vars) do
-- //                     local l_stx, l_etx = string.find(name, n)
-- //                     if l_stx == 1 then
-- //                         table.insert(l_offsets, l_offset)
-- //                         l_match = true
-- //                         l_last_offset = l_offset
-- //                     end
-- // 
-- //                     l_offset = l_offset + m_variable_sizes[ix]
-- // 
-- //                     if l_match == true then break end
-- //                 end
-- //             end
-- // 
-- //             if l_match == false then
-- //                 print("\nERROR:")
-- //                 print("Missing required variable with prefix : "..  n)
-- //                 print("FILE: ".. m_cef_filepath)
-- //                 print("Please check... Exiting now")
-- //                 os.exit(-1)
-- //             end
-- //         end
-- // 
-- //         return l_offsets
-- //     end

-- // cdrequire 'yaml'
        
    function m_parser_data:get_offsets_plus_meta(i_var_names)
        local l_last_offset = nil
        local l_last_meta = nil
        local l_offsets = {}
        local l_offsets = {}
        local l_meta_data = {}

        for i, n in ipairs(i_var_names) do
            local l_offset = 1
            local l_match = false

            if type(n) == "number" then
                if l_last_offset ~= nil then
                    l_offset = l_last_offset + 1
                    table.insert(l_offsets, l_offset)
                    table.insert(l_meta_data, l_last_meta)
                    l_match = true
                    l_last_offset = l_offset
                else
                    print("x", "error: get_offsets_plus_meta: numerical value instead of var name = ", n)
                end
            else
                for ix, name in ipairs(m_vars) do
                    local l_stx, l_etx = string.find(name, n)
                    if l_stx == 1 then
                        table.insert(l_offsets, l_offset)
-- //                         +++++++++++++++++++++++++++++++++++++++
                        table.insert(l_meta_data, m_vars[name])

-- //     local l_yaml_data = yaml.load(l_data)
-- //     print("-----------------")
-- //     print(name)
-- //     print(yaml.dump(m_vars[name]))
-- //     print("-----------------")

            
                        l_match = true
                        l_last_offset = l_offset
                        l_last_meta = m_vars[name]
                    end

                    l_offset = l_offset + m_variable_sizes[ix]

                    if l_match == true then break end
                end
            end

            if l_match == false then
                print("\nERROR:")
                print("Missing required variable with prefix : "..  n)
                print("FILE: ".. m_cef_filepath)
                print("Please check... Exiting now")
                os.exit(-1)
            end
        end

-- //         print("TAG:           ", i_tag)
-- //         print("#l_offsets:    ", #l_offsets)
-- //         print("#l_meta_data:  ", #l_meta_data)

        return l_offsets, l_meta_data
    end
        

    function m_parser_data:get_fast_read_data(i_var_names)
        local l_offsets = self:get_offsets_plus_meta(i_var_names)   -- // e.g. 6 3 5 8 10
        local l_ordered_offsets = {}                      -- // e.g. 3 5 6 8 10 
        local l_ordered_indices = {}                      -- // e.g. 2 3 1 4 5
    
        local l_fast_read_data =
        {
            offsets = l_offsets,
            ordered_offsets = l_ordered_offsets,
            ordered_indices = l_ordered_indices
        }

        for _, v in ipairs(l_offsets) do table.insert(l_ordered_offsets, v) end
        table.sort(l_ordered_offsets)                  

        for i, v in ipairs(l_ordered_offsets) do
            for j, w in ipairs(l_offsets) do
                if v == w then l_ordered_indices[i] = j break end
            end
        end

        print(m_tag,
              "In: ",  table.concat(l_offsets, "."),         
              "++: ",  table.concat(l_ordered_offsets, "-"), 
              "Ix: ",  table.concat(l_ordered_indices, "+"))
              
        return l_fast_read_data
    end


    local function parse_line_raw_fast(i_line, 
                                       i_fast_read_data)
        local l_list = {}

        local l_ordered_offsets = i_fast_read_data.ordered_offsets
        local l_ordered_indices = i_fast_read_data.ordered_indices
        local l_cur = 1

        local l_col = 1
        local l_next_col = l_ordered_offsets[l_cur]

        for w in string.gmatch(i_line, "[^, \t$]+") do
            if l_col == l_next_col then
                l_list[l_ordered_indices[l_cur]] = w

                l_cur = l_cur + 1

                if l_cur <= #l_ordered_offsets then 
                    l_next_col = l_ordered_offsets[l_cur]
                else
                    break
                end
            end

            l_col = l_col + 1
        end

        return l_list
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    -- // pass the list of indexes which are to be returned on each iteration
    function m_parser_data:iter_func(i_var_names,
                                     i_do_not_unpack)
        local l_fast_read_data = self:get_fast_read_data(i_var_names)

        local function aclosure()
            local l_file = io.open(m_cef_filepath, "r+t")
            local l_in_data = false

            local l_debug_count = 1
            local l_record = ""

            for l_line in l_file:lines() do

                if l_in_data == true then

                    -- // match [whitespaces followed by !] =  a comment
                    if string.match(l_line, "^%d") ~= nil then
                        local l_record = parse_line_raw_fast(l_line,
                                                             l_fast_read_data)

                        if i_do_not_unpack == nil then
                            coroutine.yield (unpack(l_record))
                        else
                            coroutine.yield (l_record)
                        end
                    end
                elseif string.match(l_line, "^%s*DATA_UNTIL") ~= nil then
                    l_in_data = true
                end

                l_debug_count = l_debug_count + 1

                if l_debug_count % 10000 == 0 then
                    print(m_tag, l_debug_count)
                end
            end

            print("ETX-ITER", m_cef_filepath);
            l_file:close()
        end

        return coroutine.wrap(function() return aclosure() end)
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

-- //     first_var = epoch
-- //                 delta +
-- //                 delta -
-- //                     - either a value or
-- //                     - a ref to a const/var
-- //                         - delta+ = const
-- //                         - delta- = const
-- //         
-- //                         - delta+ = var -> iter V1
-- //                         - delta- = var -> iter V1

--  ///////////////////////////////////////////////////////////////////////////
--  //

    function m_parser_data:new_Interpolator()
        local l_pseudo_delta = nil

        function get_pseudo_delta_plus_minus()
            local l_file = io.open(m_cef_filepath, "r+t")
            local l_in_data = false

            local l_line_count = 1
            local l_limit_count = 1
            local l_record = ""

            local l_time = { nil, nil }

            for l_line in l_file:lines() do
                if l_in_data == true then
                    -- // match [whitespaces followed by !] =  a comment
                    if string.match(l_line, "^%s*!") == nil then
                        l_time[l_line_count] = new_ISO_Time(l_line)
                        l_line_count = l_line_count + 1
                        if l_line_count > 2 then break end
                    end
                elseif string.match(l_line, "^%s*DATA_UNTIL") ~= nil then
                    l_in_data = true
                end

                if l_in_data == true then
                    l_limit_count = l_limit_count + 1
                    if l_limit_count > 10 then break end
                end
            end

            l_file:close()

            local l_delta = 0

            if l_time[1] ~= nil and l_time[2] ~= nil then
                l_delta = l_time[2]:diff(l_time[1])                    
            end

            return l_delta
        end



        function init_interpolator(i_value)
            local l_delta, l_delta_var_name = nil, nil

            local l_value = tonumber(i_value)

            if l_value ~= nil then
                l_delta = l_value
                if l_delta == 0 then
                    if l_pseudo_delta == nil then
                        l_psudo_delta = get_pseudo_delta_plus_minus()
                    end
                    l_delta = l_psudo_delta
                end

                -- // TODO NEED TO TEST FOR ZERO + cahce the value // TODO
                -- // read first two time values and diff /2
            else    -- // it's should be the name of a var e.g... half_interval__XXXXXXX
                local l_var = m_vars[i_value]

                if l_var ~= nil then
                    l_delta = l_var['DATA']

                    if l_delta ~= nil then
                        l_delta = tonumber(l_delta)
                    else
                        l_delta_var_name = i_value
                    end
                else
                    print("ERROR: Exiting.. invalid interpolation delta value",
                          "["..i_value.."]",
                          m_cef_filepath)
                           
                    os.exit(-1)
                end
            end
        
            return l_delta, l_delta_var_name
        end

        local l_first_var_name = m_vars[1]

        local l_first_var = m_vars[l_first_var_name]

        local l_delta_m = l_first_var['DELTA_MINUS']
        local l_delta_p = l_first_var['DELTA_PLUS']

        local l_x_delta_m, l_x_delta_m_var_name = init_interpolator(l_delta_m)
        local l_x_delta_p, l_x_delta_p_var_name = init_interpolator(l_delta_p)

        local m_interpolator =
        {
            delta_m          = l_x_delta_m,
            delta_m_var_name = l_x_delta_m_var_name,
            delta_p          = l_x_delta_p,
            delta_p_var_name = l_x_delta_p_var_name,

            delta_m_ix       = nil,
            delta_p_ix       = nil,

            last_t           = nil,
            last_record      = nil           -- // cache last record
        }

        -- // check if delta+/- need to be added to the var names table
        -- // if so will be appended to end of list and indexed by _ix
        function m_interpolator:pre_process_var_names(i_var_names)

            for _,v in ipairs(i_var_names) do print("i+",_,v) end

            local l_var_names = i_var_names

            if self.delta_m_var_name ~= nil then
                table.insert(l_var_names, self.delta_m_var_name)
                self.delta_m_ix = #l_var_names
            end

            if self.delta_p_var_name ~= nil then
                if self.delta_p_var_name ~= self.delta_m_var_name then
                    table.insert(l_var_names, self.delta_p_var_name)
                end
                self.delta_p_ix = #l_var_names
            end

            for _,v in ipairs(l_var_names) do print("o+",_,v) end

            return l_var_names
        end


        function m_interpolator:next(i_record)

            local l_delta_m = (self.delta_m_ix == nil) and self.delta_m or i_record[self.delta_m_ix]
            local l_delta_p = (self.delta_p_ix == nil) and self.delta_p or i_record[self.delta_p_ix]

            self.last_record = i_record

            self.last_t  = new_ISO_Time(i_record[1], 
                                        l_delta_m, 
                                        l_delta_p)
        end

        -- // -1, 0, 1
        function m_interpolator:is_in_delta_range(i_to)
            return self.last_t:is_in_delta_range(i_to)
        end


        function m_interpolator:get_c_delta_values()
            local l_is_delta_const = (self.delta_m_var_name == nil)

            local l_delta_m = (l_is_delta_const == true) and self.delta_m or (get_var_index(self.delta_m_var_name) - 1)
            local l_delta_p = (l_is_delta_const == true) and self.delta_p or (get_var_index(self.delta_p_var_name) - 1)

            return l_is_delta_const, l_delta_m, l_delta_p
        end


        return m_interpolator
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    function m_parser_data:get_c_iter_data(i_var_names,
                                           i_add_interpolation_separation,
                                           i_use_averages)

        if i_add_interpolation_separation == nil then i_add_interpolation_separation = false end
        if i_use_averages == nil then i_use_averages = false end
        
        local l_interpolator = self.new_Interpolator()
        local l_is_delta_const, l_delta_m, l_delta_p = l_interpolator:get_c_delta_values()
        local l_var_offsets, l_var_meta_data = self:get_offsets_plus_meta(i_var_names)

        local l_data = 
        {
            cef_filepath = i_cef_filepath,
            tag = i_tag,
            end_of_record_marker = self:get_end_of_record_marker(),
            vars_per_record = get_vars_per_record(),
            is_delta_const = l_is_delta_const,
            add_interpolation_separation = i_add_interpolation_separation,
            use_averages = i_use_averages,
            delta_m = l_delta_m, 
            delta_p = l_delta_p,
            var_offsets = l_var_offsets, 
            var_meta_data = l_var_meta_data
        }

        return l_data 
    end


    function m_parser_data:iter_func_interpolator(i_var_names,
                                                  i_do_not_unpack)
        local l_interpolator = self.new_Interpolator()
        local l_var_names = l_interpolator:pre_process_var_names(i_var_names)

        local function interpolator(i_to)
            local l_to = i_to   -- // initial value
            local l_record = nil;

            for l_record in self:iter_func(l_var_names,
                                           false) do   -- // false = no unpack

                l_interpolator:next(l_record)

                while l_to ~= nil do
                    local l_in_range = l_interpolator:is_in_delta_range(l_to)

                    if l_in_range <= 0 then
                        if l_in_range < 0 then l_record[1] = -1 end

                        if i_do_not_unpack == nil then
                            l_to = coroutine.yield (unpack(l_record))
                        else
                            l_to = coroutine.yield (l_record)
                        end

                    else
                        break
                    end
                end

                if l_to == nil then break end
            end

        end

        return coroutine.wrap(function(i_to) return interpolator(i_to) end)
    end


--  ///////////////////////////////////////////////////////////////////////////
--  //

    function m_parser_data:stats()

        print("")
        print("file:", m_cef_filepath)
        print("tag:", m_tag)
        print("#:", #m_vars)

        print("", "[ix]", "[size]", "[offset]", "[name]")

        local l_offset = 1
        local l_size = nil

        for i, l_name in ipairs(m_vars) do
            l_size = m_variable_sizes[i]
            print("", i, l_size, l_offset, l_name)

            l_offset = l_offset + l_size
        end

        print("")
    end

    -- // 2011-06-24
    function m_parser_data:get_var_data_by_prefix(i_var_prefix)
        local l_var_data = nil
        local l_name = nil

        for _, n in ipairs(m_vars) do
            if string.match(n, i_var_prefix) ~= nil then
                l_var_data = m_vars[n]
                l_name = n
                break
            end
        end

        return l_var_data, l_name
    end

    
    -- // 2011-06-28
    function m_parser_data:get_var_names_list_by_coords(i_coords,    -- "GSE, SR2, ISR2"
                                                        i_sizes)
        local l_sizes = (i_sizes ~= nil and i_sizes or 3)

        local l_var_names = {}

        for i, var_name in ipairs(m_vars) do

            local l_var = m_vars[var_name]
            local l_coords = l_var['COORDINATE_SYSTEM']

            print(i, var_name, l_var['SIZES'], l_from, l_to, l_coords)

            if tonumber(l_var['SIZES']) == l_sizes and l_coords ~= nil then

                local l_stx, l_etx = string.find(string.lower(l_coords),
                                                 i_coords)
-- //                 print(l_coords, i_coords)

                if l_stx ~= nil and l_stx >= 1 then
                    print("ADD TRANSPOSE VARIABLE => ", var_name)
                    table.insert(l_var_names, var_name)
                end
            end
        end

        return l_var_names
    end

    -- // 2011-06-28
    function m_parser_data:get_var_names_list()
    
        local l_var_names = {}

        for i, var_name in ipairs(m_vars) do

            local l_var = m_vars[var_name]

            if l_var['DATA'] == nil then
                table.insert(l_var_names, var_name)
            end
        end

        return l_var_names
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    function m_parser_data:get_cef_header_data()
        return m_cef_header_data
    end

    function m_parser_data:get_cef_header_line_count()
        return m_header_line_count
    end


    function m_parser_data:get_end_of_record_marker()
        local l_marker = string.match(m_attributes['END_OF_RECORD_MARKER'], "^[%\"%\']*(.)[%\"%\']*$")

-- //		print("------------- ")
-- //		print("-------------> ", l_marker)
-- //		print("------------- ")
		
        return (l_marker ~= nil) and l_marker or "$"
    end


    function m_parser_data:get_input_data()
        return m_input_data
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    do_parse()

    return m_parser_data
end




