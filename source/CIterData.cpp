#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ostream>
#include <iostream> 

using namespace std;

#include "CIterData.h"

///////////////////////////////////////////////////////////////////////////
//

///////////////////////////////////////////////////////////////////////////
//
//      var_meta_data
//      PARAMETER_TYPE      = "Data"
//      ENTITY              = "Observatory"
//      PROPERTY            = "Magnitude"
//      FLUCTUATIONS        = "Waveform"
//      CATDESC             = "Orbit number including phase phase of Cluster 1 Spacecraft"
//      UNITS               = "1"
//      SI_CONVERSION       = "1>1"
//      SIZES               = 1
//      VALUE_TYPE          = FLOAT
//      SIGNIFICANT_DIGITS  = 9
//      FILLVAL             = -1.0e31
//      QUALITY             = 2
//      FIELDNAM            = "Orbit number including phase phase of Cluster 1 Spacecraft"
//      LABLAXIS            = "Orbnum"
//      DEPEND_0            = time_tags__C1_CP_AUX_POSGSE_1M
//


const char* get_iter_meta_data(lua_State *L,
                               const char *i_tag,
                               long i_index,
                               const char *i_key)
{
   lua_getglobal(L, "get_iter_meta_data");

   lua_pushstring(L, i_tag);        // i_tag
   lua_pushnumber(L, i_index);      // i_var_index
   lua_pushstring(L, i_key);        // i_key    

   lua_call(L, 3, 1);

   /* get the result */
   const char *l_str = lua_tostring(L, -1);
    
   lua_pop(L, 1);

   return l_str;
}

const char* get_iter_data(lua_State *L,
                          const char *i_tag,
                          const char *i_key)
{
   lua_getglobal(L, "get_iter_data");

   lua_pushstring(L, i_tag);        // i_tag
   lua_pushstring(L, i_key);        // i_key    

   lua_call(L, 2, 1);

   /* get the result */
   const char *l_str = lua_tostring(L, -1);
    
   lua_pop(L, 1);

   return l_str;
}


///////////////////////////////////////////////////////////////////////////
//

CIterData::CIterData(lua_State *L):
    m_fill_var_strs(NULL)
{
    lua_getfield(L, -1, "cef_filepath");
    m_cef_filepath = string(lua_tostring(L, -1));       
    lua_pop(L, 1);

    lua_getfield(L, -1, "end_of_record_marker");
    m_end_of_record_marker = string(lua_tostring(L, -1));       
    lua_pop(L, 1);

    lua_getfield(L, -1, "tag");
    m_tag = string(lua_tostring(L, -1));       
    lua_pop(L, 1);

    lua_getfield(L, -1, "is_delta_const");
    m_is_delta_const = lua_toboolean(L, -1);       
    lua_pop(L, 1);

    lua_getfield(L, -1, "vars_per_record");       // expected vars per line
    m_vars_per_record = lua_tointeger(L, -1);       
    lua_pop(L, 1);

    lua_getfield(L, -1, "delta_m");
    m_delta_m = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, -1, "delta_p");
    m_delta_p = lua_tonumber(L, -1);       
    lua_pop(L, 1);

    lua_getfield(L, -1, "add_interpolation_separation");
    m_add_interpolation_separation = lua_toboolean(L, -1);       
    lua_pop(L, 1);


    lua_getfield(L, -1, "use_averages");
    m_use_averages = lua_toboolean(L, -1);       
    lua_pop(L, 1);


    lua_getfield(L, -1, "var_offsets");
    m_var_count = lua_objlen(L, -1);

    int l_var_table_index = lua_gettop(L);

    if((m_var_count > 0) && (m_var_count <= m_vars_per_record))
    {
        m_var_offsets = new int[m_var_count];

        for(int i=0; i<m_var_count; i++)
        {
            lua_pushnumber(L, i + 1);
            lua_gettable(L, l_var_table_index);
            m_var_offsets[i] = lua_tointeger( L, -1);
            lua_pop(L, 1);
        }
    }

    lua_pop(L, 1);

    m_fill_var_strs = new string *[m_var_count];

    for(int i=0;i<m_var_count;i++)
    {
        const char *l_str = get_iter_meta_data(L,
                                               m_tag.c_str(),
                                               i+1,
                                               "FILLVAL");
        if(l_str != NULL)
        {
            m_fill_var_strs[i] = new string(l_str);
        }
        else
        {
            m_fill_var_strs[i] = new string("-1e-31");
        }

//x         cout << m_tag << " : " << *m_fill_var_strs[i] << endl;
    }
}

CIterData::~CIterData()
{
    if(m_var_offsets != NULL)
    {
        delete m_var_offsets;
    }

    if(m_fill_var_strs != NULL)
    {   
        for(int i=0;i<m_var_count;i++)
        {
            delete m_fill_var_strs[i];
        }

        delete m_fill_var_strs;
    }
}

void CIterData::dump()
{
    cout << "cef_filepath                 : " << m_cef_filepath << endl;
    cout << "end_of_record_marker         : " << m_end_of_record_marker << endl;
    cout << "tag                          : " << m_tag << endl;
    cout << "vars_per_record              : " << m_vars_per_record << endl;
    cout << "var_count                    : " << m_var_count << endl;
    cout << "var_offsets                  : ";
    for(int i=0; i<m_var_count; i++) { cout << m_var_offsets[i] << "  "; }
    cout << endl;
    cout << "is_delta_const               : " << m_is_delta_const << endl;
    cout << "add_interpolation_separation : " << m_add_interpolation_separation << endl;
    cout << "use_averages                 : " << m_use_averages << endl;
    
    cout << "delta_m                      : " << m_delta_m << endl;
    cout << "delta_p                      : " << m_delta_p << endl;
    cout << endl;
}


///////////////////////////////////////////////////////////////////////////
//

//x const CIterData::get_fill_values()
//x 
//x     const char *l_tag = "FGM";
//x     long l_var_index = 1;
//x     const char *l_key = "FILLVAL";
//x 
//x 
//x     cout << l_tag
//x          << endl;
//x 
//x     cout << l_var_index
//x          << endl;
//x 
//x     cout << l_key
//x          << endl;
//x 
//x     cout << get_iter_meta_data(L,
//x                                l_tag,
//x                                l_var_index,
//x                                l_key);
//x 

///////////////////////////////////////////////////////////////////////////
//

void CIterData::open()
{
}

void CIterData::close()
{
}
