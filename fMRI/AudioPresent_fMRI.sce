#-- scenario file --#
scenario = "Auditory present task at 7 tesla";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "AudioPresent_fMRI.pcl";

scenario_type = trials;


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

# Colors
$Black = "0, 0, 0";
$White = "255, 255, 255";
$Grey = "128, 128, 128";
$Blue = "0, 0, 255";

# Position
$xpos = 0;
$ypos = 0;

# Stimuli timing
$ISI = 2000;
$Stimulus_Duration = 200; # ms
$Pre_Stimulus_Duration = 1000;
$Post_Stimulus_Duration = 1500;

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


# AUDIO
# Sounds
array{
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_1_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_1_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_1_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_1_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_1_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_1_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_1_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_1_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_1_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_1_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_2_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_2_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_2_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_2_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_2_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_2_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_2_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_2_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_2_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_2_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_3_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_3_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_3_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_3_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_3_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_3_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_3_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_3_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_3_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_3_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_4_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_4_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_4_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_4_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_4_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_4_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_4_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_4_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_4_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_4_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_5_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_5_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_5_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_5_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_5_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_5_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_5_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_5_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_5_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_5_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_6_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_6_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_6_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_6_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_6_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_6_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_6_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_6_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_6_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_6_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_7_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_7_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_7_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_7_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_7_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_7_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_7_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_7_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_7_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_7_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_8_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_8_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_8_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_8_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_8_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_8_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_8_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_8_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_8_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_8_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_9_Rep.wav "; } ; } Sound_200ms_Location_min12_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_9_Rep.wav "; } ; } Sound_200ms_Location_min10_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_9_Rep.wav  "; } ; } Sound_200ms_Location_min8_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_9_Rep.wav  "; } ; } Sound_200ms_Location_min5_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_9_Rep.wav  "; } ; } Sound_200ms_Location_min4_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_9_Rep.wav  "; } ; } Sound_200ms_Location_min3_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_9_Rep.wav  "; } ; } Sound_200ms_Location_min1_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_0_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_1_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_3_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_4_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_5_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_9_Rep.wav     "; } ; } Sound_200ms_Location_8_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_9_Rep.wav    "; } ; } Sound_200ms_Location_10_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_9_Rep.wav    "; } ; } Sound_200ms_Location_12_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_min12_Deg_10_Rep.wav"; } ; } Sound_200ms_Location_min12_Deg_10_Rep ;
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg_10_Rep.wav"; } ; } Sound_200ms_Location_min10_Deg_10_Rep ;
sound {wavefile { filename = "Sound_200ms_Location_min8_Deg_10_Rep.wav "; } ; } Sound_200ms_Location_min8_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min5_Deg_10_Rep.wav "; } ; } Sound_200ms_Location_min5_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg_10_Rep.wav "; } ; } Sound_200ms_Location_min4_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min3_Deg_10_Rep.wav "; } ; } Sound_200ms_Location_min3_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_min1_Deg_10_Rep.wav "; } ; } Sound_200ms_Location_min1_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_200ms_Location_0_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_0_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_1_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_1_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_3_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_3_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_4_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_5_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_5_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_8_Deg_10_Rep.wav    "; } ; } Sound_200ms_Location_8_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg_10_Rep.wav   "; } ; } Sound_200ms_Location_10_Deg_10_Rep    ;
sound {wavefile { filename = "Sound_200ms_Location_12_Deg_10_Rep.wav   "; } ; } Sound_200ms_Location_12_Deg_10_Rep    ;
} SOUNDS200;

array{
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_1_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_1_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_1_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_1_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_1_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_1_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_1_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_1_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_1_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_1_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_2_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_2_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_2_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_2_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_2_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_2_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_2_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_2_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_2_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_2_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_3_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_3_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_3_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_3_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_3_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_3_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_3_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_3_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_3_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_3_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_4_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_4_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_4_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_4_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_4_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_4_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_4_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_4_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_4_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_4_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_5_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_5_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_5_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_5_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_5_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_5_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_5_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_5_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_5_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_5_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_6_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_6_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_6_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_6_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_6_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_6_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_6_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_6_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_6_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_6_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_7_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_7_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_7_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_7_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_7_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_7_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_7_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_7_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_7_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_7_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_8_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_8_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_8_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_8_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_8_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_8_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_8_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_8_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_8_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_8_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_9_Rep.wav "; } ; } Sound_100ms_Location_min12_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_9_Rep.wav "; } ; } Sound_100ms_Location_min10_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_9_Rep.wav  "; } ; } Sound_100ms_Location_min8_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_9_Rep.wav  "; } ; } Sound_100ms_Location_min5_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_9_Rep.wav  "; } ; } Sound_100ms_Location_min4_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_9_Rep.wav  "; } ; } Sound_100ms_Location_min3_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_9_Rep.wav  "; } ; } Sound_100ms_Location_min1_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_0_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_1_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_3_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_4_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_5_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_9_Rep.wav     "; } ; } Sound_100ms_Location_8_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_9_Rep.wav    "; } ; } Sound_100ms_Location_10_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_9_Rep.wav    "; } ; } Sound_100ms_Location_12_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_min12_Deg_10_Rep.wav"; } ; } Sound_100ms_Location_min12_Deg_10_Rep ;
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg_10_Rep.wav"; } ; } Sound_100ms_Location_min10_Deg_10_Rep ;
sound {wavefile { filename = "Sound_100ms_Location_min8_Deg_10_Rep.wav "; } ; } Sound_100ms_Location_min8_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min5_Deg_10_Rep.wav "; } ; } Sound_100ms_Location_min5_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg_10_Rep.wav "; } ; } Sound_100ms_Location_min4_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min3_Deg_10_Rep.wav "; } ; } Sound_100ms_Location_min3_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_min1_Deg_10_Rep.wav "; } ; } Sound_100ms_Location_min1_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_100ms_Location_0_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_0_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_1_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_1_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_3_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_3_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_4_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_5_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_5_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_8_Deg_10_Rep.wav    "; } ; } Sound_100ms_Location_8_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg_10_Rep.wav   "; } ; } Sound_100ms_Location_10_Deg_10_Rep    ;
sound {wavefile { filename = "Sound_100ms_Location_12_Deg_10_Rep.wav   "; } ; } Sound_100ms_Location_12_Deg_10_Rep    ;
} SOUNDS100;

array{
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_1_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_1_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_1_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_1_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_1_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_1_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_1_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_1_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_1_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_1_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_2_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_2_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_2_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_2_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_2_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_2_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_2_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_2_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_2_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_2_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_3_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_3_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_3_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_3_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_3_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_3_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_3_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_3_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_3_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_3_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_4_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_4_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_4_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_4_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_4_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_4_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_4_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_4_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_4_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_4_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_5_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_5_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_5_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_5_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_5_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_5_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_5_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_5_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_5_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_5_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_6_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_6_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_6_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_6_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_6_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_6_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_6_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_6_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_6_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_6_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_7_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_7_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_7_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_7_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_7_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_7_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_7_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_7_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_7_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_7_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_8_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_8_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_8_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_8_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_8_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_8_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_8_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_8_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_8_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_8_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_9_Rep.wav "; } ; } Sound_80ms_Location_min12_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_9_Rep.wav "; } ; } Sound_80ms_Location_min10_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_9_Rep.wav  "; } ; } Sound_80ms_Location_min8_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_9_Rep.wav  "; } ; } Sound_80ms_Location_min5_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_9_Rep.wav  "; } ; } Sound_80ms_Location_min4_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_9_Rep.wav  "; } ; } Sound_80ms_Location_min3_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_9_Rep.wav  "; } ; } Sound_80ms_Location_min1_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_0_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_1_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_3_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_4_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_5_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_9_Rep.wav     "; } ; } Sound_80ms_Location_8_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_9_Rep.wav    "; } ; } Sound_80ms_Location_10_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_9_Rep.wav    "; } ; } Sound_80ms_Location_12_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_min12_Deg_10_Rep.wav"; } ; } Sound_80ms_Location_min12_Deg_10_Rep ;
sound {wavefile { filename = "Sound_80ms_Location_min10_Deg_10_Rep.wav"; } ; } Sound_80ms_Location_min10_Deg_10_Rep ;
sound {wavefile { filename = "Sound_80ms_Location_min8_Deg_10_Rep.wav "; } ; } Sound_80ms_Location_min8_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min5_Deg_10_Rep.wav "; } ; } Sound_80ms_Location_min5_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min4_Deg_10_Rep.wav "; } ; } Sound_80ms_Location_min4_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min3_Deg_10_Rep.wav "; } ; } Sound_80ms_Location_min3_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_min1_Deg_10_Rep.wav "; } ; } Sound_80ms_Location_min1_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_80ms_Location_0_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_0_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_1_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_1_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_3_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_3_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_4_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_4_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_5_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_5_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_8_Deg_10_Rep.wav    "; } ; } Sound_80ms_Location_8_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_80ms_Location_10_Deg_10_Rep.wav   "; } ; } Sound_80ms_Location_10_Deg_10_Rep    ;
sound {wavefile { filename = "Sound_80ms_Location_12_Deg_10_Rep.wav   "; } ; } Sound_80ms_Location_12_Deg_10_Rep    ;
} SOUNDS80;

array{
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_1_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_1_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_1_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_1_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_1_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_1_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_1_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_1_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_1_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_1_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_1_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_1_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_1_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_1_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_2_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_2_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_2_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_2_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_2_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_2_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_2_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_2_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_2_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_2_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_2_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_2_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_2_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_2_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_3_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_3_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_3_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_3_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_3_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_3_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_3_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_3_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_3_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_3_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_3_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_3_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_3_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_3_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_4_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_4_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_4_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_4_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_4_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_4_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_4_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_4_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_4_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_4_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_4_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_4_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_4_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_4_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_5_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_5_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_5_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_5_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_5_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_5_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_5_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_5_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_5_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_5_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_5_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_5_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_5_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_5_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_6_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_6_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_6_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_6_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_6_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_6_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_6_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_6_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_6_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_6_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_6_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_6_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_6_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_6_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_7_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_7_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_7_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_7_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_7_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_7_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_7_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_7_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_7_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_7_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_7_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_7_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_7_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_7_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_8_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_8_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_8_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_8_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_8_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_8_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_8_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_8_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_8_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_8_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_8_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_8_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_8_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_8_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_9_Rep.wav "; } ; } Sound_50ms_Location_min12_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_9_Rep.wav "; } ; } Sound_50ms_Location_min10_Deg_9_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_9_Rep.wav  "; } ; } Sound_50ms_Location_min8_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_9_Rep.wav  "; } ; } Sound_50ms_Location_min5_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_9_Rep.wav  "; } ; } Sound_50ms_Location_min4_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_9_Rep.wav  "; } ; } Sound_50ms_Location_min3_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_9_Rep.wav  "; } ; } Sound_50ms_Location_min1_Deg_9_Rep   ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_0_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_1_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_3_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_4_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_5_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_9_Rep.wav     "; } ; } Sound_50ms_Location_8_Deg_9_Rep      ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_9_Rep.wav    "; } ; } Sound_50ms_Location_10_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_9_Rep.wav    "; } ; } Sound_50ms_Location_12_Deg_9_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_min12_Deg_10_Rep.wav"; } ; } Sound_50ms_Location_min12_Deg_10_Rep ;
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg_10_Rep.wav"; } ; } Sound_50ms_Location_min10_Deg_10_Rep ;
sound {wavefile { filename = "Sound_50ms_Location_min8_Deg_10_Rep.wav "; } ; } Sound_50ms_Location_min8_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min5_Deg_10_Rep.wav "; } ; } Sound_50ms_Location_min5_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg_10_Rep.wav "; } ; } Sound_50ms_Location_min4_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min3_Deg_10_Rep.wav "; } ; } Sound_50ms_Location_min3_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_min1_Deg_10_Rep.wav "; } ; } Sound_50ms_Location_min1_Deg_10_Rep  ;
sound {wavefile { filename = "Sound_50ms_Location_0_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_0_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_1_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_1_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_3_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_3_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_4_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_5_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_5_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_8_Deg_10_Rep.wav    "; } ; } Sound_50ms_Location_8_Deg_10_Rep     ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg_10_Rep.wav   "; } ; } Sound_50ms_Location_10_Deg_10_Rep    ;
sound {wavefile { filename = "Sound_50ms_Location_12_Deg_10_Rep.wav   "; } ; } Sound_50ms_Location_12_Deg_10_Rep    ;
} SOUNDS50;


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
#ISI
trial {
	monitor_sounds = false;
	all_responses = true;
	trial_duration = $ISI;
	
	picture {
		text {
			caption = "CENTER";
		}ISI_Txt;
		x = 0; y = 0;
	};
	time = 0;
	
	code = "ISI";
} ISI;


# TRIALS
# AudioOnly_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;
	
	stimulus_event {
      sound Sound_50ms_Location_12_Deg_10_Rep;
		time = $Pre_Stimulus_Duration;
		code = "AudioOnly_Trial_A";
   } SoundOnly;

	stimulus_event {
		picture PictureBlueFixationCross;
		time = $Pre_Stimulus_Duration;
		duration = '$Stimulus_Duration+$Post_Stimulus_Duration';
	} PostStimFix_A;
	
} AudioOnly_Trial;


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
