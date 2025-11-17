import oscP5.*;
import netP5.*;

Table table;
int currentIndex = 0;
int lastIndex = -1;
float sliderX;
boolean dragging = false;

int btnW = 120;
int btnH = 40;
int btnY;
int btnStartX;

OscP5 oscP5;
NetAddress dest;

float pdValue = 0;
float pdSliderX = 100;

void setup() {
  size(900, 600);

  table = loadTable("spotify.csv", "header");
  table.sort("playlist_genre");

  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6000);

  sliderX = 100;

  btnY = height - 60;
  btnStartX = (width - (btnW * 3)) / 2;

  textFont(createFont("Arial", 16));
}

void draw() {
  background(15);
  fill(255);

  textAlign(CENTER);
  textSize(22);
  text("Spotify Dataset Visualizer", width/2, 40);

  drawSlider();
  drawButtons();

  int total = table.getRowCount();
  currentIndex = int(map(sliderX, 100, width - 100, 0, total - 1));
  currentIndex = constrain(currentIndex, 0, total - 1);

  TableRow row = table.getRow(currentIndex);
  showSong(row);
}

void drawSlider() {
  stroke(200);
  line(100, height-80, width-100, height-80);

  fill(255, 150, 0);
  noStroke();
  ellipse(sliderX, height-80, 20, 20);
}

void drawButtons() {
  textAlign(CENTER);
  textSize(16);

  fill(50, 180, 50);
  rect(btnStartX, btnY, btnW, btnH, 8);
  fill(255);
  text("PLAY", btnStartX + btnW/2, btnY + 26);

  fill(200, 180, 50);
  rect(btnStartX + btnW, btnY, btnW, btnH, 8);
  fill(15);
  text("PAUSE", btnStartX + btnW + btnW/2, btnY + 26);

  fill(200, 60, 60);
  rect(btnStartX + btnW*2, btnY, btnW, btnH, 8);
  fill(255);
  text("RESET", btnStartX + btnW*2 + btnW/2, btnY + 26);
}

void showSong(TableRow row) {
  textAlign(LEFT);
  textSize(16);

  String track = row.getString("track_name");
  String artist = row.getString("track_artist");
  String album = row.getString("track_album_name");
  String genre = row.getString("playlist_genre");
  String release = row.getString("track_album_release_date");

  float energy = row.getFloat("energy");
  float valence = row.getFloat("valence");
  float dance = row.getFloat("danceability");
  float tempo = row.getFloat("tempo");
  float loud = row.getFloat("loudness");

  fill(255);
  text("Genre: " + genre, 80, 150);
  text("Track: " + track, 80, 180);
  text("Artist: " + artist, 80, 210);
  text("Album: " + album, 80, 240);
  text("Release: " + release, 80, 270);

  int barX = 80;
  int barY = 310;
  drawBar(barX, barY, valence, "Valence");
  drawBar(barX, barY+30, dance, "Danceability");
  drawBar(barX, barY+60, (loud+60)/60.0, "Loudness");
  drawBar(barX, barY+90, energy, "Energy");
  drawBar(barX, barY+120, tempo/200.0, "Tempo");
}

void drawBar(int x, int y, float value, String label) {
  int w = 300;
  int h = 15;

  value = constrain(value, 0, 1);

  fill(80);
  rect(x, y, w, h);

  fill(100, 200, 255);
  rect(x, y, w * value, h);

  fill(255);
  textSize(14);
  text(label + ": " + nf(value, 1, 2), x+w+20, y+h-2);
}

void sendToggle(String address) {
  OscMessage msg1 = new OscMessage(address);
  msg1.add(1);
  oscP5.send(msg1, dest);

  delay(60);

  OscMessage msg0 = new OscMessage(address);
  msg0.add(0);
  oscP5.send(msg0, dest);

  println("OSC toggle sent: " + address);
}

void sendDataOSC(TableRow row) {
  String[] columns = {
    "playlist_genre",
    "valence",
    "danceability",
    "loudness",
    "energy",
    "tempo"
  };

  for (int i = 0; i < columns.length; i++) {
    String col = columns[i];

    if (col.equals("playlist_genre")) {
      OscMessage msg = new OscMessage("/" + col);
      msg.add("samples/" + row.getString(col) + ".wav");
      oscP5.send(msg, dest);
    } else {
      float value = row.getFloat(col);

      if (col.equals("loudness")) value = (value + 60)/60.0;
      if (col.equals("tempo")) value = value/200.0;

      OscMessage msg = new OscMessage("/" + col);
      msg.add(value);
      oscP5.send(msg, dest);
    }
  }
}

void mousePressed() {
  if (mouseX > btnStartX && mouseX < btnStartX + btnW &&
      mouseY > btnY && mouseY < btnY + btnH) {
    sendToggle("/play");

    int total = table.getRowCount();
    int forcedIndex = int(map(sliderX, 100, width - 100, 0, total - 1));
    forcedIndex = constrain(forcedIndex, 0, total - 1);

    sendDataOSC(table.getRow(forcedIndex));
    lastIndex = forcedIndex;

    println("Sending OSC data from PLAY for index: " + forcedIndex);
    return;
  }

  if (mouseX > btnStartX + btnW && mouseX < btnStartX + btnW*2 &&
      mouseY > btnY && mouseY < btnY + btnH) {
    sendToggle("/pause");
    return;
  }

  if (mouseX > btnStartX + btnW*2 && mouseX < btnStartX + btnW*3 &&
      mouseY > btnY && mouseY < btnY + btnH) {
    sendToggle("/reset");
    return;
  }

  float d = dist(mouseX, mouseY, sliderX, height-80);
  if (d < 15) dragging = true;
}

void mouseDragged() {
  if (dragging) {
    sliderX = constrain(mouseX, 100, width-100);
  }
}

void mouseReleased() {
  if (dragging) {
    dragging = false;

    int total = table.getRowCount();
    int newIndex = int(map(sliderX, 100, width - 100, 0, total - 1));
    newIndex = constrain(newIndex, 0, total - 1);

    if (newIndex != lastIndex) {
      TableRow row = table.getRow(newIndex);
      sendDataOSC(row);
      lastIndex = newIndex;
      println("Sending OSC data for index: " + newIndex);
    }
  }
}
