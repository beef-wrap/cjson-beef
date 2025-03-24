cmake -S . -B cJSON/build -DCMAKE_BUILD_TYPE=Debug
cmake --build cJSON/build --config Debug

cmake -S . -B cJSON/build -DCMAKE_BUILD_TYPE=Release
cmake --build cJSON/build --config Release