#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ostream>
#include <iostream> 

using namespace std;

#include "CCefInterpolator.h"

///////////////////////////////////////////////////////////////////////////
//

CCefInterpolator::CCefInterpolator()
{
}

CCefInterpolator::~CCefInterpolator()
{
    cleanup();
}

void CCefInterpolator::cleanup()
{
    int l_size = m_reader_vector.size();

    for(int i=0; i<l_size; i++)
    {
        CCefRecordReader *l_reader = m_reader_vector[i];
        if(l_reader != NULL)
        {
            delete l_reader;
        }
    }

    m_reader_vector.resize(0);
}

int CCefInterpolator::open(lua_State *L)
{
    cleanup();

    long l_status = 0L;
    long l_size = lua_objlen(L, -1);

    for(int i=1; i<=l_size; i++)
    {
        lua_pushnumber(L, i);           // first record
        lua_gettable(L, 1);             // the table passed as a parmameter

        CCefRecordReader *l_reader = new CCefRecordReader(L);
        m_reader_vector.push_back(l_reader);

        l_reader->dump();            

        lua_pop(L,1);
    }

//x     lua_pushnumber(L, l_status);

    return l_status;
}


int CCefInterpolator::next(lua_State *L)
{
    long l_total = 0L;
    long l_count = 0L;

    int l_size = m_reader_vector.size();

    CCefRecordReader *l_reader = m_reader_vector[0];
    if((l_count = l_reader->next(L, NULL)) > 0L)
    {
        l_total += l_count;
        const CIsoTime *l_iso_timer = l_reader->getIsoTime();     

        for(int i=1; i<l_size; i++)
        {
            l_reader = m_reader_vector[i];

            if((l_count = l_reader->next(L, 
                                         l_iso_timer)) > 0L)
            {
                l_total += l_count;
            }
            else
            {
                l_total = 0L;
                break;
            }
        }
    }

    return l_total;
}


int CCefInterpolator::close(lua_State *L)
{
    cleanup();

    long l_status = 0L;

    cout << "CLOSE" << endl;

//x     lua_pushnumber(L, l_status);

    return l_status;
}



