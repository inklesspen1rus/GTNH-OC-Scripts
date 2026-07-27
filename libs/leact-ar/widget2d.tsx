import Context2D from "ar-core/Context2D";
import BaseWidget2D from "ar-widgets/BaseWidget2D";
import { WithProvider } from 'leact-tstl/components/provider';
import useProvider from 'leact-tstl/hooks/provider';
import useState from "leact-tstl/hooks/state";
import Leact, { Node } from "leact-tstl/leact";
import { useContext2D } from "./context2d";
import { useDependency } from "leact-tstl/hooks/dependency";
import { useEffect } from "leact-tstl/hooks/effect";
import { useUpdateToken } from "leact-tstl/hooks/update-token";
import { useRenderPositionKey } from "leact-tstl/hooks/render-position";

export interface Widget2DContext<T extends BaseWidget2D = BaseWidget2D> {
    widget?: T;
    requestUpdate: (this: void) => void;
    children?: Widget2DContext[];
    orderKey: string;
    needReorderChildren?: true;
}

export function WithWidget2D(this: void, { context, children }: { context: Widget2DContext; children?: Node[]; }) {
    return <WithProvider datakey="ar-core:widget2d" value={context}>
        {Leact.children(children)}
    </WithProvider>;
}

export function useParentWidget2DContext<T extends BaseWidget2D = BaseWidget2D>(this: void): Widget2DContext<T> | undefined {
    return useProvider<Widget2DContext<T>>("ar-core:widget2d");
}

interface useWidget2DOptions {
    ordered?: boolean;
}

export function useWidget2D<T extends BaseWidget2D>(this: void, factory: (this: void, context: Context2D) => T, updater?: (this: void, widget: T) => void, updaterDeps?: any[], opts: useWidget2DOptions = {}): Widget2DContext<T> {
    const context2d = useContext2D();
    const parent = useParentWidget2DContext();
    const widget2d = useWidget2DContext<T>();

    useEffect(() => {
        const w = factory(context2d);
        widget2d.widget = w;
        if (parent) {
            if (!parent.widget!.addChild(w)) {
                w.dispose();
                error('Unable to add child to widget');
            }
            parent.children ??= [];
            parent.children.push(widget2d);
            parent.needReorderChildren = true;
            parent.requestUpdate();
        }
        return () => {
            const idx = parent?.children?.indexOf(widget2d);
            if (idx && idx !== -1) {
                parent!.children!.splice(idx, 1);
            }
            w.dispose();
        };
    }, [parent]);

    useDependency(() => {
        if (parent && !parent.needReorderChildren) {
            parent.needReorderChildren = true;
            parent.requestUpdate();
        }
    }, undefined, [parent, widget2d.orderKey]);

    useEffect(() => {
        updater?.(widget2d.widget!);
    }, updaterDeps || []);

    if (opts.ordered ?? true)
        useEffect(() => {
            if (!widget2d.needReorderChildren || !widget2d.children || widget2d.children.length <= 1) return;

            let sorted = true;
            let prevKey = widget2d.children[0].orderKey;
            for (const w2d of widget2d.children) {
                if (prevKey > w2d.orderKey) {
                    sorted = false;
                    break;
                }
                prevKey = w2d.orderKey;
            }

            for (const wc of widget2d.children) {
                const w = wc.widget!;
                if (!widget2d.widget!.removeChild(w)) error('wtf');
            }

            table.sort(widget2d.children, (a, b) => a.orderKey < b.orderKey);

            for (const wc of widget2d.children) {
                if (!widget2d.widget!.addChild(wc.widget!)) error("nut(");
            }
        });

    return widget2d;
}

export function useWidget2DContext<T extends BaseWidget2D>(this: void): Widget2DContext<T> {
    const requestUpdate = useUpdateToken();
    const renderKey = useRenderPositionKey();
    const context = useState<Widget2DContext<T>>({ requestUpdate, orderKey: '' })[0];
    context.orderKey = renderKey;
    return context;
}