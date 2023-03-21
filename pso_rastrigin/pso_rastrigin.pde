import java.util.ArrayList;
import java.util.List;

// PSO de acuerdo a Talbi (p.247 ss)

PImage surf; // imagen que entrega el fitness

// ===============================================================
int puntos = 100;
Particle[] fl; // arreglo de partículas
float d = 10; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest; // posición y fitness del mejor global
float w = 2000; // inercia: baja (~50): explotación, alta (~5000): exploración (2000 ok)
float C1 = 30, C2 =  10; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 0.4; // max velocidad (modulo)

List<ArrayList<Float>> medianRecords = new ArrayList<>();
List<ArrayList<Float>> bestRecords = new ArrayList<>();

int maxIter = 10;
int currIter = 0;
int maxDespl = 100;
int currDespl = 0;
float acum;
boolean showGrafico = false;

float graf_x, graf_px, graf_my, graf_by, graf_pmy, graf_pby, graf_y;

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  float tx, ty;
  
  // ---------------------------- Constructor
  Particle(){
    x = random (-5.12, 5.12); y = random(-5.12, 5.12);
    vx = random(-1,1); vy = random(-1,1);
    pfit = 20 + pow(x,2) - 10 * cos(2*PI*x) + pow(y,2) - 10 * cos(2*PI*y); //Como se estan buscando minimos, es mejor inicializar ambos valores con los calculos de la funcion.
    fit = 20 + pow(x,2) - 10 * cos(2*PI*x) + pow(y,2) - 10 * cos(2*PI*y); 
    tx = map(x,-5.12 ,5.12 ,0 ,width);//(width/2) + int(x*100); // map(x,)
    ty = map(y,-5.12 ,5.12 ,0 ,height);//(height/2) + int(y*100);
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(){ //recibe imagen que define función de fitness
    evals++;
    fit = 20 + pow(x,2) - 10 * cos(2*PI*x) + pow(y,2) - 10 * cos(2*PI*y);
    if(fit < pfit){ // actualiza local best si es mejor
      pfit = fit;
      px = x;
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
    };
    return fit; //retorna la componente roja
  }
  
  // ------------------------------ mueve la partícula
  void move(){
    //actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)
    //vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    //actualiza velocidad (fórmula con inercia, p.250)
    //vx = w * vx + random(0,1)*(px - x) + random(0,1)*(gbestx - x);
    //vy = w * vy + random(0,1)*(py - y) + random(0,1)*(gbesty - y);
    //actualiza velocidad (fórmula mezclada)
    vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    // trunca velocidad a maxv
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    // update position
    x = x + vx;
    y = y + vy;
    
    tx = map(x,-5.12 ,5.12 ,0 ,width);//(width/2) + int(x*100); // map(x,)
    ty = map(y,-5.12 ,5.12 ,0 ,height);//(height/2) + int(y*100);
    
    // rebota en murallas
    if (tx > width || tx < 0) vx = - vx;
    if (ty > height || ty < 0) vy = - vy;
  }
  
  // ------------------------------ despliega partícula
  void display(){ 
    fill(255,0,0);
    ellipse (tx, ty,d,d);
    // dibuja vector
    stroke(#ff0000);
    line(tx, ty,tx-10*vx,ty-10*vy);
  }
} //fin de la definición de la clase Particle


// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  fill(#0000ff);
  ellipse(gbestx,gbesty,d,d);
//  PFont f = createFont("Arial",16,true);
//  textFont(f,15);
  fill(255,50,50);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals),10,20);
}

// ===============================================================
void grafico(){
  stroke(0);
  line(50,height-50,width-50,height-50);
  line(50,50,50,height-50);
  
  fill(0);
  text("Y axis",40,30);
  text("X axis",width-50,height-30);
  
}

void setup(){  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //size(1440,720); //setea width y height
  //surf = loadImage("marscyl2.jpg");
  for(int i =0;i<maxIter;i++){
    medianRecords.add(new ArrayList<Float>());
    bestRecords.add(new ArrayList<Float>());
  }
  size(712,647); //setea width y height (de acuerdo al tamaño de la imagen)
  surf = loadImage("problems_single_rastrigin_7_1.png");
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  smooth();
  // crea arreglo de objetos partículas
  fl = new Particle[puntos];
  for(int i =0;i<puntos;i++)
    fl[i] = new Particle();
  gbest = fl[int(random(0,puntos))].Eval(); //Inicializar gbest con un fitness aleatorio(Es para evitar que inicialize en 0, recordar que buscamos minimos!)
}

void draw(){
  //background(200);
  //despliega mapa, posiciones  y otros
  if(currIter < maxIter){
    if(currDespl < maxDespl){
      image(surf,0,0);
      for(int i = 0;i<puntos;i++){
        fl[i].display();
      }
      despliegaBest();
      //mueve puntos
      acum = 0;
      for(int i = 0;i<puntos;i++){
        fl[i].move();
        acum += fl[i].Eval();
      }
      acum = acum / puntos;
      
      medianRecords.get(currIter).add(acum);
      bestRecords.get(currIter).add(gbest);
  
      currDespl++;
    } else if(currDespl >= maxDespl && !showGrafico){
      background(200);
      grafico();
      
      graf_my=height-map(medianRecords.get(currIter).get(0), 0, maxDespl, 50, height-50);
      graf_by=height-map(bestRecords.get(currIter).get(0), 0, maxDespl, 50, height-50);
      graf_x=map(0,0,maxDespl,50,width-50);
    
      graf_pmy=graf_my;
      graf_pby=graf_by;
      graf_px=graf_x;
      for(int i=0;i<maxDespl;i++){
        println(medianRecords.get(currIter).get(i)+" "+bestRecords.get(currIter).get(i));
      }
      
      fill(0);
      for(int i=0;i<maxDespl;i++){
        noStroke();
        graf_my=height-map(medianRecords.get(currIter).get(i), 0, maxDespl, 50, height-50);
        graf_by=height-map(bestRecords.get(currIter).get(i), 0, maxDespl, 50, height-50);
        graf_x=map(i,0,maxDespl,50,width-50);
        graf_y=map(i,0,maxDespl,50,height-50);
        //println((height-y)-25);
        fill(0, 0, 255);
        stroke(0, 0, 255);
  
        circle(graf_x,graf_my,4);
        line(graf_px,graf_pmy,graf_x,graf_my);
        
        fill(0, 150, 0);
        stroke(0, 150, 0);
  
        circle(graf_x,graf_by,4);
        line(graf_px,graf_pby,graf_x,graf_by);
        //delay(250);
        
        graf_pmy=graf_my;
        graf_pby=graf_by;
        graf_px=graf_x;
        
        stroke(0);
        fill(0);
        if((i + 1) % 10 == 0){
          text(i+1,graf_x,height-10);
          line(graf_x,height-50,graf_x,height-45);
          text(i+1,5,height-graf_y);
          line(50,height-graf_y,35,height-graf_y);
        }
      }
      showGrafico = true;
      text("Grafico iteracion "+(currIter + 1),width-120,50);
      } else{
        background(200);
        delay(5000);
        showGrafico = false;
        currIter++;
        currDespl = 0;
        fl = new Particle[puntos];
        for(int i =0;i<puntos;i++)
          fl[i] = new Particle();
        gbest = fl[int(random(0,puntos))].Eval(); 
      }
  } else if(currIter >= maxIter && !showGrafico){
    ArrayList<Float> smoovMedian = new ArrayList<Float>();
    ArrayList<Float> smoovBest = new ArrayList<Float>();
    float acumMedian;
    float acumBest;
    for(int i = 0;i < medianRecords.get(0).size();i++){
      acumMedian = 0;
      acumBest = 0;
      for(int j = 0;j < medianRecords.size();j++){
        acumMedian += medianRecords.get(j).get(i);
        acumBest += bestRecords.get(j).get(i);
      }
      acumMedian = acumMedian / medianRecords.size();
      acumBest = acumBest / bestRecords.size();
      
      smoovMedian.add(acumMedian);
      smoovBest.add(acumBest);
    }
    background(200);
    grafico();
    
    graf_my=height-map(smoovMedian.get(0), 0, smoovMedian.size(), 50, height-50);
    graf_by=height-map(smoovBest.get(0), 0, smoovBest.size(), 50, height-50);
    graf_x=map(0,0,smoovMedian.size(),50,width-50);
  
    graf_pmy=graf_my;
    graf_pby=graf_by;
    graf_px=graf_x;
    
    fill(0);
    for(int i=0;i<maxDespl;i++){
      noStroke();
      graf_my=height-map(smoovMedian.get(i), 0, maxDespl, 50, height-50);
      graf_by=height-map(smoovBest.get(i), 0, maxDespl, 50, height-50);
      graf_x=map(i,0,smoovMedian.size(),50,width-50);
      graf_y=map(i,0,smoovMedian.size(),50,height-50);
      //println((height-y)-25);
      fill(0, 0, 255);
      stroke(0, 0, 255);

      circle(graf_x,graf_my,4);
      line(graf_px,graf_pmy,graf_x,graf_my);
      
      fill(0, 150, 0);
      stroke(0, 150, 0);

      circle(graf_x,graf_by,4);
      line(graf_px,graf_pby,graf_x,graf_by);
      //delay(250);
      
      graf_pmy=graf_my;
      graf_pby=graf_by;
      graf_px=graf_x;
      
      stroke(0);
      fill(0);
      if((i + 1) % 10 == 0){
        text(i+1,graf_x,height-10);
        line(graf_x,height-50,graf_x,height-45);
        text(i+1,5,height-graf_y);
        line(50,height-graf_y,35,height-graf_y);
      }
    }
    text("Grafico promedio",width-120,50);
  } else {
    delay(5000);
  }
}
