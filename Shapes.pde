
abstract private class BaseShape {
  PVector loc;
  PVector size;

  protected float lastMovedTs;
  protected float moveCount;

  boolean isSpedUp;
  boolean isLocked;  // can no longer be moved
  color colour;

  Matrix pieceShape;

  public BaseShape(PVector location, Matrix shape) {
    this.loc = location;
    this.moveCount = 0;
    this.colour = color(random(0, 255), random(0, 255), random(0, 255));
    this.pieceShape = shape;
    this.size = new PVector(shape.self[0].length, shape.self.length);
  }

  void rotate(int direction) {
    Matrix matrix = new Matrix(this.pieceShape);
    matrix.rotate(direction);

    int newWidth = matrix.self[0].length;
    int newHeight = matrix.self.length;

    // Calculate potential new x position after rotation
    int potentialNewX = int(this.loc.x) + newWidth;

    // Adjust position if the rotated shape goes off the screen to the right
    if (potentialNewX > screen.grid[0].length) {
      this.loc.x = screen.grid[0].length - newWidth;
    }

    // Re-calculate potential new x and y position after position adjustment
    potentialNewX = int(this.loc.x) + newWidth;
    int potentialNewY = int(this.loc.y) + newHeight;

    // If it's still out of bounds, return without rotating
    if (potentialNewX > screen.grid[0].length || potentialNewY > screen.grid.length) {
      return;
    }

    // Check against static blocks on the grid
    for (int j = 0; j < newHeight; j++) {
      for (int i = 0; i < newWidth; i++) {
        int gridX = int(this.loc.x + i);
        int gridY = int(this.loc.y + j);

        // If the rotated block will overlap with a static block, don't rotate
        if (matrix.self[j][i] == 1 && screen.grid[gridY][gridX] != screen.fillColour) {
          return;
        }
      }
    }

    // After all the checks, apply the rotation
    this.pieceShape = matrix;
  }


  void draw() {
    pushMatrix();
    noStroke();
    fill(lerpColor(this.colour, color(0, 0, 0), 0.3));
    for (int j=0; j<this.pieceShape.self.length; j++) {
      for (int i=0; i<this.pieceShape.self[j].length; i++) {
        if (this.pieceShape.self[j][i] == 1) {
          fill(lerpColor(this.colour, color(0, 0, 0), 0.3));
          rect(
            screen.loc.x + (this.loc.x + i)*screen.blockSize,
            screen.loc.y + (this.loc.y + j)*screen.blockSize,
            screen.blockSize,
            screen.blockSize
            );
          fill(this.colour);
          rect(
            screen.loc.x +0.15*screen.blockSize + (this.loc.x + i)*screen.blockSize,
            screen.loc.y +0.15*screen.blockSize + (this.loc.y + j)*screen.blockSize,
            screen.blockSize*0.75,
            screen.blockSize*0.75
            );
        }
      }
    }
    popMatrix();
  }

  void draw(Screen screen) {
    pushMatrix();
    noStroke();
    fill(this.colour);
    for (int j=0; j<this.pieceShape.self.length; j++) {
      for (int i=0; i<this.pieceShape.self[j].length; i++) {
        if (this.pieceShape.self[j][i] == 1) {
          fill(lerpColor(this.colour, color(0, 0, 0), 0.3));
          rect(
            screen.loc.x + (this.loc.x + i)*screen.blockSize,
            screen.loc.y + (this.loc.y + j)*screen.blockSize,
            screen.blockSize,
            screen.blockSize
            );
          fill(this.colour);
          rect(
            screen.loc.x +0.15*screen.blockSize + (this.loc.x + i)*screen.blockSize,
            screen.loc.y +0.15*screen.blockSize + (this.loc.y + j)*screen.blockSize,
            screen.blockSize*0.75,
            screen.blockSize*0.75
            );
        }
      }
    }
    popMatrix();
  }

  protected boolean canMove() {  // should be able to move once every half a second
    if (this.isLocked) {
      return false;
    }
    if (this.isSpedUp) {
      if (millis() - this.lastMovedTs > 0.05*1000) {
        this.moveCount = 0;
        return true;
      }
    } else {
      if (millis() - this.lastMovedTs > 0.5*1000) {
        this.moveCount = 0;
        return true;
      }
    }
    return false;
  }

  void writeShapeToGrid() {
    for (int j = 0; j < this.pieceShape.self.length; j++) {
      for (int i = 0; i < this.pieceShape.self[j].length; i++) {
        if (this.pieceShape.self[j][i] == 1) {
          screen.grid[int(this.loc.y + j)][int(this.loc.x + i)] = this.colour;
        }
      }
    }
    score += 4; // award the same number of points as the number of squares in the piece
  }


  boolean willCollide(PVector deltaPos) {
    for (int j = 0; j < this.pieceShape.self.length; j++) {
      for (int i = 0; i < this.pieceShape.self[j].length; i++) {
        if (this.pieceShape.self[j][i] == 0) {
          continue;
        }
        int gridX = int(this.loc.x) + i + int(deltaPos.x);
        int gridY = int(this.loc.y) + j + int(deltaPos.y);

        if (gridX < 0 || gridX >= screen.grid[0].length || gridY >= screen.grid.length) {
          return true;  // Out of bounds
        }
        if (screen.grid[gridY][gridX] != screen.fillColour) {
          return true;  // Collision with existing blocks
        }
      }
    }
    return false;
  }

  void move() {
    if (this.canMove()) {
      PVector posOffset = new PVector(0, 1);
      if (this.willCollide(posOffset)) {
        writeShapeToGrid();
        this.isLocked = true;
        return;
      }
      this.loc.add(posOffset);
      this.moveCount += 1;
      this.lastMovedTs = millis();
    }
  }

  void move(int direction) {
    if (this.isLocked) {
      return;
    }

    PVector posOffset = new PVector(0, 0);

    if (direction == LEFT) {
      posOffset.x -= 1;
    } else if (direction == RIGHT) {
      posOffset.x += 1;
    }

    if (!this.willCollide(posOffset)) {
      this.loc.add(posOffset);
    }
  }
}


class Block extends BaseShape {
  Block (PVector location) {
    super(location,
      new Matrix(
      new int[][]{
      {1, 1},
      {1, 1}
      }
      ));
  }
}


class TShaped extends BaseShape {
  TShaped (PVector location) {
    super(
      location,
      new Matrix(new int[][]{
      {1, 1, 1},
      {0, 1, 0}
      }));
  }
}

class LShaped extends BaseShape {
  LShaped (PVector location) {
    super(
      location,

      new Matrix(new int[][]{
      {1, 0},
      {1, 0},
      {1, 1}
      }));
  }
}

class LShapedReversed extends BaseShape {
  LShapedReversed(PVector location) {
    super(
      location,
      new Matrix (new int[][]{
      {0, 1},
      {0, 1},
      {1, 1}
      }));
  }
}

class Straight extends BaseShape {
  Straight(PVector location) {
    super(
      location,
      new Matrix (new int[][]{
      {1, 1, 1, 1}
      }));
  }
}

class LeftZigZag extends BaseShape {
  LeftZigZag(PVector location) {
    super(
      location,
      new Matrix(new int[][]{
      {1, 1, 0},
      {0, 1, 1},
      }));
  }
}

class RightZigZag extends BaseShape {
  RightZigZag(PVector location) {
    super(
      location,
      new Matrix(new int[][]{
      {0, 1, 1},
      {1, 1, 0},
      }));
  }
}
