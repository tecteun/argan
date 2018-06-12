![Argan](https://raw.githubusercontent.com/tecteun/argan/master/drawing.svg?sanitize=true&1)
---
Define command line help inline! Argan is nuts! 🥜 🎉 

## Examples

For sys targets (see https://api.haxe.org/Sys.html for a list of targets supporting the sys package):

```haxe
if(Argan.has("help", "show this help")){
    Sys.println("Usage: 'my_executable.exe --option=value or -option value'");
    for(h in Argan.help().keys())
        Sys.println('--${StringTools.rpad(h, " ", 12)}${Argan.help()[h]}');
    Sys.println('');
    Sys.exit(0);
}

var debug = Argan.has("debug", "enable debug mode");
var param1 = Argan.getDefault("some_parameter", "configure some parameter", '//default_url_as_example/');
var param2 = Argan.getDefault("some_boolean", "configure some boolean", true);
var param3 = Argan.getDefault("some_int", "configure some int", 1);
```

For other non-sys targets:

```haxe
if(Argan.has("help", "show this help")){
    trace("Usage: 'pass object with options to Argan.start, for example Argan.start({ debug : true })'");
    for(h in Reflect.fields(Argan.help(true)))
        Sys.println('--${StringTools.rpad(h, " ", 12)}${Reflect.field(Argan.help(true), h)}');
    trace('');
    return;
}
var debug = Argan.has("debug", "enable debug mode");
var param1 = Argan.getDefault("some_parameter", "configure some parameter", '//default_url_as_example/');
var param2 = Argan.getDefault("some_boolean", "configure some boolean", true);
var param3 = Argan.getDefault("some_int", "configure some int", 1);
```

## Example program

building examples/sys:

compile with

    haxe examples/sys/build.hxml

Running

    ./bin/main --help

outputs:

<img src="https://raw.githubusercontent.com/tecteun/argan/master/console.png?sanitize=true&1" width="440"/>

## Defines

Serialize options into json:

    -D argan_json_output=filename.json

