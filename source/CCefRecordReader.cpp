#include "stdio.h"
#include "stdlib.h"
#include <cstring>
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ostream>
#include <iostream> 

using namespace std;

#include "CCefRecordReader.h"
#include "CInitData.h"

#include "CLog.h"

const char* TOKEN_DELIMS = ", \t\n\r";

///////////////////////////////////////////////////////////////////////////
//

SLineReader::SLineReader(FILE *i_file,
                         CIterData *i_iterData,
                         long i_ix):
    m_file(i_file),
    m_iterData(i_iterData),
    m_ix(i_ix),
    m_status(-1L),
    m_iso_time()
{
    m_has_end_marker = (m_iterData->m_end_of_record_marker.length() > 0);

    m_token_list = new char*[i_iterData->m_vars_per_record +1];
    m_push_values = new double[i_iterData->m_var_count +1];
}

SLineReader::~SLineReader()
{
    delete m_token_list;
    delete m_push_values;
}

void SLineReader::update_push_values()
{
    char *l_ptr;
    long l_index = 0;

    for(int i=0; i<m_iterData->m_var_count; i++)
    {
        l_index = m_iterData->m_var_offsets[i] - 1;

        if((l_index > 0) && (m_status == 0L))
        {
             m_push_values[i] = strtod(m_token_list[l_index], 
                                       &l_ptr);
        }
    }
}

void SLineReader::set_time()
{
    float l_delta_m = m_iterData->m_delta_m;
    float l_delta_p = m_iterData->m_delta_p;

    if(m_iterData->m_is_delta_const == false)
    {
        l_delta_m = atof(m_token_list[(int)m_iterData->m_delta_m]);
        l_delta_p = atof(m_token_list[(int)m_iterData->m_delta_p]);
    }

    m_iso_time.set(m_token_list[0],
                   l_delta_m,
                   l_delta_p);
}

long SLineReader::next()
{
    char *l_ptr = NULL;
    long l_count = 0L;
    int l_multiline_offset = 0L;

    m_status = -1L;

    while((!feof(m_file)) &&
          (m_status == -1L) &&
          ((l_ptr = fgets(&m_fget_line_buffer[l_multiline_offset],
                         (FGET_LINE_BUFFER_SIZE - l_multiline_offset), 
                          m_file)) != NULL))
    {
        
        while((*l_ptr <= ' ') && (*l_ptr > 0x00)) {l_ptr++;}

        //x if((*l_ptr >= '0') && (*l_ptr <= '9'))
        // 2015.05.01 Fix for when encountering a negative value as the 1st value in multiline record
        if(((*l_ptr >= '0') && (*l_ptr <= '9')) || (*l_ptr =='-') || (*l_ptr =='"') || (*l_ptr ==','))
        {
            bool l_error = false;
            char *l_tok = NULL;
            char *l_last_tok = NULL;
        
            while((l_error == false) && 
                 ((l_tok = strtok (l_ptr, TOKEN_DELIMS)) != NULL)) {
                l_last_tok = l_tok;
                l_ptr = NULL;

                if(l_count < m_iterData->m_vars_per_record) 
                {
                    if(isdigit(*l_tok) || (*l_tok == '-')) {

                        m_token_list[l_count++] = l_tok;

                        if((l_count == m_iterData->m_vars_per_record) &&
                            ((m_has_end_marker == false) || 
								(strstr(l_tok, m_iterData->m_end_of_record_marker.c_str()) != NULL)))
                        {
                            m_status = 0L;
                        }
						
                    }
                    else {
                        cout << "1. l_tok = " << l_tok << endl;
                        l_error = true;
                    }
                }
                else if(strstr(l_tok, m_iterData->m_end_of_record_marker.c_str()) != NULL) {
                    m_status = 0L;
                }
                else {
                    cout << "2. l_tok = " << l_tok << endl;
                    l_error = true;
                }
            }

            if(l_error == true)
            {
                cout << "ERROR = TRUE SLineReader::next()" << endl;
                break;
            }
            else if(m_status == -1L)       //.. it's a multiline job - most probably
            {
                l_multiline_offset = l_last_tok - &m_fget_line_buffer[0];
                l_multiline_offset += strlen(l_last_tok) + 1;
            }
        }
    }

    if(m_status == 0L)
    {
        set_time();
        update_push_values();
    }

    return m_status;
};

///////////////////////////////////////////////////////////////////////////
//

ICefLineReader::ICefLineReader():
    m_iterData(NULL),
    m_file(NULL)
{
}

ICefLineReader::ICefLineReader(CIterData *i_iterData):
    m_iterData(i_iterData)
{
    m_file = fopen(m_iterData->m_cef_filepath.c_str(), "r+t");
    m_fill_value = CInitData::get_object().m_fill_value;

    // skip header
    if(m_file != NULL) 
    {
        char *l_ptr = NULL;
        char l_fget_line_buffer[FGET_LINE_BUFFER_SIZE + 1];

        while(!feof(m_file)) {
            l_ptr = fgets(l_fget_line_buffer,
                          FGET_LINE_BUFFER_SIZE,
                          m_file);
            
            if(strstr(l_fget_line_buffer,
                      "DATA_UNTIL") != NULL) {
                break;
            }
        }
    }
    else
    {
        cout << "ERROR opening ... " << m_iterData->m_cef_filepath.c_str() << endl;
    }
}

ICefLineReader::~ICefLineReader()
{
    if(m_file != NULL)
    {
        fclose(m_file);
        m_file = NULL;
    }
}

const char* FILL_TIME_STR = "yyyy-mm-ddThh:mm:ss.00Z";
const char* FILL_VAL      = "FILL_VAL";


static long s_push_fill_count = 0;

long ICefLineReader::push_fill(lua_State *L)
{
    long l_count = 0L;

    for(int i=0; i<m_iterData->m_var_count; i++)
    {
        lua_pushstring(L, m_iterData->m_fill_var_strs[i]->c_str());

        l_count += 1;
    }

//x     cout << m_iterData->m_fill_var_strs[0]->c_str() << endl;

    if(m_iterData->m_add_interpolation_separation == true)
    {
        lua_pushnumber(L, -1);
        l_count += 1;
    }

    return l_count;
}

///////////////////////////////////////////////////////////////////////////
//

CCefLineReaderDuo::CCefLineReaderDuo(CIterData *i_iterData):
    ICefLineReader(i_iterData),
    m_cur_line(0)
{
    m_line_reader[0] = new SLineReader(m_file, i_iterData, 0);
    m_line_reader[1] = new SLineReader(m_file, i_iterData, 1);

    m_lo_reader = m_line_reader[0];
    m_hi_reader = m_line_reader[1];
}

CCefLineReaderDuo::~CCefLineReaderDuo()
{
    delete m_line_reader[0];
    delete m_line_reader[1];
}

CIsoTime* CCefLineReaderDuo::get_latest_iso_time()
{
    return &m_hi_reader->m_iso_time;
}

long CCefLineReaderDuo::push_tokens(lua_State *L, 
                                    const CIsoTime *i_iso_time)
{
    long l_count = 0L;

    if(i_iso_time == NULL)
    {
        char **l_ptr;

        for(int i=0; i<m_iterData->m_var_count; i++)
        {
            long l_index = m_iterData->m_var_offsets[i] - 1;
            lua_pushstring(L, m_hi_reader->m_token_list[l_index]);

            l_count += 1;
        }
    }
    else if((m_lo_reader->m_status == 0L) &&
            (m_hi_reader->m_status == 0L))
    {
        double l_diff = m_hi_reader->m_iso_time.diff(m_lo_reader->m_iso_time);

        // filter out values (i.e set FILL_VAL) after a gap > delta m+p
        // so interpolated values are not skewed due to the large separation
        double l_delta = (m_hi_reader->m_iso_time.m_delta_m +
                          m_hi_reader->m_iso_time.m_delta_p) * 1.2;

        if(l_diff <= l_delta) 
        {
            double l_iterpolator_fraction = i_iso_time->get_fraction(m_lo_reader->m_iso_time,
                                                                     m_hi_reader->m_iso_time);

            for(int i=0; i<m_iterData->m_var_count; i++)
            {
                long l_index = m_iterData->m_var_offsets[i] - 1;

                if(l_index == 0L)
                {
                    lua_pushstring(L, m_hi_reader->m_token_list[0]);
                }
                else
                {
                    double l_value = ((m_hi_reader->m_push_values[i] -
                                       m_lo_reader->m_push_values[i]) *
                                       l_iterpolator_fraction) +
                                       m_lo_reader->m_push_values[i];

                    lua_pushnumber(L, l_value);
                }

                l_count += 1;
            }

            if(m_iterData->m_add_interpolation_separation == true)
            {
                lua_pushnumber(L, l_diff);
                l_count += 1;
            }
        }
        else
        {
            l_count = push_fill(L);
        }
    }
    else
    {
        l_count = push_fill(L);
    }

    return l_count;
}

int CCefLineReaderDuo::is_in_range(const CIsoTime *i_iso_time)
{
    return i_iso_time->is_in_range(m_lo_reader->m_iso_time,
                                   m_hi_reader->m_iso_time);
}

long CCefLineReaderDuo::next()
{
    long l_status = m_line_reader[m_cur_line++ %2]->next();

    m_lo_reader = m_line_reader[m_cur_line %2];
    m_hi_reader = m_line_reader[(m_cur_line + 1) %2];

    return l_status;
}

long CCefLineReaderDuo::read_next(lua_State *L,
                                  const CIsoTime *i_iso_time_T0)
{
    long l_status = 1L;
    
    long d_count = 0;

    while(l_status == 1L)
    {
        l_status = next();
    
        if((l_status == 0L) && (i_iso_time_T0 != NULL))
        {
            l_status = is_in_range(i_iso_time_T0);
        }
    }

    return l_status;
}

///////////////////////////////////////////////////////////////////////////
//

CCefLineReaderAv::CCefLineReaderAv(CIterData *i_iterData):
    ICefLineReader(i_iterData)
{
    m_line_reader = new SLineReader(m_file, i_iterData, 0);

    // read first one
    m_line_reader->next();

    m_average_push_values = new double[i_iterData->m_var_count +1];
    m_average_count = 0;

}

CCefLineReaderAv::~CCefLineReaderAv()
{
    delete m_line_reader;
}


CIsoTime* CCefLineReaderAv::get_latest_iso_time()
{
    return &m_line_reader->m_iso_time;
}


long CCefLineReaderAv::push_fill(lua_State *L)
{
    long l_count = ICefLineReader::push_fill(L);

    // m_average_count
    lua_pushnumber(L, 0L);

    l_count += 1;

    return l_count;
}

long CCefLineReaderAv::push_tokens(lua_State *L,
                                   const CIsoTime *i_iso_time)
{
    long l_count = 0L;
    double l_average = 0;

    if(m_average_count > 0L)
    {
        for(int i=0; i<m_iterData->m_var_count; i++)
        {
            long l_index = m_iterData->m_var_offsets[i] - 1;

            if(l_index == 0L)
            {
                lua_pushstring(L, m_line_reader->m_token_list[0L]);
            }
            else
            {
                l_average = m_average_push_values[i] / m_average_count;
                lua_pushnumber(L, l_average);
            }
        
            l_count += 1;
        }

        lua_pushnumber(L, m_average_count);
        l_count += 1;
    }
    else
    {
        l_count = push_fill(L);
    }

    return l_count;
}

int CCefLineReaderAv::is_in_range(const CIsoTime *i_iso_time)
{
    // don't call this for now!!!
    return 1;
}

long CCefLineReaderAv::next()
{
    return m_line_reader->next();
}

long CCefLineReaderAv::read_next(lua_State *L,
                                 const CIsoTime *i_iso_time_T0)
{
    long l_status = -1L;
    bool l_fill_val_set = false;

    long d_count = 0;

    m_average_count = 0;

    if(i_iso_time_T0 != NULL)
    {
        for(int i=0; i<m_iterData->m_var_count; i++)
        {
            m_average_push_values[i] = 0.0;
        }

        while((l_status = i_iso_time_T0->is_in_delta_range(m_line_reader->m_iso_time)) < 1L)
        {
            if((l_fill_val_set == false) && (l_status == 0))
            {
                m_average_count++;

                for(int i=0; i<m_iterData->m_var_count; i++)
                {
                    long l_index = m_iterData->m_var_offsets[i] - 1;

                    // no need to average the time value
                    if((l_index > 0L) && 
                        (m_average_push_values[i] != m_fill_value))
                    {
                        double l_value = m_line_reader->m_push_values[i];

                        if(l_value == m_fill_value)
                        {
//x                             cout << " x " << m_average_count << " x " << endl;
                            m_average_push_values[i] = m_fill_value;
                            l_fill_val_set = true;
                            m_average_count = 0;
                            break;
                        }
                        else
                        {
                            m_average_push_values[i] += l_value;
                        }
                    }
                }
            }

            // read next line
            if(next() != 0)
            {
                l_fill_val_set = true;
                m_average_count = 0;
                break;
            }
        }
    }

    return (l_fill_val_set == false && (m_average_count > 0)) ? 0L : 1L;
}

///////////////////////////////////////////////////////////////////////////
//

CCefRecordReader::CCefRecordReader(lua_State *L):
    m_iterData(NULL),
    m_lineReaderImpl(NULL),
    m_file(NULL)
{
    m_iterData = new CIterData(L); 

    if(m_iterData->m_use_averages == false)
    {
        m_lineReaderImpl = new CCefLineReaderDuo(m_iterData);
    }
    else
    {
        m_lineReaderImpl = new CCefLineReaderAv(m_iterData);
    }
}

CCefRecordReader::~CCefRecordReader()
{
    if(m_iterData != NULL)
    {
        delete m_iterData;
        m_iterData = NULL;
    }

    if(m_lineReaderImpl != NULL)
    {
        delete m_lineReaderImpl;
        m_lineReaderImpl = NULL;
    }
}

///////////////////////////////////////////////////////////////////////////
//

void CCefRecordReader::dump()
{
    m_iterData->dump();
}

const CIsoTime* CCefRecordReader::getIsoTime()
{
    return m_lineReaderImpl->get_latest_iso_time();
}

///////////////////////////////////////////////////////////////////////////
//
   
long CCefRecordReader::next(lua_State *L,
                            const CIsoTime *i_iso_time_T0)
{
    long l_count = 0L;
    long l_status = 0L;

    if(!((i_iso_time_T0 != NULL) &&
        ((l_status = m_lineReaderImpl->is_in_range(i_iso_time_T0)) <= 0L)))
    {
        l_status = m_lineReaderImpl->read_next(L,
                                               i_iso_time_T0);
    }

    if(l_status == 0L)
    {
        l_count = m_lineReaderImpl->push_tokens(L, 
                                               i_iso_time_T0);
    }
    else if(i_iso_time_T0 != NULL)
    {
        l_count = m_lineReaderImpl->push_fill(L);
    }
    else
    {
        l_count = -1L;
    }

    return l_count;
}

