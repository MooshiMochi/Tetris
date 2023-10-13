
class Matrix {
  int[][] self;

  Matrix(int[][] self) {
    this.self = self;
  }
  
  Matrix(Matrix other) {
    this.self = other.self;
  }

  void rotate(int direction) {
    if (direction == LEFT) {
      for (int i = 0; i < 3; i++) {
        this.rotate(RIGHT);
      }
      return;
    }

    // Perform clockwise rotation
    int rowCount = self.length;
    int colCount = self[0].length;
    int[][] rotated = new int[colCount][rowCount];

    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < colCount; j++) {
        rotated[j][rowCount - 1 - i] = self[i][j];
      }
    }

    self = rotated;
  }

  void fillToSize(int _width, int _height) {
    int rowsToAdd = max(_height - this.self.length, 0);
    int colsToAdd = max(_width - this.self[0].length, 0);

    if (rowsToAdd == 0 && colsToAdd == 0) {
      return;
    }

    int[][] newMatrix = new int[this.self.length + rowsToAdd][this.self[0].length + colsToAdd];

    for (int i = 0; i < this.self.length; ++i) {
      for (int j = 0; j < this.self[0].length; ++j) {
        newMatrix[i][j] = this.self[i][j];
      }
    }

    this.self = newMatrix;
  }

  void trim() {
    int top = 0, bottom = self.length - 1;
    int left = 0, right = self[0].length - 1;

    // Find the top-most non-zero row
    while (top <= bottom && isRowZero(self[top])) {
      top++;
    }

    // Find the bottom-most non-zero row
    while (bottom >= top && isRowZero(self[bottom])) {
      bottom--;
    }

    // Find the left-most non-zero column
    while (left <= right && isColumnZero(self, left)) {
      left++;
    }

    // Find the right-most non-zero column
    while (right >= left && isColumnZero(self, right)) {
      right--;
    }

    int newHeight = bottom - top + 1;
    int newWidth = right - left + 1;
    int[][] newMatrix = new int[newHeight][newWidth];

    for (int i = 0; i < newHeight; i++) {
      System.arraycopy(self[top + i], left, newMatrix[i], 0, newWidth);
    }

    self = newMatrix;
  }

  boolean isRowZero(int[] row) {
    for (int val : row) {
      if (val != 0) {
        return false;
      }
    }
    return true;
  }

  boolean isColumnZero(int[][] matrix, int col) {
    for (int[] row : matrix) {
      if (row[col] != 0) {
        return false;
      }
    }
    return true;
  }
}
