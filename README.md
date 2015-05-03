## libcef_v2:
A project for Interpolation + Transposition Processing of cef files. (code in lua and cpp)

## Overview:
- A merger of two older google-code hosted projects libcef (efw PartA/B processing) and the cef2cef interpolation code. Slight variations in results from the original cef2cef interpolations are to be expected as a different method of calculating interpolation values is used. 
 
NEW Recipes:
5 recipes and the corresponding lua scripts for use in conjunction with libcef_v2 are detailed here:

1. [efw_L2_A-recipe (CIS-CODIF)](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/recipes/efw_L2_A-recipe.md)

- [efw_L2_A.lua](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/bin/efw_L2_A.lua)
    
2. [efw_L3_B-recipe (CIS-HIA)](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/recipes/efw_L3_B-recipe.md)
- [efw_L3_B.lua](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/bin/efw_L3_B.lua)
    
3. [peace_A1-recipe (peace)](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/recipes/peace_A1-recipe.md)
- [peace_A1.lua](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/bin/peace_A1.lua)
    
4. [peace_A2-recipe (codif)](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/recipes/peace_A2-recipe.md)
- [peace_A2.lua](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/bin/peace_A2.lua)
    
5. [peace_A3-recipe (hia)](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/recipes/peace_A3-recipe.md)
- [peace_A3.lua](https://github.com/caa-dev-apps/libcef_v2/blob/v1.0.0/app/bin/peace_A3.lua)



## Introduction
This code attempts to merge to original cef2cef transpose + interpolation functionality with the libecef code used to interpolate values used for the efw PartA/PartB products.

The core functionality - interpolating a set of cef data files based on timings of the first in the cef dataset is written in C/C++ and contained in the libcef_v2.so library. High level lua code scripts contain the functionality for parsing the cef meta data, performing the mathematical functions (e.g. efw PartA/B) on the data read and final out put formating of the resulting data. The lua code provides a high degree of flexibility for further use-cases involving the creation of derived data sets based on data interpolation and transformation functions.

See the example lua files in the app/bin folder for further ideas on the structure of the code.

## Usage
The main application scripts are contained in the app/bin folder, along with the small luajit compiler/fast virtual machine.

   cd app/bin
   export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH


        /app
            /bin
                cef_2_cef_transpose
                efw_l2_part_A
                efw_l3_part_B
                efw_L3_part_B_EV3D.lua
                libcef_v2.so
                *luajit
                lua51.so
            /docs
                README.txt
            /lib
                lua code used by the app's in \bin
To run the application scripts follow the following patterns.

## EDW PART A L2:
--------------
        ./luajit ./efw_L2_part_A.lua  /path/EFW_L2  /path/AUX_PosGSE  /path/FGM  /path/AUX_LatLong /path/OUTPUT-FOLDER
## EDW PART B L3:
--------------
        ./luajit ./efw_L3_part_B.lua  /path/EFW_L3  /path/AUX_PosGSE  /path/FGM  /path/AUX_LatLong /path/OUTPUT-FOLDER
        
## cef_2_cef_transform:
--------------------

        -from       [gse, isr, isr2]
        -to         [gse, isr, isr2]
        -in         cef file with vars to be transposed
        -aux        the cef file containg the lat+long vars used for the transform
        -out        the cef output file post transform
        -vars       [replace, all]   which vars to include in output
        -varlist    [varname.x, varname.y... ]
        -inifile    [contains varlist]
        -ceh        include filename to be added to the meta data
        -dataset    similar to -ceh e.g. "C4_CP_EFW_L3_E3D_GSE__"

        -debug      flag to add aux lat + long + pre-transposed values to ouputfile
        -maxlines   to limit the number of records written to outfile - test aid.
 
        e.g.

        [0] ./luajit cef_2_cef_transpose -from isr2 -to gse -in /path/infile.cef -aux /path/auxfile.cef -out /path/outfolder 
        [1] ./luajit cef_2_cef_transpose -from isr2 -to gse -in /path/infile.cef -aux /path/auxfile.cef -out /path/outfolder -vars replace
        [2] ./luajit cef_2_cef_transpose -from isr2 -to gse -in /path/infile.cef -aux /path/auxfile.cef -out /path/outfolder -vars all
        [3] ./luajit cef_2_cef_transpose -from isr2 -to gse -in /path/infile.cef -aux /path/auxfile.cef -out /path/outfolder -varlist varname.x varname.y ...
        [4] ./luajit cef_2_cef_transpose -from isr2 -to gse -in /path/infile.cef -aux /path/auxfile.cef -out /path/outfolder -inifile ./inifile

        Subject to there being a set of vars to transpose (v.*) in the infile.cef then each of the 
        above configurations will result in at least a time-tag [t0] field and a set of transposed
        vars (v.*)' fields.
      
        n.b. The output format pattern is now t0 [selected vars] (v.*)'.

        If (V.*) is the original set of variables then the following output is expected...

        [0]     t0, (v.*)'
        [1]     t0, (V.*) - (v.*) + (v.*)'
        [2]     t0, (V.*) + (v.*)'
        [3]     t0, (V.x V.y ..) + (v.*)'
        [4]     t0, (V.x V.y ..) + (v.*)'
    if running the scripts from a location other than app/bin, then 
    set the following environment vars prior to running the scripts.


    export LD_LIBRARY_PATH=/path/app/bin:$LD_LIBRARY_PATH
    export LUA_PATH=/path/app/?.lua
    export LUA_CPATH=/path/app/bin/?.so




    test e.g.
           ./luajit ./cef_2_cef_transform.lua -from gse -to isr2 
            -in /in-path/TESTS/C4_CP_EFW_L3_E3D_GSE__20071231_000000_20080101_000000_V100315.cef 
            -aux /aux-path/TESTS/CL_SP_AUX__20071231_000000_20080101_000000_V090217.cef 
            -out /out-path/TESTS/001/ 
            -dataset AA_BB_CCC_DD_EEE_FFF 
            -vars replace 
            -maxlines 1000000
             (for debug)    