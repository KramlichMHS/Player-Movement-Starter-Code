/// @description Core Player Lgoic

//Get player inputs

key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
key_jump = keyboard_check_pressed(vk_space);
key_slide = keyboard_check_pressed(vk_control);

//Calc movoment horiz
walljumpdelay = max(walljumpdelay-1,0);
slidedelay = max(slidedelay-1,0);
slideresetdelay = max(slideresetdelay-1,0);


//disable movement for slide and wall jump
if (walljumpdelay == 0 && slidedelay == 0 && !slidestuck) {
	var _move = key_right - key_left;
} else {
	var _move = 0;
}

//set and reset slide collision
if (slidedelay > 0){
	mask_index = spr_player_slide;
} else {
	if (mask_index == spr_player_slide) {
		mask_index = spr_player;
		slidestuck = false;
		if (place_meeting(x, bbox_top, obj_wall)) {
			mask_index = spr_player_slide;
			slidedelay += 1;
			slidestuck = true;
		}
	}
}

//calc friction
hsp += _move * walksp;
if(_move == 0 && slidedelay == 0) { //normal friction with ground and air
	var hsp_fric_final = hsp_fric_ground;
	if (!on_ground) hsp_fric_final = hsp_fric_air;
	
	if (hsp < 0) {
		hsp += hsp_fric_final;
	}
	if (hsp > 0) {
		hsp -= hsp_fric_final;
	}
	if (hsp_fric_final >= abs(hsp)) {
		hsp = 0;
	}
} else if (slidedelay > 0) { //slide friction set
	var hsp_fric_final = hsp_fric_slide;
	if (hsp < 0) {
		hsp += hsp_fric_final;
	}
	if (hsp > 0) {
		hsp -= hsp_fric_final;
	}
	if (abs(hsp) < slidestuck_spd) {
		hsp = -slidestuck_spd;
		if (going_right) hsp = slidestuck_spd;
	}
}
hsp = clamp(hsp, -max_walksp, max_walksp);

//slide
if (on_ground && !on_wall && key_slide && slideresetdelay == 0) {
	slideresetdelay = slideresetdelay_max;
	slidedelay = slidedelay_max;
}

//stops upward wall momentum
if ((key_left != 0 || key_right != 0) && on_wall != 0 && !on_ground && vsp < 0) {
	vsp = 0;
}

//wall jump
if (on_wall != 0) && (!on_ground) && (key_jump) && (key_left != 0 || key_right != 0) {
	walljumpdelay = walljumpdelay_max;
	hsp = -on_wall * hsp_wjump;
	vsp = vsp_wjump;
}

//Calc movoment vertical
var grv_final = grv;
if (on_wall != 0) && (vsp > 0) && (key_left != 0 || key_right != 0) {
	grv_final = grv_wall;
}
vsp += grv_final;

if (on_ground) {
	currjumps = 0;
}

if key_jump && (currjumps < maxjumps) {
	vsp = -jumpsp;
	currjumps += 1;
	slidedelay = 0;
}

//Horizontal collision
if (place_meeting(x + hsp, y, obj_wall)) {
	while (!place_meeting(x + sign(hsp), y, obj_wall)) {
		x += sign(hsp);
	}
	hsp = 0;
}
x += hsp;

//Vertical collision
if (place_meeting(x, y + vsp, obj_wall)) {
	while (!place_meeting(x, y + sign(vsp), obj_wall)) {
		y += sign(vsp);
	}
	vsp = 0;
}

vsp = clamp(vsp, -12, 20);
y += vsp;

//Calculate current status
on_ground = place_meeting(x, y + 1, obj_wall);
on_wall = place_meeting(x + 1, y, obj_wall) - place_meeting(x - 1, y, obj_wall);
going_right = hsp > 0;

//Animation
if (slidedelay > 0 || slidestuck) {
	sprite_index = spr_player_slide;
}
else if (on_wall != 0 && !on_ground && (key_left != 0 || key_right != 0)) {
	sprite_index = spr_player_wall;
	image_index = 0;
	image_speed = 0;
} else if (!place_meeting(x, y + 1, obj_wall)) {
	sprite_index = spr_player_jump;
	image_speed = 0;
	if (vsp > 0) {
		image_index = 2;
	} else if (vsp == 0) {
		image_index = 1;	
	} else {
		image_index = 0;
	}
} else {
	image_speed = 1;
	if (hsp == 0) {
		sprite_index = spr_player;
	} else {
		sprite_index = spr_player_run;
	}
}

if(hsp != 0) {
	image_xscale = sign(hsp);
}

//debug area
