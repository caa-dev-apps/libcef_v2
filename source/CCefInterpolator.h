#ifndef CCEFINTERPOLATOR_INCLUDED
#define CCEFINTERPOLATOR_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

#include <string>
#include <vector>
#include <stdbool.h>

#include <lua.hpp>

#include "CCefRecordReader.h"

class CCefInterpolator
{
    vector<CCefRecordReader *> m_reader_vector;

public:
    CCefInterpolator();
    virtual ~CCefInterpolator();

    int open(lua_State *L);
    int next(lua_State *L);
    int close(lua_State *L);

private:
    void cleanup();
};

///////////////////////////////////////////////////////////////////////////
//


#endif // CCEFINTERPOLATOR_INCLUDED




