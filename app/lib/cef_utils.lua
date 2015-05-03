local libcef_v2 = require 'libcef_v2'

--  ///////////////////////////////////////////////////////////////////////////
--  //

FILL_VAL = -1*10^31
FILL_VAL_STR = -1e31

local c_set_fill_val = libcef_v2.c_set_fill_val

local c_transform_gse_2_isr2 = libcef_v2.c_transform_gse_2_isr2
local c_transform_isr2_2_gse = libcef_v2.c_transform_isr2_2_gse


--  ///////////////////////////////////////////////////////////////////////////
--  //

function table_list_append(i_table1, i_table2)
    for _, v in ipairs(i_table2) do
        table.insert(i_table1, v)
    end

    return i_table1
end


function get_todays_date_str()
    local l_date = os.date("*t")

    return ("%0.4d-%0.2d-%0.2d"):format(l_date.year,
                                        l_date.month,
                                        l_date.day)
end

TODAYS_DATE_STR             = get_todays_date_str()


--  ///////////////////////////////////////////////////////////////////////////
--  //

function cef_filepath_splts(i_filepath)
    local l_in_cef_folder, l_in_cef_filename = string.match(i_filepath, 
                                                            "^(.-)([^\\/]+).[cC][eE][fF]$")
    return l_in_cef_folder, l_in_cef_filename
end

function string_split_csv(i_text)
    local l_list = {}

    for w in string.gmatch(i_text, "[^, \t]+") do
        table.insert(l_list, w)
    end

    return l_list
end

function string_strip_whitespace(i_text)
    local l_text = i_text

    local i1,i2 = string.find(l_text,'^%s*')
    if i2 >= i1 then
        l_text = string.sub(l_text,i2+1)
    end
    local i1,i2 = string.find(l_text,'%s*$')
    if i2 >= i1 then
        l_text = string.sub(l_text,1,i1-1)
    end

    return (l_text ~= nil) and l_text or ("")
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

function get_file_data(i_root_cef_filepath)

--//	print("1", i_root_cef_filepath)

    local m_data = 
    {
        spacecraft = 0,
        stx_data = {},
        etx_data = {},
    }

-- // e.g. C1_CP_EFW_L2_E__20071231_000000_20080101_000000_V100312.cef"
-- //  e.g. => 20071231_000000
    function get_date_time_data(i_date_time_str)
        local l_data = {}
    
        if i_date_time_str ~= nil then
            l_data.year,
            l_data.month,
            l_data.day,
            l_data.hour,
            l_data.min,
            l_data.second = string.match(i_date_time_str, 
                                         "^(%d%d%d%d)(%d%d)(%d%d)_(%d%d)(%d%d)(%d%d)$")
        end

        return l_data
    end

    function parse_root_cef_filepath()

        local l_in_cef_folder, 
              l_in_cef_filename = string.match(i_root_cef_filepath, 
                                               "^(.-)([^\\/]+).[cC][eE][fF]$")
        if l_in_cef_filename ~= nil then
            m_data.prefix = string.match(l_in_cef_filename, 
                                         "^(.-_.-_.-_)")

			print("m_data.prefix", m_data.prefix)
										 
										 
-- // e.g. C1_CP_EFW_L2_E__20071231_000000_20080101_000000_V100312.cef"

            m_data.spacecraft,
            _,
            m_data.date_range,
            m_data.version = string.match(l_in_cef_filename, 
                                                           "^[cC](%d)(.*)__(.+)_(.-)$")
														   
--//			print("m_data.spacecraft", m_data.spacecraft)
--//			print("m_data.date_range", m_data.date_range)
--//			print("m_data.version", m_data.version)

            m_data.m_date_range_and_version = m_data.date_range..
                                              "_"..
                                              "V00"
            m_data.stx,
            m_data.etx, 
            _ = string.match(m_data.date_range, 
                             "^(%d+_%d+)_(%d+_%d+)$")

--//			print("m_date_range_and_version.version", m_data.m_date_range_and_version)
--//			print("m_data.stx", m_data.stx)
--//			print("m_data.etx", m_data.etx)
							 
            m_data.stx_data = get_date_time_data(m_data.stx)
            m_data.etx_data = get_date_time_data(m_data.etx)
			
--//			print("m_data.stx_data", m_data.stx_data)
--//			print("m_data.etx_data", m_data.etx_data)

        else
            print("Error: parsing filename")
            exit(-1)
        end
    end

    function m_data:get_file_time_span()
        -- // e.g. 2001-02-04T13:49:23.011952868Z/2001-02-04T13:49:59.999975938Z
        return string.format("%04d-%02d-%02dT%02d:%02d:%02d.000000000Z/%04d-%02d-%02dT%02d:%02d:%02d.000000000Z",
                              m_data.stx_data.year,
                              m_data.stx_data.month,
                              m_data.stx_data.day,
                              m_data.stx_data.hour,
                              m_data.stx_data.min,
                              m_data.stx_data.second,
                              m_data.etx_data.year,
                              m_data.etx_data.month,
                              m_data.etx_data.day,
                              m_data.etx_data.hour,
                              m_data.etx_data.min,
                              m_data.etx_data.second)
 
    end

    parse_root_cef_filepath()

    return m_data
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

function new_Timer(i_tag)

    local m_data =
    {
        m_start = os.time(),
        m_stop = nil,
    }

    function m_data:now()
        local l_difftime = os.difftime(os.time(), m_data.m_start)
        print(i_tag, 
              l_difftime,
              tostring(math.floor(l_difftime / 60)).."m ",
              tostring(l_difftime % 60).."s")
    end

    function m_data:start()
        m_data.m_start = os.time()
        m_data.m_stop = nil
    end

    function m_data:stop()
        print(i_tag.. "stop")
        m_data.m_stop = os.time()
        m_data:now()
    end

    return m_data
end

--  ///////////////////////////////////////////////////////////////////////////
--  //

function set_fill_val(i_fillval)
-- //     c_set_fill_val(FILL_VAL)
    c_set_fill_val(i_fillval)
end


function is_fill(...)
    local l_args = {...}
    
    for i=1,#l_args do
        if l_args[i] == FILL_VAL then
            return FILL_VAL
        end
    end

    return nil
end


function is_fill_x3(...)
    return is_fill(...) ~= nil and {FILL_VAL,FILL_VAL,FILL_VAL} or nil
end


function transform_isr2_2_gse(x,y,z,Lat,Long)
    return unpack(is_fill_x3(x,y,z,Lat,Long) or
                  {c_transform_isr2_2_gse(x,y,z,Lat,Long)})
end


function transform_gse_2_isr2(x,y,z,Lat,Long)
    return unpack(is_fill_x3(x,y,z,Lat,Long) or
                  {c_transform_gse_2_isr2(x,y,z,Lat,Long)})
end


function to_3_decimal_places(i_vals)
    local l_strs = {}

    for i,v in ipairs(i_vals) do
        l_strs[i] = tostring(math.floor(v * 1000 + 0.5) / 1000)
    end
    
    return unpack(l_strs)
end

-- // set incoming fill vals to output fillval (-1e31).. a preprocess step
function normalise_fillvals(...)
    local l_in = {...}
    local l_out = {}

    local l_len = #l_in
    local l_fillval = l_in[l_len]

    for i=1, l_len-1 do
        local l_val = tonumber(l_in[i])

        l_out[i] = (l_val == l_fillval and FILL_VAL or l_val)
    end

    return unpack(l_out)
end







