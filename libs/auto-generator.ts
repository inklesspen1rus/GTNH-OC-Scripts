import { timer } from "event";
import * as component from "component";

export default function installAutoGenerator(this: void, refueler: (this: void, generator: OC.Components.Generator) => void) {
    timer(15.0, () => {
        if (computer.energy() / computer.maxEnergy() > .75) return;
        
        let generator: OC.Components.Generator = undefined!;
        {
            const iter = component.list("generator", true);
            let address: string | undefined;
            let found = false;
            while ((address = iter()[0]) !== undefined) {
                generator = component.proxy(address)
                if (generator.count() !== 0) break;
                found = true;
            }
            if (!found) return;
        }

        refueler(generator)
    });
}