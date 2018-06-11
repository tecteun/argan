package ;
#if sys
typedef ArgsMap = Map<String, String>;
class ArgParser {
    private static inline var HELP_RESOURCE_KEY:String = "_help_map";
    private static var _args:ArgsMap = null;
    public static var args(get_args, null):ArgsMap;
    
    static function get_args() : ArgsMap {
        if(_args == null){
            #if sys
            _args = parseArgs(Sys.args());
            #end
        }
        return _args;
    }

    static function parseArgs(args:Array<String>):Map<String, String>{
        var args_set:Map<String, String> = new Map<String, String>();

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

    public static function help():Map<String,String>
        return haxe.Unserializer.run(haxe.Resource.getString(HELP_RESOURCE_KEY));
    
    /**
     *  Checks if commandline argument is given
     *  @param key commandline argument key to check 
     *  @param help optional help text, added to haxe.Resource and returned on help() 
     *  @return haxe.macro.Expr
     */
    macro public static function has(key:String, ?help:String = null):haxe.macro.Expr{
        #if macro
            var map:Map<String,String> = null;
            if(haxe.macro.Context.getResources().exists(HELP_RESOURCE_KEY)){
                map  = haxe.Unserializer.run('${haxe.macro.Context.getResources().get(HELP_RESOURCE_KEY)}');  
                if(map.exists(key))
                    throw "ArgParser error, use unique keys please..";
                map.set(key, help);
            }else{
                map = [ key => help ];
            }
            haxe.macro.Context.addResource(HELP_RESOURCE_KEY, haxe.io.Bytes.ofString(haxe.Serializer.run(map)));
        #end
        return macro {
            ArgParser.args.exists($v{key});
        };
    }

    /**
     *  Get commandline argument
     *  @param key String
     *  @return return String
     */
    macro public static function get(key:String)
        return macro {
            ArgParser.args.get($v{key});
        }
}
#end