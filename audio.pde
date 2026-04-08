class Audio {
  
  int cols = 20; 
  int rows = 20;  
  Dot[][] dots;
  float scale = 2.5;
  float maxDepth = 50;
  
  Audio() {
    dots = new Dot[cols][rows];
    
    float spacingX = 300.0/(cols-1);
    float spacingY = 300.0/(rows-1);
    
    for (int i = 0; i < cols; i++) 
    {
      for (int j = 0; j < rows; j++)
      {
        dots[i][j] = new Dot(
          i * spacingX - 150,
          j * spacingY - 150,  
          3                   
        );
      }
    }
  }
  
  void update(AudioPlayer player) 
  {
    if (player != null && player.mix != null) 
    {
      float overallAmp = player.mix.level() * scale * 50;
      
      for (int i = 0; i < cols; i++) 
      {
        for (int j = 0; j < rows; j++) 
        {
          float distNorm = dist(i, j, cols/2, rows/2) / (cols/2);
          
          float wave = (1 - distNorm) * overallAmp;
          
          float noiseFactor = noise(i*0.1, j*0.1, frameCount*0.05) * 10;
          
          dots[i][j].update(wave + noiseFactor);
        }
      }
    }
  }
  
  //waveform
  void display() 
  {
    pushMatrix();
      translate(0, 0, 0);
      fill(255);
      noStroke();
      rect(0, 0, 310, 310);

      for (int i = 0; i < cols; i++) 
      {
        for (int j = 0; j < rows; j++)
        {
          dots[i][j].display(maxDepth);
        }
      }
      
    popMatrix();
  }
  
  void stopAll(int currentTrack) 
  {
    for (int i = 0; i < totalSongs; i++) 
    {
      if (i != currentTrack && sound[i].isPlaying())
      {
        sound[i].pause();
        sound[i].rewind();
      }
      }
   }
    
  void songTime(int time, int duration)
  {
      int timeMinutes = time/60000;
      int timeSeconds = (time %60000) / 1000;
      String timeDisplay = nf(timeMinutes, 1) + ":" + nf(timeSeconds, 2);
      
      int durationMinutes = duration/60000;
      int durationSeconds = (duration %60000) /1000;
      String durationDisplay = nf(durationMinutes, 1) + ":" + nf(durationSeconds, 2);
     
      fill(0);
      rect(0, 275, 300, 1);
      text(timeDisplay, -130, 250);
      text(durationDisplay, 130, 250);
      
      SongXPos = map(time, 0, duration, -150, 150); 
      fill(253, 225, 0);
      translate(SongXPos, 275, 0);
      sphere(10);
  }
}

class Dot
{
  float x, y, baseSize, currentSize, zOffset;
  color dotColor;
  float hueShift;
  
  Dot(float x, float y, float size)
  {
    this.x = x;
    this.y = y;
    this.baseSize = size;
    this.currentSize = size;
    this.zOffset = 0;
    this.dotColor = color(253, 225, 0); // Yellow
  }
  
  void update(float audioInput) 
  {

    currentSize = lerp(currentSize, baseSize + audioInput * 0.5, 0.1);
    zOffset = lerp(zOffset, min(audioInput, 1) * 5, 0.1); 

    hueShift += 0.5; 
    
    if (hueShift > 255) hueShift = 0;
    {
      color baseColor = color(hueShift, 255, 255);
      color reactiveColor = lerpColor(color(253, 225, 0), color(255, 0, 0), constrain(audioInput/50.0, 0, 0.3));
      dotColor = lerpColor(baseColor, reactiveColor, 0.5); 
      colorMode(RGB, 255); 
    }
  }
  
  void display(float maxZ) 
  {
    pushMatrix();
      float constrainedZ = constrain(zOffset, -maxZ, maxZ);
      translate(x, y, constrainedZ);
      
      fill(dotColor);
     
      noStroke();
      ellipse(0, 0, currentSize, currentSize);
   
    popMatrix();
  }
  
}
