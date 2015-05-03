
function new_ISO_Time(i_epoch_str, 
                      i_delta_m, 
                      i_delta_p)

    if i_epoch_str == nil then i_epoch_str = "" end

    local y,m,d,h,mi,s,fs = string.match(i_epoch_str, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d%d)([.%d]-)Z")
    local l_fs = (fs ~= nil and tonumber(fs) or 0)

    function to_seconds()
        local l_seconds = 0

        if y ~= nil then
            l_seconds = os.time({ year=y, month=m, day=d, hour=h, min=mi, sec=s })
        end

        return l_seconds
    end


    local m_data =
    {
        m_delta_m = i_delta_m ~= nil and -tonumber(i_delta_m) or 0,
        m_delta_p = i_delta_p ~= nil and tonumber(i_delta_p) or 0,
        m_secs = to_seconds(),
        m_fsecs = l_fs
    }

    function m_data:get_iso_str()
        return i_epoch_str
    end


    function m_data:is_in_delta_range(i_iso_time)
        local l_diff = i_iso_time.m_secs - self.m_secs  +
                       ((i_iso_time.m_fsecs - self.m_fsecs) * 10^-12)

        local l_return = 0

        if     l_diff < self.m_delta_m then print("x", i_iso_time:get_iso_str()) l_return  = -1
        elseif l_diff >= self.m_delta_p then l_return = 1
        end

        return l_return
    end

    function m_data:is_valid()
        return self.m_secs ~= 0
    end

    function m_data:diff(i_iso_time)
        local l_diff = 0

        if self:is_valid() and i_iso_time:is_valid() then
    
            l_diff = self.m_secs - i_iso_time.m_secs +
                     (self.m_fsecs - i_iso_time.m_fsecs)
        end

        return l_diff
    end


    return m_data
end


