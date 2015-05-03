#ifndef CITERDATA_INCLUDED
#define CITERDATA_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

#include <lua.hpp>


class CIterData
{
public:
    string m_cef_filepath;
    string m_end_of_record_marker;
    string m_tag;
    int m_var_count;
    int m_vars_per_record;
    int *m_var_offsets;
    bool m_is_delta_const;
    bool m_add_interpolation_separation;
    bool m_use_averages;

    float m_delta_m;
    float m_delta_p;

    string **m_fill_var_strs;


public:
    CIterData(lua_State *L);
    ~CIterData();

    void dump();

    void open();
    void close();

};

extern const char* get_iter_meta_data(lua_State *L,
                                      const char *i_tag,
                                      long i_index,
                                      const char *i_key);

extern const char* get_iter_data(lua_State *L,
                                 const char *i_tag,
                                 const char *i_key);

///////////////////////////////////////////////////////////////////////////
//


#endif // CITERDATA_INCLUDED


