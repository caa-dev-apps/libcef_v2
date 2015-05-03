-- ///////////////////////////////////////////////////////////////////////////
-- //.     
-- //.     
-- //.     !-------------------- CEF ASCII FILE ----------------
-- //.     FILE_NAME            = "C1_CP_WBD_WAVEFORM_20010204_1340_V02.cef.gz"
-- //.     FILE_FORMAT_VERSION  = "CEF-2.0"
-- //.     END_OF_RECORD_MARKER = "$"
-- //.     !----------------------------------------------------
-- //.     INCLUDE              = "C1_CH_WBD_WAVEFORM.ceh"
-- //.     !----------------------------------------------------
-- //.     !
-- //.     START_META           = FILE_TYPE
-- //.     ENTRY                = "cef"
-- //.     END_META             = FILE_TYPE
-- //.     !
-- //.     START_META           = LOGICAL_FILE_ID
-- //.     ENTRY                = "C1_CP_WBD_WAVEFORM_20010204_1340_V02"
-- //.     END_META             = LOGICAL_FILE_ID
-- //.     !
-- //.     START_META           = DATASET_VERSION
-- //.     ENTRY                = "V1.0 Jan 2010"
-- //.     END_META             = DATASET_VERSION
-- //.     !
-- //.     START_META           = VERSION_NUMBER
-- //.     ENTRY                = "02"
-- //.     END_META             = VERSION_NUMBER
-- //.     !
-- //.     START_META           = FILE_TIME_SPAN
-- //.     VALUE_TYPE           = ISO_TIME_RANGE
-- //.     ENTRY                = 2001-02-04T13:49:23.011952868Z/2001-02-04T13:49:59.999975938Z
-- //.     END_META             = FILE_TIME_SPAN
-- //.     !
-- //.     START_META           = GENERATION_DATE
-- //.     VALUE_TYPE           = ISO_TIME
-- //.     ENTRY                = 2010-02-03T11:22:42Z
-- //.     END_META             = GENERATION_DATE
-- //.     !
-- //.     START_META           = FILE_CAVEATS
-- //.     ENTRY                = "File converted by CAA Wed Feb  3 12:22:42 2010"
-- //.     ENTRY                = "Source File: c1_waveform_wbd_200102041340_v02.cdf"
-- //.     END_META             = FILE_CAVEATS
-- //.     !----------------------------------------------------
-- //.     !
-- //.     DATA_UNTIL           = "END_OF_DATA"
-- //.     
-- //

--  ///////////////////////////////////////////////////////////////////////////
--  //

-- //         function m_writer_data:init_header(i_args_data,
-- //                                            i_header_vars)
-- // 
-- //             local l_header_data = new_header_T(m_cef_filepath,
-- //                                                i_file_data, 
-- //                                                i_tag,
-- //                                                END_OF_RECORD)
-- // 

function new_header_T(i_cef_filepath,
                      i_file_data, 
                      i_tag,
                      i_end_of_record,
                      i_args_data)

    local l_lua_app_folder, 
          l_lua_app_filename = string.match(arg[0],
                                            "^(.-)([^\\/]+)$")
    local l_out_cef_folder, 
          m_cef_filename = string.match(i_cef_filepath, 
                                        "^(.-)([^\\/]+)$")

    local m_logical_file_id  = string.match(m_cef_filename,
                                            "^(.-).[cC][eE][fF]$")

    local m_include, _  = string.match(m_cef_filename,
                                       "^(.-)__(.-)$")

    m_include = m_include.. ".ceh"

    local m_file_time_span                      =  i_file_data:get_file_time_span()
    local m_generation_date                     = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local m_file_caveats_conversions_timestamp  = "File converted by CAA : "..
                                                  os.date("!%a, %d %b %Y %H:%M:%S ")
    local m_file_caveats_app_name               = "CAA App based on ceflib.so/dll + "..
                                                  l_lua_app_filename

    local FILE_FORMAT_VERSION                   = "CEF-2.0"
    local END_OF_RECORD_MARKER                  = i_end_of_record or "$"
    local FILE_TYPE                             = "cef"
    local DATASET_VERSION                       = "V2.0 April 2011"
    local VERSION_NUMBER                        = "00"

    local FILE_TIME_SPAN_VALUE_TYPE             = "ISO_TIME_RANGE"
    local GENERATION_DATE_VALUE_TYPE            = "ISO_TIME"

    local m_template_data_stx = 
    {
        "!-------------------- CEF ASCII FILE ----------------",
        { FILE_NAME            = m_cef_filename },
        { FILE_FORMAT_VERSION  = FILE_FORMAT_VERSION },
        { END_OF_RECORD_MARKER = END_OF_RECORD_MARKER },
        "!----------------------------------------------------",
        { INCLUDE              = m_include },
        "!----------------------------------------------------",
        "!",
        { START_META           = "FILE_TYPE" },
        { ENTRY                = FILE_TYPE },
        { END_META             = "FILE_TYPE" },
        "!",
        { START_META           = "LOGICAL_FILE_ID" },
        { ENTRY                = m_logical_file_id },
        { END_META             = "LOGICAL_FILE_ID" },
        "!",
        { START_META           = "DATASET_VERSION" },
        { ENTRY                = DATASET_VERSION },
        { END_META             = "DATASET_VERSION" },
        "!",
        { START_META           = "VERSION_NUMBER" },
        { ENTRY                = VERSION_NUMBER },
        { END_META             = "VERSION_NUMBER" },
        "!",
        { START_META           = "FILE_TIME_SPAN" },
        { VALUE_TYPE           = FILE_TIME_SPAN_VALUE_TYPE },
        { ENTRY                = m_file_time_span },
        { END_META             = "FILE_TIME_SPAN" },
        "!",
        { START_META           = "GENERATION_DATE" },
        { VALUE_TYPE           = GENERATION_DATE_VALUE_TYPE },
        { ENTRY                = m_generation_date },
        { END_META             = "GENERATION_DATE" },
        "!",
    }


    local function get_caveats()
        local l_caveats = 
        {
            { START_META           = "FILE_CAVEATS" },
            { ENTRY                = m_file_caveats_conversions_timestamp },
            { ENTRY                = m_file_caveats_app_name },
        }

        for k,v in pairs(i_args_data) do
            if type(v) ~= "function" then

                if type(v) == "string" then
                    local l_folder, 
                          l_filename = string.match(v, "^(.-)([^\\/]+)$")

                    if l_filename ~= nil then
                        v = l_filename
                    end
                end

                local l_entry = { ENTRY = " arg. ".. k.. ": ".. tostring(v) }
                table.insert(l_caveats, l_entry)
            end
        end
           
        table.insert(l_caveats, { END_META             = "FILE_CAVEATS" })
        table.insert(l_caveats, "!----------------------------------------------------")
        table.insert(l_caveats, "!")
        
        return l_caveats
    end


    local m_template_data_caveats = get_caveats()

    local m_template_data_etx = 
    {
        { DATA_UNTIL           = "END_OF_DATA"},
    }

    local no_quotes = 
    {
        START_META      = true,
        END_META        = true,
        VALUE_TYPE      = true,
        START_VARIBLE   = true,
        END_VARIBLE     = true
    }

    local indents = 
    {
        ENTRY       = true,
        VALUE_TYPE  = true
    }

    local no_indents = 
    {
        START_META      = true,
        END_META        = true,
        START_VARIBLE   = true,
        END_VARIBLE     = true,
        DATA_UNTIL      = true,
    }

    

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local m_data = {}

    function format_header_str(i_template_data,
                               i_ignore_quotes)
        local l_table = {}

        for _, w in ipairs(i_template_data) do
            if type(w) == "string" then
                l_table[#l_table + 1] = w
            else
                for k, v in pairs(w) do
                    if i_ignore_quotes == nil and no_quotes[k] == nil then v = '\"'..v..'\"' end
                    if no_indents[k] == nil then k = " "..k end

                    l_table[#l_table + 1] = string.format("%-25s",k)
                    l_table[#l_table + 1] = " = "
                    l_table[#l_table + 1] = v
                end
            end

            l_table[#l_table + 1] = "\n"
        end

        return l_table
    end

    function m_data:get_header_str(i_header_vars)
        local l_table_stx = format_header_str(m_template_data_stx)
        local l_table_caveats = format_header_str(m_template_data_caveats)

        local l_str = ""
        l_str = l_str..table.concat(l_table_stx)
        l_str = l_str..table.concat(l_table_caveats)

        local l_template_data_vars = {}

        if i_header_vars ~= nil then
            for _, n in ipairs(i_header_vars) do
                local l_var = i_header_vars[n]
                table.insert(l_template_data_vars, {START_VARIBLE=n})
                for k,v in pairs(l_var) do
                    local l_temp = {}
                    l_temp[k] = v
                    table.insert(l_template_data_vars, l_temp)
                end
                table.insert(l_template_data_vars, {END_VARIBLE=n})
                table.insert(l_template_data_vars, "!")
            end

            local l_table_vars= format_header_str(l_template_data_vars,
                                                  true)
            l_str = l_str..table.concat(l_table_vars)
        end

        local l_table_etx = format_header_str(m_template_data_etx)
        l_str = l_str..table.concat(l_table_etx)
        print(l_str)

        return l_str
    end

    return m_data
end

