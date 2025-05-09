import * as ts from "typescript";
import * as tstl from "typescript-to-lua";
import * as path from 'path'
const luamin = require('luamin')

const plugin: tstl.Plugin = {
    beforeEmit(program: ts.Program, options: tstl.CompilerOptions, emitHost: tstl.EmitHost, result: tstl.EmitFile[]) {
        for (const file of result) {
            const origSize = file.code.length
            file.code = luamin.minify(file.code)
            const localPath = path.relative(options.outDir ?? path.resolve('.'), file.outputPath)
    
            console.log(`Minified ${localPath}: ${origSize} -> ${file.code.length}`)
        }
        console.log(``)
    },
};

export default plugin;