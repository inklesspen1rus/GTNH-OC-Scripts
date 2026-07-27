const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>;
import { useEffect } from "leact-tstl/hooks/effect";

/**
 * Launches background timer to periodically run function.
 */
export default function useInterval(this: void, func: () => void, interval: number) {
    useEffect(() => {
        const timerId = event.timer(interval, () => {
            func()
        }, math.huge)
            
        return () => event.cancel(timerId);
    }, [interval, func])
}