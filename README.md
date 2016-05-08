# MMRIMM
## Modern Modular Ruby Ircbot Made by ~marahin

>I'm not sure if this is a good thing. I did it because finals. Please don't judge.

author

## What is this exactly?

Well, as the name says:
>Modern Modular Ruby Ircbot (...)

Yeah, that's basicly it. Written purely in Ruby, MMRIMM uses [Cinch](https://github.com/cinchrb/cinch) as IRC API. This link is the only one pointing to the original repository, the others are pointing to my fork of it (should work on both of them anyways, unless guys at Cinch work on a version that drops backward compatibility).

#### What's the point?

Honestly? I was looking for a bot that would allow me to do whatever I want without touching the core itself. Simply: clone, do the initial configuration of nickname and stuff like that, then just add the features I want as plugins.

God is the only one who knows how much time I've spent, how many times have I cussed. So I decided to do it myself.

## Features

#### Before you proceed...
**I AM NOT A PROFESSIONAL.**

I do my best to keep it as following:
- __bot__ is _supposed_ to be modular. That means: the bot itself is only the core, and every cool-feature you want to add should be maintained and handled as plugin.
- __bot__ means everything in root folder except `plugins/`, so exactly:
  - everything in `lib/`
  - `.git*`
  - `bot.rb`
  - `Gemfile`
  - `README.md`
  - `version`
everything apart from those files is considered third party, and **should not** be understood as "part of the bot".
- __bot__, when starting, loads initial configuration data from `config.yml`.
- __plugins__ **should** be contained in `plugins/` or any other specific directory, however remember to specify it in `config.yml`. Default is `plugins/`.


#### Features! At last!
Aight, so, so far:
- __bot__, due to the use of [Cinch](https://github.com/Marahin/cinch), contains the **modularity** of plugins, **threaded approach** in every possible way those guys and I could think of. I find it _cool_.
- I did (and still am doing!) my best to implement and provide the best way to load, reload, unload __plugins__ *__on the run__*. Someone is abusing your cool "hello, nick" plugin? Just `unhook hello_nick`. It's done, baby.
- __bot__ has a __help system__ for maintaining plugins and commands. What this means, is every plugin you write / someone writes for you can be handled and supported live, on IRC, through `help` command. See below for details of __Help system__.
- Apart from the above, __writing plugins for MMRIMM is same as for [Cinch](https://github.com/Marahin/cinch)__. The only difference is the __Help system__ and possible hooking for one of the default plugins, __Admins__ (read below).

#### Help system

__Help system__ is a newly added feature. It has been made to serve purpose as built-in way to handle support for different plugins and features of the bot. So far it might feel clunky at times, but if you understand how to work with it - it works great.

###### Okay, so what is it?

__Help system__ is defined in `lib/HelpObj.rb` and loaded during startup. It is a really simple design: a class, which has only one attribute - `@plugins`, which is an object of `Array`, extended by `lib/ModuleThreadedEach.rb` for the greatness of multithreading!

###### How does it work?

During startup a class is defined and with it - an object of the class, named `Help`. So, for your own sake: do your best and notice the differece between the class name (`HelpObj`) and the object on which we will work - `Help`.

Help object has an `Array` of `@plugins`, which you can maintain with certain methods (look below). Every plugin has it's own `Array` of commands, which you can also maintain. I try to make it as simple as possible to operate on, however in order to make it as flexible as possible - it might feel clunky at times.

##### Commands and operating Help

###### Commands

`Help` object has several methods. Following ones are already used in core of the __bot__:
- `Help.commands` - returning an array (extended by `ModuleThreadedEach`) of commands. If no commands are registered, it will return empty array (`Array.new`).
- `Help.plugins` - returning an array of all the plugins supporting Help system (so the ones that register themselves. If the plugin doesn't register itself to the Help system, it **will not be visible**). The `Array` is extended by `ModuleThreadedEach`. If no plugins are registered, it will return empty array (`Array.new`).
- `Help.plugin_commands(plugin)` - returning an array of commands for the given plugin name. The array is extended by `ModuleThreadedEach`, unless there's no such plugin - then it will return empty array (`Array.new`) **without the extension**.

The other ones are used to maintain plugin's Help support. Those are the calls you use in your plugin, so it registers in the __Help System__.
- `Help.add_plugin(name, filepath, description)` - registering the plugin in __Help system__, allowing it to recognize the plugin.
- `Help.add_command(plugin_name, syntax, description)` - registering a command under the given plugin, with given syntax and description, allowing Help system to serve it to the users.

A good example would be our included, default [Admins plugin](https://github.com/Marahin/mmrimm/blob/master/plugins/admins.rb):
```
(...)
Help.add_plugin(self.name, __FILE__, "User privilege plugin to maintain various commands.")
Help.add_command(self.name, "admins", "lists all admins")
(...)
```

As you can see from the example, `add_plugin`'s name attribute (or `add_command`'s plugin_name) is the **class name** of the plugin.

###### Operating Help

As mentioned above, __Help system__ can be accessed by object named `Help`. This object can be accessed by several commands mentioned above as well.
If you do everything by the book, your __plugin__ should be available to access `Help` instantaneous. Feel free to look at example plugins mentioned below (and the code itself in the repository).

Structure and datatypes are as following:

- Commands (received, for example, through `Help.commands`), have two hash keys:
  - :syntax - which is the **unprefixed** "supposed" syntax of the command
  - :description - a short description of the command, explaining what shall it do, when executed.
  Example of usage could be: Help.commands[0][:syntax].
- Plugins have:
  - :plugin - name of the plugin
  - :filename - path to the file
  - :description - short description of the plugin
  - :commands - an array of commands. This option, however, **is not accessible through `Help.plugins`**. Instead, you can call either `Help.commands` to get a list for all of registered commands or `Help.plugin_commands(plugin)` to get a list for all of given plugin registered commands.

#### Plugins
