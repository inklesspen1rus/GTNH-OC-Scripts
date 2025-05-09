import * as _component from 'component';
import { pull } from 'event';

// Sadly...
const component = _component as typeof _component & {
    assembler: {
        start(this: void): boolean;
        status(this: void): LuaMultiReturn<['busy', number] | ['idle', false]>
    },
    transposer: {
        getAllStacks(this: void, size: number): LuaMultiReturn<[{
            count(this: void): number,
            getAll(this:void): any
        } & LuaIterable<any>]> | LuaMultiReturn<[undefined, string]>,
        transferItem(this:void, sourceSide: number, sinkSide: number, count?: number, sourceSlot?: number, sinkSlot?: number): number
    }
};

const transposer = component.transposer;
const assembler = component.assembler;

let assemblerSide: number = undefined!;
let interfaceSide: number = undefined!;

for (const side of [0, 1, 2, 3, 4, 5]) {
    const d = transposer.getAllStacks(side)[0]
    if (!d) continue;
    
    const c = d.count();
    if (c == 22) {
        assemblerSide = side
    } else if (c == 9) {
        interfaceSide = side
    }
}

if (assemblerSide == -1 || interfaceSide == -1) {
    error('Не удалось обнаружить ' + assemblerSide && 'Ассемблер' || 'МЭ Интерфейс')
}

function isAssemblerFilled() {
    const allStacks = transposer.getAllStacks(assemblerSide)[0]!
    return !!next(allStacks())[0]
}

function startAndWaitAsm() {
    if (!assembler.start()) {
        error('Не удалось запустить ассемблер')
    }

    while (assembler.status()[0] == 'busy') os.sleep(.25);
}

function transferAsmToInterface() {
    while (transposer.transferItem(assemblerSide, interfaceSide) != 1);
}

while (true) {
    if (isAssemblerFilled()) {
        print('Работа найдена, запускаем и ждём...')
        startAndWaitAsm()
        print('Работа выполнена, выгружаем')
        transferAsmToInterface()
        print('Готово, ждём следующего захода')
    }

    os.sleep(.25)
}
