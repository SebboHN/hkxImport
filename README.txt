## Installation

Move corresponding .dlu located in correct version folder into ***%3ds max installation directory%/stdplugs***. \ (e.g. \Program Files\Autodesk\3ds Max 20xx\stdplugs)
Versions must match!\
Additionally plugin will require **Visual C++ Redistributable for Visual Studio 2017** to be installed in order to work.

Open the F4BipedCAT_2013.max file
Drag and Drop (or use the import menu) an Animation HKX file into the 3dsMax view. 
Run the Script HKXImport.mse via Drag and Drop into the view screen or via MAXScript menu. 

Optional: Create a button for the script in "Customize User Interface" Menu and place the script file into the
\Program Files\Autodesk\3ds Max 20xx\scripts\Startup folder
https://www.augi.com/articles/detail/customize-3ds-max-with-script-buttons



## Troubleshooting:

If the animation has an inverted Z-Axies you have to import an hkx once manually. (Top Left 3dsMax Symbol Button)
Uncheck the "Invert Top" option in the Importer Window and import the file. Leave the Rest as is.
The settings will be saved for the next drag and drop.


## .dlu file info
This plugin is available under GPL v3 license. (See LICENSE.md)

This plugin uses following libraries:

* HavokLib, Copyright (c) 2016-2020 Lukas Cone
### [Latest Release](https://github.com/PredatorCZ/HavokMax/releases/)
