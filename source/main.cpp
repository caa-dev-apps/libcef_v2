#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <stdbool.h>

#include <iostream>
#include <sstream>

using namespace std;

#include <lua.hpp>

#include "lua_c_funcs.h"
#include "lua_c_tests.h"
#include "lua_c_utils.h"

#include "CLog.h"
#include "CCaaTransform.h"
#include "CInitData.h"

///////////////////////////////////////////////////////////////////////////
//

#ifdef __cplusplus
extern "C" {
#endif
 
LUALIB_API int luaopen_libcef_v2(lua_State *L);
 
#ifdef __cplusplus
}
#endif


///////////////////////////////////////////////////////////////////////////
//

static const luaL_reg libcef[] =
{
    { "c_transform_gse_2_isr2",          c_transform_gse_2_isr2},
    { "c_transform_isr2_2_gse",          c_transform_isr2_2_gse },

    { "c_transform_gse_2_sr2",           c_transform_gse_2_sr2},
    { "c_transform_sr2_2_gse",           c_transform_sr2_2_gse },

    { "c_utils_mkdir",                   c_utils_mkdir },
    { "c_utils_file_exists",             c_utils_file_exists },

    { "c_set_fill_val",                  c_set_fill_val },

    { "c_cef_cell_reader_open",          c_cef_cell_reader_open },
    { "c_cef_cell_reader_next",          c_cef_cell_reader_next },
    { "c_cef_cell_reader_close",         c_cef_cell_reader_close },

    { "c_test_iso_time",                 c_test_iso_time },
    { "c_test_iso_time_in_delta_range",  c_test_iso_time_in_delta_range },

    { NULL, NULL}
};

//x     m_fill_value = CInitData::get_object().m_fill_value;

LUALIB_API int luaopen_libcef_v2(lua_State *L)
{
    CLog::init(L);

//x     ostringstream l_stream;

    cout  << "libcef_v2, Build: "
          << __DATE__
          << " @ "
          << __TIME__
          << endl;

   luaL_openlib(L, "libcef", libcef, 0);

//x    CLog::write(l_stream);

//x    CInitData::init(L);

   return 1;
}



//x ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/ceflib.dll

