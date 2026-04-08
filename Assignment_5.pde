//DISCLAIMER:
//This project has been developed and tested entrely on a Windows machine.
//If for some reason the project does not work on Mac, please test it on windows please

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import processing.sound.*;
import peasy.*;

PeasyCam cam;
AudioPlayer[] sound;
Minim minim;

int totalSongs = 64;

Audio audio;
Stats stats;
Collective collective;

float lerpValue = 0;
float SongXPos;

PFont font, artistFont;

String[] song, artist, tonality, mode;
int[] dance, valence, energy, acoustic, live, day, month, year, bpm;
 Float prevVolume = 10.0;
 int volumeLevel;


int n;
Table table;
PImage play, pause, next, previous, ui;
PGraphics spotifyInterface, sphere; 

int z;

float scrollX = 0;
boolean scrolling = false;
float scrollSpeed = 1; 
boolean movingLeft = true;

boolean playing = true;
boolean instruction = true;

void setup()
{
  
  size(600, 800, P3D); 
  cam = new PeasyCam(this, 800); 
  //Allows for the user not to zoom to close or too far out
  cam.setMinimumDistance(500);
  cam.setMaximumDistance(6000);

  buttonpg = createGraphics(600, 800, P3D);

  //Audio
  minim = new Minim(this);
  sound = new AudioPlayer[totalSongs];
  for (int i = 0; i < totalSongs; i++)
  {
    sound[i] = minim.loadFile("Assets/audio/" + i + ".mp3");
  }

  audio = new Audio();
  stats = new Stats();
  collective = new Collective();

  n = totalSongs;

  song = new String[n];
  artist = new String[n];
  dance = new int[n];
  valence = new int[n];
  energy = new int[n];
  acoustic = new int[n];
  live = new int[n];
  tonality = new String[n];
  mode = new String[n];
  day = new int[n];
  month = new int[n];
  year = new int[n];
  bpm = new int[n];

  //buttons/fonts
  play = loadImage("Assets/play.png");
  pause = loadImage("Assets/pause.png");
  next = loadImage("Assets/next.png");
  previous = loadImage("Assets/previous.png");
  ui = loadImage("Assets/UI.png");
  font = loadFont("data/Agency.vlw");
  artistFont = loadFont("data/FootlightMTLight-30.vlw");
  
  textFont(font, 40);

  rectMode(CENTER);
  textAlign(CENTER, CENTER);

  // Spotify UI
  spotifyInterface = createGraphics(400, 600, P2D);

  //table
   table = loadTable("Data.csv", "header");

  //Allows the stroke not to be broken while zooming in/out
  hint(ENABLE_STROKE_PERSPECTIVE);

}


void draw()
{

  background(0);

  // Load song and artist data
  for (int k = 0; k < n; k++)
  {
    TableRow row = table.getRow(k);
    song[k] = row.getString("track_name");
    artist[k] = row.getString("artist(s)_name");
    dance[k] = row.getInt("danceability_%");
    valence[k] = row.getInt("valence_%");
    energy[k] = row.getInt("energy_%");
    acoustic[k] = row.getInt("acousticness_%");
    live[k] = row.getInt("liveness_%");
    tonality[k] = row.getString("key");
    mode[k] = row.getString("mode");
    year[k] = row.getInt("released_year");
    month[k] = row.getInt("released_month");
    day[k] = row.getInt("released_day");
    bpm[k] = row.getInt("bpm");
  }


  //scroll the name of the song
  float textWidthSong = spotifyInterface.textWidth(song[z]);
  float boxWidth = 480;  

  if (textWidthSong > boxWidth)
  {
    scrolling = true;
  } 
  else
  {
    scrolling = false;
    scrollX = spotifyInterface.width/2; 
  }

  if (scrolling)
  {
    scrollX -= scrollSpeed;
    if (scrollX < -textWidthSong + (textWidthSong /2))
    {
      scrollX = boxWidth + (textWidthSong/2); 
    }
  }


  // Create Spotify UI and its components
  spotifyInterface.beginDraw();
    spotifyInterface.background(255);
    spotifyInterface.fill(0);
    spotifyInterface.textSize(40);
    spotifyInterface.textAlign(CENTER, CENTER);
    spotifyInterface.imageMode(CENTER);
    spotifyInterface.text(song[z], scrollX, 380);
    spotifyInterface.fill(255);
    spotifyInterface.noStroke();
    spotifyInterface.rect(0, 350, 40, 70);
    spotifyInterface.rect(360, 350, 40, 70);
    spotifyInterface.fill(0);
    if (z < totalSongs)
    {
      audio.stopAll(z);
      if (playing)
      {
        sound[z].play();
      }
    }
    spotifyInterface.textFont(artistFont);
    spotifyInterface.text(artist[z], spotifyInterface.width/2, 420);
    spotifyInterface.textFont(font);
    if (playing)
    {
      spotifyInterface.image(pause, spotifyInterface.width/2, spotifyInterface.height - 60);
    } else
    {
      spotifyInterface.image(play, spotifyInterface.width/2, spotifyInterface.height - 60);
    }
    spotifyInterface.image(next, (spotifyInterface.width/4 * 3), spotifyInterface.height - 60);
    spotifyInterface.image(previous, spotifyInterface.width/4, spotifyInterface.height - 60);
  spotifyInterface.endDraw();
  //end of Spotify UI

  // Draw box
  pushMatrix();
    translate(0, 0, 0);  
    drawRectangularCube(spotifyInterface);  
    //falsecolour
    drawButtonHitBoxes(buttonpg);
  popMatrix();
  //End of box

  //Front
  pushMatrix();
    translate(0, -100, 76);
    audio.display();
    audio.songTime(sound[z].position(), sound[z].length());
    scale(0.5, 0.5);
  popMatrix();
  //End of Front


  //Back
  pushMatrix();
    translate(0, -100, -77);
    rotate(PI);
    scale(1, -1);
    int[] currentStats = {dance[z], valence[z], energy[z], acoustic[z], live[z]};
    stats.display(currentStats);
  popMatrix();
  //End of Back
  
  //Top
  pushMatrix();
    translate(0, -301, 0); 
    rotateX(HALF_PI);
    stats.displayTop(tonality[z], mode[z]);  
  popMatrix();
  //end of Top


  //bottom
  pushMatrix();
    translate(0, 301, 0);
    rotateX(HALF_PI);
    scale(1, -1);
    stats.displayBottom(day[z], month[z], year[z]);
  popMatrix();
  //end of bottom

  //right
  pushMatrix();
    translate(201, 0, 0);
    rotateY(HALF_PI);
    rotateZ(HALF_PI);
    stats.displayRight(bpm[z]);
  popMatrix();
  //end of right
  
  //left
  pushMatrix();
    translate(-201, 0, 0);
    rotateY(HALF_PI);
    rotateZ(HALF_PI);
    scale(-1, 1);
    stats.displayLeft(sound[z]);
  popMatrix();
  //end of left
  
  //instruction
  pushMatrix();
        translate(0,0, 200);
        if(instruction)
        {
          collective.instruction();
        }
   popMatrix();
        
        
 
  //Audio waveform
  audio.update(sound[z]);

  //checks of the song is finished and rewinds it
  checkSongEnd();
  if (!sound[z].isPlaying() && playing) 
  {
    sound[z].rewind();      
    z = (z + 1) % sound.length;
    sound[z].play();          
  }
  
 // if(hud)
 // {
 //push();  //save current draw settings; just to avoid messing up other drawing functions
 //   cam.beginHUD(); //ignore camera settings so that we can draw image in 2D
 //   tint(255, 100); //make semi transparent
 //   image(buttonpg, 0, 0); //draw the falsecolour PGraphics
 //   cam.endHUD();
 //   pop();
 // }
    //END
}

//False colour
boolean hud = false;
PGraphics buttonpg;
color button1_falsecolor = color(255, 0, 0);
color button2_falsecolor = color(0, 255, 0);
color button3_falsecolor = color(0, 0, 255);
color back_falsecolor = color(123, 0, 123);
color songTime_falsecolor = color(255, 0, 255);

//void keyPressed()
//{
//  hud = !hud;
//}

//mouse interactivity for buttons
void mouseClicked()
{
  color c = buttonpg.get(mouseX, mouseY);

  if (colorDistance(button1_falsecolor, c) < 1)
  {
      leftControl();
  }
  if (colorDistance(button2_falsecolor, c) < 1)
  {
   rightControl();
  } 
  if(colorDistance(button3_falsecolor, c) < 1)
  {
    playControl();
  }
  if(colorDistance(songTime_falsecolor, c) <1)
  {
    int newTime = int(map(mouseX, 150, 450, 0, sound[z].length()));
   
     sound[z].cue(newTime);
  }
 
}

float colorDistance(color c1, color c2)
{
  return dist(red(c1), green(c1), blue(c1), red(c2), green(c2), blue(c2));
}

void drawButtonHitBoxes(PGraphics pg2)
{
  PMatrix3D original = (PMatrix3D) g.getMatrix();  //get the current camera rotation matrix
  
  pg2.beginDraw();
  
    pg2.background(0);
    pg2.resetMatrix();
    pg2.applyMatrix(original); //camera settings of the Real Scene in the Falsecolor Scene
    pg2.noStroke();
    
  
    pg2.translate(0, 0, 0);
  
    pg2.fill(50);
    pg2.box(400, 600, 140);
    
    //button 2 hit box
    pg2.translate(100, 240, 76); 
    pg2.fill(button2_falsecolor);
    pg2.circle(0, 0, 60);
    
    pg2.translate(-200, 0, 0);
    pg2.fill(button1_falsecolor);
    pg2.circle(0, 0, 60);
    
    //button 3
    pg2.translate(100, 0, 0);
    pg2.fill(button3_falsecolor);
    pg2.circle(0, 0, 100);
    
    //button 4
    pg2.translate(0, -70, 0);
    pg2.fill(songTime_falsecolor);
    pg2.rect(-150, 0, 300, 10);

  pg2.endDraw();
}
//END OF ADDED


// Spotify UI
void drawRectangularCube(PGraphics texture)
{
  float w = 400;  
  float h = 600; 
  float d = 150;

  // Front
  beginShape();
    texture(texture);
    vertex(-w/2, -h/2, d/2, 0, 0);
    vertex(w/2, -h/2, d/2, texture.width, 0);
    vertex(w/2, h/2, d/2, texture.width, texture.height);
    vertex(-w/2, h/2, d/2, 0, texture.height);
  endShape(CLOSE);

  // Back
  fill(255);
  beginShape();
    vertex(-w/2, -h/2, -d/2);
    vertex(w/2, -h/2, -d/2);
    vertex(w/2, h/2, -d/2);
    vertex(-w/2, h/2, -d/2);
  endShape(CLOSE);

  // Left
  fill(255);
  beginShape();
    vertex(-w/2, -h/2, -d/2);
    vertex(-w/2, -h/2, d/2);
    vertex(-w/2, h/2, d/2);
    vertex(-w/2, h/2, -d/2);
  endShape(CLOSE);

  // Right
  fill(255);
  beginShape();
    vertex(w/2, -h/2, -d/2);
    vertex(w/2, -h/2, d/2);
    vertex(w/2, h/2, d/2);
    vertex(w/2, h/2, -d/2);
  endShape(CLOSE);

  // Top
  fill(255);
  beginShape();
    vertex(-w/2, -h/2, -d/2);
    vertex(w/2, -h/2, -d/2);
    vertex(w/2, -h/2, d/2);
    vertex(-w/2, -h/2, d/2);
  endShape(CLOSE);

  // Bottom
  fill(255);
  beginShape();
    vertex(-w/2, h/2, -d/2);
    vertex(w/2, h/2, -d/2);
    vertex(w/2, h/2, d/2);
    vertex(-w/2, h/2, d/2);
  endShape(CLOSE);
}

void keyReleased()
{
  //volume and audio Control
  prevVolume = sound[z].getGain(); 
   char lowerKey = Character.toLowerCase(key);
  if(keyCode == '+' || keyCode == '-')
  {
    prevVolume = sound[z].getGain();
  }
  if (keyCode == LEFT)
  {
    leftControl();
  }
  if (keyCode == RIGHT)
  {
    rightControl();
  }
  if (key == ' ')
  {
    playControl();
  }

  if (lowerKey == 'r')
  {
    z = int(random(0, totalSongs-1));
  }
  if (lowerKey == 'i')
  {
    instruction = !instruction;
  }
  
  sound[z].setGain(prevVolume);
}

void playControl()
{
 if (playing)
    {
      sound[z].pause();
    } else
    {
      sound[z].play();
    }
    playing = !playing;
}

void rightControl()
{
    if (z == totalSongs -1)
    {
      z = 0;
    } else
    {
      z += 1;
    }
}

void leftControl()
{
  if (z==0)
    {
      z = n;
    }
    z -= 1;
}

void checkSongEnd()
{
  if (!sound[z].isPlaying() && playing) 
  {
    prevVolume = sound[z].getGain(); 
    sound[z].rewind();      
    z = (z + 1) % totalSongs;
   
    sound[z].play();          
    sound[z].setGain(prevVolume); 
  }
}

 
