#-- scenario file --#
scenario = "Calibration for Tobii eyetracker";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "EyeTrack_Calibration.pcl";

scenario_type = trials;


default_text_color = 255,255,255; #white text by default
default_background_color = 128,128,128; #grey background

default_text_align = align_center;
default_font = "Arial"; #Arial font by default
default_font_size = 24; 

active_buttons = 1;
button_codes = 1;

default_stimulus_time_in = 0;
default_stimulus_time_out = never;
default_clear_active_stimuli = false;


# --------------------------------------------------- #
#					           SDL									#
# --------------------------------------------------- #
begin;

# Colors
$Blue = "0, 0, 255";

# Position
$xpos = 0;
$ypos = 0;

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
	} 
	Default;

picture {
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PictureBlueFixationCross;


#--------#
# TRIALS #
#--------#
##EYETRACKER INFO
trial {
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 1;   
	
	picture {
		text {
			caption = "Press ENTER to start.";
		}EyeTrackTxt;
		x = 0; y = 0;
	} EyeTracPic;
} EyeTrackScreen;