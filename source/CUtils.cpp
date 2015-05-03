#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <vector>
#include <stdbool.h>

#include <cstdlib>
#include <ctime>
#include <ostream>
#include <iostream> 
#include <unistd.h>

using namespace std;

//x #include <cstdlib>

///////////////////////////////////////////////////////////////////////////
//

class CTimer
{
    const char *m_tag;
    clock_t m_stx;

public:
    CTimer(const char *i_tag):
      m_tag(i_tag),
      m_stx(clock())
    {
        now();
    }

    void now()
    {
        clock_t l_ticks = clock() - m_stx;

        cout << "TICKS = " 
             << l_ticks 
             << " SECS = " 
             << (l_ticks / CLOCKS_PER_SEC)
             << "  "
             << " CLOCKS_PER_SEC = " 
             << CLOCKS_PER_SEC
             << "  "
             << m_tag
             << endl;
    }
};

