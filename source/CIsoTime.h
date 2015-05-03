#ifndef CISOTIME_INCLUDED
#define CISOTIME_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

class CIsoTime
{
public:
//d string d_iso_str;

    time_t m_time_t;
    double m_fsec;

    float m_delta_m;
    float m_delta_p;

public:
    CIsoTime();
    CIsoTime(const char *i_iso_str,
             float i_delta_m = 0,
             float i_delta_p = 0);
    ~CIsoTime();

    bool operator<(const CIsoTime &i_iso_time) const;
    bool operator<=(const CIsoTime &i_iso_time) const;
    bool operator>(const CIsoTime &i_iso_time) const;
    bool operator>=(const CIsoTime &i_iso_time) const;

    void set(const char *i_iso_str,
             float i_delta_m = 0.0,
             float i_delta_p = 0.0);

    long  is_in_range(const CIsoTime &i_T0,
                      const CIsoTime &i_T1) const;

    long is_in_delta_range(const CIsoTime &i_iso_time) const;

    double diff(const CIsoTime &i_iso_time) const;
    double get_fraction(const CIsoTime &i_T0,
                        const CIsoTime &i_T1) const;

    float get_fraction_float(const CIsoTime &i_T0,
                             const CIsoTime &i_T1) const;

};

///////////////////////////////////////////////////////////////////////////
//


#endif // CISOTIME_INCLUDED


