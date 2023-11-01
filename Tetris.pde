final int WIDTH = 10;
final int HEIGHT = 20;
final int CELL = 40;
final int CELL_GAP = 2;
final color GAP_COLOR = #ffffff;
final int W_WIDTH = WIDTH*CELL + (WIDTH+1)*CELL_GAP;
final int W_HEIGHT = HEIGHT*CELL + (HEIGHT+1) * CELL_GAP;
final color[] colors = {#FF0000, #FFFF00, #00FF00, #0000FF, #00FFFF, #9C00FF};
final int SPEED = 3;

color board[][] = new color[WIDTH][HEIGHT];
boolean fallen_board[][] = new boolean[WIDTH][HEIGHT];

void settings() {
    size(W_WIDTH, W_HEIGHT);
}

void setup() {
    frameRate(30);
    gen_new_figure();
    handling_event(x, y, figure_rotate);
    randomSeed(System.currentTimeMillis() / 1000L);
    tmr = millis();
}

int x;
int y;
int prev_x;
int prev_y;
boolean need_for_clean = false;
color cur_color;
int prev_rotate;
int figure_id;
int figure_rotate;
boolean fallen = false;
int tmr;

void draw() {
    timerStuff();
    draw_board();
}

void timerStuff() {
    if (millis() - tmr > (1000 / SPEED)) {
        tmr = millis();
        handling_event_falling(x, y + 1, figure_rotate);
        if (!fallen) {
            return;
        }
        figure_indexing((tx, ty, ix, iy) -> {
            if (figures[figure_id][figure_rotate][iy].charAt(ix) == empty) {
               return true;
            }
            fallen_board[tx][ty] = true;
            return true;
        }, x, y);
        fallen = false;
        check_line_on_clear();
        gen_new_figure();
        handling_event(x, y, figure_rotate);
    }
}

void gen_new_figure() {
    x = WIDTH / 2 - 1;
    y = 0;
    figure_id = int(random(0, figures.length));
    figure_rotate = int(random(0, figures[figure_id].length));
    prev_rotate = figure_rotate;
    need_for_clean = false;
    cur_color = colors[int(random(0, colors.length))];
}

void check_line_on_clear() {
    int j = HEIGHT - 1;
    while (j >= 0) {
        int count = 0;
        for (int i = 0; i < WIDTH; i++) {
            count += (board[i][j] != 0 ? 1 : 0);
        }
        if (count == 0) {
            break;
        }
        if (count != WIDTH) {
            j--;
            continue;
        }
        // move to 
        for (int ty = j - 1; ty >= 0; ty--) {
            for (int tx = 0; tx < WIDTH; tx++) {
                board[tx][ty + 1] = board[tx][ty];
                fallen_board[tx][ty + 1] = fallen_board[tx][ty];
            }
        }
        for (int tx = 0; tx < WIDTH; tx++) {
            board[tx][0] = 0;
            fallen_board[tx][0] = false;
        }
    }
}

// Falling / Moving figure handling
void handling_event_falling(int new_x, int new_y, int new_figure_rotate) {
    boolean result = figure_indexing((tx, ty, ix, iy) -> {
        if (figures[figure_id][new_figure_rotate][iy].charAt(ix) == empty) {
            return true;
        }
        if (tx < 0 || tx >= WIDTH) {
            return false;
        }
        if (ty >= HEIGHT || fallen_board[tx][ty] || (board[tx][ty] != cur_color && board[tx][ty] != 0)) {
            fallen = true;
            return false;
        }
        return true;
    }, new_x, new_y);
    if (!result) {
        return;
    }
    handling_event(new_x, new_y, new_figure_rotate);
}

// return true only if success
boolean handling_event(int new_x, int new_y, int new_figure_rotate) {
    if (fallen) {
        return false;
    }
    boolean result = figure_indexing((tx, ty, ix, iy) -> {
        if (figures[figure_id][new_figure_rotate][iy].charAt(ix) == empty) {
            return true;
        }
        if (tx < 0 || tx >= WIDTH || fallen_board[tx][ty] || (board[tx][ty] != cur_color && board[tx][ty] != 0)) {
            return false;
        }
        return true;
    }, new_x, new_y);
    if (!result) {
        return false;
    }
    prev_x = x;
    prev_y = y;
    prev_rotate = figure_rotate;
    if (!need_for_clean) {
        need_for_clean = true;
    } else {
        figure_indexing((tx, ty, ix, iy) -> {
            if (figures[figure_id][prev_rotate][iy].charAt(ix) == empty) {
                return true;
            }
            board[tx][ty] = 0;
            return true;
        }, prev_x, prev_y);
    }
    x = new_x;
    y = new_y;
    figure_rotate = new_figure_rotate;
    figure_indexing((tx, ty, ix, iy) -> {
        if (figures[figure_id][figure_rotate][iy].charAt(ix) == empty) {
            return true;
        }
        board[tx][ty] = cur_color;
        return true;
    }, new_x, new_y);
    return true;
}

// Keyboard events
void keyPressed() {
    //println(keyCode);
    switch (keyCode) {
    case UP:
        up_pressed();
        break;
    case RIGHT:
        right_pressed();
        break;
    case LEFT:
        left_pressed();
        break;
    case DOWN:
        down_pressed();
        break;
    case ' ':
        //instant_fall();
        break;
    }
}

void left_pressed() {
    handling_event(x - 1, y, figure_rotate);
}

void right_pressed() {
    handling_event(x + 1, y, figure_rotate);
}

void up_pressed() {
    int new_rotate = (figure_rotate + 1) % figures[figure_id].length;
    handling_event_falling(x, y, new_rotate);
}

void down_pressed() {
    handling_event_falling(x, y + 1, figure_rotate);
}

void instant_fall() {
//     int i = 0;
//     for (; i < HEIGHT - 1; i++) {
//         if (board[x][i + 1] != 0 && board[x][i] == 0) {
//            break;
//         }
//     }
//     if (board[x][HEIGHT - 1] == 0) {
//        i = HEIGHT - 1;  
//     }
//     handling_event_falling(x, i);
//     fallen = true;
//     for (int tx = x; tx < x + 4; tx++) {
//                 for (int ty = y; ty < y + 4; ty++) {
//                     int ix = tx - x;
//                     int iy = ty - y;
//                     if (figures[figure_id][figure_rotate][iy].charAt(ix) == empty) {
//                        continue;
//                     }
//                     fallen_board[tx][ty] = true;
//                 }
//     }
// //    handling_event_falling(x, i + 1);
}

// Board "refreshing"
void draw_board() {
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            int posx = CELL * i + CELL_GAP * (i + 1);
            int posy = CELL * j + CELL_GAP * (j + 1);
            fill(board[i][j]);
            noStroke();
            rect(posx, posy, CELL, CELL);
        }
    }
    stroke(GAP_COLOR);
    strokeWeight(CELL_GAP);
    for (int i = 0; i <= WIDTH; i++) {
        int pos = (CELL + CELL_GAP) * i;
        line(pos, 0, pos, W_HEIGHT);
    }
    for (int i = 0; i <= HEIGHT; i++) {
        int pos = (CELL + CELL_GAP) * i;
        line(0, pos, W_WIDTH, pos);
    }
}

@FunctionalInterface
interface FigureIndexing {
    public boolean iterate(int tx, int ty, int ix, int iy);
}

// return true if loop wasn't broken
boolean figure_indexing(FigureIndexing r, int startx, int starty) {
    for (int tx = startx; tx < startx + 4; tx++) {
        for (int ty = starty; ty < starty + 4; ty++) {
            int ix = tx - startx;
            int iy = ty - starty;
            boolean result = r.iterate(tx, ty, ix, iy);
            if (!result) {
                return false;
            }
        }
    }
    return true;
}
