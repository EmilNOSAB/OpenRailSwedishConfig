Viewset.mvba is utilized in the delivered example workspaces by using the right mouse click
and selecting View Control.  

The file:

...\Configuration\Organization-Civil\_Civil Default Standards - Imperial\Dgnlib\GUI\Custom_Menu.dgnlib

...is what provides access to this menu system.

Additionally, this variable needs set to activate in your workspace...

MS_VBAAUTOLOADPROJECTS > $(CIVIL_ORGANIZATION_STANDARDS)Macros/ViewSet

	
Notes: The viewset.mvba macro is calling the xml settings file (ViewControlConfigurations.xml) 
       that needs to reside in the same folder as the viewset.mvba file unless you use the
       config variable shown below.  The values in this xml file can be adjusted 
       but all of the names in this XML file are called by the mvba so the names of the 
       settings should not be revised.  The distances are in percentages of available screen area.  
       The upper left corner is considered the “0,0” percent location. The bottom right corner is then 
       the “100,100” percent location.
       
       If you need to put the settings file in a different location, a variable is supported
       to locate this file at any desired location.
       
       Example:
       
       VIEWSET_SETTINGS_FILE = C:/My Settings/ViewControlConfigurations.xml
       
Update: 2021 R1 Release...

Note in the bottom entries of the new ViewControlConfigurations.xml file there are now two additional optional fields

1. orientation="RIGHT"
2. rendering="WIREFRAME"

These new fields can be used to auto set the orientation and view render settings respectively.

Orientation options are:

TOP
BOTTOM
FRONT
BACK
LEFT
RIGHT
ISO
 

Rendering options are:

WIREFRAME
HIDDENLINE
SMOOTH
SOLIDFILL

for example running the keyin command:

vba run fourview2 foursquare2

...will process the module named "fourview2" using the settings from the xml file entitled "foursquare2"


Update: 2024 Release

Viewset.MVBA requires an update to function properly in the 2024 releases due to a change in how a window pointer is defined. The Viewset.MVBA delivered with the software has already been updated and can be used directly or copied to your workspace without any changes required.

If you have a customized version of Viewset.MVBA in your workspace it will need to be updated by changing the Long declarations to LongLong. See the four lines and locations that are now declared as LongLong instead of as a Long.
LINE 3: Declare PtrSafe Function mdlWindow_resize Lib "stdmdlbltin.dll" (ByVal windowP As LongLong, ByVal cornerNum As Long, ByRef newPositionP As LPoint2d) As Long
LINE 4: Declare PtrSafe Function mdlWindow_viewWindowGet Lib "stdmdlbltin.dll" (ByVal viewNum As Long) As LongLong ' Returns a pointer to a structure
LINE 5: Declare PtrSafe Function mdlWindow_contentRectGetGlobal Lib "stdmdlbltin.dll" (ByRef contentRectP As BSIRect, ByVal windowP As LongLong) As Long
LINE 23: Dim lngWindowPtr As LongLong


