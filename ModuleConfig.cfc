component{
    // Module Properties
    this.modelNamespace = "commandbox-minify";
    this.cfmapping 		= "commandbox-minify";
    this.dependencies 	= [  ];

    function configure(){

    
        // Declare some interceptors to listen
        interceptors = [
    
        ];

        // Ad-hoc interception events I will announce myself
        interceptorSettings = {
            customInterceptionPoints = ''
        };


    }

    // Runs when module is loaded
    function onLoad(){
    }

    // Runs when module is unloaded
    function onUnLoad(){
    }

    // An interceptor that listens for every command that's run.
    function preCommand( interceptData ){
    }    

}