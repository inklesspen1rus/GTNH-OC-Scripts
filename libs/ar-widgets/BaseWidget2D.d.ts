export default class BaseWidget2D {
    setPos(x: number, y: number): void;
    dispose(): void;
    children(): LuaIterable<BaseWidget2D>;
}