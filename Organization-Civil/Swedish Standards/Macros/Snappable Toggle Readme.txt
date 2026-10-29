Snappable Toggle.mvba uses Crtl+F1 and Crtl+F2 function keys.  
With this file is a second file (SnappableToggle_Levels.txt) that is user customizable.  
This MVBA will turn on or off the specified levels like a toggle as well as 
enable or disable the snappability of the particular elements.  
This is useful when annotating the drawing models of cross sections or profiles 
where the grid lines may be in the way.

SnappableToggle.mvba (imperial and Metric are the same file)
SnappableToggle_Levels.txt (imperial and Metric are the same file)
function_keys_seed.mnu (imperial and Metric are the same file)

The Snappable Toggle MVBA has been enhanced to allow the configuration variable:

CIVIL_SNAPPABLETOGGLE_LEVELS_FILE 

...to be set to define the location and name of the SnappableToggle_Levels.txt file. 
The variable definition must include the file name. 
The variable is optional, if it is not included in the workspace, or if it points to a missing file, 
the SnappableToggle_Levels.txt in the same location as the MVBA will be used.
