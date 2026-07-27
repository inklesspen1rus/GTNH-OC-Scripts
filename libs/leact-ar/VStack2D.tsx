import Leact, { Node } from "leact-tstl/leact";
const widget = require("ar-containers/VStack2D") as Awaited<typeof import("ar-containers/VStack2D")>['default'];
import { useWidget2D, WithWidget2D } from "./widget2d";

export interface VStack2DProps {
    x?: number;
    y?: number;
    children?: Node[];
}

export function VStack2D(this: void, props: VStack2DProps) {
    const widget2d = useWidget2D(
        context => widget.new({ context }),
        w => {
            if (props.x || props.y) w.setPos(props.x || 0, props.y || 0);
        }, [props.x, props.y]
    );
    
    return <WithWidget2D context={widget2d}>
        {Leact.children(props.children)}
    </WithWidget2D>;
}