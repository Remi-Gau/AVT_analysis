#-- scenario file --#
scenario = "Tactile stimuli at 7 tesla";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "Touch_Present_fMRI.pcl";

#scenario_type = fMRI;
scenario_type = fMRI_emulation;
scan_period = 3000;

pulse_code = 30;
pulses_per_scan = 1;


default_text_color = 255,255,255; #white text by default
default_background_color = 128,128,128; #grey background

default_text_align = align_center;
default_font = "Arial"; #Arial font by default
default_font_size = 24; 


response_matching = simple_matching;
response_logging = log_all;


active_buttons = 1;
button_codes = 1;


default_stimulus_time_in = 0;
default_stimulus_time_out = never;
default_clear_active_stimuli = false;


# --------------------------------------------------- #
#					           SDL									#
# --------------------------------------------------- #
begin;

# SDL variables

# VISUAL HARDWARE
$RefreshRate = 60.0;

# Colors
$Black = "0, 0, 0";
$White = "255, 255, 255";
$Grey = "128, 128, 128";
$Blue = "0, 0, 255";
$Green = "0, 255, 0";
$Red = "255, 0, 0";

# Position
$xpos = 0;
$ypos = 0;

# Stimuli timing
$ISI = 1700;
$Pre_Stimulus_Duration = 500;

# Fixation Cross
$FixationCrossLineWidth = 2;
$FixationCrossHalfWidth = 8;
$NegativeFixationCrossHalfWidth = '-($FixationCrossHalfWidth)';


#------------------#
# STIMULI ELEMENTS #
#------------------#

# VISUAL

# Blue Fixation Cross
line_graphic {
	coordinates = $NegativeFixationCrossHalfWidth, 0, $FixationCrossHalfWidth, 0;
	coordinates = 0, $NegativeFixationCrossHalfWidth, 0, $FixationCrossHalfWidth;
	line_width = $FixationCrossLineWidth;
	line_color = $Blue;
}BlueFixationCross;


#---------#
# STIMULI #
#---------#
picture {
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PictureBlueFixationCross;


#--------#
# TRIALS #
#--------#
#START
trial {	
	nothing {};
	mri_pulse = 1;
	picture PictureBlueFixationCross;
	code = "Start";
} Start_Trial;


#ISI
trial {
	monitor_sounds = false;
	all_responses = true;
	trial_duration = $ISI;
	
	picture PictureBlueFixationCross;
	time = 0;
	
	code = "ISI";
} ISI;


# TRIALS
# Tactile_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;

	picture {
			text {
				caption = "Stimulus";
			}StimTxt;
			x = 0; y = 0;
		};
	code = "Tactile_Trial";
	time = $Pre_Stimulus_Duration;
	duration = $Pre_Stimulus_Duration; 
	
} Tactile_Trial;


#TARGETS
# Tactile_Target;
trial {	
	monitor_sounds = false;
	all_responses = true;

	picture {
		text {
			caption = "Target";
		}TargetTxt;
		x = 0; y = 0;
	};
	code = "Tactile_Target";
	time = 0;
	duration = $Pre_Stimulus_Duration; 
	
} Tactile_Target;


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