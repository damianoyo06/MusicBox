class Collective
{
    Collective()
    {
           
    }

    
    void instruction()
    {
        cam.beginHUD();
          fill(253, 225, 0, 200);
          rect(width/2, height - 150, 500, 200);
          image(ui, 50, height - 250);
        cam.endHUD();
    }
}
