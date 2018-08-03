#-- scenario file --#
scenario = "Tactile stimuli at 7 tesla";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "Touch_fMRI.pcl";

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


active_buttons = 2;
button_codes = 1, 2;


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

#Compute the number of pixel per degree
$MaxFOV = 34.0;  #2.0 * 180.0 * arctan(MonitorWidth/2.0/ViewDist)/ Pi;
$Win_W = 1024.0 ;
$Win_H = 728.0 ; 
$PPD = '$Win_W/$MaxFOV';

# for ViewDist = 30
# MonWidth	MaxFOV
# 48.0		77
# 37			63
# 29			52
# 21.5		40

# for ViewDist = 50
# MonWidth	MaxFOV
# 48.0		51

# for ViewDist = 60
# MonWidth	MaxFOV
# 33.0		31
# 37			34

# for ViewDist = 160
# MonWidth	MaxFOV
# 39.0		40

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
$ISI = 1300;
$Pre_Stimulus_Duration = 500;

# Fixation Cross
$FixationCrossLineWidth = 2;
$FixationCrossHalfWidth = 8;
$NegativeFixationCrossHalfWidth = '-($FixationCrossHalfWidth)';

# Fixation
$FinalFixationDuration = 1000.0;
$Fixation_Duration = 10000.0;


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
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration; 
		
	picture PictureBlueFixationCross;
	code = "Tactile_Trial";
	time = $Pre_Stimulus_Duration;
} Tactile_Trial;


#TARGETS
# Tactile_Target;
trial {	
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;

	stimulus_event {
		picture PictureBlueFixationCross;
		code = "Tactile_Target";
		time = $Pre_Stimulus_Duration;
		target_button = 1;
	} Tactile_Target_Event;
	
} Tactile_Target;


##CONFIRMATION AT START
trial {
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 2;   
	
	picture {
		text {
			caption = "Press ENTER to start.";
		}ConfirmationTxt;
		x = 0; y = 0;
	};
} Confirmation;


# FIXATIONS
# Fixation
trial {
	monitor_sounds = false;
	all_responses = true;
	trial_duration = 'int($Fixation_Duration)';
	
	picture PictureBlueFixationCross;
	
	code = "Fixation";
	
	save_logfile {
      filename = "temp.log"; # use temp.log in default logfile directory
   };
} Fixation;


# Final Fixation
trial {
	all_responses = true;
   trial_duration = 'int($FinalFixationDuration)';
	
	picture PictureBlueFixationCross;
	
	code = "Final_Fixation";
} Final_Fixation;