-- // require 'pl.pretty'

--  ///////////////////////////////////////////////////////////////////////////
--  //


function log(i_function,
             i_message)

    print("-+--+--+--+--+--+--+--+--+--+--+--+--+--+--+-")
    print(i_function, i_message)
    print("-+--+--+--+--+--+--+--+--+--+--+--+--+--+--+-")

end

function console_diag(i_data, i_tag)
-- // print(yaml.dump(l_args))

    print("\n")

    if i_tag ~= nil then
        print(i_tag)
    end

    if type(i_data) == "table" then
-- //        pl.pretty.dump(i_data)
        print(unpack(i_data))
    else
        print(i_data)
    end
end



function console_log(i_data, i_tag)
-- // print(yaml.dump(l_args))

    print("\n")

    if i_tag ~= nil then
        print(i_tag)
    end

    if type(i_data) == "table" then
-- //         pl.pretty.dump(i_data)
    else
        print(i_data)
    end
end
