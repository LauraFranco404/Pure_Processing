// ----------------------------------------------------------
// Visualizador de registros del dataset de Spotify + OSC
// Envía los valores del registro actual a Pure Data (puerto 6000)
// ----------------------------------------------------------

import oscP5.*;
import netP5.*;

Table table;
int currentIndex = 0;  // índice actual del registro
float sliderX;
boolean dragging = false;

// Comunicación OSC
OscP5 oscP5;
NetAddress dest;  // destino (IP y puerto de Pure Data)

void setup() {
  size(900, 600);
  table = loadTable("spotify.csv", "header");
  
  // Configurar OSC
  oscP5 = new OscP5(this, 12000); // puerto local para escuchar respuestas
  dest = new NetAddress("127.0.0.1", 6000); // puerto de PD
  
  sliderX = 100;
  textFont(createFont("Arial", 16));
}

void draw() {
  background(15);
  fill(255);
  
  textAlign(CENTER);
  textSize(22);
  text("Spotify Dataset Visualizer + OSC", width/2, 40);
  
  drawSlider();
  
  int total = table.getRowCount();
  currentIndex = int(map(sliderX, 100, width - 100, 0, total - 1));
  currentIndex = constrain(currentIndex, 0, total - 1);
  
  TableRow row = table.getRow(currentIndex);
  showSong(row);
  sendDataOSC(row); // Envía los datos al puerto 6000
}

// ----------------------------------------------------------
void drawSlider() {
  stroke(200);
  line(100, height-80, width-100, height-80);
  fill(255, 150, 0);
  noStroke();
  ellipse(sliderX, height-80, 20, 20);
  
  fill(255);
  textSize(14);
  textAlign(CENTER);
  text("Canción " + (currentIndex+1) + " / " + table.getRowCount(), width/2, height-40);
}

// ----------------------------------------------------------
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
  float popular = row.getFloat("track_popularity");
  
  fill(255);
  text("Track: " + track, 80, 120);
  text("Artist: " + artist, 80, 150);
  text("Album: " + album, 80, 180);
  text("Genre: " + genre, 80, 210);
  text("Release: " + release, 80, 240);
  
  int barX = 80;
  int barY = 280;
  drawBar(barX, barY, energy, "Energy");
  drawBar(barX, barY+30, valence, "Valence");
  drawBar(barX, barY+60, dance, "Danceability");
  drawBar(barX, barY+90, tempo/200.0, "Tempo");
  drawBar(barX, barY+120, (loud+60)/60.0, "Loudness");
  drawBar(barX, barY+150, popular/100.0, "Popularity");
}

// ----------------------------------------------------------
void drawBar(int x, int y, float value, String label) {
  int w = 300;
  int h = 15;
  value = constrain(value, 0, 1);
  
  fill(80);
  rect(x, y, w, h);
  fill(100, 200, 255);
  rect(x, y, w*value, h);
  
  fill(255);
  textSize(14);
  text(label + ": " + nf(value, 1, 2), x+w+20, y+h-2);
}

// ----------------------------------------------------------
// Enviar datos al puerto 6000 vía OSC
// ----------------------------------------------------------

void sendDataOSC(TableRow row) {
  // Lista de columnas a enviar
  String[] columns = {
    "energy",
    "valence",
    "danceability",
    "tempo",
    "loudness",
    "track_popularity"
  };
  
  for (int i = 0; i < columns.length; i++) {
    String col = columns[i];
    float value = row.getFloat(col);
    
    // Normalizar valores para que estén entre 0 y 1 si corresponde
    if (col.equals("loudness")) value = (value + 60)/60.0; // entre 0 y 1
    if (col.equals("tempo")) value = value/200.0;            // aprox normalizado
    if (col.equals("track_popularity")) value = value/100.0;
    
    // Crear mensaje OSC con la dirección igual al nombre de la columna
    OscMessage msg = new OscMessage("/" + col);
    msg.add(value);
    
    // Enviar mensaje al destino
    oscP5.send(msg, dest);
  }
}


// ----------------------------------------------------------
void mousePressed() {
  float d = dist(mouseX, mouseY, sliderX, height-80);
  if(d < 15) {
    dragging = true;
  }
}

void mouseDragged() {
  if(dragging) {
    sliderX = constrain(mouseX, 100, width-100);
  }
}

void mouseReleased() {
  dragging = false;
}
