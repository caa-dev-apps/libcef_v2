

to run scripts 
--------------

    cd /app/bin


        /app
            /bin
                cef_2_cef_transpose
                efw_l2_part_A
                efw_l3_part_B
                peace_A1
                peace_A2
                peace_A3
                libcef_v2.so
                *luajit
                lua51.so
            /docs
                README.txt
            /lib
                lua code used by the app's in \bin



    PART A L2:
    ----------
        ./luajit ./efw_L2_part_A.lua  /path/EFW_L2  /path/AUX_PosGSE  /path/FGM  /path/AUX_LatLong /path/OUTPUT-FOLDER


    PART B L3:
    ----------
        ./luajit ./efw_L3_part_B.lua  /path/EFW_L3  /path/AUX_PosGSE  /path/FGM  /path/AUX_LatLong /path/OUTPUT-FOLDER


    PEACE A1
    ----------
        ./luajit ./peace_a1.lua  /path/PEA_MOMENTS  /path/FGM_5VPS /path/AUX_PosGSE  /path/AUX_LatLong /path/OUTPUT-FOLDER


    PEACE A2
    ----------
        ./luajit ./peace_a2.lua  /path/H1_MOMENTS  /path/FGM_5VPS /path/AUX_PosGSE  /path/AUX_LatLong /path/OUTPUT-FOLDER


    PEACE A3
    ----------
        ./luajit ./peace_a3.lua  /path/ONBOARD_MOMENTS  /path/FGM_5VPS /path/AUX_PosGSE  /path/AUX_LatLong /path/OUTPUT-FOLDER




    cef_2_cef_transform:
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







