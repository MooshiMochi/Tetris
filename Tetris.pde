
Screen screen, secondaryScreen;
BaseShape activeShape;
BaseShape[] nextShapes;
int score;
PImage imgStars;

void setup() {
  screen = new Screen(new PVector(width/10, 100), 300, 10, 20);
  //screen.showGrid = false;
  secondaryScreen = new Screen(new PVector(6*width/10, 260), 120, 5, 13);
  secondaryScreen.showGrid = false;
  size(800, 800);
  activeShape = randomShape();
  nextShapes = new BaseShape[]{randomShape(), randomShape(), randomShape()};
  score = 0;
  tint(160);
  imgStars = loadImage("space.jpeg");
}

void drawNextShapes() {
  for (int i=0; i<nextShapes.length; i++) {
    BaseShape shape = nextShapes[i];
    fill(shape.colour);
    shape.loc = new PVector(1, 1 + (i * 4));
    shape.draw(secondaryScreen);
  }
}

BaseShape randomShape() {
  int randNum = (int)random(0, 7);  // 7 possible shapes
  PVector locVector = new PVector(4, 0);  // row 0, col 5
  BaseShape newShape;
  switch (randNum) {
  case 0:
    newShape = new Block(locVector);
    break;
  case 1:
    newShape = new TShaped(locVector);
    break;
  case 2:
    newShape = new LShaped(locVector);
    break;
  case 3:
    newShape = new LShapedReversed(locVector);
    break;
  case 4:
    locVector.x -= 1;  // translate to the left by 1
    newShape = new Straight(locVector);
    break;
  case 5:
    newShape = new LeftZigZag(locVector);
    break;
  case 6:
    newShape = new RightZigZag(locVector);
    break;
  default:
    newShape = new Block(locVector);
    break;
  }
  while (newShape.willCollide(new PVector(0, 1))) {
    newShape.loc.y -= 1;
    if (newShape.loc.y <= 0) {
      endGame();
      return newShape;
    }
  }

  return newShape;
}

void draw() {
  //background(200);
  image(imgStars, 0, 0, imgStars.width*1.2, height);
  drawTitle();
  strokeWeight(1);
  stroke(1);
  secondaryScreen.draw();
  screen.draw();
  displayScore();
  drawNextShapes();

  activeShape.draw();
  activeShape.move();
  if (activeShape.isLocked) {
    activeShape = nextShapes[0];
    activeShape.loc.x = 4;
    activeShape.loc.y = 0;
    
    nextShapes[0] = nextShapes[1];
    nextShapes[1] = nextShapes[2];
    nextShapes[2] = randomShape();
    }
}


void drawTitle() {
  pushMatrix();
  PVector pos = new PVector(width/2, 60);
  
  textSize(48);
  textAlign(CENTER);
  fill(168, 52, 96, 150);
  
  stroke(5);
  fill(256, 256, 100);
  text("Tetris :)", pos.x, pos.y);
  
  popMatrix();
}

void displayScore() {
  fill(255, 100, 100);
  textSize(24);
  textAlign(LEFT);
  String scoreText = String.format("Score: %d", score);
  text(scoreText, screen.loc.x, screen.loc.y - 20);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    activeShape.rotate(RIGHT);
  }
}

void keyPressed() {
  if (keyCode == 39 || key == 'd') {  // arrow right
    activeShape.move(RIGHT);
  } else if (keyCode == 37 || key == 'a') {  // arrow left
    activeShape.move(LEFT);
  } else if (keyCode == 40 || key == 's') {  // arrow down
    activeShape.isSpedUp = true;
    score += 1;
  } else if (key == 'r' || key == 'w' || keyCode == 38) {  // arrow up
    activeShape.rotate(RIGHT);
  }
}

void keyReleased() {
  if (keyCode == 40 || key == 's') {
    activeShape.isSpedUp = false;
  }
}


void endGame() {
  String message = String.format("Game Ended! Your score: %d", score);
  fill(60);
  rect(0, height/2-60, width, 100);
  fill(255, 160, 50, 230);
  textSize(48);
  textAlign(CENTER);
  text(message, width/2, height/2);
  frameRate(0);
}
