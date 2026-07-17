import { cancel, timer } from "event";
import { useEffect } from "leact-tstl/hooks/effect";
import useMemo from "leact-tstl/hooks/memo";

export default function useInterval(this: void, func: () => void, interval: number) {
    useEffect(() => {
        const timerId = timer(interval, () => {
            func()
        }, math.huge)
            
        return () => {
            cancel(timerId)
        }
    }, [interval])
}