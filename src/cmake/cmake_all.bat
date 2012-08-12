echo off

rem
rem Try and build a bunch of output files, if you dont have
rem the right compiler setup then that build type will fail
rem this gets you a bunch of msvc project files that you can
rem then use as you see fit. Well thats the theory :)
rem
rem devc, well, mingwin or gcc in general is suported
rem from the unixmakefile option.
rem
rem at the moment vc6 is the only fully tested build but
rem the vc2003 one probably works
rem
rem  Borland Makefiles           = Generates Borland makefiles.
rem  NMake Makefiles             = Generates NMake makefiles.
rem  Unix Makefiles              = Generates standard UNIX makefiles.
rem  Visual Studio 6             = Generates Visual Studio 6 project files.
rem  Visual Studio 7             = Generates Visual Studio .NET 2002 project
rem                                files.
rem  Visual Studio 7 .NET 2003   = Generates Visual Studio .NET 2003 project
rem                                files.

rem path c:/xix/_pc/cmake/bin
REM path C:\Program Files\CMake 2.6\bin

rem call cmake_one.bat msys       -G"Unix Makefiles"            -D"BUILD_SHARED_LIBS:BOOL=OFF"
rem call cmake_one.bat msys_DLL   -G"Unix Makefiles"            -D"BUILD_SHARED_LIBS:BOOL=ON"

rem call cmake_one.bat vc6        -G"Visual Studio 6"           -D"BUILD_SHARED_LIBS:BOOL=OFF"
rem call cmake_one.bat vc6_DLL    -G"Visual Studio 6"           -D"BUILD_SHARED_LIBS:BOOL=ON"


call cmake_one.bat vc9_DLL    -G"Visual Studio 9 2008"           -D"BUILD_SHARED_LIBS:BOOL=ON"


rem call cmake_one.bat vc2003     -G"Visual Studio 7 .NET 2003" -D"BUILD_SHARED_LIBS:BOOL=OFF"
rem call cmake_one.bat vc2003_DLL -G"Visual Studio 7 .NET 2003" -D"BUILD_SHARED_LIBS:BOOL=ON"
