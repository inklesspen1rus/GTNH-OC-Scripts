const thread = [globalThis.require][0]('thread') as Awaited<typeof import('thread')>;
import { useEffect } from "leact-tstl/hooks/effect";
import useState from "leact-tstl/hooks/state";

/**
 * Launches background thread to run blocking routines without UI thread.
 * Function must be stable to survive between rerenders. Use useMemo.
 */
export function useThread(this: void, func: (this: void) => void, deps?: any[]) {
    useEffect(() => {
        const shared = {} as {
            thread?: OpenOS.Thread;
        };
        shared.thread = thread.create(() => {
            try {
                func()
            } catch (e) {
                print(e)
            }
        });
        return () => shared.thread?.kill();
    }, deps);
}

export function useThreadResult<R>(this: void, func: (this: void) => R, deps?: any[]): R | undefined {
    const [state, setState] = useState<{ init?: R, error?: any; }>({});

    useEffect(() => {
        const shared = {} as {
            thread?: OpenOS.Thread;
        };
        shared.thread = thread.create(() => {
            try {
                setState({init: func()})
            } catch (e) {
                setState({init: state.init, error: e})
            }
            shared.thread = undefined;
        });
        return () => shared.thread?.kill();
    }, deps);

    if (state.error) {
        throw state.error;
    }

    return state.init
}