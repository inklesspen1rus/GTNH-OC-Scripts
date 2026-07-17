import Context2D from "ar-core/Context2D"
import Text2D from "./Text2D"

export default class UpdatingText2D extends Text2D {
    static new(props: {
        context: Context2D
    }): UpdatingText2D;
    
    setTimer(func: (this: UpdatingText2D) => void, interval: number): void;
}