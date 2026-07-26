import { useEffect } from "leact-tstl/hooks/effect";
import useHookusRootUserdata from "leact-tstl/hooks/hookus-root-userdata";
import { PropsType } from "leact-tstl/leact";
const widget = require("ar-widgets/Text2D") as Awaited<typeof import("ar-widgets/Text2D")>['default'];
import Context2D from "ar-core/Context2D";

export interface Text2DProps {
    x?: number;
    y?: number;
    text: string;
    scale?: number;
}

export default function Text2D(this: void, props: Text2DProps) {
    const { ar_context_2d } = (useHookusRootUserdata()[0] as {
        userdata: {ar_context_2d: Context2D};
    }).userdata;

    print('ar_context_2d', ar_context_2d)

    useEffect(() => {
        const w = widget.new({ context: ar_context_2d });
        w.setPos(props.x || 0, props.y || 0);
        w.setText(props.text);
        w.setScale(props.scale || 1);
        return () => w.dispose();
    }, [props.text, props.scale, props.x, props.y]);
}