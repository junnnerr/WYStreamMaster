//
//  YTCommunityCollectionCell.m
//  WYTelevision
//
//  Created by Jyh on 2017/4/12.
//  Copyright © 2017年 Zhejiang wangjing network Co., Ltd. All rights reserved.
//

#import "YTCommunityCollectionCell.h"
#import "YTClassifyBBSDetailModel.h"
//#import "YTClassifyCommunityImageView.h"
//#import "YTClassifyBottomView.h"

#define kCommunityAvatarWidth  28

@interface YTCommunityCollectionCell ()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIImageView *genderImageView;
@property (strong, nonatomic) UIImageView *identiImageView;

@property (strong, nonatomic) UIImageView *videoCoverImageView;

@property (strong, nonatomic) UILabel *nickNameLabel;
@property (strong, nonatomic) UILabel *creatDateLabel;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UIButton *gameCategoryButton;

//@property (strong, nonatomic) YTClassifyBottomView *bottomView;
//@property (strong, nonatomic) YTClassifyCommunityImageView *imagesview;

@property (strong, nonatomic) YTClassifyBBSDetailModel *bbsInfo;

@end

@implementation YTCommunityCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupSubViews];
}

+ (CGFloat)heightWithEntity:(YTClassifyBBSDetailModel *)model
{
    if (!model) {
        return 0;
    }
    CGFloat cellHeight = 0;
    CGFloat contentTextY = 60; // 文字的y坐标
    CGFloat imageViewHeight = 100;
    CGFloat videoViewHeight = 160;
    CGFloat categoryHeight = 40;
    CGFloat bottomViewHeight = 38;
    
    cellHeight = contentTextY;
    CGFloat textHeight;
//    textHeight = [WYCommonUtils sizeWithText:model.content font:[UIFont systemFontOfSize:11] width:kScreenWidth - 25*2].height;
    if (textHeight > 40) {
        // 最多显示三行
        textHeight = 40;
    }
    cellHeight += textHeight;
    if (model.bbsType == YTBBSTypeText) {
        // 纯消息
        cellHeight += categoryHeight+20;
        cellHeight += bottomViewHeight;
    } else if (model.bbsType == YTBBSTypeGraphic) {
        // 图文
        cellHeight += imageViewHeight;
        cellHeight += categoryHeight;
        cellHeight += bottomViewHeight;
    } else if (model.bbsType == YTBBSTypeVideo) {
        cellHeight += videoViewHeight;
        cellHeight += categoryHeight;
        cellHeight += bottomViewHeight;
    }
    
//    NSLog(@"计算专区cell的高度是      ……%f",cellHeight);
    return ceilf(cellHeight);
}

- (void)updateCommunifyCellWithData:(YTClassifyBBSDetailModel *)model
{
    if (model) {
        _bbsInfo = model;
        [self.avatarImageView setImageWithURL:model.avatarImageURL placeholder:[UIImage imageNamed:@"common_default_avatar_70"]];
        [self.videoCoverImageView setImageWithURL:model.coverImageURL placeholder:[UIImage imageNamed:@"common_list_placehoder_image"]];
        self.nickNameLabel.text = model.nickName;
        self.identiImageView.hidden = !model.isCertificate;
        self.genderImageView.image = [UIImage imageNamed:model.isFemale ? @"home_female_label" : @"home_male_label"];

        self.titleLabel.text = model.title;
        self.contentLabel.text = model.content;
        
        if (model.bbsType == YTBBSTypeText) {
            
        } else if (model.bbsType == YTBBSTypeGraphic) {
           
        } else if (model.bbsType == YTBBSTypeVideo) {
            self.videoCoverImageView.hidden = NO;
        }
        
        NSAttributedString *buttonString = [[NSAttributedString alloc] initWithString:model.gameName attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"00A3FF"]}];
        [_gameCategoryButton setAttributedTitle:buttonString forState:UIControlStateNormal];
        [_gameCategoryButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 5, 1, 5)];
        CGFloat gameWidth = [model.gameName widthForFont:[UIFont systemFontOfSize:10]] + 10;
        [self.gameCategoryButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(gameWidth);
        }];
        
    }
}

///添加subviews
- (void)setupSubViews {
    WEAKSELF
    self.backgroundColor = [UIColor whiteColor];
    // 头像
    [self addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(12);
        make.top.equalTo(self.mas_top).offset(10);
        make.width.height.mas_equalTo(kCommunityAvatarWidth);
    }];
    
    // 昵称
    [self addSubview:self.nickNameLabel];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.mas_top).offset(-2);
        make.left.equalTo(self.avatarImageView.mas_right).offset(10);
    }];
    
    // 性别
    [self addSubview:self.genderImageView];
    [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.equalTo(self.nickNameLabel.mas_centerY);
        make.left.equalTo(self.nickNameLabel.mas_right).offset(10);
    }];
    
    // 认证标示
    [self addSubview:self.identiImageView];
    [self.identiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.genderImageView.mas_right).offset(10);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(13);
        make.centerY.equalTo(self.nickNameLabel.mas_centerY);
        make.right.lessThanOrEqualTo(self.mas_right).offset(-10);
    }];
    
    // 创建日期
    [self addSubview:self.creatDateLabel];
    [self.creatDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.avatarImageView.mas_bottom).offset(2);
        make.left.equalTo(self.nickNameLabel.mas_left);
        make.right.greaterThanOrEqualTo(self.mas_left).offset(-10).with.priority(10);
    }];
    
    // 标题
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.mas_left);
        make.top.equalTo(self.avatarImageView.mas_bottom).offset(15);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.priority(10);
    }];
    
    // 内容
    [self addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.mas_right).offset(-10);
        make.height.mas_lessThanOrEqualTo(45).with.priority(15);
    }];
    
    // 图片view
//    [self addSubview:self.imagesview];
//    [self.imagesview mas_makeConstraints:^(MASConstraintMaker *make) {
//        STRONGSELF
//        make.top.mas_equalTo(strongSelf.contentLabel.mas_bottom).offset(10);
//        make.left.right.equalTo(strongSelf);
//        make.height.mas_equalTo(80);
//    }];
    
    // 视频封面 宽高比25/14
    [self addSubview:self.videoCoverImageView];
    [self.videoCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(0);
        make.left.equalTo(self.contentLabel.mas_left);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150*25/14);
    }];
    self.videoCoverImageView.hidden = YES;
    
    // 底部操作view
//    [self addSubview:self.bottomView];
//    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        STRONGSELF
//        make.left.bottom.right.equalTo(strongSelf);
//        make.height.mas_equalTo(37);
//    }];
    
    // 游戏分类label
    [self addSubview:self.gameCategoryButton];
    [self.gameCategoryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_top).offset(-10);
        make.left.equalTo(self.contentLabel.mas_left);
        make.height.mas_equalTo(18);
        make.width.mas_lessThanOrEqualTo(200);
    }];
}

#pragma mark
#pragma mark - Private Methods

- (void)pushToPersionalVC
{
    if (self.bbsInfo.userID) {
        WYSuperViewController *vc = [WYCommonUtils getCurrentVC];
        
        
    }
}

#pragma mark
#pragma mark - Getters and Setters

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = kCommunityAvatarWidth / 2.0;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.opaque = NO;
        _avatarImageView.userInteractionEnabled = YES;
        ///先设置个默认头像
        _avatarImageView.image = [UIImage imageNamed:@"common_default_avatar_70"];
        ///添加头像点击事件
        WEAKSELF
        UITapGestureRecognizer *tapAvatar = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weakSelf pushToPersionalVC];
        }];
        [_avatarImageView addGestureRecognizer:tapAvatar];
    }
    
    return _avatarImageView;
}

- (UIImageView *)genderImageView {
    if (!_genderImageView) {
        _genderImageView = [[UIImageView alloc] init];
        _genderImageView.contentMode = UIViewContentModeScaleAspectFill;
        _genderImageView.opaque = NO;
        _genderImageView.image = [UIImage imageNamed:@"home_female_label"];
    }
    
    return _genderImageView;
}

- (UIImageView *)identiImageView {
    if (!_identiImageView) {
        _identiImageView = [[UIImageView alloc] init];
        _identiImageView.contentMode = UIViewContentModeScaleAspectFill;
        _identiImageView.image = [UIImage imageNamed:@"authentication"];
        _identiImageView.opaque = NO;
    }
    
    return _identiImageView;
}

- (UIImageView *)videoCoverImageView {
    if (!_videoCoverImageView) {
        _videoCoverImageView = [[UIImageView alloc] init];
        _videoCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        _videoCoverImageView.opaque = NO;
        _videoCoverImageView.clipsToBounds = YES;
        _videoCoverImageView.image = [UIImage imageNamed:@"common_list_placehoder_image"];
    }
    
    return _videoCoverImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.backgroundColor = [UIColor clearColor];
        _nickNameLabel.numberOfLines = 1;
        _nickNameLabel.font = [UIFont systemFontOfSize:13];
//        _nickNameLabel.text = @"一人我饮酒醉，醉把家人成双对";
        _nickNameLabel.textColor = [WYStyleSheet defaultStyleSheet].navTextColor;
        _nickNameLabel.userInteractionEnabled = YES;
        WEAKSELF
        UITapGestureRecognizer *tapNickname = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [weakSelf pushToPersionalVC];
        }];
        [_nickNameLabel addGestureRecognizer:tapNickname];
    }
    
    return _nickNameLabel;
}

- (UILabel *)creatDateLabel {
    if (!_creatDateLabel) {
        _creatDateLabel = [[UILabel alloc] init];
        _creatDateLabel.backgroundColor = [UIColor clearColor];
        _creatDateLabel.font = [UIFont systemFontOfSize:10];
        _creatDateLabel.textColor = [UIColor colorWithHexString:@"999999"];
//        _creatDateLabel.text = @"2月2日 15:30";
    }
    
    return _creatDateLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textColor = [WYStyleSheet defaultStyleSheet].navTextColor;
//        _titleLabel.text = @"王者农药，天上天下，唯朕独尊";
    }
    
    return _titleLabel;
}


- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 3;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:11];
        _contentLabel.textColor = [UIColor colorWithHexString:@"666666"];
//        _contentLabel.text = @"由于此次为不停机更新，维护时登入游戏，将收到“游戏维护中”的提示，维护完毕后即可正常进入；维护时已经登入游戏的玩家不受任何影响。更新结束后请各位在线的召唤师，切记退出游戏重新登录更新。以免遇到部分素材、资源等无法刷出的异常，影响大家的体验。";
    }
    
    return _contentLabel;
}

- (UIButton *)gameCategoryButton {
    if (!_gameCategoryButton) {
        _gameCategoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _gameCategoryButton.layer.cornerRadius = 3;
        _gameCategoryButton.layer.borderWidth = 1;
        _gameCategoryButton.layer.borderColor = [UIColor colorWithHexString:@"00A3FF"].CGColor;
    }
    
    return _gameCategoryButton;
}

@end
