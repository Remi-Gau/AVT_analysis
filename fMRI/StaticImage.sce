scenario = "Static image";
scenario_type = trials;

active_buttons = 1;
button_codes = 1;


default_text_color = 255,255,255; #white text by default
default_background_color = 128,128,128; #grey background

default_text_align = align_center;
default_font = "Arial"; #Arial font by default
default_font_size = 24; 

begin;

#Compute the number of pixel per degree
$MonitorWidth = 37.0;
$ViewDist = 30.0;
$MaxFOV = 63.0;  #2.0 * 180.0 * arctan(MonitorWidth/2.0/ViewDist)/ Pi;
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

# Fixation Cross
$FixationCrossLineWidth = 2;
$FixationCrossHalfWidth = 8;
$NegativeFixationCrossHalfWidth = '-($FixationCrossHalfWidth)';

# Dots
$Dot_Size = 6.0;
$Dot_Size_Pixel = '$Dot_Size * $PPD';
$Dot_Color = $White;

# Feedback
$Feedback_Size = 1;
$Feedback_Size_Pixel = '$Feedback_Size * $PPD';
$PositiveFeedback_Color = $Green;
$NegativeFeedback_Color = $Red;



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

# Positive Feedback
ellipse_graphic {
	ellipse_width = $Feedback_Size_Pixel;
	ellipse_height = $Feedback_Size_Pixel;
	color = $PositiveFeedback_Color;
}PositiveFeedbackDot;


picture {
	ellipse_graphic Dot; 	
	x = $xpos; y = $ypos;
	
	ellipse_graphic PositiveFeedbackDot;
	x = $xpos; y = $ypos;
	
	line_graphic BlueFixationCross;
	x = $xpos; y = $ypos;
} default;


trial {
	trial_type = specific_response;
	trial_duration = forever;
	terminator_button = 1; 
	picture default;
} main_trial;

begin_pcl;

main_trial.present();