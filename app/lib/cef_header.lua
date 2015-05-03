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

function new_header(i_cef_filepath,
                    i_file_data, 
                    i_tag,
                    i_end_of_record)

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

    -- m_include = m_include.. ".ceh"
	--// 20120216 SMCC modified CP to CH in header name    m_include = m_include.. ".ceh"
	m_include = string.gsub(m_include,"_CP_","_CH_",1).. ".ceh"	
	
    local m_file_time_span                      =  i_file_data:get_file_time_span()
    local m_generation_date                     = os.date("!%Y-%m-%dT%H:%M:%SZ")
    local m_file_caveats_conversions_timestamp  = "File converted by CAA : "..
                                                  os.date("!%a, %d %b %Y %H:%M:%S ")
    local m_file_caveats_app_name               = "CAA App based on ceflib_v2.so/dll + "..
                                                  l_lua_app_filename

    local FILE_FORMAT_VERSION                   = "CEF-2.0"
    local END_OF_RECORD_MARKER                  = "$"
    local FILE_TYPE                             = "cef"
    local DATASET_VERSION                       = "V2.0 April 2011"
    local VERSION_NUMBER                        = "00"

    local FILE_TIME_SPAN_VALUE_TYPE             = "ISO_TIME_RANGE"
    local GENERATION_DATE_VALUE_TYPE            = "ISO_TIME"

    local m_template_data = 
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
        { START_META           = "FILE_CAVEATS" },
        { ENTRY                = m_file_caveats_conversions_timestamp },
        { ENTRY                = m_file_caveats_app_name },
        { END_META             = "FILE_CAVEATS" },
        "!----------------------------------------------------",
        "!",
        { DATA_UNTIL           = "END_OF_DATA"},
    }

    local no_quotes = 
    {
        START_META  = true,
        END_META    = true,
        VALUE_TYPE  = true
    }

    local indents = 
    {
        ENTRY       = true,
        VALUE_TYPE  = true
    }


    local m_data = {}

    function format_header_str()
        local l_table = {}

        for _, w in ipairs(m_template_data) do
            if type(w) == "string" then
                l_table[#l_table + 1] = w
            else
                for k, v in pairs(w) do
                    if no_quotes[k] == nil then v = '\"'..v..'\"' end
                    if indents[k] ~= nil then k = " "..k end

                    l_table[#l_table + 1] = string.format("%-25s",k)
                    l_table[#l_table + 1] = " = "
                    l_table[#l_table + 1] = v
                end
            end

            l_table[#l_table + 1] = "\n"
        end

        m_data.header_str = table.concat(l_table)
    end

    format_header_str()

    return m_data
end

