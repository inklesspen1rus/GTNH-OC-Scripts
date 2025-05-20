import { timer } from "event";
import * as event from "event"
import * as robot from "robot";
import * as sides from "sides";
import * as computer from "computer";

import * as component from "component";
const nav = component.navigation as {
    getPosition(this: void): LuaMultiReturn<[number, number, number]>
};
const inv = component.inventory_controller;

const width = 16
const untilY = 10

function installAutoGenerator(this: void, refueler: (this: void, generator: OC.Components.Generator) => void) {
    function check() {
        const ratio = (computer.energy() / computer.maxEnergy());
        if (ratio > .50) return;
        print(`Energy ratio: ${ratio}`)
        
        let generator: OC.Components.Generator = undefined!;
        {
            const iter = component.list("generator", true);
            let address: string | undefined;
            let found = false;
            while ((address = iter()[0]) !== undefined) {
                generator = component.proxy(address);
                if (generator.count() === 0) {
                    found = true;
                    break;
                }
            }
            if (!found) return;
        }

        print(`generator: ${generator}`)

        refueler(generator);
    }

    check()
    timer(15.0, check, math.huge);
}

function findFirstEmptySlot(this: void): number {
    const size = robot.inventorySize();
    for (const slot of $range(1, size)) {
        if (!inv.getStackInInternalSlot(slot)) {
            return slot;
        }
    }
    return -1;
}

function refueler(this: void, generator: OC.Components.Generator) {
    const oldSlot = robot.select();

    try
    {
        robot.select(16)
        robot.swingDown()
        if (!robot.placeDown()[0]) return;
        if (inv.suckFromSlot(sides.bottom, 27, 4)) generator.insert();
        robot.swingDown();
    }
    finally
    {
        robot.select(oldSlot);
    }
}

installAutoGenerator(refueler);

function digRow(count: number) {
    const maxEnergy = computer.maxEnergy()
    for (const _ of $range(1, count)) {
        const ratio = (computer.energy() / maxEnergy)
        if (ratio < 0.5) event.pull(10 * (.5 - ratio));
        do {
            robot.swing()
            event.pull(0);
        } while(!robot.forward()[0])
    }
}

function digDown() {
    while (!robot.down()[0]) {
        robot.swingDown()
        event.pull(0);
    }
}

function digLayer(continueRight: boolean): boolean {
    digRow(width - 1)
    for (const _ of $range(2, width)) {
        continueRight ? robot.turnRight() : robot.turnLeft()
        do {
            robot.swing()
            event.pull(0)
        } while (!robot.forward()[0]);
        continueRight ? robot.turnRight() : robot.turnLeft()
        continueRight = !continueRight
        digRow(width - 1)
    }
    return continueRight
}

let continueRight = true;
while (nav.getPosition()[1] > untilY) {
    continueRight = digLayer(continueRight);
    robot.turnLeft()
    robot.turnLeft()
    if (nav.getPosition()[1] != (untilY + 1))
        digDown()
}
