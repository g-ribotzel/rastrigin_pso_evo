import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

PImage surf; // imagen que entrega el fitness
// ===============================================================
int puntos = 100;
ArrayList<float[]> test = new ArrayList<float[]>();
List<ArrayList<Float>> medianRecords = new ArrayList<>();
List<ArrayList<Float>> bestRecords = new ArrayList<>();

float d = 5; // radio del círculo, solo para despliegue
float maxv = 3; // max velocidad (modulo)
float gbest, bestx, besty;

int maxIter = 30;
int maxGen = 50;
int currIter = 0;
int currGen = 0;
boolean showGrafico=false;
float graf_my,graf_by,graf_x,graf_pmy,graf_pby,graf_px,graf_y;

float tx, ty;
float sel_val = 0.80; //probabilidad de seleccion. valor entre 0 y 1. mientras mas alto, mayor probabilidad de seleccionar a mejores candidatos. en caso opuesto, elegira a peores candidatos con mejor probabilidad
float rep_val = 0.30; //probabilidad de reemplazo. valor entre 0 y 1. mientras mas alto, mayor probabilidad de reemplazo generacional(padres reemplazados). en caso opuesto, mayor probabilidad de aplicar steady state(padres compiten con hijos, ganan quienes sean mejor segun su funcion evaluacion)

float Evaluacion(float x, float y){
  float fit = 20 +pow(x,2)-10*cos(2*PI*x)+pow(y,2)-10*cos(2*PI*y);
  if(fit < gbest){
    gbest = fit;
    bestx = x;
    besty = y;
  }
  return fit;
}

ArrayList<float[]> Seleccion(int puntos, ArrayList<float[]> cord){
  ArrayList <float[]> seleccionados = new ArrayList<float[]>(cord);
  int i = 0;
  //PERDIDO: PROMEDIO Y AJUSTES A LA SELECCION (CONSTANTE DE INCLINACION A BENEFICIAR PEOR/MEJOR.)
  float median = 0;
  
  for(int x=0;x<puntos;x++){
    median += cord.get(x)[2];
  }
  
  median = median/puntos;
  
  int selLen = puntos/2;
  while(seleccionados.size() > selLen){ //La seleccion termina cuando quede la mitad del arraylist original.
    float roll = random(0,1);
    if(roll < sel_val && seleccionados.get(i)[2] > median){ //Si la evaluacion esta sobre la mitad, es excluido de la seleccion. La opcion ocurre con un 60%(que se cumplan ambas es otra cosa xd).
      //println("valor excluido por estar sobre la mitad "+ seleccionados.get(i)[2]);
      seleccionados.remove(i);
      i--;
    } else if(roll >= 1 - sel_val && seleccionados.get(i)[2] <= median){
      //println("valor excluido por estar sobre la mitad "+ seleccionados.get(i)[2]);
      seleccionados.remove(i);
      i--;
    } else if(roll < 0.05){ // Si no pasa, entonces ocurre una exclusion aleatoria con un 10%(sucesos de la vida :( )
      //println("valor excluido porque si :) "+ seleccionados.get(i)[2]);
      seleccionados.remove(i);
      i--;
    }
    i++;
    if(i >= seleccionados.size()){ //Empezar desde el principio en caso de llegar al final del arraylist.
      i = 0;
    }
  }
  return seleccionados;
}

ArrayList<float[]> Cruzamiento(ArrayList<float[]> padres){
  ArrayList<float[]> paps = new ArrayList<float[]>(padres);
  ArrayList<float[]> hijos = new ArrayList<float[]>();
  while(paps.size() != 0){
    float[] papa = paps.get(0);
    float[] mama = paps.get(paps.size() - 1);
    
    //Dar a luz a los hijos.
     String xPapa = Integer.toBinaryString(Math.abs(int(papa[0] * 100)));
     String yPapa = Integer.toBinaryString(Math.abs(int(papa[1] * 100)));
     while(xPapa.length() < 10){
       xPapa = "0" + xPapa;
     }
     while(yPapa.length() < 10){
       yPapa = "0" + yPapa;
     }
     String xMama = Integer.toBinaryString(Math.abs(int(mama[0] * 100)));
     String yMama = Integer.toBinaryString(Math.abs(int(mama[1] * 100)));
     while(xMama.length() < 10){
       xMama = "0" + xMama;
     }
     while(yMama.length() < 10){
       yMama = "0" + yMama;
     }
     
     String[] h1 = {xPapa.substring(0,5) + xMama.substring(5,10), yPapa.substring(0,5) + yMama.substring(5,10)};
     String[] h2 = {xMama.substring(0,5) + xPapa.substring(5,10), yMama.substring(0,5) + yPapa.substring(5,10)};
     
     int[] iH1 = {int(Math.signum(papa[0]))*Integer.parseInt(h1[0],2), int(Math.signum(papa[1]))*Integer.parseInt(h1[1],2)};
     int[] iH2 = {int(Math.signum(mama[0]))*Integer.parseInt(h2[0],2), int(Math.signum(mama[1]))*Integer.parseInt(h2[1],2)};
     
     float[] hijo1 = {float(Mutante(iH1[0])) / 100, float(Mutante(iH1[1])) / 100, 0.0};
     float[] hijo2 = {float(Mutante(iH2[0])) / 100, float(Mutante(iH2[1])) / 100, 0.0};
     
     hijo1[2] = Evaluacion(hijo1[0],hijo1[1]);
     hijo2[2] = Evaluacion(hijo2[0],hijo2[1]);
     
     hijos.add(hijo1);
     hijos.add(hijo2);
     
     paps.remove(0);
     paps.remove(paps.size() - 1);
  }
  return hijos;
}    

int Mutante(int victima){
      //PERDIDO: CAMBIOS EN LA MUTACION. ADICION DE TRES ERRORES DE COORDENADAS Y CORRECCION DE CASOS DE BORDE.
      
      float sel = random(0,1);
      if(sel < 0.02){
        //println("victima de la mutacion : "+ victima);
        int bits = int(random(0,10));
        //println("el cabro esta mutando :( "+bits+" "+pow(2,bits));
        if(victima!=0){
          victima = int(Math.signum(victima))*(Math.abs(victima) ^ int(pow(2,bits)));
        } else{
          float signRoll = random(0,1);
          if(signRoll < 0.50){
            victima = -(victima ^ int(pow(2,bits)));
          } else{
            victima = victima ^ int(pow(2,bits));
          }
        }      
      } else if(sel < 0.10){
        victima = victima + int(random(-100,101));
      } else if(sel < 0.20){
        victima = victima + int(random(-50,51));
      } else if(sel < 0.30){
        victima = victima + int(random(-15,16));
      }
      
      if(victima > 512){
        victima = -(victima - 512);
      } else if(victima < -512){
        victima = -(victima + 512);
      }
      
      return victima;
}

ArrayList<float[]> Reemplazar(ArrayList<float[]> sons, ArrayList<float[]> oldGen, ArrayList<float[]> parents){
  float roll = random(0,1);
  for(int i=0;i<parents.size();i++){
    int index = oldGen.indexOf(parents.get(i));
    oldGen.remove(index);
  }
  if(roll < rep_val){
    //println("los viejos se murieron :(");
    //Variante 1: Hijos reemplazan a los padres..  
    ArrayList<float[]> newGen = new ArrayList<float[]>(sons);
    for(int j=0;j<oldGen.size();j++){
      newGen.add(oldGen.get(j));
    }
    Collections.shuffle(newGen);
    return newGen;
  } else{
    //println("se estan matando D:");
    //Variante 2: Nueva generacion compite con los padres.
    ArrayList<float[]> newGen = new ArrayList<float[]>(oldGen);
    while(newGen.size() < oldGen.size()*2){
      int comp_par = int(random(0,parents.size()));
      int comp_son = int(random(0,sons.size()));
            
      if(parents.get(comp_par)[2] < sons.get(comp_son)[2]){
        newGen.add(parents.get(comp_par));
        sons.remove(comp_son);
      } else{
        newGen.add(sons.get(comp_son));
        parents.remove(comp_par);
      }
    }
    Collections.shuffle(newGen);
    return newGen;
  }
}
ArrayList<float[]> build(int p){
  ArrayList<float[]> pobla = new ArrayList<float[]>();
  for(int i = 0; i<p; i++){
    float[] perso = new float[3];
    perso[0] = random(-5.12, 5.12);
    perso[1] = random(-5.12, 5.12);
    perso[2] = Evaluacion(perso[0],perso[1]);
    pobla.add(perso);
  }
  return pobla;
}

void printData(ArrayList<float[]> data){
  for(int i=0;i<data.size();i++){
    println(i+1 + ") " + data.get(i)[0] + " " + data.get(i)[1] + " " + data.get(i)[2]);
  }
  println();
}

void grafico(){
  stroke(0);
  line(50,height-50,width-50,height-50);
  line(50,50,50,height-50);
  
  fill(0);
  text("Fitness",40,25);
  text("Generacion",width-50,height-30);
  text("0",40,height-40);
  
  noStroke();
  fill(0, 0, 255);
  circle(width-130,95,6);
  text("Fitness Promedio",width-120,100);
  fill(0, 150, 0);
  circle(width-130,115,6);
  text("Mejor Fitness",width-120,120);
}

void setup(){
 size(712,647);
 surf = loadImage("problems_single_rastrigin_7_1.png");
 //For the love of god save.
 for(int i =0;i<maxIter;i++){
   medianRecords.add(new ArrayList<Float>());
   bestRecords.add(new ArrayList<Float>());
 }
 test = build(puntos);
 gbest = test.get(0)[2];
 for(int i = 0;i<puntos;i++){
   if(test.get(0)[2] < gbest){
     gbest = test.get(0)[2];
   }
 }
 printData(test);
 loop();
}
void draw(){
  background(200);
  //despliega mapa, posiciones  y otros
  //println(currGen);
  if(currIter < maxIter){
    if(currGen < maxGen){
      image(surf,0,0);
      noStroke();
      fill(255, 0, 0);
      float medianRec = 0;
      for(int i = 0;i<test.size();i++){
         tx = map(test.get(i)[0],-5.12,5.12,0,width);
         ty = map(test.get(i)[1],-5.12,5.12,0,height);
         circle(tx, ty, d);
         
         medianRec += test.get(i)[2];
      }
      medianRec=medianRec/puntos;
      
      medianRecords.get(currIter).add(medianRec);
      bestRecords.get(currIter).add(gbest);
      
      ArrayList<float[]> selTest = Seleccion(puntos, test);
      ArrayList<float[]> cruceTest = Cruzamiento(selTest);
      test = Reemplazar(cruceTest,test,selTest);
      //printData(test);
      delay(10);
      currGen++;
    } else if(currGen >= maxGen && !showGrafico){
      background(200);
      grafico();
      
      graf_my=height-map(medianRecords.get(currIter).get(0), 0, maxGen, 50, height-50);
      graf_by=height-map(bestRecords.get(currIter).get(0), 0, maxGen, 50, height-50);
      graf_x=map(0,0,maxGen,50,width-50);
    
      graf_pmy=graf_my;
      graf_pby=graf_by;
      graf_px=graf_x;
      for(int i=0;i<maxGen;i++){
        println(medianRecords.get(currIter).get(i)+" "+bestRecords.get(currIter).get(i));
      }
      
      
      fill(0);
      for(int i=0;i<maxGen;i++){
        noStroke();
        graf_my=height-map(medianRecords.get(currIter).get(i), 0, maxGen, 50, height-50);
        graf_by=height-map(bestRecords.get(currIter).get(i), 0, maxGen, 50, height-50);
        graf_x=map(i,0,maxGen,50,width-50);
        graf_y=map(i,0,maxGen,50,height-50);
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
      currGen = 0;
      test = build(puntos);
      gbest = test.get(0)[2];
      for(int i = 0;i<puntos;i++){
        if(test.get(0)[2] < gbest){
          gbest = test.get(0)[2];
        }
      }
    } 
  } else if(currIter>=maxIter && !showGrafico){
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
    for(int i=0;i<maxGen;i++){
      noStroke();
      graf_my=height-map(smoovMedian.get(i), 0, maxGen, 50, height-50);
      graf_by=height-map(smoovBest.get(i), 0, maxGen, 50, height-50);
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
