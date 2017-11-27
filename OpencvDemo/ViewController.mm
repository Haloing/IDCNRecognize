//
//  ViewController.m
//  OpencvDemo
//
//  Created by Mac OS X on 2017/11/23.
//  Copyright © 2017年 Haooing. All rights reserved.
//

#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import "ViewController.h"
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController () <UITextViewDelegate> {
    
    cv::Mat cvImage;
    
    UIImage *image;
    
    UIImage *dis_Img;
    
    int index;
}

@property (nonatomic, strong) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    image = [UIImage imageNamed:@"yixiao"];
    
    CGFloat width = image.size.width;
    CGFloat height;
    CGFloat scale = image.size.height/image.size.width;
    
    width = width > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.width: width;
    height = width * scale;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - width)*0.5, 200, width, height)];
    [self.view addSubview:self.imageView];
    self.imageView.image = image;
    dis_Img = image;
}

- (IBAction)DiscernAction:(UIButton *)sender {
    
    /*http://www.cocoachina.com/ios/20150708/12463.html
     1.初始化tesseract为一个新的G8Tesseract对象
     2.Tesseract将从.traineddata文件中寻找你在该参数中指定的语言，指定为eng和fra将从"eng.traineddata" 和 "fra.traineddata"包含的数据中分别检测英文和法文，法语转换数据（trained data）已经被包含到该工程中了，因为本教程中你将使用的示例诗词中包含一部分法语(Très romantique!)，法语中的重读符号不在英语字母集中，因此为了能展示出这些重读符号，你需要连接法语的.traineddata文件。将法语数据包含进来也是很好的，因为.traineddata中有一部分涉及到了语言词汇。
     */
    G8Tesseract*     tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    
    /*
     3.你可以指定三种不同的OCR工作模式：.TesseractOnly是最快但最不精确的方法；.CubeOnly要慢一些，但更精确，因为它使用了更多的人工智能；.TesseractCubeCombined同时使用.TesseractOnly和.CubeOnly来提供最精确的结果，不过这也导致了它成为三种工作方式中最慢的一种。
     */
    tesseract.engineMode = G8OCREngineModeTesseractCubeCombined;
    
    
    /*
     4.Tesseract假定处理的文字是均匀的一段文字，但是你的样例诗中分了多段。Tesseract的pageSegmentationMode可以让它知道文字是怎么样被划分的。所以这里设置pageSegmentationMode为.Auto来支持自动页划分（automatic page segmentation），这样Tesseract就有能力识别段落分割了。
     */
    tesseract.pageSegmentationMode = G8PageSegmentationModeAuto;
    
    /*
     5.这里你通过设定maximumRecognitionTime来限制Tesseract识别图片的时间为一有限的时间。不过这样设定以后，只有Tesseract引擎被限制了，如果你正在使用.CubeOnly 或 .TesseractCubeCombined工作模式，那么即使Tesseract已经达到了maximumRecognitionTime指定的时间，立体引擎（Cube engine）依然会继续处理。
     */
    tesseract.maximumRecognitionTime = 30.0;
    
    // 开始识别
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    /*
     6.如果文字和背景相差很大，那么你将得到Tesseract处理的最好结果。Tesseract有一个内置的滤镜，g8_blackAndWhite()，降低图片颜色的饱和度，增加对比度，减少亮度。这里你在Tesseract图像识别过程开始之前，将滤镜处理后的图像赋值给Tesseract对象的image属性。
     */
    tesseract.image = [dis_Img g8_blackAndWhite];
    
    NSString *dis_str = tesseract.recognizedText;
    
    // 识别结束
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    
    // 显示识别结果
    UIAlertController *alert    = [UIAlertController alertControllerWithTitle:@"OCR RESULT" message:[NSString stringWithFormat:@"\n%@\n\n%@",[NSString stringWithFormat:@"识别用时:  %f",end - start],dis_str] preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *OK_Action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        // 点击取消按钮时 要进行的操作可以写到这里
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:OK_Action];
    [self presentViewController:alert animated:YES completion:nil];
    
    self.timeLabel.text = [NSString stringWithFormat:@"识别用时:  %f",end - start];
}

-(void)textViewDidChange:(UITextView *)textView {
    //获得textView的初始尺寸
    CGFloat width = CGRectGetWidth(textView.frame);
    CGFloat height = CGRectGetHeight(textView.frame);
    CGSize newSize = [textView sizeThatFits:CGSizeMake(width,MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmax(width, newSize.width), fmax(height, newSize.height));
    textView.frame= newFrame;
}

// 灰度处理
- (IBAction)grayDealAction:(UIButton *)sender {
    
    // UIImage -> Mat
    UIImageToMat(image, cvImage);
    
    [self GrayDealPicture];
    
    [self cv_MatToUIImageWithMat:cvImage];
}

// 二值化
- (IBAction)ThresholdingAction:(UIButton *)sender {
    
    // UIImage -> Mat
    UIImageToMat(image, cvImage);
    
    [self GrayDealPicture];
    [self Thresholding];
    
    [self cv_MatToUIImageWithMat:cvImage];
    
}

// 腐蚀
- (IBAction)erodeAction:(UIButton *)sender {
    
    // UIImage -> Mat
    UIImageToMat(image, cvImage);
    
    [self GrayDealPicture];
    [self Thresholding];
    [self Erosion];
    
    [self cv_MatToUIImageWithMat:cvImage];
}

// 轮廓检测
- (IBAction)dilateAction:(UIButton *)sender {
    
    // UIImage -> Mat
    UIImageToMat(image, cvImage);
    
    [self GrayDealPicture];
    [self Thresholding];
    [self Erosion];
    
    std::vector<std::vector<cv::Point>> contours; //定义一个容器来存储所有检测到的轮廊
    std::vector<cv::Vec4i> hierarchy;
    
    // 轮廓检测函数
    cv::findContours(cvImage, contours,hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE, cvPoint(0, 0));
    
    /*  取出身份证号码区域  */
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    
    // 定义并直接赋值第一个元素
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    
    // 遍历容器内的所有元素
    for (; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        
        // rect放入rects容器存储
        rects.push_back(rect);
        
        printf("X:%d - Y:%d - width:%d - height:%d \n",rect.x,rect.y,rect.width,rect.height);
        
        // 算法原理
        if (rect.width > numberRect.width && rect.width > rect.height * 3) {
            numberRect = rect;
        }
    }
    
    if (numberRect.width != 0 && numberRect.height != 0) {
       
        [self showUIImageWithRect:numberRect];
    }
}

- (IBAction)lastAction:(UIButton *)sender {
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    // 轮廓检测函数
    cv::findContours(cvImage, contours,hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE, cvPoint(0, 0));
    
    if (index > 0) {
        --index;
    }
    
    [self takePictureForRectWith:contours];
}


- (IBAction)nextAction:(UIButton *)sender {
    
    std::vector<std::vector<cv::Point>> contours; //定义一个容器来存储所有检测到的轮廊
    std::vector<cv::Vec4i> hierarchy;
    // 轮廓检测函数
    cv::findContours(cvImage, contours,hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE, cvPoint(0, 0));
    
    long max_Index = contours.size();
    
    if (index < max_Index-1) {
        ++index;
    }
    
    [self takePictureForRectWith:contours];
}

// 灰度处理
- (void)GrayDealPicture{
    
    cv::cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    /*----------------------------------------------------------------*/
    // 参数说明:                                                        //
    // cv::InputArray src --输入图像即要进行颜色空间变换的原图像，可以是Mat类  //
    // cv::OutputArray dst --输出图像即进行颜色空间变换后存储图像，也可以Mat类 //
    // int code --转换的代码或标识                                       //
    // int dstCn = 0: 目标图像通道数，如果取值为0，则由src和code决定         //
    /*----------------------------------------------------------------*/
}

// 二值化   cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
- (void)Thresholding{
    
    cv::adaptiveThreshold(cvImage, cvImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 40);
}

// 腐蚀，填充(腐蚀是让黑点变大)
- (void)Erosion{
    
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(15,15));
    cv::erode(cvImage, cvImage, erodeElement);
}

- (void)takePictureForRectWith:(std::vector<std::vector<cv::Point>>)contours{
    
    // 取出对应的区域
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    
    long max_Index = contours.size();
    
    if (max_Index > 0) {
        cv::Rect rect = cv::boundingRect(itContours[index]);
        numberRect = rect;
        printf("X:%d - Y:%d - width:%d - height:%d \n",rect.x,rect.y,rect.width,rect.height);
    }
    
    if (numberRect.width != 0 && numberRect.height != 0) {
        
        [self showUIImageWithRect:numberRect];
    }
}

- (void)showUIImageWithRect:(cv::Rect)numberRect {
    
    // 目标图像
    cv::Mat resultImage;
    
    // 原图 -> Mat
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    
    // 取到对应Rect的目标图像
    resultImage = matImage(numberRect);
    
    // 将目标图像灰度处理
    cv::cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    // 二值化
    cv::adaptiveThreshold(resultImage, resultImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 40);
    
    [self cv_MatToUIImageWithMat:resultImage];
}

- (void)cv_MatToUIImageWithMat:(cv::Mat)Mat {
    // Mat -> UIImage
    UIImage *newImage = MatToUIImage(Mat);
    
    // 供识别的Image赋值
    dis_Img = newImage;
    
    // 显示UIImage图
    CGFloat width = newImage.size.width;
    CGFloat height;
    CGFloat scale = newImage.size.height/newImage.size.width;
    width = width > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.width: width;
    height = width * scale;
    CGRect imgRect = CGRectMake(([UIScreen mainScreen].bounds.size.width - width) * 0.5, 200, width, height);
    self.imageView.frame = imgRect;
    self.imageView.image = newImage;
}

@end
