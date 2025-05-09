import * as ts from "typescript";
import * as tstl from "typescript-to-lua";
import * as path from 'path'
const luamin = require('luamin')

const plugin: tstl.Plugin = {
    beforeEmit(program: ts.Program, options: tstl.CompilerOptions, emitHost: tstl.EmitHost, result: tstl.EmitFile[]) {
        if (options.luaBundle) return;
        const file = result.find(x => path.basename(x.outputPath) == 'lualib_bundle.lua');
        if (!file) {
            console.log('minify_lualib: lualib not found')
            return
        }

        const origSize = file.code.length
        file.code = luamin.minify(file.code)

        console.log(`Minified lualib`)
        console.log(`Bundle size ${origSize} -> ${file.code.length}`)
        console.log(``)
    },
};

export default plugin;