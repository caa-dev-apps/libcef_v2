#ifndef CINITDATA_INCLUDED
#define CINITDATA_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

#include <lua.hpp>

class CInitData
{
public:
    string m_fill_value_str;
    double m_fill_value;

public:
    CInitData();
    ~CInitData();

public:
//x 2011-03-29    static CInitData& CInitData::get_object();
    static CInitData& get_object();
    static void init(lua_State *L);

    void update_fill_str();
    void dump();
};

///////////////////////////////////////////////////////////////////////////
//


#endif // CINITDATA_INCLUDED


