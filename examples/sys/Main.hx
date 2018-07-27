package ;
class Main {
    public function new() {
        if(Argan.has("help", "show this help")){
			Sys.println("Usage: 'main --option=value or -option value'");
			for(h in Argan.help().keys())
				Sys.println('--${StringTools.rpad(h, " ", 12)}${Argan.help()[h]}');
			Sys.println('');
			Sys.exit(0);
		}
        trace(Argan.get("username"));
        var username = Argan.get("username", "override user");
        //trace(Argan.get("username", "should give warning"));
        var password = Argan.get("password", "override password");
        /*
        if(Argan.getDefault("threads", "set number of threads", 11) == 11){
            //start threads
            trace(Argan.getDefault("threads", "set number of threads", 11));
            trace(Argan.get("threads", "set number of threads", 11));
        }
        */
        if(Argan.has("beer")){
            //drink
        }
        var debug = Argan.getDefault("debug", "enable debug mode", false);

        trace('debug : $debug');
        trace('username : $username');
        trace('password : $password');
        trace('beer value : ${Argan.get("beer")}');
    }

    static function main() {
        new Main();
    }
}