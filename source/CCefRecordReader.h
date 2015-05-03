    #ifndef CCEFRECORDREADER_INCLUDED
#define CCEFRECORDREADER_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

//x #include <lua.hpp>
#include "CIterData.h"
#include "CIsoTime.h"

const int FGET_LINE_BUFFER_SIZE = 4048;

///////////////////////////////////////////////////////////////////////////
//

struct SLineReader
{
    FILE *m_file;
    CIterData *m_iterData;
                
    long m_ix;
    char m_fget_line_buffer[FGET_LINE_BUFFER_SIZE + 1];
    char **m_token_list;
    double *m_push_values;
    CIsoTime m_iso_time;

    bool m_has_end_marker;

    long m_status;

public:
    SLineReader(FILE *i_file,
                CIterData *i_iterData,
                long i_ix);
    virtual ~SLineReader();

    void set_time();
    long next();

private:
    void update_push_values();
};

///////////////////////////////////////////////////////////////////////////
//

class ICefLineReader
{
public:
    FILE *m_file;
    CIterData *m_iterData;
    double m_fill_value;

public:
    ICefLineReader();
    ICefLineReader(CIterData *i_iterData);
    virtual ~ICefLineReader();

    virtual long push_fill(lua_State *L);

    virtual CIsoTime* get_latest_iso_time() = 0;

    virtual long push_tokens(lua_State *L, 
                             const CIsoTime *i_iso_time) = 0;

    virtual int is_in_range(const CIsoTime *i_iso_time) = 0;
    virtual long next() = 0;

    virtual long read_next(lua_State *L,
                           const CIsoTime *i_iso_time_T0) = 0;

};

class CCefLineReaderDuo : public ICefLineReader
{
    SLineReader *m_line_reader[2];
    SLineReader *m_lo_reader;
    SLineReader *m_hi_reader;

    long m_cur_line;
//x     double m_fill_value;

public:
    CCefLineReaderDuo(CIterData *i_iterData);
    virtual ~CCefLineReaderDuo();
    CIsoTime* get_latest_iso_time();

    long push_tokens(lua_State *L, 
                     const CIsoTime *i_iso_time);

    int is_in_range(const CIsoTime *i_iso_time);
    long next();
    long read_next(lua_State *L,
                   const CIsoTime *i_iso_time_T0);
};


class CCefLineReaderAv : public ICefLineReader
{
    SLineReader *m_line_reader;
    double *m_average_push_values;
    long m_average_count;

public:
    CCefLineReaderAv(CIterData *i_iterData);
    virtual ~CCefLineReaderAv();

    CIsoTime* get_latest_iso_time();

    long push_fill(lua_State *L);
    long push_tokens(lua_State *L, 
             const CIsoTime *i_iso_time);

    int is_in_range(const CIsoTime *i_iso_time);
    long next();
    long read_next(lua_State *L,
                   const CIsoTime *i_iso_time_T0);

};

///////////////////////////////////////////////////////////////////////////
//

class CCefRecordReader
{
    CIterData *m_iterData;
    ICefLineReader *m_lineReaderImpl;
    FILE *m_file;

public:
    CCefRecordReader(lua_State *L);
    virtual ~CCefRecordReader();

    void dump();
    const CIsoTime* getIsoTime();
    long push_tokens(lua_State *L);

    long push_fill_tokens(lua_State *L);
   
//x     long read_next(lua_State *L,
//x                    const CIsoTime *i_iso_time_T0);

    long next(lua_State *L,
              const CIsoTime *i_iso_time_T0);
};

///////////////////////////////////////////////////////////////////////////
//

#endif // CCEFRECORDREADER_INCLUDED


