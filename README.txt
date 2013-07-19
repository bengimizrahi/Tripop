    Links to Check out:

1) http://gamesfromwithin.com/break-that-thumb-for-best-iphone-performance
2) [Add ttf 2 fnt jnlp link here]

-----------o-------------o-------------o------------o----------

    Near TO-DO List:

1) Power bar duzeltilecek.
 - Asagidaki gibi.
 - Color ball eklenecek
 - Makas eklenecek
6) Add HelpScene()
7) Add Sound Effects.
10) RELEASE THE GAMEEEE!... :)

-----------o-------------o-------------o------------o----------

Questions:
1) Do we really need GameModel.hexagrids?

-----------o-------------o-------------o------------o----------

    Tuning the Game for Better Playability TO-DO List:

1) Rotate the PowerActions slower to recognize the sprites.

-----------o-------------o-------------o------------o----------

    Next Update TO-DO List:

1) Modify Power Bar:
  +------------------------------------------------+
  |  A    B     C     D      E      F     G      H |
  +------------------------------------------------+
2) Use Move action in Dynamite, too.
3) Mixed colored balls
    3.1) Seperation of Ball Type and Ball Color
        3.1.1) Remove BallType, use inheritance for Ball type
        3.1.2) Use bits for colors (not enums)
    3.2) Joker Ball Power Action (simply all color bits are ON)
4) Connect-2, Connect-3, Connect-4, etc. (for making the game more difficult)
5) Use Facebook Connect & CocosLive for submitting hi-scores.
    5.1) Highest Score: 23435
                    By: rager
                 Since: 3 days

          Your Ranking: 3233rd place (12%)

               Changes: 3 places down
                 Since: 2 days

          Totally 23444 players submitted

6) Color-Clear Power Action
    6.1) Animate blinking
7) Atom-Bomb Power Action
8) Sound-Bomb Power Action
    8.1) You may need to seperate Ball.position and Sprite.position, this way collision detector will use Ball.position while Actions use Sprite.position for animations.
9) Detacher Power Action
10) Ring-Laser Power Action
11) Add Music (maybe Lotus 2 Challange, with dancing Menu Items. :) )
12) TRIPOP text made by balls in the MainMenu background.

-----------o-------------o-------------o------------o----------

    Deliberately Ignored TO-DO List:

1) Use the fastest texture format. (Consider using a TextureManager)
2) Try using CADisplayLink Director. (Also check out FastDirector)
3) Use this to shake the core/screen, when it is full power for instance:
    [self actionWithRange:5 shakeZ:YES grid:ccg(15, 10) duration:t
4) Use a Ball or sprite pool for reuse.
5) Use ccArray instead of NS[Mutable]Array.
