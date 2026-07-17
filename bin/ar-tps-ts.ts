// local unbundle = _G.require
// local event    = unbundle("event")

// local Context2D = require('ar-core.Context2D')
// local UpdatingText2D = require('ar-widgets.UpdatingText2D')
// local WrapBox2D = require('ar-containers.WrapBox2D')

// ---@module "component"
// local component = unbundle('component')

// import component from 'component';
const component = [globalThis.require][0]('component') as Awaited<typeof import('component')>
const event = [globalThis.require][0]('event') as Awaited<typeof import('event')>

/** @customName require */
declare const unrequire: typeof require;

import Context2D from 'ar-core/Context2D';
import WrapBox2D from 'ar-containers/WrapBox2D';
import UpdatingText2D from 'ar-widgets/UpdatingText2D';
// const UpdatingText2D = unrequire('ar-widgets.UpdatingText2D')

const tps: any = component.tps_card;
const glasses: any = component.glasses;


// local tps = component.tps_card
// local glasses = component.glasses
(glasses.removeAll as (this: void) => void)()

// glasses.removeAll()

const context = Context2D.fromCalibratedGlasses({
    glasses,
    calibration: {
        originFontScale:  .5,
        screenWidth:  480,
        screenHeight:  270,
        fontScaleWidthRatio:  4,
        fontScaleHeightRatio:  8,
    }
})

// local context = Context2D:fromCalibratedGlasses({
//     glasses = glasses,
//     calibration = {
//         originFontScale = .5,
//         screenWidth = 480,
//         screenHeight = 270,
//         fontScaleWidthRatio = 4,
//         fontScaleHeightRatio = 8,
//     },
// })

const w = UpdatingText2D.new({context})

// local w = UpdatingText2D:new({
//     context = context
// })

const box = WrapBox2D.new({context})
// local box = WrapBox2D:new({
//     context = context
// })
function updateWidger(this: typeof w) {
    const tt = (tps.getOverallTickTime as (this: void) => any)()
    const tp = (tps.convertTickTimeIntoTps as (this: void, x: any) => any)(tt)
    this.setText(string.format('TPS: %.1f (%.1f ms)', tp, tt))
}
w.setTimer(updateWidger, .25)
// ---@param wid ArText2D
// local function updateWidger(wid)
//     local tt = tps.getOverallTickTime()
//     local tp = tps.convertTickTimeIntoTps(tt)

//     wid:setText(string.format('TPS: %.1f (%.1f ms)', tp, tt))
// end
// w:setTimer(updateWidger, .25)
updateWidger.call(w);
// updateWidger(w)
w.setScale(context.calibration.screenHeight / context.calibration.fontScaleHeightRatio / 10)
// w:setScale(context.calibration.screenHeight / context.calibration.fontScaleHeightRatio / 10)
box.setChild(w)
// box:setChild(w)

const box2 = WrapBox2D.new({context})
// local box2 = WrapBox2D:new({context = context})
box2.setPos(80, 10)
// box2:setPos(80, 10)
box2.setChild(box)
// box2:setChild(box)
box2.setColor(0xFF000000)
// box2:setColor(0xFF000000)

event.pull('interrupted')
// event.pull('interrupted')

box2.dispose()
// box2:dispose()
