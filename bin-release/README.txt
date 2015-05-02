 /$$$$$$$  /$$$$$$ /$$$$$$$$        /$$$$$$  /$$      /$$  /$$$$$$   /$$$$$$  /$$   /$$ /$$$$$$$$ /$$$$$$$ 
| $$__  $$|_  $$_/|__  $$__/       /$$__  $$| $$$    /$$$ /$$__  $$ /$$__  $$| $$  | $$| $$_____/| $$__  $$
| $$  \ $$  | $$     | $$         | $$  \__/| $$$$  /$$$$| $$  \ $$| $$  \__/| $$  | $$| $$      | $$  \ $$
| $$$$$$$   | $$     | $$         |  $$$$$$ | $$ $$/$$ $$| $$$$$$$$|  $$$$$$ | $$$$$$$$| $$$$$   | $$$$$$$/
| $$__  $$  | $$     | $$          \____  $$| $$  $$$| $$| $$__  $$ \____  $$| $$__  $$| $$__/   | $$__  $$
| $$  \ $$  | $$     | $$          /$$  \ $$| $$\  $ | $$| $$  | $$ /$$  \ $$| $$  | $$| $$      | $$  \ $$
| $$$$$$$/ /$$$$$$   | $$         |  $$$$$$/| $$ \/  | $$| $$  | $$|  $$$$$$/| $$  | $$| $$$$$$$$| $$  | $$
|_______/ |______/   |__/          \______/ |__/     |__/|__/  |__/ \______/ |__/  |__/|________/|__/  |__/


/*========================================================================================
				RETENTION EDITOR v0.5.2
========================================================================================*/
Updated: Thu May 22 13:18:02 Central Daylight Time 2014

=====================
HOW TO USE:
=====================
	- Select the stage when the app runs
	- Open all image files from the same directory that you want to be placed in the editor, or choose an existing level to load
		- if you choose an existing level, you will have to select teh stage again to open all the image files
		
	- Adjust the level width and level height accordingly on the settings panel to the right (editor will resize to fit the screen in this version, next version I will have a zoom feature)
	- Select a layer from the settings panel (background, midground, or foreground)
	- You can optionally choose which layers are visible while editing

       *=============================================================================================================*
       *Controls/Instructions/Hotkeys
       *=============================================================================================================*
		- Select a tile from your palette, click somewhere in the grid to place it
		- After a tile is placed you can move it 1 pixel at a time in the x/y direction using the arrow keys
		- Hold SHIFT to move 10 pixels at a time
		- Hold CONTROL + LEFT MOUSE down to create collision objects
		- CONTROL + Z to undo (you can undo placed tiles, and placed collisions only currently)
		- MOUSE WHEEL for zooming in and out
		- Hold SPACE and LEFT MOUSE down to drag and move the level around
		- Hold SHIFT when placing down a tile to queue a duplicate
		- Press ESCAPE when a tile is selected if you want to remove it from your cursor
	===============================================================================================================
	
	===============================================================================================================

	- When you are finished hit Save, a file will be exported of type rmf (retention map format, basically a text file with byte code)
	- We will need that file for the game to run (Next version of the overworld will have this being parsed, I'll deploy a version of that so you can see the live version)
	- Select a tile that was placed at any time to adjust it
	- Also when you select a tile, a properties menu will appear for the tile
	- You can select a collision object to give it a property type of "wall" or "floor" --> I'll add in more options as needed
	
=====================	
Bugs:
=====================
	- Should any bugs appear email me - bennett.yeates@gmail.com
