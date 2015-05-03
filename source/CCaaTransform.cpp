#include "stdio.h"
#include "stdlib.h"
#include <string>
#include <stdbool.h>

#include <cmath>

#include <cstdlib>
#include <ostream>
#include <iostream> 

using namespace std;

#include "CCaaTransform.h"

///////////////////////////////////////////////////////////////////////////
//

const string CCaaTransform::SR2 = "sr2";
const string CCaaTransform::ISR2 = "isr2";
const string CCaaTransform::GSE = "gse";

///////////////////////////////////////////////////////////////////////////
//

CCaaTransform::CCaaTransform()
{
}

CCaaTransform::CCaaTransform(const string &i_from,
                             const string &i_to)
//x                              :
//x     m_logger("CCaaTransform")
{
    string l_from = string(i_from);
    string l_to = string(i_to);

    string_tolower(l_from);
    string_tolower(l_to);

    if((l_from.compare(SR2) == 0) && (l_to.compare(GSE) == 0))
        m_transform_type = TYPE_SR2_TO_GSE;
    else if((l_from.compare(ISR2) == 0) && (l_to.compare(GSE) == 0))
        m_transform_type = TYPE_ISR2_TO_GSE;
    else if((l_from.compare(GSE) == 0) && (l_to.compare(SR2) == 0))
        m_transform_type = TYPE_GSE_TO_SR2;
    else if((l_from.compare(GSE) == 0) && (l_to.compare(ISR2) == 0))
        m_transform_type = TYPE_GSE_TO_ISR2;
    else
    {
        m_transform_type = TYPE_INVALID;

        cout << "usage:error" 
             << endl;
        cout << "either:" 
             << endl;
        cout << "-from[sr2, isr2] -to[gse]"
             << endl;
        cout << "or:" 
             << endl;
        cout << "-from[gse] -to[sr2, isr2]"
             << endl;
        cout << "INPUT=>["
             << i_from 
             << "]["
             << i_to
             << "]"
             << endl;
        exit(-1);
                
    }
}

CCaaTransform::CCaaTransform(enum TransformType i_transform_type):
    m_transform_type(i_transform_type)
{
}

CCaaTransform::~CCaaTransform()
{
}

///////////////////////////////////////////////////////////////////////////
//

void CCaaTransform::cross(double io_result[3],
                          double i_A[3],
                          double i_B[3])
{
    io_result[0] = i_A[1]*i_B[2] - i_A[2]*i_B[1];
    io_result[1] = -i_A[0]*i_B[2] + i_A[2]*i_B[0];
    io_result[2] = i_A[0]*i_B[1] - i_A[1]*i_B[0];
}

float CCaaTransform::matrix_3x3_determinant(double M[3][3])
{
    // M[row][col]
    return M[0][0] * M[1][1] * M[2][2] +
           M[0][1] * M[1][2] * M[2][0] +
           M[0][2] * M[1][0] * M[2][1] -
           M[0][0] * M[1][2] * M[2][1] -
           M[0][1] * M[1][0] * M[2][2] -
           M[0][2] * M[1][1] * M[2][0];
}

bool CCaaTransform::matrix_3x3_inverse(double I[3][3],
                                       double M[3][3])
{
    double l_det = matrix_3x3_determinant(M);

    I[0][0] =  ((M[1][1] * M[2][2]) - (M[1][2] * M[2][1])) / l_det;
    I[0][1] =  ((M[0][2] * M[2][1]) - (M[0][1] * M[2][2])) / l_det;
    I[0][2] =  ((M[0][1] * M[1][2]) - (M[0][2] * M[1][1])) / l_det;

    I[1][0] =  ((M[1][2] * M[2][0]) - (M[1][0] * M[2][2])) / l_det;
    I[1][1] =  ((M[0][0] * M[2][2]) - (M[0][2] * M[2][0])) / l_det;
    I[1][2] =  ((M[0][2] * M[1][0]) - (M[0][0] * M[1][2])) / l_det;

    I[2][0] =  ((M[1][0] * M[2][1]) - (M[1][1] * M[2][0])) / l_det;
    I[2][1] =  ((M[0][1] * M[2][0]) - (M[0][0] * M[2][1])) / l_det;
    I[2][2] =  ((M[0][0] * M[1][1]) - (M[0][1] * M[1][0])) / l_det;

    return true;
}

void CCaaTransform::matrix_3x3_print(double M[3][3],
                                     char *i_name)
{
    printf("MATRIX: %s\n", i_name);
    printf("[0] => %f %f %f\n", M[0][0], M[0][1], M[0][2] );
    printf("[1] => %f %f %f\n", M[1][0], M[1][1], M[1][2] );
    printf("[2] => %f %f %f\n", M[2][0], M[2][1], M[2][2] );
}

void CCaaTransform::vector_1_x_3_print(double V[3],
                                       char *i_name)
{
    printf("%s => %f %f %f\n", i_name,
                               V[0],
                               V[1],
                               V[2] );
}

///////////////////////////////////////////////////////////////////////////
//

void CCaaTransform::flip_i_sr2(double i_in[3])
{
    i_in[1] *= -1;
    i_in[2] *= -1;
}

void CCaaTransform::string_tolower(std::string &str) 
{
    for(string::iterator iter = str.begin(); iter != str.end(); ++iter )
    {
        *iter = std::tolower( *iter );
    }
}

double* CCaaTransform::transpose(double i_in[3],
                                 double i_lat,    // degrees
                                 double i_long)   // degrees
{
    double l_in[3] = { i_in[0], i_in[1], i_in[2] };

    double l_rads_long = (i_long * M_PI) / 180;
    double l_rads_lat = (i_lat * M_PI) / 180;

    double l_Z0 = cos(l_rads_long) * cos(l_rads_lat);
    double l_Z1 = sin(l_rads_long) * cos(l_rads_lat);
    double l_Z2 = sin(l_rads_lat);

    double l_X[3];
    double l_Y[3];
    double l_Z[3] = { l_Z0, l_Z1, l_Z2 };
    double l_Yrep0[3] = {1, 0, 0};

    cross(l_Y, l_Z, l_Yrep0);       // Y=cross(Z,Yrep0)

    double l_value = sqrt((l_Y[1]*l_Y[1]) + (l_Y[2]*l_Y[2]));

    if(l_value != 0)
    {
        l_Y[0] /= l_value;
        l_Y[1] /= l_value;
        l_Y[2] /= l_value;
    }

    cross(l_X, l_Y, l_Z);

    double l_out[3] = { 0,0,0};
    double l_invA[3][3];
    double l_A[3][3] =
    {
        {l_X[0], l_X[1], l_X[2]},
        {l_Y[0], l_Y[1], l_Y[2]},
        {l_Z[0], l_Z[1], l_Z[2]}
    };

    matrix_3x3_inverse(l_invA,
                       l_A);

    if((m_transform_type == TYPE_SR2_TO_GSE) || (m_transform_type == TYPE_ISR2_TO_GSE))
    {
        if(m_transform_type == TYPE_ISR2_TO_GSE)
        {
            flip_i_sr2(l_in);
        }

        m_out[0] = (l_invA[0][0] * l_in[0]) + (l_invA[0][1] * l_in[1]) + (l_invA[0][2] * l_in[2]);
        m_out[1] = (l_invA[1][0] * l_in[0]) + (l_invA[1][1] * l_in[1]) + (l_invA[1][2] * l_in[2]);
        m_out[2] = (l_invA[2][0] * l_in[0]) + (l_invA[2][1] * l_in[1]) + (l_invA[2][2] * l_in[2]);
    }
    else if((m_transform_type == TYPE_GSE_TO_SR2) || (m_transform_type == TYPE_GSE_TO_ISR2))
    {
        m_out[0] = (l_A[0][0] * l_in[0]) + (l_A[0][1] * l_in[1]) + (l_A[0][2] * l_in[2]);
        m_out[1] = (l_A[1][0] * l_in[0]) + (l_A[1][1] * l_in[1]) + (l_A[1][2] * l_in[2]);
        m_out[2] = (l_A[2][0] * l_in[0]) + (l_A[2][1] * l_in[1]) + (l_A[2][2] * l_in[2]);

        if(m_transform_type == TYPE_GSE_TO_ISR2)
        {
            flip_i_sr2(m_out);
        }
    }

//d     vector_1_x_3_print(m_out, "out = ");

    return m_out;
}

///////////////////////////////////////////////////////////////////////////
//


CCaaTransform s_GSE_2_ISR2(CCaaTransform::TYPE_GSE_TO_ISR2);
CCaaTransform s_ISR2_2_GSE(CCaaTransform::TYPE_ISR2_TO_GSE);

CCaaTransform s_GSE_2_SR2(CCaaTransform::TYPE_GSE_TO_SR2);
CCaaTransform s_SR2_2_GSE(CCaaTransform::TYPE_SR2_TO_GSE);


///////////////////////////////////////////////////////////////////////////
//

int do_transform(lua_State *L,
                 CCaaTransform &i_transform)
{
    long l_status = 0L;
    
    double l_in[3] =    
    {
        lua_tonumber(L, 1),
        lua_tonumber(L, 2),
        lua_tonumber(L, 3)
    };

    double l_lat = lua_tonumber(L, 4);
    double l_long = lua_tonumber(L, 5);

    double* l_out = i_transform.transpose(l_in,
                                          l_lat,
                                          l_long);
    lua_pushnumber(L, l_out[0]);
    lua_pushnumber(L, l_out[1]);
    lua_pushnumber(L, l_out[2]);

    lua_pushnumber(L, l_status);

    return 4;
}



int c_transform_gse_2_isr2(lua_State *L)
{
    return do_transform(L, s_GSE_2_ISR2);
}

int c_transform_isr2_2_gse(lua_State *L)
{
    return do_transform(L, s_ISR2_2_GSE);
}


int c_transform_gse_2_sr2(lua_State *L)
{
    return do_transform(L, s_GSE_2_SR2);
}

int c_transform_sr2_2_gse(lua_State *L)
{
    return do_transform(L, s_SR2_2_GSE);
}


