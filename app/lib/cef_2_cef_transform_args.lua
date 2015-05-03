function parse_args_cef_2_cef()

    local s_options =
    {
        _from = nil,
        _to = nil,
        _in = nil,
        _aux = nil,
        _out = nil,
        _vars = nil,
        _varlist = nil,
        _inifile = nil,
        _ceh = nil,
        _dataset = nil,
        _debug = false,
        _maxlines = nil
    }

    local s_to_from =
    {
        "gse",
        "sr2",
        "isr2"
    }

    local s_vars =
    {
        "replace",
        "all"
    }


--  ///////////////////////////////////////////////////////////////////////////
--  //

    local function _assert(i_assert, i_message)
        if i_assert == nil or i_assert == false then
            print("\n\n\n")
            print(i_message)
            os.exit(-1)
        end
    end

    local function check_to_from(i_tag, i_value)
        local l_is_ok = false

        for _, v in ipairs (s_to_from) do
            if i_value == v then 
                l_is_ok = true
                break
            end
        end

        _assert(l_is_ok, "Error! Invalid ".. i_tag)
    end

    local function check_file(i_tag, i_file_path)

        if i_file_path ~= nil then
            
            local l_file = io.open(i_file_path, "r+t")
            _assert(l_file, "Error! Invalid file path ".. 
                            i_tag.. 
                            "  ".. 
                            i_file_path)

            l_file:close()
        end
    end


    local function check_folder_pseudo(i_tag, i_path)
        local l_folder_exists = false

        if i_path ~= nil then
            local l_time = os.time()
            local l_dummy_file_path = i_path.. "/.".. tostring(l_time).. ".txt"
            local l_file, err, code = io.open(l_dummy_file_path, "w+t")                

            if l_file ~= nil then
                l_file:close()
                os.remove(l_dummy_file_path)
                l_folder_exists = true
            end
        end

        _assert(l_folder_exists == true, "Error! Invalid Folder path ".. 
                        i_tag.. 
                        "  ".. 
                        i_path)
    end


    local function chack_vars(i_tag, i_vars)
        if i_vars ~= nil then
            local l_is_ok = false

            for _, v in ipairs (s_vars) do
-- //                 print("=> ", v, i_vars)

                if i_vars == v then 
                    l_is_ok = true
                    break
                end
            end

            _assert(l_is_ok, "Error! Invalid ".. i_tag)
        end
    end
   

    local function do_checks()
        _assert(s_options._from, "Error! Missing  -from ")
        _assert(s_options._to, "Error! Missing  -to ")
        _assert(s_options._in, "Error! Missing  -in ")
        _assert(s_options._aux, "Error! Missing  -aux ")
        _assert(s_options._out, "Error! Missing  -out ")

        _assert(s_options._ceh or 
                s_options._dataset, "Error! Missing -ceh filename OR -dataset id")

        s_options._from = string.lower(s_options._from)
        s_options._to = string.lower(s_options._to)


        check_to_from("-from", s_options._from)
        check_to_from("-to",   s_options._to)

        _assert(s_options._from ~= s_options._to, 
               "Error! -to and -from need to be different (gse,isr,isr2)")
        
        chack_vars("-vars", s_options._vars)

        check_file("-in", s_options._in)
        check_file("-aux", s_options._aux)
        check_file("-inifile", s_options._inifile)

        check_folder_pseudo("-out", s_options._out)
    end

--  ///////////////////////////////////////////////////////////////////////////
--  //

    local function add(i_key, 
                       i_value)
        local l_key = "_".. string.sub(i_key, 2)
        s_options[l_key] = i_value
    end

    local function add_str(i_key, 
                           i_ix)
        add(i_key, arg[i_ix])
        return i_ix + 1
    end

    local function add_bool(i_key, 
                            i_ix)
        local l_value = false

        if arg[i_ix] == "true" or arg[i_ix] == "TRUE" then l_value = true end
        add(i_key,  l_value)

        return i_ix + 1
    end

    local function add_int(i_key, 
                           i_ix)
        add(i_key, tonumber(arg[i_ix]))

        return i_ix + 1
    end

    local function add_list(i_key, 
                            i_ix,
                            i_count)
        local l_count = i_count ~= nil and i_count or (#arg - i_ix + 1)
        local l_list = {}
                
        for i = 1, l_count do
            l_list[i] = arg[i_ix + i -1]
        end

        add(i_key, l_list)

        return i_ix + l_count
    end


    for i=1, #arg - 1 do
        local l_arg = arg[i]

        if l_arg =="-from" then          add_str(l_arg, i + 1)
        elseif l_arg == "-to" then       add_str(l_arg, i + 1)
        elseif l_arg == "-in" then       add_str(l_arg, i + 1)
        elseif l_arg == "-aux" then      add_str(l_arg, i + 1)
        elseif l_arg == "-out" then      add_str(l_arg, i + 1)
        elseif l_arg == "-vars" then     add_str(l_arg, i + 1)
        elseif l_arg == "-inifile" then  add_str(l_arg, i + 1)
        elseif l_arg == "-ceh" then      add_str(l_arg, i + 1)
        elseif l_arg == "-dataset" then  add_str(l_arg, i + 1)
        
        elseif l_arg == "-debug" then    add_bool(l_arg, i + 1)
        elseif l_arg == "-maxlines" then add_int(l_arg, i + 1)
        elseif l_arg == "-varlist" then  add_list(l_arg, i + 1)
        end
    end

    function s_options:get_dataset()
        local l_dataset = nil

        if s_options._dataset ~= nil then
            l_dataset = s_options._dataset
        elseif s_options._ceh ~= nil then
            _, l_dataset = string.match(l_ceh, 
                                        "^(.-)([^\\/]+).[cC][eE][hH]$")
        end        

        return l_dataset
    end

    do_checks()

    return s_options
end

