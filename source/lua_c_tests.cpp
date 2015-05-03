#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ostream>
#include <iostream> 
#include <stdexcept>

using namespace std;

#include "lua_c_tests.h"
#include "CIsoTime.h"

///////////////////////////////////////////////////////////////////////////
//

int c_test_iso_time(lua_State *L)
{
    long l_status = 0L;

    try
    {
        CIsoTime l_isoTime(lua_tostring(L, 1),      // ISO_TIME string
                           lua_tonumber(L, 2),     // delta_minus
                           lua_tonumber(L, 3));    // delta_plus
        
    }
    catch (std::exception& e)
    {
        cout << e.what() 
             << endl;
    }

    lua_pushnumber(L, l_status); 

    return(1);
}

int c_test_iso_time_in_delta_range(lua_State *L)
{
    bool l_status = 0L;

    try
    {
        CIsoTime l_isoTime01(lua_tostring(L, 1),      // ISO_TIME string
                             lua_tonumber(L, 2),     // delta_minus
                             lua_tonumber(L, 3));    // delta_plus
        
        CIsoTime l_isoTime02(lua_tostring(L, 4),      // ISO_TIME string
                             lua_tonumber(L, 5),     // delta_minus
                             lua_tonumber(L, 6));    // delta_plus

//x        l_isoTime01.is_in_delta_range(l_isoTime02);

    }
    catch (std::exception& e)
    {
        cout << e.what() 
             << endl;
    }

    lua_pushboolean(L, l_status); 

    return(1);
}

