import Leact, { LeactContext } from 'leact-tstl/leact';
const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>
import useState from 'leact-tstl/hooks/state';
import { useEffect } from 'leact-tstl/hooks/effect';
import Text2D from 'leact-ar/Text2D';
// import Context2D from 'ar-core/Context2D';
const Context2D = require('ar-core/Context2D') as Awaited<typeof import("ar-core/Context2D")>['default'];

const component = [globalThis.require][0]('component') as Awaited<typeof import('component')>
const glasses = component.glasses;

const context = Context2D.fromCalibratedGlasses({
    glasses,
    calibration: {
        originFontScale:  .5,
        screenWidth:  480,
        screenHeight:  270,
        fontScaleWidthRatio:  4,
        fontScaleHeightRatio:  8,
    }
})

let needUpdate = true;
using ctx = new LeactContext({
    ar_context_2d: context
}, executor => {
    executor && event.timer(0.0, () => executor())
});

function useInterval(this: void, func: () => void, interval: number) {
    useEffect(() => {
        const timerId = event.timer(interval, () => {
            func();
        }, math.huge);

        return () => {
            event.cancel(timerId);
        };
    }, [interval, func]);
}

function App() {
    const [state, setState] = useState(0);

    useInterval(() => {
        print('Setting state!');
        setState(state + 1);
    }, 1);

    print(state);

    return <Text2D text={'Hello!' + state} x={100} y={100} />;
}

ctx.mount(<App></App>);

event.pull('interrupted')