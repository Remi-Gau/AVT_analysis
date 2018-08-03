#-- scenario file --#
scenario = "Sound test";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "SoundTest.pcl";

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
