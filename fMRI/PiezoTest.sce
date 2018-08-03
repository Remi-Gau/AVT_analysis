scenario = "Piezo Test";
scenario_type = trials;
pcl_file = "PiezoTest.pcl";

active_buttons = 1;
button_codes = 1;

begin;

picture {
} default;

trial {
  picture default;
} main_trial;

##CONFIRMATION AT START
trial {
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 1;   
	
	picture {
		text {
			caption = "Press ENTER to start.";
		}ConfirmationTxt;
		x = 0; y = 0;
	};
} Confirmation;