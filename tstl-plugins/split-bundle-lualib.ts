import * as ts from "typescript";
import * as tstl from "typescript-to-lua";
import * as path from 'path'
const luaparse = require('luaparse')
const luamin = require('luamin')

const plugin: tstl.Plugin = {
    beforeEmit(program: ts.Program, options: tstl.CompilerOptions, emitHost: tstl.EmitHost, result: tstl.EmitFile[]) {
        if (!options.luaBundle) return;
        const file = result[0];

        const origSize = file.code.length;
        
        const ast = luaparse.parse(file.code, {
            luaVersion: options.luaTarget,
            scope: true
        })
        
        const modules = (ast.body as any[])
        .filter(x => x.type == 'AssignmentStatement' && (x.variables as any[]).find(x => x.name == '____modules'))
        const initIdx = (modules[0].variables as any[]).findIndex(x => x.name == '____modules')
        
        const initFields = modules[0].init[initIdx].fields as ({ key: {raw: string} }|any)[]
        const lualibIdx = initFields.findIndex(x => x.key.raw == `"lualib_bundle"`)
        const lualib = initFields.splice(lualibIdx, 1)[0]

        file.code = luamin.minify(ast)

        const ast2 = {
            type: 'Chunk',
            body: lualib.value.body,
            comments: [],
            globals: ast.globals
        }

        const lualibCode = luamin.minify(ast2);
        result.push({
            code: lualibCode,
            outputPath: path.join(path.dirname(file.outputPath), 'lualib_bundle.lua')
        })

        console.log(`Splitted and minified lualib from bundle.`)
        console.log(`Bundle size ${origSize} -> ${file.code.length}`)
        console.log(`Lualib size ${lualibCode.length}`)
        console.log(``)
    },
};

export default plugin;