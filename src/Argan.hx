package ;

#if macro
import sys.io.File;
import sys.FileSystem;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
#end

typedef ArganMap = Map<String, Dynamic>;
class Argan {
    private static var HELP_RESOURCE_KEY:String = "_help_map";
    #if macro
    static var firstRun:Bool = true;
    static var jsonFile:String = '${HELP_RESOURCE_KEY}_file.json';
    #end

    #if !sys
    public static var args(default, null):ArganMap;
    public static function start(config:Dynamic) : Void {
        var args_set:ArganMap = new ArganMap();
        for(f in Reflect.fields(config)){
            args_set.set(f, Reflect.field(config, f));
        }
        args = args_set;
    }
    #else
    private static var _args:ArganMap = null;
    public static var args(get_args, null):ArganMap;
    
    static function get_args() : ArganMap {
        if(_args == null){
            #if sys
            _args = parseArgs(Sys.args());
            #end
        }
        return _args;
    }
    static function parseArgs(args:Array<String>) : ArganMap {
        var args_set:ArganMap = new ArganMap();
        var previousArg = null;
        for(s in args){
            if(StringTools.startsWith(s, "-")){
                while(s.charAt(0) == "-"){
                    s = s.substr(1);
                }
                if(s.indexOf("=") > -1){
                    var split = s.split("=");
                    if(split.length > 1)
                        args_set.set(split[0], split[1]);
                }else{
                    if(previousArg != null)
                        args_set.set(previousArg, null);
                    
                    previousArg = s;
                }
            }else if(previousArg != null){
                args_set.set(previousArg, s);
                previousArg = null;
            }else{
                throw 'unsupported commandline arg: $s';
            }
        }
        if(previousArg != null)
            args_set.set(previousArg, null);

        return args_set;
    }
    #end

    public static function objectFromMap(map:ArganMap) {
        var obj = {};
        for(k in map.keys())
            Reflect.setField(obj, k, map.get(k));
        return obj;
    }

    macro public static function help(object:Bool = false){
        if(object)
            return macro { Argan.objectFromMap(haxe.Unserializer.run(haxe.Resource.getString($v{HELP_RESOURCE_KEY}))); };
        else
            return macro { cast(haxe.Unserializer.run(haxe.Resource.getString($v{HELP_RESOURCE_KEY})), Argan.ArganMap); };
    }

    /**
     *  Checks if commandline argument is given
     *  @param key commandline argument key to check 
     *  @param help optional help text, added to haxe.Resource and returned on help() 
     *  @return haxe.macro.Expr
     */
    macro public static function has(key:String, ?help:String = null):haxe.macro.Expr{
        #if macro
            var map:ArganMap = null;
            if(firstRun)
                firstrun();
            
            if(Context.getResources().exists(HELP_RESOURCE_KEY)){
                map = map_load();
                map.exists(key) ? trace('Argan.hx, possible issue with key ${key}, ${key} already in use, use unique keys please..') : map.set(key, help);
            }else{
                map = [ key => help ];
            }
            Context.addResource(HELP_RESOURCE_KEY, haxe.io.Bytes.ofString(haxe.Serializer.run(map)));
        #end
        return macro {
            Argan.args != null ? Argan.args.exists($v{key}) : false;
        };
    }

    #if macro
        private static function firstrun(){
            firstRun = false;
            trace('Saving \'help map\' into haxe.Resource["$HELP_RESOURCE_KEY"], use Argan.get() for easy access');
            if(haxe.macro.Context.defined("argan_json_output")){
                var val = haxe.macro.Context.definedValue("argan_json_output");
                if(val != "1"){
                    jsonFile = val;
                    Argan.HELP_RESOURCE_KEY = val + Argan.HELP_RESOURCE_KEY;
                }
                Context.onAfterGenerate(function(){
                    var str = new StringBuf();
                    var map = map_load();
                    str.add('\n>> Argan.hx Macro <<\n${map}\nsaved to:\n');
                    str.add('JSON ${jsonFile} saved');
                    str.add(FileSystem.exists(jsonFile) ? ' (overwritten!)\n' : '\n');
                    var content = new StringBuf();
                    //content.add('window["version"] = "${Macros.GetVersion()}";');
                    //content.add('window["${StringTools.htmlEscape(jsonFile)}"] = ${haxe.Json.stringify(objectFromMap(map))}');
                    content.add('//${StringTools.htmlEscape(jsonFile)}\n');
                    content.add('${haxe.Json.stringify(objectFromMap(map))}');
                    File.saveContent(jsonFile, content.toString());
                    trace(str);
                });
            }
        }
        private static function map_load():ArganMap{
            return haxe.Unserializer.run('${Context.getResources().get(HELP_RESOURCE_KEY)}');
        }
    #end

    macro public static function getDefault(key:String, help:String, ?default_:Null<Dynamic> = null):Dynamic {
        var stype = switch(default_.expr){
            case EConst(const): '$const';
            default: null;
        }
        return macro {   var _:Dynamic = Argan.has($v{key}, $v{help + ' [default: ${stype}]'} ) ? Argan.get($v{key}) : ${default_}; _; };
    }
    
    /**
     *  Get commandline argument
     *  @param key String
     *  @return return String
     */
    macro public static function get(key:String)
        return macro {
            Argan.args.get($v{key});
        }
}