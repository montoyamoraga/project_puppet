//Particle[] particles = new Particle[10];
ArrayList<Particle> particles = new ArrayList<Particle>();
Sun s;

float angle = 0;
int initParticleNum = 10;

int lowSpeedCount = 0;
float speedThreshold = 40;

void setup() {
  //size(640, 360, P3D);
  fullScreen(P3D);
  setupKinect();

  for ( int i = 0; i< initParticleNum; i++) {
    PVector pos = new PVector(random(0, width), random(0, height), random(-100, 100));
    particles.add(new Particle(random(1, 2), pos));
  }
  s = new Sun(0, 0, 0);
}

PVector pleftHand = new PVector(0, 0, 0);
PVector leftHand = new PVector(0, 0, 0);
void draw() {
  //mouse mode

  PVector mousePos = new PVector(mouseX, mouseY, 0);
  PVector pmousePos = new PVector(pmouseX, pmouseY, 0);
  PVector mouseSpeed = PVector.sub(mousePos, pmousePos);
  float mSpeed = mouseSpeed.mag();
  PVector mDir = mouseSpeed.normalize();



  background(0);
  updateKinectSkeletons();

  //get data from kinect: left hand pos-speed
  if (trailingJointPositions.size()>0) {
    leftHand = trailingJointPositions.get(1);
    leftHand.mult(kinectScaling);
    leftHand.y = height/2 - leftHand.y;
    leftHand.x +=width/2;
  }

  //kinect mode
  PVector leftHandSpeed = PVector.sub(leftHand, pleftHand);
  float lHandSpeed = leftHandSpeed.mag();
  // around 1-150
  println(lHandSpeed);

  //setup 3D scene
  sphereDetail(8);
  lights();
  //translate(width/2, height/2);
  rotateY(angle);
  pushMatrix();
  translate(width/2, height/2, 40);
  //fill(200,20);
  noFill();
  box(width, height, 120);
  popMatrix();

  //keep the size in explosion time in 2000
  if (particles.size()>2000) {
    particles.remove(0);
  }

  if (lowSpeedCount>300 && particles.size()>10) {
    particles.remove(0);
  }

  if (lHandSpeed>speedThreshold) {
    lowSpeedCount = 0;
    particles.add(new Particle(random(1, 2), leftHand));
    for (Particle p : particles) {
      p.applyForce(leftHandSpeed);
      p.update();
    }
  } else if (lHandSpeed<speedThreshold) {
    lowSpeedCount++;
  }



  s.location = new PVector(leftHand.x, leftHand.y);
  for (Particle p : particles) {
    PVector force = s.getAttractForce(p);
    if (lowSpeedCount<20) {
      if (particles.size()>150) {
        force.mult(-1);
      }
    }
    p.applyForce(force);
    p.run();
  }
  s.display();

  //update previous left hand position
  pleftHand = leftHand;
}