//
//  WYNewRegisterViewController.m
//  WYStreamMaster
//
//  Created by wangjingkeji on 2017/9/25.
//  Copyright © 2017年 Leejun. All rights reserved.
//

#import "WYRegistersViewController.h"
#import "NSString+Value.h"

@interface WYRegistersViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nicknameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *againPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *mailboxField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation WYRegistersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [self setupView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - setup
- (void)setupView
{
    [self.passwordField setTextColor:[UIColor whiteColor]];
    [self.passwordField setPlaceholder:@"请输入密码"];
    
    [self.againPasswordField setTextColor:[UIColor whiteColor]];
    [self.againPasswordField setPlaceholder:@"请再次输入密码"];
    
    [self.mailboxField setTextColor:[UIColor whiteColor]];
    [self.mailboxField setPlaceholder:@"请输入个人邮箱"];
    
    UITapGestureRecognizer *tapGestureView =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureView)];
    [self.view addGestureRecognizer:tapGestureView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - network
- (void)userRegisterRequest{
    NSString *accountText = [_nicknameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordText = [_passwordField.text md5String];
    NSString *re_passwordText = [_againPasswordField.text md5String];
    NSString *emailText = [_mailboxField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //    NSString *agentText = [_agentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![emailText isValidateEmail]) {
        [MBProgressHUD showError:[WYCommonUtils acquireCurrentLocalizedText:@"wy_validate_email_tip"]];
        return;
    }
    
    
    NSString *requestUrl = [[WYAPIGenerate sharedInstance] API:@"apply_anchor"];
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    
    [paramsDic setObject:accountText forKey:@"user_name"];
    [paramsDic setObject:passwordText forKey:@"password"];
    [paramsDic setObject:re_passwordText forKey:@"re_password"];
    [paramsDic setObject:emailText forKey:@"email"];

//    [paramsDic setObject:_avatarUrlStr forKey:@"head_icon"];
//    [paramsDic setObject:_sugaoUrlStr forKey:@"low_pic"];
//    [paramsDic setObject:_makeupUrlStr forKey:@"mid_pic"];
//    [paramsDic setObject:_artsUrlStr forKey:@"hig_pic"];
//    if (self.areaCode.length > 0) {
//        [paramsDic setObject:self.areaCode forKey:@"anchor_country"];//channel_code
//    }
    
    WS(weakSelf)
    [self.networkManager GET:requestUrl needCache:NO parameters:paramsDic responseClass:nil success:^(WYRequestType requestType, NSString *message, id dataObject) {
        NSLog(@"error:%@ data:%@",message,dataObject);
        [MBProgressHUD hideHUD];
        
        if (requestType == WYRequestTypeSuccess) {
            [MBProgressHUD showSuccess:@"注册成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            
            [MBProgressHUD showError:message toView:weakSelf.view];
        }
        
    } failure:^(id responseObject, NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showAlertMessage:[WYCommonUtils acquireCurrentLocalizedText:@"wy_register_result_failure_tip"] toView:weakSelf.view];
    }];
    
}
#pragma mark - event
- (IBAction)backLogin:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickRegisterButton:(UIButton *)sender {
    [self userRegisterRequest];
}

- (void)tapGestureView
{
    [self.nicknameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.againPasswordField resignFirstResponder];
    [self.mailboxField resignFirstResponder];
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