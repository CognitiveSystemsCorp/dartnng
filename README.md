
-get Dependencies 

`dart pub get`

- Run main test function

`dart main.dart`


Prepare NNG sources

```
cd ../
git clone  git@git.cognitivesystems.com:zen/nng.git
mkdir nng/build
cd nng/build

```

- Generate Dart FFI bindings

```
cd dartnng
dart run ffigen
```

- Compile NNG for Android:
```
cmake -DBUILD_SHARED_LIBS=True -DNNG_ENABLE_TLS=OFF -DCMAKE_BUILD_TYPE=Release -DNNG_TESTS=OFF -DNNG_TOOLS=OFF -DANDROID_ABI=arm64-v8a -DCMAKE_TOOLCHAIN_FILE=~/.buildozer/android/platform/android-ndk-r19c/build/cmake/android.toolchain.cmake ..
make 
cp libnng.so ../../zenf/android/app/libs/arm64-v8a/libnng.so
```

- Compile NNG for Linux:

```
cmake -DBUILD_SHARED_LIBS=True -DNNG_ENABLE_TLS=OFF -DCMAKE_BUILD_TYPE=Release -DNNG_TESTS=OFF -DNNG_TOOLS=OFF 
make 
sudo make install
sudo ldconfig
```
