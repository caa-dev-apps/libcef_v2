#ifndef CLOG_INCLUDED
#define CLOG_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

#include <lua.hpp>

#include <sstream>


class CLog
{
public:
    static lua_State *s_L;

    CLog();

    static void init(lua_State *L);
    static void write(const char *i_message);

    static void write(const char *i_function,
                      const char *i_message);

    static void write(const string &i_str);
    static void write(const ostringstream &i_ostream);
};

///////////////////////////////////////////////////////////////////////////
//


#endif // CLOG_INCLUDED


