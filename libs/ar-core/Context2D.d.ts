import { Calibration } from "../leact-ar-widgets/common"

export default class Context2D {
    static fromCalibratedGlasses(props: {
        glasses: any,
        calibration: Calibration
    }): Context2D;

    public calibration: Calibration;
}
