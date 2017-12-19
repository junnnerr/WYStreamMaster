//
//  WYSpaceDetailViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/11/10.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYSpaceDetailViewController.h"
#import <MJRefresh.h>
#import "YTCommunityDetailCollectionCell.h"
#import "YTClassifyBBSDetailModel.h"
#import "WYCustomActionSheet.h"
#import "WYImagePickerController.h"
#import "UIImage+ProportionalFill.h"
#import "UINavigationBar+Awesome.h"
#import "WYSpaceDetailModel.h"
#import "YTInteractMessageTableViewCell.h"
#import "WYSpaceDetailBottomView.h"
#import "WYLoginManager.h"
#import "ZYZCPlayViewController.h"
#define kClassifyHeaderHeight (kScreenWidth * 210 / 375 + 44)
static NSString *const kCommunityDetailCollectionCell = @"YTCommunityDetailCollectionCell";
static NSString *const kSpaceHeaderView = @"WYSpaceHeaderView";
static NSString *const kInteractMessageTableViewCell = @"YTInteractMessageTableViewCell";

@interface WYSpaceDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) YTClassifyBBSDetailModel *spaceModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WYSpaceDetailBottomView *spaceDetailBottomView;
@property (nonatomic, copy) NSString *parent_id;

@end

@implementation WYSpaceDetailViewController
- (instancetype)init:(YTClassifyBBSDetailModel *)spaceListModel
{
    self = [super init];
    if (self) {
        self.startIndexPage = 1;
        self.spaceModel = spaceListModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"评论详情";
//    self.edgesForExtendedLayout = UIRectEdgeTop;
    [self setupView];
    [self getSpaceRequest];
}

#pragma mark - setup
- (void)setupView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [self.view addGestureRecognizer:tap];
    
    self.collectionView.backgroundColor = [WYStyleSheet currentStyleSheet].themeBackgroundColor;
    
    [self.collectionView registerNib:[UINib nibWithNibName:kCommunityDetailCollectionCell bundle:nil] forCellWithReuseIdentifier:kCommunityDetailCollectionCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kSpaceHeaderView bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSpaceHeaderView];
    
    
    WEAKSELF
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(10);
        make.left.right.width.bottom.equalTo(weakSelf.view);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:kInteractMessageTableViewCell bundle:nil] forCellReuseIdentifier:kInteractMessageTableViewCell];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    CGFloat itemHeight;
    if (self.spaceModel.bbsType == YTBBSTypeText) {
        itemHeight = 138;
    } else if (self.spaceModel.bbsType == YTBBSTypeGraphic) {
        itemHeight = 100.0*kScreenWidth / 375.0 + 168;
    } else if (self.spaceModel.bbsType == YTBBSTypeVideo) {
        itemHeight = 310;
    } else {
        itemHeight = 0.0;
    }
    [self.tableView becomeFirstResponder];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.bottom.equalTo(@-60);
        make.top.mas_offset(itemHeight);
    }];
    
    self.spaceDetailBottomView = [[[NSBundle mainBundle] loadNibNamed:@"WYSpaceDetailBottomView" owner:self options:nil] objectAtIndex:0];
    self.spaceDetailBottomView.spaceDetailTextField.delegate = self;
    [self.spaceDetailBottomView.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.spaceDetailBottomView];
    [self.spaceDetailBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.mas_offset(50);
    }];
}
#pragma mark - event
- (void)sendButtonAction:(UIButton *)sender
{
    [self publishComment:self.parent_id];
}

- (void)viewTapped
{
    [self.spaceDetailBottomView.spaceDetailTextField resignFirstResponder];
    if (self.spaceModel.bbsType == YTBBSTypeVideo) {
        NSString *videosStr = self.spaceModel.videos[0];
//        NSString *videoCoverStr = [videosStr substringToIndex:videosStr.length - 1];
        ZYZCPlayViewController *playVC = [[ZYZCPlayViewController alloc] init];
        playVC.urlString = videosStr;
        playVC.hidesBottomBarWhenPushed = YES;
        [self presentViewController:playVC animated:YES completion:nil];
    }
}
#pragma mark -
#pragma mark - Server
- (void)getSpaceRequest{
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"get_blog_comments"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.spaceModel.identity forKey:@"blog_id"];
    [paramsDic setObject:[NSString stringWithFormat:@"%zd", self.startIndexPage] forKey:@"cur_page"];
    [paramsDic setObject:@"100" forKey:@"page_size"];
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            NSArray *dataArr = [NSArray modelArrayWithClass:[WYSpaceDetailModel class] json:dataObject[@"list"]];
            [weakSelf.dataSource addObjectsFromArray:dataArr];
            [weakSelf.tableView reloadData];
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}

- (void)publishComment:(NSString *)parent_id{
    NSString *auditStatu = [NSString stringWithFormat:@"%@", [WYLoginManager sharedManager].loginModel.audit_statu];

    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"publish_comment"];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:self.spaceModel.identity forKey:@"blog_id"];
//    [paramsDic setObject:[WYLoginUserManager userID] forKey:@"user_code"];
    [paramsDic setObject:self.spaceDetailBottomView.spaceDetailTextField.text forKey:@"content"];
    if ([auditStatu isEqualToString:@"2"]) {
        [paramsDic setObject:@"1" forKey:@"is_anchor"];
    } else {
        [paramsDic setObject:@"0" forKey:@"is_anchor"];
    }

    if ([parent_id length] != 0) {
        [paramsDic setObject:parent_id forKey:@"parent_id"];
    }
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        if (requestType == WYRequestTypeSuccess) {
            weakSelf.dataSource = [NSMutableArray array];
            [weakSelf getSpaceRequest];
            weakSelf.spaceDetailBottomView.spaceDetailTextField.text = @"";
        } else {
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
#pragma - mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YTClassifyBBSDetailModel *model = self.spaceModel;
    CGFloat itemHeight = [YTCommunityDetailCollectionCell heightWithEntity:model];
    return CGSizeMake(kScreenWidth - 12 * 2, itemHeight);
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//
//    return UIEdgeInsetsMake(5, 12, 12, 12);
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeMake(SCREEN_WIDTH, 0.1);
    return headerSize;
}


#pragma mark
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YTCommunityDetailCollectionCell *communityCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommunityDetailCollectionCell forIndexPath:indexPath];
    [communityCell updateCommunifyCellWithData:self.spaceModel];
    return communityCell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
        if (self.spaceModel.bbsType == YTBBSTypeVideo) {
            NSString *videosStr = self.spaceModel.videos[0];
            NSString *videoCoverStr = [videosStr substringToIndex:videosStr.length - 1];
            ZYZCPlayViewController *playVC = [[ZYZCPlayViewController alloc] init];
            playVC.urlString = videoCoverStr;
            playVC.hidesBottomBarWhenPushed = YES;
            [self presentViewController:playVC animated:YES completion:nil];
        }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    return  [model getCellHeigt] + 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YTInteractMessageTableViewCell";
    YTInteractMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYSpaceDetailModel *model = self.dataSource[indexPath.row];
    self.parent_id = model.commentId;
    [self.spaceDetailBottomView.spaceDetailTextField becomeFirstResponder];
    [tableView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
