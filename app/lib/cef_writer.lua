require 'lib.cef_header'


function new_Cef_writer(i_out_folder, 
                        i_file_data, 
                        i_tag,
                        i_end_of_record)

    local m_writer_data = {}
    local m_cef_filepath = i_out_folder.. 
                           "/".. 
                           i_file_data.prefix..
                           i_tag..
                           "__"..
                           i_file_data.m_date_range_and_version..
                           ".cef"

--//	print("===========> ", m_cef_filepath)

    local END_OF_RECORD = i_end_of_record or "$"
    END_OF_RECORD = " ".. END_OF_RECORD.. "\n"

    local m_file = io.open(m_cef_filepath, "w+t")


-- //     print("-------------------", "m_file", m_file)

    local l_header_data = new_header(m_cef_filepath,
                                     i_file_data, 
                                     i_tag,
                                     END_OF_RECORD)

    m_file:write(l_header_data.header_str)

    function m_writer_data:writeln(...)
        local l_args = {...}

        m_file:write(table.concat(l_args, ", ", 1, #l_args))
        m_file:write(END_OF_RECORD)
    end


    function m_writer_data:writelist(i_list)
        m_file:write(table.concat(i_list, ", ", 1, #i_list))
        m_file:write(END_OF_RECORD)
    end



    function m_writer_data:close(i_records_count)
        m_file:write("!RECORDS= ".. 
                     tostring(i_records_count)..
                     "\n")
        m_file:write("END_OF_DATA\n")
        m_file:close()
    end

    return m_writer_data, m_file ~= nil
end

--  ///////////////////////////////////////////////////////////////////////////
--  //


function new_cef_writer_factory(i_out_folder, 
                                i_file_data)

    local m_out_folder = i_out_folder
    local m_file_data =  i_file_data

    local m_writers = {}        
    local m_data = {}        

    function m_data:open(i_tag)
        local l_writer = new_Cef_writer(m_out_folder, m_file_data, i_tag)

        table.insert(m_writers,l_writer)

        return l_writer
    end

    function m_data:close(i_record_count)
        for _, w in ipairs(m_writers) do
            w:close(i_record_count)
        end
    end

    return m_data
end



















