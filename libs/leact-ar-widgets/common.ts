import { PropsType } from "leact-tstl/leact";

declare module "leact-tstl/leact" {
    interface PropsType {
        xpos: number;
        ypos: number;
    }
}

export interface IWidget {
    children(): LuaIterable<IWidget>;
    requestRedraw(): void;
    destroyGlasses(): void;
    dispose(props: {}): void;
}

export interface Calibration {
    screenWidth: number;
    screenHeight: number;
    originFontScale: number;
    fontScaleWidthRatio: number;
    fontScaleHeightRatio: number;
}

export interface IWidget2D extends IWidget {
    children(): LuaIterable<IWidget2D>;
    calculatedSize(): LuaMultiReturn<[number, number]>;
    setPos(x: number, y: number): void;
    getPos(): LuaMultiReturn<[number, number]>;
    sizeLimit(): LuaMultiReturn<[number, number]>;
    getAbsPos(): LuaMultiReturn<[number, number]>;
}

