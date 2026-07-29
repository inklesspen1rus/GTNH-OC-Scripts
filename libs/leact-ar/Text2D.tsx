const widget = require("ar-widgets/Text2D") as Awaited<typeof import("ar-widgets/Text2D")>['default'];
import { useWidget2D } from "./widget2d";

export interface Text2DProps {
    x?: number;
    y?: number;
    text?: string;
    children?: string[];
    scale?: number;
}

export default function Text2D(this: void, props: Text2DProps) {
    const text = props.text || (props.children || [])[0] || ''

    useWidget2D(
        context => widget.new({ context }),
        w => {
            w.setText(text);
            w.setScale(props.scale || 1);
            if (props.x || props.y) w.setPos(props.x || 0, props.y || 0);
        }, [props.x, props.y, text, props.scale]
    );
}