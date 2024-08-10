# 2048 project

**2048** is a famous single player puzzle game. Its objective is to move some tiles on a grid up, down, left and right so that equal tiles merge to obtain a tile of value 2048. Its concept is simple, but the game isn't so easy as it seems.
Originally, the game is implemented only on a 4x4 table, but we decided to leave the player to choose between three different sizes (4x4, 5x5, 6x6) to try new strategies and have more fun!
## How to play
- In the main menu, choose your preferred grid size and click "Start!".
- When the game starts, you can use the arrow keys or WASD to move and merge your tiles to merge equal numbers and reach 2048.
- You win if you reach 2048, you lose if your grid is full and you can't move your tiles anymore.

 > **N.B.** You can also find the rules and the key bindings in the `Help > About` section of the main menu.
## Project Structure
- `BestScore.java`: this class saves the highest score you've obtained playing the game;
- `GameController.java`: this is the most important class of the project. On its inside, you can find methods that:
	- initialize the game itself;
	- update the grid (add tiles at the grid, changes color based on the value of the grid etc.);
	- control and implement your moves;
	- control win and lose condition;
	- updates your best score.
- `MainApplication.java`: starts your 2048 app and lets you play;
- `MenuController.java`: manages the main menu of the application;
- `Tile.java`: represents the elements in the game grid.
## Reference
[Original 2048 game](https://play2048.co/)
## People:
People involved in this project:
- [Angelo Chiacchio](https://github.com/DkAngelo)
- [Marianna Mileo](https://github.com/merymylo) 