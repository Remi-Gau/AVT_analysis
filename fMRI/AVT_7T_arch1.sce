#-- scenario file --#
scenario = "AVT at 7 tesla";

# --------------------------------------------------- #
# 								HEADER 								#
# --------------------------------------------------- #
pcl_file = "AVT_7T.pcl";

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


active_buttons = 5;
button_codes = 1, 2, 3, 4, 5;


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
$MonitorWidth = 37.0;
$ViewDist = 30.0;
$MaxFOV = 51.0;  #2.0 * 180.0 * arctan(MonitorWidth/2.0/ViewDist)/ Pi;
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
$ISI = 2000;
$AV_Stimulus_Duration = 50; # ms
$Stimulus_Duration = 192; # ms
$Pre_Stimulus_Duration = 500;
$Post_Stimulus_Duration = 250;
$Feedback_Duration = 500;

# Fixation Cross
$FixationCrossLineWidth = 2;
$FixationCrossHalfWidth = 8;
$NegativeFixationCrossHalfWidth = '-($FixationCrossHalfWidth)';

# Dots
$Dot_Size = 0.43;
$Dot_Size_Pixel = '$Dot_Size * $PPD';
$Dot_Color = $White;

# Feedback
$Feedback_Size = 1;
$Feedback_Size_Pixel = '$Feedback_Size * $PPD';
$PositiveFeedback_Color = $Green;
$NegativeFeedback_Color = $Red;

# Fixation
$FinalFixationDuration = 40000.0;
$Fixation_Duration = 6000.0;


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
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_2;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_3;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_4;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_5;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_6;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_7;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_8;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_9;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_10;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_11;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_12;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_13;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_14;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_15;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_16;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_17;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_18;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_19;
ellipse_graphic {ellipse_width = $Dot_Size_Pixel; ellipse_height = $Dot_Size_Pixel; color = $Dot_Color; } Dot_20;
} DOTS_ARRAY;

# Positive Feedback
ellipse_graphic {
	ellipse_width = $Feedback_Size_Pixel;
	ellipse_height = $Feedback_Size_Pixel;
	color = $PositiveFeedback_Color;
}PositiveFeedbackDot;

#Negative Feedback
ellipse_graphic {
	ellipse_width = $Feedback_Size_Pixel;
	ellipse_height = $Feedback_Size_Pixel;
	color = $NegativeFeedback_Color;
}NegativeFeedbackDot;


# AUDIO

# Sounds
array{
sound {wavefile { filename = "Sound_50ms_Location_min10_Deg.wav"; } ; } Sound_50ms_Location_min10_Deg ;
sound {wavefile { filename = "Sound_50ms_Location_min4_Deg.wav "; } ; } Sound_50ms_Location_min4_Deg  ;
sound {wavefile { filename = "Sound_50ms_Location_4_Deg.wav    "; } ; } Sound_50ms_Location_4_Deg     ;
sound {wavefile { filename = "Sound_50ms_Location_10_Deg.wav   "; } ; } Sound_50ms_Location_10_Deg    ;
} SOUNDS050;

array{
sound {wavefile { filename = "Sound_100ms_Location_min10_Deg.wav"; } ; } Sound_100ms_Location_min10_Deg ;
sound {wavefile { filename = "Sound_100ms_Location_min4_Deg.wav "; } ; } Sound_100ms_Location_min4_Deg  ;
sound {wavefile { filename = "Sound_100ms_Location_4_Deg.wav    "; } ; } Sound_100ms_Location_4_Deg     ;
sound {wavefile { filename = "Sound_100ms_Location_10_Deg.wav   "; } ; } Sound_100ms_Location_10_Deg    ;
} SOUNDS100;

array{
sound {wavefile { filename = "Sound_200ms_Location_min10_Deg.wav"; } ; } Sound_200ms_Location_min10_Deg ;
sound {wavefile { filename = "Sound_200ms_Location_min4_Deg.wav "; } ; } Sound_200ms_Location_min4_Deg  ;
sound {wavefile { filename = "Sound_200ms_Location_4_Deg.wav    "; } ; } Sound_200ms_Location_4_Deg     ;
sound {wavefile { filename = "Sound_200ms_Location_10_Deg.wav   "; } ; } Sound_200ms_Location_10_Deg    ;
} SOUNDS200;


#Targets
array{
sound {wavefile { filename = "Target_200ms_Location_min10_Deg.wav"; } ; } Target_200ms_Location_min10_Deg ;
sound {wavefile { filename = "Target_200ms_Location_min4_Deg.wav "; } ; } Target_200ms_Location_min4_Deg  ;
sound {wavefile { filename = "Target_200ms_Location_4_Deg.wav    "; } ; } Target_200ms_Location_4_Deg     ;
sound {wavefile { filename = "Target_200ms_Location_10_Deg.wav   "; } ; } Target_200ms_Location_10_Deg    ;
} TARGETS;


#---------#
# STIMULI #
#---------#
picture {
	ellipse_graphic Dot_1; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_2; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_3; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_4; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_5; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_6; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_7; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_8; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_9; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_10; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_11; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_12; 	x = $xpos; y = $ypos;	
	ellipse_graphic Dot_13; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_14; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_15; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_16; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_17; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_18; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_19; 	x = $xpos; y = $ypos;
	ellipse_graphic Dot_20; 	x = $xpos; y = $ypos;
	
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} Dots;


picture {
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PictureBlueFixationCross;


picture {
	ellipse_graphic PositiveFeedbackDot;
	x = $xpos; y = $ypos;
	
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PicturePositiveFeedback;


picture {
	ellipse_graphic NegativeFeedbackDot;
	x = $xpos; y = $ypos;
	
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} PictureNegativeFeedback;



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
# AudioVisual_Con_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	
	stimulus_event {
		picture Dots;
		time = $Pre_Stimulus_Duration;
		duration = $AV_Stimulus_Duration;
		code = "AudioVisual_Con_Trial_V";
	} Dots_Con;
	
	stimulus_event {
      sound Sound_50ms_Location_min10_Deg;
		time = $Pre_Stimulus_Duration;
		code = "AudioVisual_Con_Trial_A";
   } SoundWithDots_Con;
} AudioVisual_Con_Trial;


# AudioVisual_Inc_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
		
	stimulus_event {
		picture Dots;
		time = $Pre_Stimulus_Duration;
		duration = $AV_Stimulus_Duration;
		code = "AudioVisual_Inc_Trial_V";
	} Dots_Inc;
	
	stimulus_event {
      sound Sound_50ms_Location_min10_Deg;
		time = $Pre_Stimulus_Duration;
		code = "AudioVisual_Inc_Trial_A";
   } SoundWithDots_Inc;
} AudioVisual_Inc_Trial;


# VisualOnly_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
		
	picture Dots;
	time = $Pre_Stimulus_Duration;
   duration = $Stimulus_Duration;
	code = "VisualOnly_Trial";
} VisualOnly_Trial;


# AudioOnly_Trial;
trial {
	monitor_sounds = false;
	all_responses = true;
	
	picture PictureBlueFixationCross;
	time = 0; 
	
	stimulus_event {
      sound Sound_50ms_Location_min10_Deg;
		time = $Pre_Stimulus_Duration;
		code = "AudioOnly_Trial_A";
   } SoundOnly;

	picture PictureBlueFixationCross;
	time = $Pre_Stimulus_Duration;
   duration = $Stimulus_Duration;
	code = "AudioOnly_Trial_V";	
} AudioOnly_Trial;


# Tactile_Trial;
trial {
	
	picture PictureBlueFixationCross;
	time = 0; 
		
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
		
	picture Dots;
	time = $Pre_Stimulus_Duration;
   duration = '$Stimulus_Duration/3';
	code = "VisualOnly_Target";
	
	picture PictureBlueFixationCross;
	delta_time = '$Stimulus_Duration/3';
	duration = '$Stimulus_Duration/3';
	
	stimulus_event {
		picture Dots;
		delta_time = '$Stimulus_Duration/3';
		duration = '$Stimulus_Duration/3';
		target_button = 1;
	} Dot_Target;
} VisualOnly_Target;


# AudioOnly_Target;
trial {
	monitor_sounds = false;
	all_responses = true;
		
	picture PictureBlueFixationCross;
	time = 0; 
		
	stimulus_event {
      sound Target_200ms_Location_min10_Deg;
		time = $Pre_Stimulus_Duration;
		target_button = 1;
		code = "AudioOnly_Target_A";
   } Sound_Target;

	picture PictureBlueFixationCross;
	time = $Pre_Stimulus_Duration;
   duration = $Stimulus_Duration;
	code = "AudioOnly_Target_V";	
} AudioOnly_Target;


# Tactile_Target;
trial {	

	
	picture PictureBlueFixationCross;
	time = 0; 

	stimulus_event {
		picture PictureBlueFixationCross;
		code = "Tactile_Target";
		time = $Pre_Stimulus_Duration;
		target_button = 1;
	} Tactile_Target_Event;
} Tactile_Target;



#RESPONSES
# Auditory location
trial {
	monitor_sounds = false;
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 1, 2; 
	
	stimulus_event {
	picture {
		text {
			caption = "Auditory location?\nLEFT  /  RIGHT";
		};
		x = 0; y = 0;
	} AudLocPic;
	code = "AuditoryLocation";
	} AudLocEvent;
	
} AuditoryLocation;

# Common source judgment
trial {
	monitor_sounds = false;
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 3, 4;  
	
	picture {
		text {
			caption = "Source?\nSAME (S)  /  DIFFERENT (D)";
		};
		x = 0; y = 0;
	} SameDifferentPic;
	code = "CommonSource";
	
} SameDifferent;



# FEEDBACK
# Positive feedback;
trial {
	monitor_sounds = false;
	all_responses = false;
	trial_duration = $Feedback_Duration;
	
	picture PicturePositiveFeedback;
	
	code = "PositiveFeeback";
} PositiveFeedback;

# Negative feedback;
trial {
	monitor_sounds = false;
	all_responses = false;
	trial_duration = $Feedback_Duration;
	
	picture PictureNegativeFeedback;
	
	code = "NegativeFeeback";
} NegativeFeedback;



##CONFIRMATION AT START
trial {
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 5;   
	
	picture {
		text {
			caption = "Press ENTER to start.";
		}ConfirmationTxt;
		x = 0; y = 0;
	};
} Confirmation;




##BREAK
trial {
	monitor_sounds = false;
	all_responses = true;
   trial_duration = forever;
   trial_type = specific_response;
   terminator_button = 5;   
	
	stimulus_event {
	picture {
		text {
			caption = "Take a break!\n\n\nPress ENTER to start the fun again.";
		};
		x = 0; y = 0;
	} ;

	code = "BREAK";
	} BreakEvent;
} Break;



# FIXATIONS
# Post Stim Fixation
trial {
	monitor_sounds = false;
	all_responses = true;

	picture PictureBlueFixationCross;
	time = 0;
	duration = $Post_Stimulus_Duration;
	code = "PostStim_Fixation";
	
} PostStim_Fixation;

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