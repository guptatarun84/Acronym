//
//  AcronymViewController.m
//  Acronym
//
//  Created by Tarun Gupta on 2/22/17.
//  Copyright © 2017 Tarun Gupta. All rights reserved.
//

#import "AcronymViewController.h"
#import "ResponseModel.h"

@interface AcronymViewController ()
	
@property (nonatomic, strong) NSArray *meaningArray;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@end

@implementation AcronymViewController
	
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	
	_meaningArray = [[NSArray alloc] init];
	self.navigationItem.title = @"Search Acronym";
	_searchBar.showsSearchResultsButton = YES;
}
	
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}
	
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	[self searchTableView:theSearchBar.text];
	//	[self addScannerOverLayView]; // Replace it with MBProgressHud
}
	
- (void)searchTableView:(NSString *)searchText {
	[[AcronymNetworkEngine sharedInstance] initiateNetworkRequest:searchText completion:^(NSArray *data, NSError *error) {
		//		NSLog(@"----%@",[data ]);
		ResponseModel *responseModel = data.firstObject;
		//		[self.scannerOverlay removeAnimation]; // Replace it with MBProgressHud
		//		[self.loadingAlert dismiss];
		if(responseModel) {
			_meaningArray = [NSArray arrayWithArray:responseModel.contentArray];
			[_searchDisplayController.searchResultsTableView reloadData];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No content avialable" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			return;
		}
	}];
}
	
	
#pragma mark - UITableViewDatasource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {              // Default is 1 if not implemented
	return 1;
}
	
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [_meaningArray count];
	
}
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	[cell.textLabel setFont:[UIFont fontWithName: @"HelveticaNeue-Italic" size:18.0f]];
	cell.textLabel.text = [_meaningArray objectAtIndex:indexPath.row];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	return cell;
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
