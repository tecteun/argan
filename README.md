![Argan](https://raw.githubusercontent.com/tecteun/argan/master/drawing.svg?sanitize=true&1)
---
Define command line help inline!

## Examples

For sys targets (see https://api.haxe.org/Sys.html for a list of targets supporting the sys package):

    if(Argan.has("help", "show this help")){
        Sys.println("Usage: 'my_executable.exe --option=value or -option value'");
        for(h in Argan.help().keys())
            Sys.println('--${StringTools.rpad(h, " ", 12)}${Argan.help()[h]}');
        Sys.println('');
        Sys.exit(0);
    }

For other non-sys targets:

    if(Argan.has("help", "show this help")){
        trace("Usage: 'my_executable.exe --option=value or -option value'");
        for(h in Reflect.fields(Argan.help(true)))
            Sys.println('--${StringTools.rpad(h, " ", 12)}${Reflect.field(Argan.help(true), h)}');
        trace('');
        return;
    }

## Defines

