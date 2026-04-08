class Stats 
{

  color[] colors = {
    color(0, 100, 200),  // Danceability 
    color(0, 180, 120),   // Valence 
    color(255, 90, 90),   // Energy 
    color(120, 50, 220),   // Acousticness 
    color(255, 180, 0)    // Liveness 
  };

  void display(int[] metrics) 
  {
    
    pushMatrix();
      translate(0, 75, 0);
  
      float radius = 30;
      float spacing = 100;
      
      for (int i = 0; i < 5; i++) 
      {
        pushMatrix();
          strokeWeight(10);   
          translate(0, (i-2) * spacing);
          drawMeter(radius, metrics[i], colors[i], i);
        popMatrix();
      }
      
    popMatrix();
  }
  
  
  void displayTop(String k, String m)
  {
    textSize(30);
    text("The key signature is:", 0, -20);
    text(k + " " + m, 0, 20);
  }

  void displayBottom(int d, int m, int y)
  {
    text("Release date:", 0, -20);
    text(d + "/" + m  + "/" + y, 0, 20);
  }
  
  void displayRight(int bpm)
  {
    fill(0);
    text(bpm + " Beats Per Minute", 0, 0);
  }
  
  void displayLeft(AudioPlayer song)
  {
    ellipseMode(CENTER);
    float audioLevel = song.getGain();
    int decibels = int(map(audioLevel, -80, 6, 0, 100)); 
    decibels = constrain(decibels, 0, 100);
    
    text("Volume: "  + decibels + "%", 0, 40);
    volumeLevel = int(map(decibels, 0, 100, -100, 100));
    pushMatrix();
      translate(0, 0, -2);
      fill(255, 0, 0);
      ellipse(volumeLevel, -10, 30, 30);
    popMatrix();
    fill(0);
    rect(0, -10, 200, 20);
    
    text("Press + or - to toggle volume", 0, -50);

    if(keyPressed)
    {
      if(key == '+')
      {
        song.setGain(song.getGain() + 0.5);
      }
      else if (key == '-')
      {
        song.setGain(song.getGain() - 0.5);
      }
    }
  }
  
  void drawMeter(float radius, int value, color c, int i) {
  
    float angle = map(value, 0, 100, 0, TWO_PI);
    
    noFill();
    stroke(c);
    arc(0, 0, radius * 2, radius *2, -HALF_PI, angle -HALF_PI);
    
    noStroke();
    
    fill(0);
    textSize(12);
    textAlign(CENTER, CENTER);
    text(value + "%", 0, 0);
    
    textSize(20);
    String[] labels = {"Danceability", "Valence", "Energy", "Acoustic", "Live"};
    
     text(labels[i], 0, radius + 15);
  }
}
