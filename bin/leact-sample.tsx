import Leact, { LeactContext } from 'leact-tstl/leact';
const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>
import useState from 'leact-tstl/hooks/state';
import { useEffect } from 'leact-tstl/hooks/effect';
import Text2D from 'leact-ar/Text2D';

let needUpdate = true;
using ctx = new LeactContext(undefined, executor => {
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