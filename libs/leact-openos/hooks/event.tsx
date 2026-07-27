const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>;
import { useEffect } from "leact-tstl/hooks/effect";

export function useEvent(this: void, name: string, func: (this: void) => void) {
    useEffect(() => {
        event.listen(name, func);
        return () => event.ignore(name, func);
    }, [name, func])
}