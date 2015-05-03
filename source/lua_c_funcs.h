#ifndef LUA_C_FUNCS_INCLUDED
#define LUA_C_FUNCS_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

#include <lua.hpp>

extern int c_cef_cell_reader_open(lua_State *L);
extern int c_cef_cell_reader_next(lua_State *L);
extern int c_cef_cell_reader_close(lua_State *L);

extern int c_set_fill_val(lua_State *L);

///////////////////////////////////////////////////////////////////////////
//


#endif // LUA_C_FUNCS_INCLUDED

