#include "stdio.h"
#include <iostream>
#include <cmath>
#include <cstring>
#include <sstream> 

using namespace std;

#include "lua_c_funcs.h"
#include "CCefInterpolator.h"
#include "CInitData.h"

///////////////////////////////////////////////////////////////////////////
//

CCefInterpolator s_interpolator;

int c_set_fill_val(lua_State *L)
{
    long l_status = 0L;

    double l_fill_val = lua_tonumber(L, 1);

    CInitData::get_object().m_fill_value = l_fill_val;

    lua_pushnumber(L, l_status);

    return(1);
}

int c_cef_cell_reader_open(lua_State *L)
{
    long l_status = s_interpolator.open(L);

    lua_pushnumber(L, l_status);

    return(1);
}

int c_cef_cell_reader_next(lua_State *L)
{
    long l_status = 0L;

    long l_total = s_interpolator.next(L);
    l_status = (l_total > 0) ? 0L : -1L;

    lua_pushnumber(L, l_status);

    return(l_total + 1);
}

int c_cef_cell_reader_close(lua_State *L)
{
    long l_status = s_interpolator.close(L);

    lua_pushnumber(L, l_status);

    return(1);
}

