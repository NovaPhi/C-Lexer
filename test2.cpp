#include <iostream>
#define PI 3

// Calculate area of a rectangle and a circle
int area_rect(int w, int h) {
    return w * h;
}

int area_circle(int r) {
    return PI * r * r;
}

int main() {
    int width = 5;
    int height = 10;
    int radius = 4;

    int rect = area_rect(width, height);
    int circ = area_circle(radius);

    return 0;
}