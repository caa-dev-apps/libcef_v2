#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

//x #include <cstdlib>
//x #include <ostream>
//x #include <iostream> 
//x #include <sstream>
//#include <ostringstream>
//#include <stringstream>

using namespace std;

#include "CLog.h"

///////////////////////////////////////////////////////////////////////////
//

lua_State *CLog::s_L = NULL;

CLog::CLog()
{
}

void CLog::init(lua_State *L)
{
    CLog::s_L = L;
}

//x     static lua_State *s_L;
//x 
//x     CLog();
//x 
//x     static void init(lua_State *L);
//x     static void write(char *i_message);
//x 
//x     static void write(char *i_function,
//x                       char *i_message);

//x static
void CLog::write(const char *i_message)
{
    lua_getglobal(s_L, "log");

    /* the first argument */ 
    lua_pushstring(s_L, i_message);

//x     /* the second argument */ 
//x     lua_pushnumber(L, y); 

    /* call the function with 2 arguments, return 1 result */ 

//x     lua_call(L, 2, 1); 
    lua_call(s_L, 1, 0);
//x 
//x     /* get the result */ 
//x     sum = (int)lua_tointeger(L, -1); 
//x 
//x     lua_pop(L, 1); 
}

// static
void CLog::write(const char *i_function,
                 const char *i_message)
{
    lua_getglobal(s_L, "log");

    /* the first argument */ 
    lua_pushstring(s_L, i_function);

    /* the second argument */ 
    lua_pushstring(s_L, i_message);

    /* call the function with 2 arguments, return 1 result */ 

    lua_call(s_L, 2, 0);

//x     /* get the result */ 
//x     sum = (int)lua_tointeger(L, -1); 
//x 
//x     lua_pop(L, 1); 

}


void CLog::write(const string &i_str)
{
    CLog::write(i_str.c_str());
}

void CLog::write(const ostringstream &i_ostream)
{
    CLog::write(i_ostream.str());
}

