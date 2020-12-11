//
//  ViewController.m
//  Demo
//
//  Created by 董雷 on 2019/9/19.
//  Copyright © 2019 董雷. All rights reserved.
//

#import "ViewController.h"
#import "WDAlertController.h"
#import <Masonry.h>
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataArr;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UITableView *table = [[UITableView alloc] init];
//    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
//    table.delegate = self;
//    table.dataSource = self;
//    [self.view addSubview:table];
//    [table mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.offset(0);
//    }];
//
//    self.dataArr = @[@"普通标题，普通内容",@"富文本标题，富文本内容",@"有标题，无内容",@"无标题，有内容",@"系统"];
//    [self start:0 end:0];
    [self test1];
}


- (void)test1 {
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = UIColor.lightGrayColor;
    [self.view addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.offset(200);
    }];
    
    UIImageView *image = [[UIImageView alloc] init];
    image.backgroundColor = UIColor.darkGrayColor;
    [backView addSubview:image];
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.left.offset(10);
        make.width.offset(70);
        make.height.offset(60);
    }];
    
    UILabel *title = [[UILabel alloc] init];
    title.numberOfLines = 0;
    title.textColor = UIColor.whiteColor;
    title.text = @"我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题我是标题";
    [backView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(image.mas_right).offset(5);
        make.right.offset(-10);
        make.top.offset(5);
    }];
    
    UILabel *timeTitle = [[UILabel alloc] init];
    timeTitle.numberOfLines = 0;
    timeTitle.textColor = UIColor.whiteColor;
    timeTitle.text = @"拍卖时间:";
    [backView addSubview:timeTitle];
    [timeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(image.mas_right).offset(5);
        make.top.equalTo(title.mas_bottom).offset(5);
        make.width.offset(80);
    }];
    
    UILabel *time = [[UILabel alloc] init];
    time.numberOfLines = 0;
    time.textColor = UIColor.whiteColor;
    time.text = @"2020年9月25日 17:40:29";
    [backView addSubview:time];
    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(timeTitle.mas_right).offset(5);
        make.right.offset(-10);
        make.top.equalTo(title.mas_bottom).offset(5);
    }];
    
    UILabel *addressTitle = [[UILabel alloc] init];
    addressTitle.numberOfLines = 0;
    addressTitle.textColor = UIColor.whiteColor;
    addressTitle.text = @"拍卖地址:";
    [backView addSubview:addressTitle];
    [addressTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(image.mas_right).offset(5);
        make.top.equalTo(time.mas_bottom).offset(5);
        make.width.offset(80);
    }];
    
    UILabel *address = [[UILabel alloc] init];
    address.numberOfLines = 0;
    address.textColor = UIColor.whiteColor;
    address.text = @"我是地址我是地址我是地址我是地址我是地址我是地址我是地址我是地址我是地址我是地址我是地址我是地址";
    [backView addSubview:address];
    [address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressTitle.mas_right).offset(5);
        make.right.offset(-10);
        make.top.equalTo(time.mas_bottom).offset(5);
        make.bottom.offset(-5);
    }];
    
    [address setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}



- (void)start:(NSInteger)start end:(NSInteger)end {
    NSInteger countDownSecond = 7200;
    int second = (int)countDownSecond  % 60;
    int minute = ((int)countDownSecond / 60) % 60;
    int hours = (int)countDownSecond / (60 *60) % 24;
    int days = (int)countDownSecond / (60 *60) / 24;
    
    NSLog(@"%d天 %d时 %d分 %d秒",days,hours,minute,second);
    
}



# pragma mark - tableView delegate  datasource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        switch (indexPath.row) {
            case 0:
                [self showType1];
                break;
            case 1:
                [self showType2];
                break;
            case 2:
                [self showType3];
                break;
            case 3:
                [self showType4];
                break;
            case 4:
                [self showType5];
                break;
            default:
                break;
        }
}

//普通标题，普通内容
- (void)showType1 {
    
    WDAlertController *alert = [WDAlertController alertWithTitle:@"一千年以后" content:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" actionName:@"好听" ActionHandle:^(WDAlertAction * _Nonnull action) {
        
    } cancelAction:YES];
    alert.contentLineSpace = 8;
    alert.actions.firstObject.titleColor = [UIColor blueColor];
    alert.contentAlignment = NSTextAlignmentCenter;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"text1";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"text2";
    }];
    
    [alert show];
}

//富文本标题，富文本内容
- (void)showType2 {

    NSString *contentStr = @"恭喜您已领先！\n此次出价为 RMB 200,000";
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    [content addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Semibold" size:13]} range:[contentStr rangeOfString:@"200,000"]];
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.titleText = @"出价成功";
    alert.attributeContent = content;
    alert.contentAlignment = NSTextAlignmentCenter;
    alert.buttonHeight = 50;
    alert.showBlurBackView = YES;
//    UIView *view = [[UIView alloc] init];
//    UILabel *subView = [[UILabel alloc] init];
//    subView.text = @"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。\n别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞";
//    subView.numberOfLines = 0;
//
//    [view addSubview:subView];
//    [subView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.offset(0);
//        make.right.bottom.offset(-0);
//    }];
//    [subView sizeToFit];
    
    UITableView *table = [[UITableView alloc] init];
       [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
       table.delegate = self;
       table.dataSource = self;
    alert.customView = table;
//    alert.showAreaMarginInsets = UIEdgeInsetsMake(0, 100, 0, 0);
    
    [alert addActionWithTitle:@"取消" font:[UIFont systemFontOfSize:17] color:[UIColor colorWithWhite:11/255.0 alpha:1] handler:nil];
    [alert addActionWithTitle:@"确定" font:nil color:[UIColor colorWithRed:200/255.0 green:22/255.0 blue:30/255.0 alpha:1] handler:nil];
//    [alert addActionWithTitle:@"测试" font:nil color:[UIColor colorWithRed:200/255.0 green:22/255.0 blue:30/255.0 alpha:1] handler:nil];
    [alert show];
}

//有标题，无内容
- (void)showType3 {
//    WDAlertController *alert = [WDAlertController alertWithTitle:@"一千年以后" content:nil actionName:@"好听" ActionHandle:nil cancelAction:YES];
    
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.titleText = @"是否确认删除订单？";
    alert.titleFont = [UIFont systemFontOfSize:18];
    alert.titleColor = [UIColor colorWithWhite:17/255.0 alpha:1];
    alert.topOffset = 20;
    alert.bottomOffset = 20;
    [alert addActionWithTitle:@"取消" font:[UIFont systemFontOfSize:17] color:[UIColor colorWithWhite:11/255.0 alpha:1] handler:nil];
    [alert addActionWithTitle:@"确定" font:[UIFont fontWithName:@"PingFangSC-Medium" size:17] color:[UIColor colorWithRed:200/255.0 green:22/255.0 blue:30/255.0 alpha:1] handler:nil];
    [alert show];
}

//无标题，有内容
- (void)showType4 {
    WDAlertController *alert = [WDAlertController alertWithTitle:nil content:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" actionName:@"好听" ActionHandle:nil cancelAction:YES];
    
    [alert show];
}

- (void)showType5 {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"一千年以后" message:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好听" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:action1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}
@end
