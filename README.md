# What is it?

Well, that's a pretty shitty repository for my scripts with unlimited potencial which impossible due to lack of personal time.

My ill mind imagine here all sorts of useful scripts to make GTNH a bit... programmable (which's a good idea!) and modern (probably too...). I started this bcs I tired to progress GTNH but I still want to play GTNH so I involved my twisted mind to make things my friends called "useless idiotims".

When I finish this shit... I show them... I show them ALL!

# State of repository?

Shit. I started my journey in OpenComputers here. Historically I've been programing on typed-only languages so I hate Lua. I tried replace it with several typed language which compiles to Lua or involve language servers which check types.

So I tried:

* LuaLS (which a pretty good until u find corner cases which I found and hate now)
* TypeScriptToLua (TSTL) (which a pretty buggy but TypeScript's type system is VERY good)
  * Also, TypeScriptToLua provider TSX support which allow me make React-like programs.

Because I use all of that shit, I had to make them play together. I mean... I still **have** to make them play together because there are still some issues.

Also bcs of size of programs and state of my soul, I involved 2-3 lua minifiers and bundlers to make programs compact

# Finally, what's here?

* A bit useful programs
  * ar-tps - Program for OC Glasses to display server TPS
  * ae2-level - Program to automatically request crafting things in AE2 with a bit locking logic to exclude high contention and leave some machines available for user crafting requests. Probably, indeed, that's ae2-better-level, I can't remember.
  * bm-spawner - Helper program which takes souls from AE2 and spawn on the front. Useful to automatically sacrify mobs and get BloodMagic blood. To automate kills I wrote [autoclick](./readside/autoclick/src/main.rs) program which just click LMB.
  * netrunnet.lua - Program to automatically download files from internet and invoke program it with custom arguments.
    * Personally I use it to redownload configs for ae2-level by request.
  * ae2-tc-infuser - Simple robot program to make infusion possible via AE2.
  * 
* Test-programs
  * ar-cam-scan - Program to scan front of camera and display 3D-dots in the world
  * ar-remote-display - Program to display computer's GPU state on the player screen
  * ar-remtote-clicker - Proxy AR-user's keyboard to computer with AR-host
  * leact-sample - TSX test to draw AR-progams. WIP.
  * geotrack - Tried to write [nav.lua](https://github.com/Akuukis/RobotColorWars-Minecraft/blob/master/lib/nav.lua). Well.. now I think I drop it.
  * get-item-nbt - Display robot's current item NBT. Wanted to use in bee-breeding. But I think there already are programs for this so I think I won't do it.
  * robot-dig-cave - Tried to make robot-quary. Forget to give him torchs. So now I have big cave with mobs under my base. Fuck.
  * ar-reboot-button - Example program to test AR-user's input.
  * 
* Libraries
  * I forget what I did here. I won't to know really, sorry.
  * At least, here's some data card's algorithms in pure lua.
  * Also, nbt, json libraries... but I wanna replace them with OPPM libraries because OPPM is nice!
  * 
  * intseqs - library to store number sequences a efficiently. Stores simple sequences (1,2,3,4....) in 2 numbers: start of sequence and length.
  * lockres - Library to virtually lock some resources. Useful in case of resource contention of coroutines. WIP.
  * vector.lua - Vector library which really works.
* Here's a bit more things but I can't remember them or just don't want to describe them.

# Repository design

Oh shit.... just... drink some vodka, so your eyes won't explode during exploration.

# TSTL... LuaLS... so how I can build that if that's not pure Lua?

Heh, u have to install some dependencies:

* nodejs (idk which version)
* npm (idk which version)
* load git modules (dude find info in the web)
* make (sorry I'm on Linux. Probably in Future I'll replace it with npm-scripts bcs I already don't know what I coded in Makefile)

Then install package dependencies:

```sh
npm i
```

Now, finally, i can compile all:

```sh
make all
```

So what we get now? These folders!

* build
  * Here's typescript programs which bunlded so they are ready-to-run until they require some libraries in the system
* dist
  * Here's ALL programs and their bundled versions (which has `-bundled` suffix)

# Future?

Some time ago I found OPPM and now I love it. So... my current goal is make this repo compatible with oppm. I guess that's impossible so probably I finish with separate branch with compiled code.

So, final unordered roadmap:

* Reorganize source code
  * Because current state of this repo is total shit
* Make this repo OPPM-native
  * Which can make bundling useless
* Add some screenshots to be a bit more pretty
* More documentation for each program
* Actively involve minitel for communication
* Write OC Glasses hub program
* Complete TSX library to draw AR-programs.
* Finally complete ar-calibration to make programs pretty!
  * That's really important because AR's fonts are sucks.