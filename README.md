# THIS PROJECT HAS MOVED

Find the updated version here [**github.com/VacaRoxa/CodenameLT**](https://github.com/VacaRoxa/CodenameLT)


## Codename-LT

Codename-LT source here is the product of 48h of development with an awesome team of people from the [VACAROXA](https://www.padrim.com.br/vacaroxa). 
Find them on [twitter looking the Hashtag](https://twitter.com/hashtag/vacaroxa?src=hash) or follow [@estudiovacaroxa](https://twitter.com/estudiovacaroxa).

Firstly the people involved in the whole project:

[@bakudas](https://twitter.com/bakudas) | [@pcbmani](https://twitter.com/pcbmani) | [@_Gabrielfer](https://twitter.com/_Gabrielfer) | [@MauricioMunky](https://twitter.com/MauricioMunky) | [@DidiGameBoy](https://twitter.com/DidiGameBoy) | [@derekpxart](https://twitter.com/derekpxart) | [@eri0o](https://twitter.com/eri0o) | [@rafaelgiordanno](https://twitter.com/rafaelgiordanno)


This README tries to explain only the **source code** of the game. The not great decision of
making a game engine, in a language I had only used for 2h in the previous sunday, and riskying the 
whole project was mine. 

So just to be clear, I had NEVER made a game in lua and this was the first attempt. 
I feel really sad for my team members but the learning experience for me was gigantic. Also I loved the memes.
So let`s dive in the code.

## Wait, what is Love2d and Lua ?

**Lua** is a scripting language that is really good at being plugged in existing C++ code and exposing it
like an API, to offer script functionality: imagine you built something like Autocad and forgot to 
build a console to offer advanced functionality, Lua is really good for that. I understand that Lua
doesn't aim to enable pure feature complete Lua development.

**Love2d** is a framework for game development. Love2d is not built in Lua, it's built in C++ with SDL and 
exposes an API with an attached Lua interpreter. Porting your game to a platform, means essentially porting
Love2d to that platform. 

## The libraries

We can't invent the wheel that many times, so besides using **Love2d** and **Lua**, libraries were used
to ease development.

#### [hump](https://github.com/vrld/hump) 

**hump** was used to provide ***gamestates*** which were used for providing the title screen, 
the credits, the game and the cutscene. 

It's important to notice that each state has no information on the other (unless using globals),
so for example, to switch state, you have to ask the `main.lua`, a function was built to deal with this.

hump also provided Timers, which was used to prevent an input in dialog boxes from skipping additional 
dialogs. Other tools from hump were not used. The Camera is also provided by hump and we attached it to
the player sprite.

### Proxies

One liners were provided to ease Music and Image loading from correponding assets folder. 
They are in `main.lua`, and allow stuff like `Music.music_name:play()` to happen.

### [STI](https://github.com/karai17/Simple-Tiled-Implementation) 

A library for loading [**Tiled**](http://www.mapeditor.org/) maps that are exported as *.lua* files.
Tiled also provides a box2d implementation for physics. The **box2d** implementation from the latest library
was broken or incompatible with latest Tiled, so a modded one was made on the fly to work, and was
how the collision with walls and characters was made in game.

### [terebi](https://github.com/oniietzschan/terebi)

All the art is pixel art, this library guarantees everything will be draw pixel perfect and also
gives us nice features like rescalling. So the game provides f11 for full screen and + and - for rescalling
the main window.

### [anim8](https://github.com/kikito/anim8)

This library was used to animate the player sprite, the agents sprite and other sprites.

### Other libraries

During development in the rush to get a game in 48h, other libraries were added, notably lume.lerp for
easing the dialog appearance in game. Other libraries can be find in the source but they were not used in the end.

## The engine

The basic idea was we need to get graphics in game fast (6 artists!!!), so [**lua**](https://www.lua.org/) with 
[**love2d**](https://love2d.org/) as the game framework. The images, music and sounds can be just placed in the
game folder and directly be used in game, skipping any import/export workflow. 

One of the artists was converted in game designer, so to allow this workflow to happen, **Tiled** was used.
The game was developed in Tiled and from the maps data, the engine code was built to allow them to render
what was idealized. At least that was the plan.

### main.lua

The main code deals with initializing everything (terebi, game states, load assets, and push shaders), 
creates a function to provide access to game states, set the initial state to the StartScreen and unifies 
the keyboard and joystick input in a single interface that can be pooled.

### Game.lua

The actual game. The `init` function starts the game and sets the level to 1. Once each level is loaded,
the map is loaded through sti and objects in the map are replaced by entities: the `Player` receives the 
player entity, `ennemySpawner` (with typo TM) receives the agents and they are disabled, the itemSpawner 
are removed and the entities are inserted too. All entities created are inserted in a table called `sprite_list`,
a new layer is created in the game map, it's draw function is replaced by one to draw the entities and this 
layer is then inserted before the foreground layer, allowing for everything to be drawn by a single `map:draw()`.

The draw code for the dialog box is only drawn if the local variable `screen_msg` has a valid string.

The update function deals with all the game logic: makes the player be followed by agents, checks for collision
between the player and the items and the exit point.

### other files (*.lua)

The cutscene, credits and start screen are really concise and can be easily understood by code. A waitforbutton library
was created but not used. A Character entity and Item entity were created to deal with those objects: postion, size,
animation and direction.

## What went wrong 

Obviously, coding in a language you are not familiar with, even in the concept, made things way harder than
they needed to. Lua has lot's of details:

- Arrays start in 1.
- String manipulation is not as easy as JS or Python (you can't split!)
- The community is not as active as in other languages, both for love and lua, so Google will not save you all the time.
- library documentation is poor to non-existent, so you will have to read the sources!!!

There were other details in coding, but these were the main problems that killed me from advancing.

Additionally, in Adventure Game Studio or RPG Maker I can just write say('a sentence'), if(a>b) say('another sentence'),
requiring the player to press a button between each dialog box. I had the same built for JS already, but you can always do
callbacks. 

In Love2d/Lua + Tiled, I had no way to easily express this sequence of events. Writing a sequence of ONLY dialog boxes ate 
10 hours. The sti box2d library also didn't work and we had to mod our own, which also ate another 10 hours. Overall it
had a promissing start but those 2 issues - along with trying to get PS4 gamepad working with Love2d - ate **most** of 
development time.

## What went right 

Tiled has lots of quirkies, but being able to use it standalone in a computer is a nice way to develop game levels.
It's a little too advanced for my taste, but it gets the job done. Also being able to just load the assets directly 
from code (without a IDE) is great. **Visual Studio Code**, with lua plugin, was used for coding in a Ubuntu Linux 
machine and provided a really comfortable coding experience since it's the code editor I use for *JavaScript* development.

Love2d is also VERY forgiving, the drawing code is mostly a mess, but everything just works. Love2d also can be easily
run in Linux, Windows and OSX, so your game is already multi platform - for x86 computers. I also liked how easily 
shaders can be loaded and ran in love2d, so I added shaders in almost all game states.

I am very sad to not be able to finish the game code in jam time, but I think the learning experience was really a valid
one. I felt **Lua** with **Love2d** can be actually used in a 2d small commercial game project that needs to be iterated
and shipped fast.

## Future development

The game code is expected to improve on [here after the global game jam](https://github.com/VacaRoxa/CodenameLT), 
in [@estudiovacaroxa](https://twitter.com/estudiovacaroxa)'s github, and the original [boilerplate code](https://github.com/ericoporto/myFirstLove) 
can be found here if any game wants to build on top - it lacks some libraries used in this 'final' game code.


*This readme and this not really working code is written by [@eri0o](https://twitter.com/eri0o). If anything is wrong with this text, tell me.*
