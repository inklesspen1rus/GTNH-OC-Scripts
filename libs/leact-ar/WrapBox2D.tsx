import Leact, { Node } from "leact-tstl/leact";
const widget = require("ar-containers/WrapBox2D") as Awaited<typeof import("ar-containers/WrapBox2D")>['default'];
import { useWidget2D, WithWidget2D } from "./widget2d";

export interface WrapBox2DProps {
    x?: number;
    y?: number;
    color?: number;
    children?: Node[];
}

export function WrapBox2D(this: void, props: WrapBox2DProps = {}) {
    const widget2d = useWidget2D(
        context => widget.new({ context }),
        w => {
            if (props.x || props.y) w.setPos(props.x || 0, props.y || 0);
            w.setColor(props.color ?? 0xFFFFFFFF);
        }, [props.x, props.y, props.color]
    );
    
    return <WithWidget2D context={widget2d}>
        {Leact.children(props.children)}
    </WithWidget2D>;
}