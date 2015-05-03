#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ostream>
#include <iostream> 
#include <sstream>

using namespace std;

#include "CInitData.h"

///////////////////////////////////////////////////////////////////////////
//

CInitData::CInitData():
    m_fill_value(-1*10^31)
{
    update_fill_str();
}

CInitData::~CInitData() 
{
}

///////////////////////////////////////////////////////////////////////////
//

void CInitData::update_fill_str()
{
    ostringstream l_stream;
    l_stream << m_fill_value;

    m_fill_value_str = string(l_stream.str());
}

CInitData& CInitData::get_object()
{
    static CInitData s_init_data;
    return s_init_data;
}

void CInitData::init(lua_State *L)
{
    lua_getglobal(L, "FILL_VAL");

    CInitData::get_object().m_fill_value = lua_tonumber(L, -1);

    lua_pop(L, 1);
    CInitData::get_object().update_fill_str();
}

///////////////////////////////////////////////////////////////////////////
//

void CInitData::dump() 
{
    cout << "m_fill_value          +: " << m_fill_value << endl;
    cout << "m_fill_value_str      +: " << m_fill_value_str << endl;
}

