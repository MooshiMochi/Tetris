

class Screen {
  PVector loc;
  PVector size;
  boolean showGrid;
  int[][] grid;
  int blockSize;
  color fillColour;

  Screen(PVector location, int _width, int numCellsX, int numCellsY) {
    this.grid = new int[numCellsY][numCellsX];
    this.loc = location;
    this.blockSize = (int)_width/numCellsX;
    this.size = new PVector(_width, blockSize*numCellsY);
    this.showGrid = true;
    fillColour = 160;

    for (int j=0; j<numCellsY; j++) {
      for (int i=0; i<numCellsX; i++) {
        grid[j][i] = 160;
      }
    }
  }

  void checkFilledRows() {
    // checking for filled rows
    for (int j=this.grid.length-1; j > 0; j--) { // going from the bottom up
      int rowSum = 0;
      for (int i=0; i<this.grid[j].length; i++) {
        if (this.grid[j][i] != this.fillColour) {  // cell is not Empty
          rowSum += 1;
        }
      }
      if (rowSum == this.grid[j].length) {  // row is full, clear, translate the top down and award points
        clearRow(j);
        translateScreenDownUpTo(j);
        score += 20;
      }
    }
  }

  void clearRow(int rowToClear) {
    for (int j=0; j<this.grid.length; j++) {
      if (rowToClear == j) {
        for (int i=0; i<this.grid[j].length; i++) {
          this.grid[rowToClear][i] = fillColour;
        }
      }
    }
  }

  void translateScreenDownUpTo(int rowToStop) {
    for (int j=rowToStop - 1; j>0; j--) {
      for (int i=0; i<this.grid[j].length; i++) {
        this.grid[j+1][i] = this.grid[j][i];
        this.grid[j][i] = fillColour;
      }
    }
  }

  void draw() {
    fill(fillColour);
    rect(loc.x, loc.y, size.x, size.y);
    fill(50);
    if (this.showGrid == true) {
      stroke(255);
      strokeWeight(2);
      for (float x = this.loc.x; x<this.loc.x + this.size.x; x+=blockSize) {
        line(x, this.loc.y, x, this.loc.y + this.size.y);
      }
      for (float y = this.loc.y + this.size.y; y > this.loc.y; y-=blockSize) {
        line(this.loc.x, y, this.loc.x + this.size.x, y);
      }
    }
    checkFilledRows();
    for (int j=0; j<this.grid.length; j++) {
      for (int i=0; i<this.grid[j].length; i++) {
        color colour = this.grid[j][i];
        if (colour != this.fillColour) {
          noStroke();
        }
        else if (this.showGrid == false) {
          noStroke();
        }
        else {
          stroke(255);
          strokeWeight(2);
        }
        fill(colour);
        rect(screen.loc.x + i*screen.blockSize, screen.loc.y + j*screen.blockSize, screen.blockSize, screen.blockSize);
      }
    }
  }
}
