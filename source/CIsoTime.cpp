#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <cstring>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ctime>
#include <ostream>
#include <iostream> 
#include <unistd.h>

using namespace std;

#include "CIsoTime.h"

///////////////////////////////////////////////////////////////////////////
//

CIsoTime::CIsoTime()
{
}

//x CIsoTime::CIsoTime(const char *i_iso_str,
//x                    float i_delta_m,
//x                    float i_delta_p):
//x     m_delta_m(i_delta_m),
//x     m_delta_p(i_delta_p)
//x {
//x     set(i_iso_str);
//x }

CIsoTime::CIsoTime(const char *i_iso_str,
                   float i_delta_m,
                   float i_delta_p)
{
    set(i_iso_str, 
        i_delta_m, 
        i_delta_p);
}

CIsoTime::~CIsoTime()
{
}

///////////////////////////////////////////////////////////////////////////
//

double CIsoTime::diff(const CIsoTime &i_iso_time) const
{
    return difftime(m_time_t, i_iso_time.m_time_t) +
                   (m_fsec - i_iso_time.m_fsec);
}


bool CIsoTime::operator<(const CIsoTime &i_iso_time) const
{
    return (diff(i_iso_time) < 0.0);
}

bool CIsoTime::operator<=(const CIsoTime &i_iso_time) const
{
    return (diff(i_iso_time) <= 0.0);
}

bool CIsoTime::operator>(const CIsoTime &i_iso_time) const
{
    return (diff(i_iso_time) > 0.0);
}

bool CIsoTime::operator>=(const CIsoTime &i_iso_time) const
{
    return (diff(i_iso_time) >= 0.0);
}

///////////////////////////////////////////////////////////////////////////
//

void CIsoTime::set(const char *i_iso_str,
                   float i_delta_m,
                   float i_delta_p)
{
    m_delta_m = i_delta_m;
    m_delta_p = i_delta_p;

//d d_iso_str = string(i_iso_str);

    m_time_t  = 0;
    m_fsec    = 0.0;

    if((i_iso_str != NULL) && (i_iso_str[10] == 'T'))
    {
        struct tm l_time_tm;

        l_time_tm.tm_year  = atoi(i_iso_str + 0) - 1900;
        l_time_tm.tm_mon   = atoi(i_iso_str + 5) - 1;
        l_time_tm.tm_mday  = atoi(i_iso_str + 8);
        l_time_tm.tm_hour  = atoi(i_iso_str + 11);
        l_time_tm.tm_min   = atoi(i_iso_str + 14);
        l_time_tm.tm_sec   = atoi(i_iso_str + 17);
        l_time_tm.tm_isdst = 0;

        m_time_t = mktime(&l_time_tm);

        int l_len = strlen(i_iso_str);

        if(l_len > 21) 
        {
            char *l_etx = NULL;

            m_fsec = strtod(i_iso_str + 19, &l_etx);
        }

//x         cout << "tt." << i_iso_str << endl;

        m_fsec += ((m_delta_p - m_delta_m) / 2);
    }
    else
    {
        cout << "CIsoTime::ERROR" << endl;
    }
}

long CIsoTime::is_in_range(const CIsoTime &i_T0,
                           const CIsoTime &i_T1) const
{
    long l_result = 1L;

    if((i_T0.m_time_t > 0) && (i_T1.m_time_t > 0))
    {
        if(*this < i_T0)
        {
            l_result = -1;
        }
        else if (*this >= i_T1)
        {
            l_result = 1L;
        }
        else
        {
            l_result = 0L;
        }
    }

//d     cout << "IS IN RANGE: "  
//d          << l_result
//d          << "(IN:  "
//d          << d_iso_str
//d          << ") (LOW:  "
//d          << i_T0.d_iso_str
//d          << ") (HIGH: "
//d          << i_T1.d_iso_str
//d          << ")"
//d          << endl;
//d 

    return l_result;
}


//x     function m_data:is_in_delta_range(i_iso_time)
//x         local l_diff = i_iso_time.m_secs - self.m_secs  +
//x                        ((i_iso_time.m_fsecs - self.m_fsecs) * 10^-12)
//x 
//x         local l_return = 0
//x 
//x         if     l_diff < self.m_delta_m then print("x", i_iso_time:get_iso_str()) l_return  = -1
//x         elseif l_diff >= self.m_delta_p then l_return = 1
//x         end
//x 
//x         return l_return
//x     end



long CIsoTime::is_in_delta_range(const CIsoTime &i_iso_time) const
{
    long l_result = 1L;

    double l_diff = diff(i_iso_time);

//x     if(l_diff < -m_delta_m)
//x     {
//x         l_result = 1;
//x     }
//x     else if(l_diff >= m_delta_p)
//x     {
//x         l_result = -1;
//x     }
    if(l_diff > m_delta_m)
    {
        l_result = -1;
    }
    else if(l_diff <= - m_delta_p)
    {
        l_result = 1;
    }
    else
    {
        l_result = 0;
    }


//x     cout << l_result
//x          << "    "
//x          << d_iso_str 
//x          << "("
//x          << m_time_t
//x          << "."
//x          << m_fsec
//x          << ")  -"
//x          << m_delta_m
//x          << "  +"
//x          << m_delta_p
//x          << "  << "
//x          << l_diff 
//x          << "  << "
//x          << i_iso_time.d_iso_str 
//x          << "."
//x          << i_iso_time.m_fsec
//x          << "("
//x          << i_iso_time.m_time_t
//x          << ")"
//x          << endl;


    return l_result;
}





// = (t - T0)/(T1 - T0)
double CIsoTime::get_fraction(const CIsoTime &i_T0,
                              const CIsoTime &i_T1) const
{
    double l_n = diff(i_T0);
    double l_d = i_T1.diff(i_T0);

//d     cout << d_iso_str 
//d          << " - "
//d          << i_T0.d_iso_str
//d          << " = "
//d          << l_n
//d          << endl;
//d 
//d     cout << i_T1.d_iso_str 
//d          << " - "
//d          << i_T0.d_iso_str
//d          << " = "
//d          << l_d
//d          << endl;
//d 
//d     cout << "===================="
//d          << endl
//d          << l_n
//d          << " / "
//d          << l_d
//d          << " = "
//d          << (l_n / l_d)
//d          << endl
//d          << endl;


    return l_n / l_d;
}
            

float CIsoTime::get_fraction_float(const CIsoTime &i_T0,
                                   const CIsoTime &i_T1) const
{
    double l_n = diff(i_T0);
    double l_d = i_T1.diff(i_T0);

//    return (diff(i_T0) / i_T1.diff(i_T0));
    return (float)(l_n / l_d);
}
            
