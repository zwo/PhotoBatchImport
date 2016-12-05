//
//  ViewController.m
//  PhotoBatchImport
//
//  Created by zhouweiou on 16/12/5.
//  Copyright © 2016年 R&F Properties. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "PBFileManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface ViewController ()
@property (strong, nonatomic) UITextField *txtFldFolderName;
@property (strong, nonatomic) UILabel *labelStatus;
@property (strong, nonatomic) NSArray *imagePaths;
@property (nonatomic, strong) ALAssetsLibrary * assetsLibrary;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.assetsLibrary=[[ALAssetsLibrary alloc] init];
    [self setupUI];
    [self onBtnRefresh:nil];
}

- (void)setupUI
{
    _labelStatus=[UILabel new];
    _labelStatus.font=[UIFont systemFontOfSize:16];
    _labelStatus.textColor=[UIColor blackColor];
    [self.view addSubview:_labelStatus];
    
    _txtFldFolderName=[UITextField new];
    _txtFldFolderName.clearButtonMode = UITextFieldViewModeWhileEditing;
    _txtFldFolderName.placeholder=@"输入相册名称";
    [self.view addSubview:_txtFldFolderName];
    
    UIButton *btnRefresh=[UIButton buttonWithType:UIButtonTypeSystem];
    [btnRefresh setTitle:@"刷新文件夹图片数据" forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(onBtnRefresh:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRefresh];
    
    UIButton *btnImport=[UIButton buttonWithType:UIButtonTypeSystem];
    [btnImport setTitle:@"导入图片到系统相册" forState:UIControlStateNormal];
    [btnImport addTarget:self action:@selector(onBtnImport:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnImport];
    
    [_txtFldFolderName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width/2);
    }];
    
    [_labelStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(_txtFldFolderName.mas_top).offset(-30);
    }];
    
    [btnRefresh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(_txtFldFolderName.mas_bottom).offset(30);
    }];
    
    [btnImport mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(btnRefresh.mas_bottom).offset(30);
    }];
}

#pragma mark - Action

- (void)onBtnRefresh:(UIButton*)btn
{
    [SVProgressHUD show];
    [PBFileManager queryAllImageFilesInDocumentCompletion:^(NSArray *result) {
        [SVProgressHUD dismiss];
        NSInteger count=[result count];
        self.labelStatus.text=[NSString stringWithFormat:@"当前文件夹中包含图片%zd张",count];
        self.imagePaths=result;
    }];
}

- (void)onBtnImport:(UIButton*)btn
{
    if ([self.imagePaths count]==0) {
        [SVProgressHUD showErrorWithStatus:@"无图片可以保存"];
        return;
    }
    
    if ([self.txtFldFolderName.text length]==0) {
        [SVProgressHUD showErrorWithStatus:@"请填写相册名称"];
        return;
    }
    [self saveImageToAlbum:self.txtFldFolderName.text index:0];
}

- (void)saveImageToAlbum:(NSString *)album index:(NSInteger)index
{
    NSInteger count=[self.imagePaths count];
    [SVProgressHUD showProgress:index/(CGFloat)count status:[NSString stringWithFormat:@"%zd/%zd",index,count]];
    NSString *path=self.imagePaths[index];
    path=[[PBFileManager documentPath] stringByAppendingPathComponent:path];
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    [self.assetsLibrary saveImage:image toAlbum:album completion:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } else {
            NSInteger nextIndex=index+1;
            if (nextIndex==count) {
                [SVProgressHUD showSuccessWithStatus:@"导入完成"];
            } else {
                [self saveImageToAlbum:album index:nextIndex];
            }
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark -- 点击空白处收起键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
