import Context2D from "ar-core/Context2D";
import { useThread } from "leact-openos/hooks/thread";
import { WithProvider } from 'leact-tstl/components/provider';
import useProvider from 'leact-tstl/hooks/provider';
import useState from "leact-tstl/hooks/state";
import useMemo from "leact-tstl/hooks/memo";
import Leact, { Node } from "leact-tstl/leact";
const component = [globalThis.require][0]('component') as Awaited<typeof import('component')>;

export function WithContext2D(this: void, { context, children }: { context: Context2D; children?: Node[]; }) {
    const [warmed, setWarmed] = useState(false);

    // Warmup this shit
    useThread(() => {
        try {
            const glasses = (component.glasses as any);
            const addDot = (glasses.addDot as (this: void) => void);
            const removeAll = (glasses.removeAll as (this: void) => void);
    
            removeAll();
            print('Warming up...');
            for (const _ of $range(1, 64)) {
                for (const _ of $range(1, 8)) {
                    addDot();
                }
                os.sleep(0);
            }
            print('Warmed up...');
            removeAll();
            addDot();
            
            setWarmed(true);
        }
        catch (e) {
            print(e);
        }
    }, []);

    return warmed ? <WithProvider datakey="ar-core:context2d" value={context}>
        {Leact.children(children)}
    </WithProvider> : undefined;
}

export function useContext2D(this: void): Context2D {
    const context = useProvider<Context2D>("ar-core:context2d");
    if (!context) throw 'No Context2D registered';
    return context;
}