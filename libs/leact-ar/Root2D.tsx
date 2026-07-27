const widget = require("ar-containers/Root2D") as Awaited<typeof import("ar-containers/Root2D")>['default'];
import Leact, { Node } from "leact-tstl/leact";
import { useWidget2D, WithWidget2D } from "./widget2d";

export interface Root2DProps {
    children?: Node[]
}

export default function Root2D(this: void, props: Root2DProps = {}) {
    const widget2d = useWidget2D(
        context => widget.new({ context })
    );

    return <WithWidget2D context={widget2d}>
        {Leact.children(props.children)}
    </WithWidget2D>;
}