const widget = require("ar-widgets/Text2D") as Awaited<typeof import("ar-widgets/Text2D")>['default'];
import { useWidget2D } from "./widget2d";

export interface Text2DProps {
    x?: number;
    y?: number;
    text: string;
    scale?: number;
}

export default function Text2D(this: void, props: Text2DProps) {
    useWidget2D(
        context => widget.new({ context }),
        w => {
            w.setText(props.text);
            w.setScale(props.scale || 1);
            if (props.x || props.y) w.setPos(props.x || 0, props.y || 0);
        }, [props.x, props.y, props.text, props.scale]
    );
}