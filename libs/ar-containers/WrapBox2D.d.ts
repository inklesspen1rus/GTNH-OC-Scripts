import Context2D from "../ar-core/Context2D";
import BaseWidget2D from "../ar-widgets/BaseWidget2D";

export default class WrapBox2D extends BaseWidget2D {
    static new(props: {
        context: Context2D
    }): WrapBox2D
    
    setChild(w: BaseWidget2D): void;
    setColor(value: number): void;
}