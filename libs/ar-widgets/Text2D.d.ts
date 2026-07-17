import Context2D from "../ar-core/Context2D";
import BaseWidget2D from "./BaseWidget2D";

export default class Text2D extends BaseWidget2D {
    static new(props: {
        context: Context2D
    }): Text2D;

    setText(value: string): void;
    setScale(value: number): void;
}