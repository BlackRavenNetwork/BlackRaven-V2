# POSIX thread model required for std::mutex/std::thread with BLS/relic (not win32).
x86_64_mingw32_host_CC=x86_64-w64-mingw32-gcc-posix
x86_64_mingw32_host_CXX=x86_64-w64-mingw32-g++-posix
i686_mingw32_host_CC=i686-w64-mingw32-gcc-posix
i686_mingw32_host_CXX=i686-w64-mingw32-g++-posix

mingw32_CFLAGS=-pipe -D_REENTRANT -pthread
mingw32_CXXFLAGS=$(mingw32_CFLAGS) -static-libstdc++ -std=c++17

mingw32_release_CFLAGS=-O2
mingw32_release_CXXFLAGS=$(mingw32_release_CFLAGS)

mingw32_debug_CFLAGS=-O1
mingw32_debug_CXXFLAGS=$(mingw32_debug_CFLAGS)

mingw32_debug_CPPFLAGS=-D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC
