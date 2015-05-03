#ifndef CCAATRANSFORM_INCLUDED
#define CCAATRANSFORM_INCLUDED

///////////////////////////////////////////////////////////////////////////
//

class CCaaTransform
{

public:
    static const string SR2;
    static const string ISR2;
    static const string GSE;

private:
    double m_out[3];
//x     CCefLogger m_logger;

public:
    enum TransformType 
    {
        TYPE_INVALID = 0,
        TYPE_SR2_TO_GSE,
        TYPE_ISR2_TO_GSE,
        TYPE_GSE_TO_SR2,
        TYPE_GSE_TO_ISR2,
    } m_transform_type;

public:
    CCaaTransform();
    CCaaTransform(const string &i_from,
                  const string &i_to);
    CCaaTransform(enum TransformType i_type);

    ~CCaaTransform();

private:
    void cross(double io_result[3],
               double i_A[3],
               double i_B[3]);

    float matrix_3x3_determinant(double M[3][3]);
    bool matrix_3x3_inverse(double I[3][3],
                            double M[3][3]);
    void matrix_3x3_print(double M[3][3],
                          char *i_name = "");
    void vector_1_x_3_print(double V[3],
                            char *i_name);

    void flip_i_sr2(double i_in[3]);


    void string_tolower(std::string &str);

public:
    double* transpose(double i_in[3],
                      double i_lat,    // degrees
                      double i_long);  // degrees
};

///////////////////////////////////////////////////////////////////////////
//

#include <lua.hpp>

extern int c_transform_gse_2_isr2(lua_State *L);
extern int c_transform_isr2_2_gse(lua_State *L);

extern int c_transform_gse_2_sr2(lua_State *L);
extern int c_transform_sr2_2_gse(lua_State *L);


#endif // CCAATRANSFORM_INCLUDED

