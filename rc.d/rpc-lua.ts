declare module "rpc" {
    function register(this: void, name: string, func: Function): void;
    function unregister(this: void, name: string): void;
    function call<R>(this: void, host: string, name: string, ...args: any[]): R;
    function callAsync(this: void, callback: Function, host: string, name: string, ...args: any[]): any;
    function proxy<T>(this: void, host: string, filter: string): T;
}

function start() {
    
}

function stop() {

}