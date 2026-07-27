/**
 * @noSelfInFile
 */

declare module "rpc" {
    function register(this: void, name: string, func: Function): void;
    function unregister(this: void, name: string): void;
    function call<R extends any[]>(this: void, host: string, name: string, ...args: any[]): LuaMultiReturn<R>;
    function callAsync<R extends any[]>(this: void, callback: (this: void, ...args: R) => void, host: string, name: string, ...args: any[]): void;
    function proxy<T>(this: void, host: string, filter: string): T;
}

const comp = [globalThis.require][0]('component') as Awaited<typeof import('component')>
const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>

function tick() {
    
}

let timerId: number | undefined = undefined;

declare var start: any;
start = () => {
    event.timer(0.0, tick);
    timerId ??= event.timer(30.0, tick, math.huge);
}

declare var stop: any;
stop = () => {
    if (timerId) {
        event.cancel(timerId);
        timerId = undefined;
    }
}