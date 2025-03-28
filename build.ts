import { type Build } from 'cmake-ts-gen';

const build: Build = {
    common: {
        project: 'cjson',
        archs: ['x64'],
        variables: [],
        copy: {},
        defines: [],
        options: [
            ["BUILD_SHARED_LIBS", false],
            ["ENABLE_CJSON_TEST", false]
        ],
        subdirectories: ['cJSON'],
        libraries: {
            cjson: {}
        },
        buildDir: 'build',
        buildOutDir: '../libs',
        buildFlags: [],
    },
    platforms: {
        win32: {
            windows: {},
            android: {
                archs: ['x86', 'x86_64', 'armeabi-v7a', 'arm64-v8a'],
            }
        },
        linux: {
            linux: {},
        },
        darwin: {
            macos: {}
        }
    }
}

export default build;