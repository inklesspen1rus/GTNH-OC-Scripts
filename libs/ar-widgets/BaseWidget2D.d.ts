export default class BaseWidget2D {
    setPos(x: number, y: number): void;
    dispose(): void;
    children(): LuaIterable<BaseWidget2D>;
    addChild(w: BaseWidget2D): boolean;
    removeChild(w: BaseWidget2D): boolean;
    protected requestRedraw(): void;
}