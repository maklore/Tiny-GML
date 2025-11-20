function tiny_announcer() constructor {
    
    //Initialize the values.
    static maximum = 5;
    static size    = 0;
    static prompt  = -1;
    static time    = 3;
    static alpha   = 1;
    static time_pf = 1 / game_get_speed(gamespeed_fps);  
    static color   = [c_green, c_yellow, c_red];    //news, warning, error
    static type    = [0, 1, 2];                     //news, warning, error
    static val     = {
        text  : 0,
        type  : 1,
        time  : 2,
        alpha : 3
    }
    
    /**
     * @desc With this function you can send a stringed alert to the broadcasting system. The types and colored text of systems are as follows: 0 (News - green), 1 (Warning - yellow), and 2 (Error - red).
     * @param {string} _string  The string message you wish to add broadcasting system.
     * @param {string} _type    The type of message you wish to broadcast.
     */
    alert = function(_string, _type) {
        
        //If the type is not correct send a stringed alert to the broadcasting system and exit the function.
        if !array_contains(type, _type) { alert($"{_type} is invalid type!", "warn"); exit; }
        
        if !ds_exists(prompt, ds_type_list) { prompt = ds_list_create(); }
        
        //Insert into the first entry: string, type, timer to the broadcasting prompter.
        ds_list_insert(prompt, 0, variable_clone([_string, _type, time, alpha]));
		
		//Get the size of the DS list.
        size = ds_list_size(prompt);
        
        //If the size is greater (should not happen) or equal to the maximum size, delete the last entry.
        if size >= maximum { ds_list_delete(prompt, size); }
        
    }
   
    /**
    * @desc With this function messages will be broadcasted to the upper center of the screen. Add this to the Draw_GUI event.
    */
    broadcast = function() {
        
        //Initialize the draw position.
        static gui_x = display_get_gui_width() * 0.5;   //Center of the GUI width.
        static gui_y = display_get_gui_height() * 0.1;  //Upper part of the GUI height.
        
        //If there is no DS list exit the function.
        if !ds_exists(prompt, ds_type_list) { exit; }
        
        var _string_y = 0;
        
        for (var i = 0; i < size; ++i) {
			
			//If there is an undefined entry exit the loop.
			if prompt[| i] == undefined { exit }
			
            //Adds the first entries string height to the current entry if there are more than one entry.
            _string_y = i > 0 ? _string_y + string_height(prompt[| 0][val.text]) : 0;
			
            		
            draw_text_transformed_color(gui_x, 
                                        gui_y + _string_y, 
                                        prompt[| i][val.text],
                                        1,
                                        1,
                                        0,
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        color[prompt[| i][val.type]],
                                        prompt[| i][val.alpha]);
										
            //Reduce timer by time per frame.
            prompt[| i][val.time] -= time_pf;
            
            //Reduce alpha to zero during the last second.
            if prompt[| i][val.time] <= 1 { prompt[| i][val.alpha] -= time_pf; }
            
            //Delete the entry that has had it's timer reached zero.
            if prompt[| i][val.time] <= 0 { ds_list_delete(prompt, i); }
        }
        
        //If the list is empty, destroy it, and reset values.
        if ds_list_empty(prompt) { ds_list_destroy(prompt); prompt = -1; size = 0; }
    }
}

//INITIALIZE THE BROADCASTING CONSTRUCTOR
#macro MSG global.msg
MSG = new tiny_announcer();