clang -c -g -gcodeview -o cjson-windows.lib -target x86_64-pc-windows -fuse-ld=llvm-lib -Wall cjson\cjson.c

mkdir libs
move cjson-windows.lib libs
