Read me!
For the script to work make sure you have all the necessary prerequisite:

- Havok Content Tools 
- Havok 3ds Max Plugin (https://github.com/PredatorCZ/HavokMax/releases) 
- NIF_Exporter (for 3ds Max 2013 provided by Beth in \Fallout 4\Tools\NIF_Exporter folder. (For newer 3ds Max versions search on nexusmods) 
  (If you install the NIF_Exporter for the first time make sure to config 3dsMax Max:
    Select the 'Customize' -> 'Configure User Paths' menu options.
	Under 'External Files' tab, you need to add the new directory "C:\Program Files\Autodesk\3ds Max 2013\plugins\BGS\Shaders\", or equivalent.)
- Optional: For the annotation feature to work a installed Java JRE is needed (https://www.java.com/en/).

Installation: 
- Close 3ds Max
- Use the 3dsMaxPlugin files included or download the latest release. ( https://github.com/PredatorCZ/HavokMax/releases )
- Copy the file for your 3dsMax version into the following folder: InstallPath\Autodesk\3ds Max 20xx\plugins
- Copy the hkxreano.exe and hkxpack-cli.jar into the same folder as your HKXImport.ms file. Those three files must always stay together. You can place them where ever you want, but they need to be together.
  
  If you create a button in 3dsMax for this script, be aware that you have to place the .exe & .jar into that Max folder.
  (e.g. C:\Users\<user>\AppData\Local\Autodesk\3dsMax\2013 - 64bit\ENU\usermacros\)
  
Usage:
Video: https://youtu.be/htTYy2-CwZE

- Open the max file included with this script: F4BipedCAT_2013.max. 
- Run the script via MAXScript menu or via drag and drop into the view screen. 
- Select the source race. 
- Import a *.hkx via MaxMenu, Script Button or Drag and Drop (into the script window, not the 3dsMax View)
- Make sure „Invert Top" is unchecked in the import menu.(The import menu only shows up if you import manualy, not drag and drop). 
- Press run on the script. 
- Save the max file with a new filename and start editing. 
- If an animation is already loaded or there is an error and you want to try another one, press the reset button before and set the source race. 

To-Do List:
- Overall stability
- Making the annotation list editable.
- Append more than one animation to the scene 

 Created by Sebbo 

 Used librarys: https://github.com/Dexesttp/hkxpack
 Used plugin: https://github.com/PredatorCZ/HavokMax