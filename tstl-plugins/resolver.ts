import * as tstl from "typescript-to-lua";
import * as path from 'path'
import { existsSync } from "fs";

const plugin: tstl.Plugin = {
    moduleResolution(
        moduleIdentifier: string,
        requiringFile: string,
        options: tstl.CompilerOptions,
        emitHost: tstl.EmitHost,
    ) {
        if ((requiringFile.endsWith('.ts') || requiringFile.endsWith('.tsx')) && moduleIdentifier.indexOf('.') > 1)
        {
            return moduleIdentifier.replaceAll('.', '/')
        }
        console.log(moduleIdentifier)
    },
};

export default plugin;