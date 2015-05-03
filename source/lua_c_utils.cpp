#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <stdbool.h>

#include <sys/stat.h>
#include <stdbool.h>

#include <iostream>
#include <lua.hpp>

using namespace std;

#include "lua_c_utils.h"

///////////////////////////////////////////////////////////////////////////
//

int c_utils_mkdir(lua_State *L)
{
    long l_status = 0L;

    const char *l_dir = lua_tostring(L, 1);

    cout << "c_mkdir: " << l_dir << endl;

//    l_status = mkdir(l_dir, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    lua_pushnumber(L, l_status);

    return 1;
}

int c_utils_file_exists(lua_State *L)
{
    long l_status = 0L;

    const char *l_file_or_dir = lua_tostring(L, 1);

    cout << "c_file_exists: " << l_file_or_dir << endl;

    struct stat   buffer;   
    l_status = (stat (l_file_or_dir, &buffer) == 0);
    
    lua_pushnumber(L, l_status);

    return 1;
}

