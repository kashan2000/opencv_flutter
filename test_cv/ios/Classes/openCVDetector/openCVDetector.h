#pragma once
#include <opencv2/core.hpp>

using namespace std;
using namespace cv;

struct ArucoResult {
    vector<Point2f> corners;
    int index = -1;
};

struct ArucoDict {
    vector<vector<int>> sigs;
    vector<vector<Point3f>> worldLoc;
};

class ArucoDetector {
public:
    ArucoDetector(Mat marker, int bits);
    vector<ArucoResult> detectArucos(Mat frame, int misses = 0);
    ArucoDict m_dict;

private:
    vector<int> getContoursBits(Mat image, vector<Point2f> cnt, int bits);
    bool equalSig(vector<int>& sig1, vector<int>& sig2, int allowedMisses = 0);
    void orderContour(vector<Point2f>& cnt);
    vector<vector<Point2f>> findSquares(Mat img);
    ArucoDict loadMarkerDictionary(Mat marker, int bits);
    TermCriteria TERM_CRIT = TermCriteria(TermCriteria::EPS + TermCriteria::MAX_ITER, 40, 0.001);
};



struct ShapeResult {
    vector<Point2f> corners;
    string shapeName = "Not detected";
    Scalar dominantColor;
};

class ShapeDetector {
public:
    vector<ShapeResult> detectShapes(Mat frame);

private:
    vector<vector<Point2f>> findShapes(Mat img);
    void orderContour(vector<Point2f>& cnt);
    Scalar getDominantColor(Mat image, vector<Point2f> cnt);
    string getShapeName(vector<Point2f> cnt);
    double angle(Point2f pt1, Point2f pt2, Point2f pt0);
};