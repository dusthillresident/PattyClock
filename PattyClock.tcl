#!/usr/bin/tclsh

# ...........
# .. CLÖCK ..
# ...........

package require Tk
tk appname PattyClock

# Obtain the default foreground and background colours so that the colours of the clock match the system defined colour scheme.
button .b
set bg_col [lindex [lindex [.b configure] 3] end]
set fg_col [lindex [lindex [.b configure] 15] end]
destroy .b

# Create the clock window icon picture.
image create photo clock_icon -data {iVBORw0KGgoAAAANSUhEUgAAABEAAAARCAYAAAA7bUf6AAAABHNCSVQICAgIfAhkiAAAAKdJREFUOE+tk1sSgCAIRaVp/1s2H6AXJMmZ+lIeBy5kSj98tGFkx+fGe8aWnHNnEJE6M1jl3aZayfUa6FEArkEDhMQtwEqrHQrosk5752BrVneBHHVRCSytaQ872bbATpnJmKYdLMrBjQG8T6d3t24F1+t1JMN9lRMBEOqu+AsgXLGdiycFbSinwNdXsLGNYPvbV5B6O0r7LKKqraVn1roueC+RxGP/A2qMPB+WbRS5AAAAAElFTkSuQmCC}
wm iconphoto . clock_icon

# Create a text label at the bottom of the window. We will use this to display the date and time in text/digital form.
pack [label .clock_text_string -text "Clock"] -fill x -side bottom
# Create the canvas and make it fill the rest of the area of the window.
pack [canvas .clock_face -background $bg_col] -fill both -expand 1

# .....................
# .. draw_clock_hand ..
# .....................
# Procedure for drawing clock hands, this is used by 'update_clock'.
#  'length' is a value between 0.0 and 1.0 specifying how long the clock hand is,
#  'thickness' specifies the thickness of the line used to draw the clock hand, 
#  'turn_amount' is a value between 0.0 and 1.0 specifying how much we're turning the clock hand, from around 1 o'clock to around 12 o'clock
proc draw_clock_hand {length thickness turn_amount} {
 global fg_col bg_col
 upvar 1 wh wh cx cx cy cy
 set angle [expr {$turn_amount * 2 * 3.1415926535897931  -  3.1415926535897931 * 0.5}]
 .clock_face create line $cx $cy [expr {$cx+cos($angle)*$wh*$length*0.5}] [expr {$cy+sin($angle)*$wh*$length*0.5}] -fill $fg_col -width $thickness
}

# ..................
# .. update_clock ..
# ..................
# This procedure wipes the .clock_face canvas blank and then redraws the clock based on the current time.
proc update_clock {} { 
 global fg_col bg_col
 # Prepare some local variables
 set canv_w [winfo width .clock_face] ;# canv_w,canv_h = the width and height of the canvas
 set canv_h [winfo height .clock_face]
 set cx [expr {$canv_w*0.5}] ;# cx,cy = the point in the centre of the canvas
 set cy [expr {$canv_h*0.5}]
 set wh [expr {$canv_w<$canv_h ? $canv_w : $canv_h}] ;# wh = the width and height of the clock face itself, it is the minimum value of the canvas width and height.
 set radius [expr {$wh*0.5-5}] ;# the clock outline's radius
 # Calculate the hand position values based on the current time
 set timenow [expr {[clock seconds] % (60*60*12)}]
 set hournow   [expr {($timenow+60*60) / (60*60*12.0)}]
 set minutenow [expr {$timenow % (60*60) / (60.0*60.0)}]
 set secondnow [expr {($timenow+1) % 60 / 60.0}]
 # Clear the 'clock_face' canvas so we can redraw the clock from scratch
 foreach itm [.clock_face find all] {
  .clock_face delete $itm
 }
 # Draw the outline of the clock
 .clock_face create oval [expr {$cx-$radius}] [expr {$cy-$radius}] [expr {$cx+$radius}] [expr {$cy+$radius}] -outline $fg_col -width 5
 # Draw the visual aid markers around the edge of the clock
 for {set i 0} {$i < 12} {incr i} {
  set a [expr {3.1415926535897931 * 2 / 12 * $i}]
  set x [expr {$cx+$radius*0.95*sin($a)}]
  set y [expr {$cy+$radius*0.95*cos($a)}]
  set r [expr {$radius*0.03}]
  .clock_face create oval [expr {$x-$r}] [expr {$y-$r}] [expr {$x+$r}] [expr {$y+$r}] -outline $fg_col -fill $fg_col
 }
 # Draw the hours hand of the clock
 draw_clock_hand 0.5  5 $hournow
 # and the minutes hand
 draw_clock_hand 0.76 5 $minutenow
 # and finally the seconds hand
 draw_clock_hand 0.86 1 $secondnow
 # Update the text string representation of the time
 .clock_text_string configure -text [clock format [clock seconds]]
}

# Bind to 'Configure' events so that 'update_clock' is immediately called to correctly redraw the display whenever the window size changes.
bind . <Configure> {
 update_clock
}

# .............
# .. updater ..
# .............
# This procedure calls 'update_clock' to update the clock display, and then recursively schedules itself to run again one second later before returning.
# So it'll run every second and keep the clock display updated.
proc updater {} {
 update_clock
 after 1000 updater
}
updater

wm geometry . 256x280