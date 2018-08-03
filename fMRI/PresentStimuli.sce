#-- scenario file --#
scenario = "AVT at 7 tesla";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "PresentStimuli.pcl";

scenario_type = trials;

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

#Compute the number of pixel per degree
$MaxFOV = 13.0;  #2.0 * 180.0 * arctan(MonitorWidth/2.0/ViewDist)/ Pi;
$Win_W = 1024.0 ;
$Win_H = 768.0 ; 
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
# 29			28

# for ViewDist = 160
# MonWidth	MaxFOV
# 39.0		40
# 28.5		10,2

# Colors
$Black = "0, 0, 0";
$White = "255, 255, 255";
$Grey = "128, 128, 128";
$Blue = "0, 0, 255";

# Position
$xpos = 0;
$ypos = 0;

# Stimuli timing
$Stimulus_Duration = 50; # ms
$Pre_Stimulus_Duration = 100;

# Fixation Cross
$FixationCrossLineWidth = 2;
$FixationCrossHalfWidth = 8;
$NegativeFixationCrossHalfWidth = '-($FixationCrossHalfWidth)';

# Dots
$Dot_Size = 3.0;
$Dot_Size_Pixel = '$Dot_Size * $PPD';
$Dot_Color = $White;

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

# Single Dot
ellipse_graphic {
	ellipse_width = $Dot_Size_Pixel;
	ellipse_height = $Dot_Size_Pixel;
	color = $Dot_Color;
}Dot;

# Dots
array{
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_1;
} DOTS_ARRAY;

# AUDIO
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
	ellipse_graphic Dot_1; 	x = $xpos; y = $ypos;
	
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} Dots;


picture {
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PictureBlueFixationCross;


picture {
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} default;


#--------#
# TRIALS #
#--------#
#START
trial {	
	monitor_sounds = false;
	nothing {};
	mri_pulse = 1;
	picture PictureBlueFixationCross;
	code = "Start";
} Start_Trial;


# TRIALS
# VisualOnly_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;

	stimulus_event {
		picture Dots;
		time = $Pre_Stimulus_Duration;
		duration = $Stimulus_Duration;
		code = "VisualOnly_Trial";
	} Dots_V;

} VisualOnly_Trial;


# AudioOnly_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;
	
	stimulus_event {
      sound Sound_50ms_Location_min12_Deg_5_Rep;
		time = $Pre_Stimulus_Duration;
		code = "AudioOnly_Trial_A";
   } SoundOnly;
	
} AudioOnly_Trial;


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
# VisualOnly_Target;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;

	stimulus_event {
		picture Dots;
		time = $Pre_Stimulus_Duration;
		duration = $Stimulus_Duration;
		code = "VisualOnly_Target";
	} Dot_Target_1;	
	
	stimulus_event {
		picture PictureBlueFixationCross;
		delta_time = $Stimulus_Duration;
		duration = $Stimulus_Duration;
	} Inter_Dot;
	
	stimulus_event {
		picture Dots;
		delta_time = $Stimulus_Duration;
		duration = $Stimulus_Duration;
		target_button = 1;		
	} Dot_Target_2;

} VisualOnly_Target;


# AudioOnly_Target;
trial {
	monitor_sounds = false;
	all_responses = true;

	picture PictureBlueFixationCross;
	time = 0; 
	duration = $Pre_Stimulus_Duration;

	stimulus_event {
      sound Sound_50ms_Location_min12_Deg_5_Rep;
		time = $Pre_Stimulus_Duration;
		code = "AudioOnly_Target_A";
   } Sound_Target1;
	
	stimulus_event {
      sound Sound_50ms_Location_min12_Deg_5_Rep;
		time = '$Pre_Stimulus_Duration+$Stimulus_Duration*2';
		target_button = 1;
   } Sound_Target2;

} AudioOnly_Target;


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
   terminator_button = 1;   
	
	picture {
		text {
			caption = "Press ENTER to start.";
		}ConfirmationTxt;
		x = 0; y = 0;
	};
} Confirmation;

#Trial description
trial {
	all_responses = true;
	monitor_sounds = false;

	picture {
		text {
			caption = "Press ENTER to start.";
		}StimNatureText;
		x = 0; y = 0;
	};
	duration = 1500;
	
} StimNature;