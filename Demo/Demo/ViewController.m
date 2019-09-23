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
    UITableView *table = [[UITableView alloc] init];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    self.dataArr = @[@"普通标题，普通内容",@"富文本标题，富文本内容",@"有标题，无内容",@"无标题，有内容"];
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
    
    //当cell的selectionStyle = UITableViewCellSelectionStyleNone时，present控制器会有延时，把这个操作放到主线程就可以了
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

//普通标题，普通内容
- (void)showType1 {
    
    WDAlertController *alert = [WDAlertController alertWithTitle:@"一千年以后" content:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" actionName:@"好听" ActionHandle:nil cancelAction:YES];
    
    [alert show];
}

//富文本标题，富文本内容
- (void)showType2 {
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"一千年以后" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
    NSString *contentStr = @"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞";
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:contentStr attributes:@{NSForegroundColorAttributeName : [UIColor brownColor]}];
    [content addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:[contentStr rangeOfString:@"一千年以后"]];
    WDAlertController *alert = [[WDAlertController alloc] init];
    alert.attributeTitle = title;
    alert.attributeContent = content;
    [alert addActionWithTitle:@"好听" handler:nil];
    [alert show];
}

//有标题，无内容
- (void)showType3 {
    WDAlertController *alert = [WDAlertController alertWithTitle:@"一千年以后" content:nil actionName:@"好听" ActionHandle:nil cancelAction:YES];
    [alert show];
}

//无标题，有内容
- (void)showType4 {
    WDAlertController *alert = [WDAlertController alertWithTitle:nil content:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" actionName:@"好听" ActionHandle:nil cancelAction:YES];
    
    [alert show];
}

- (void)showType5 {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"一千年以后" message:@"因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞,因为在一千年以后，世界早已没有我，无法深情挽着你的手，浅吻着你额头。别等到一千年以后，所有人的遗忘了我。那是红色黄昏的沙漠，能有谁解开缠绕千年的寂寞" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.frame = CGRectMake(CGRectGetMinX(textField.frame), CGRectGetMinY(textField.frame), CGRectGetWidth(textField.frame), 100);
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好听" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}
@end
