import Leact, { LeactContext, Node } from 'leact-tstl/leact';
const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>;
const ser = [globalThis.require][0]('serialization') as Awaited<typeof import('serialization')>;
import useState from 'leact-tstl/hooks/state';
import { useEffect } from 'leact-tstl/hooks/effect';
import Text2D from 'leact-ar/Text2D';
import { WithContext2D } from 'leact-ar/context2d';
import { WrapBox2D } from 'leact-ar/WrapBox2D';
import { VStack2D } from 'leact-ar/VStack2D';
import { useRenderPositionKey } from 'leact-tstl/hooks/render-position';
import Root2D from 'leact-ar/Root2D';
import { useThread } from 'leact-openos/hooks/thread';
const Context2D = require('ar-core/Context2D') as Awaited<typeof import("ar-core/Context2D")>['default'];
const thread = [globalThis.require][0]('thread') as Awaited<typeof import('thread')>;

const component = [globalThis.require][0]('component') as Awaited<typeof import('component')>;
const glasses = component.glasses as any;

const context = Context2D.fromCalibratedGlasses({
    glasses,
    calibration: {
        originFontScale: 1,
        screenWidth: 640,
        screenHeight: 360,
        fontScaleWidthRatio: 4.164,
        fontScaleHeightRatio: 8,
        textStartX: 1,
        textStartY: -1,
    }
});

let executorQueue: ((this: void) => void)[] = [];
let executing = false;

function runExecutors(executor?: (this: void) => void): void {
    if (executing) return;
    executing = true;
    try {
        executor ??= executorQueue.shift();
        while (executor) {
            try {
                executor();
            }
            catch (e) {
                print(e);
                os.exit(1);
            }
            executor = executorQueue.shift();
        }
    } catch (e) {
        print('Global execution failed');
        os.exit(1);
    }
    executing = false;
}

using ctx = new LeactContext({}, executor => {
    if (executor) {
        executorQueue.push(executor);
    }
});

function Position(this: void) {
    const [state, setState] = useState([0.0, 0.0, 0.0, 0.0]);

    useThread(() => {
        const nav = component.navigation as any;
        const getPosition = (nav.getPosition) as (this: void) => LuaMultiReturn<[number, number, number]>;
        let start = os.time();
        while (true) {
            let done = false;
            try {
                let ret = getPosition();
                const finish = os.time();
                done = true;
                setState([...ret, (finish - start) / 72]);
            } catch { }
            os.sleep(15);
            if (done)
                start = os.time();
        }
    }, []);

    return <VStack2D>
        <Text2D text={string.format('Position: %.1f %.1f %.1f', state[0], state[1], state[2])} />
        <Text2D text={string.format('Remote call duration: %.1f', state[3])} />
    </VStack2D>
}

function TPS(this: void) {
    const [state, setState] = useState([0.0, 0.0]);

    useThread(() => {
        const tps: any = component.tps_card;
        while (true) {
            os.sleep(.2);
            
            const tt = (tps.getOverallTickTime as (this: void) => any)()
            const tp = (tps.convertTickTimeIntoTps as (this: void, x: any) => any)(tt)

            setState([tp, tt]);
        }
    }, []);

    return <Text2D text={string.format('TPS: %.1f (%.1f ms)', state[0], state[1])} />;
}

function Lapotron(this: void) {
    const [state, setState] = useState<{
        stored?: string,
        max?: string,
        in5s?: string,
        out5s?: string,
    }>({});

    useThread(() => {
        while (true) {
            const [_a, _b, port, data] = event.pull()
            if (+port == 994) {
                const newData = ser.unserialize(data) as any[]
                const datasource = newData[0] as string
                if (datasource == 'datasource.main.supercapacitor') {
                    setState(newData[1])
                }
            }
        }
    }, []);

    if (!state.stored) {
        return undefined;
    }

    const stored = +state.stored!;
    const max = +state.max!;

    return <WrapBox2D>
        <VStack2D>
            <Text2D>Lapotron Information</Text2D>
            <Text2D>{string.format('%s (%0.0f%%)', state.stored, stored / max * 100)}</Text2D>
            <Text2D>{state.in5s}</Text2D>
            <Text2D>{state.out5s}</Text2D>
        </VStack2D>
    </WrapBox2D>
}

function App(this: void) {
    return <WithContext2D context={context}>
        <Root2D>
            <WrapBox2D x={100} y={10} color={0xFF000000}>
                <WrapBox2D>
                    <VStack2D>
                        <TPS />
                        <Position />
                        <Lapotron />
                    </VStack2D>
                </WrapBox2D>
            </WrapBox2D>
        </Root2D>
    </WithContext2D>;
}

declare module "event" {
    function pull<T extends any[]>(this: void, timeout: number, event: string): LuaMultiReturn<[string, ...T]>;
    function pull<T extends any[]>(this: void): LuaMultiReturn<[string, ...T]>;
}

// const t = thread.create(() => {
runExecutors(() => ctx.mount(<App></App>));
while (true) {
    const name = event.pull(0.05, 'interrupted')[0];
    if (name === 'interrupted') {
        break;
    }
    runExecutors();
}
// });
// t.join()
// os.exit(0)
// {/* <Inner state={state} /> */}
//                     {/* <WrapBox2D color={state % 2 == 0 ? 0xFF00FFFF : 0xFF0000FF}>
//                         {state % 2 == 0 ? <WrapBox2D>
//                             <Text2D text={'Hello!' + state} />
//                         </WrapBox2D> : <Text2D text={'Hello!' + state} />}
//                     </WrapBox2D> */}