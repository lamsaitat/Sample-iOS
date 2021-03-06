//
//  BILViewController.m
//  TV Guide
//
//  Created by Cameron Barrie on 26/11/12.
//  Copyright (c) 2012 Bilue. All rights reserved.
//

#import "BILTVGuideViewController.h"
#import "BILTVGuideEpisodeCell.h"
#import "BILTVGuideGridView.h"
#import "BILTVGuideEpisodesRequestModel.h"
#import "Service.h"
#import "Episode.h"

static const NSInteger kEpisodeIntervalInMinute = 5;

@interface BILTVGuideViewController ()

@end

@implementation BILTVGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TV Guide";
    self.gridView = [[BILTVGuideGridView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gridView.dataSource = self;
    self.gridView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [self.view addSubview:self.gridView];
    
    [self.episodesRequestModel loadEpisodes];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.gridView reloadData];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"h:mm a";
    }
    return _dateFormatter;
}

- (BILTVGuideEpisodesRequestModel *)episodesRequestModel
{
    if (_episodesRequestModel == nil) {
        _episodesRequestModel = [[BILTVGuideEpisodesRequestModel alloc] initWithURLPath:kBILTVGuideJSONURL];
        
        __weak BILTVGuideGridView* gridView = self.gridView;
        BILTVGuideEpisodesRequestCompletionBlock completionBlock = ^(){
            [gridView reloadData];
        };
        _episodesRequestModel.completionBlock = completionBlock;
    }
    
    return _episodesRequestModel;
}

- (id)gridView:(BILTVGuideGridView *)gridView objectForIndexPath:(NSIndexPath *)indexPath
{
    Service* service = [self.episodesRequestModel.services objectAtIndex:indexPath.row];
    if (service.episodes.count > indexPath.row) {
        Episode* episode = [service.episodes objectAtIndex:indexPath.column];
        return episode;
    }
    return nil;
}

- (CGFloat)gridView:(BILTVGuideGridView *)gridView heightForRowInSection:(NSUInteger)section {
    return 60.0f;
}

- (CGFloat)widthForGridView:(BILTVGuideGridView *)gridView {
    return 10000.f;
}

- (NSInteger)numberOfRowsInGridView:(BILTVGuideGridView *)gridView {
    return self.episodesRequestModel.services.count;
}

- (NSUInteger)numberOfCellsInRow:(NSUInteger)row {
    // Make sure we don't hit out of bounds.  I rather show empty row than crash.
    if (self.episodesRequestModel.services.count <= row) {
        return 0;
    }
    
    Service* service = [self.episodesRequestModel.services objectAtIndex:row];
    return service.episodes.count;
}

- (BILTVGuideCell *)gridView:(BILTVGuideGridView *)gridView cellForIndexPath:(NSIndexPath *)indexPath {
    static  NSString* episodeCell = @"episodeCell";

    BILTVGuideEpisodeCell* cell = (BILTVGuideEpisodeCell *)[self.gridView dequeueReusableCellWithIdentifier:episodeCell];
    if (cell == nil) {
        cell = [[BILTVGuideEpisodeCell alloc] initWithReuseIdentifier:episodeCell];
        cell.dateFormatter = self.dateFormatter;
        cell.backgroundView.image = [[UIImage imageNamed:@"tv-guide-cell"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 5, 44, 5)];
        cell.backgroundView.highlightedImage = [[UIImage imageNamed:@"tv-guide-cell-active"] resizableImageWithCapInsets:UIEdgeInsetsMake(44, 5, 44, 5)];
    }
    
    // Add episodes to the cell here...
    id episode = [gridView.dataSource gridView:gridView objectForIndexPath:indexPath];
    [cell addEpisode:episode];
    
    return cell;
}

- (CGRect)gridView:(BILTVGuideGridView *)gridView frameForCellAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = 200;
    
    CGFloat rowHeight = [gridView.dataSource gridView:gridView heightForRowInSection:indexPath.row];
    CGFloat cellX = cellWidth * indexPath.column;
    
    id object = [gridView.dataSource gridView:gridView objectForIndexPath:indexPath];
    
    if ([object isKindOfClass:[Episode class]]) {
        Episode* episode = object;
        if (indexPath.column > 0) {
            NSIndexPath* previousEpisodeIndexPath = [NSIndexPath indexPathForRow:indexPath.row inColumn:indexPath.column - 1];
            CGRect previousEpisodeFrame = [gridView.dataSource gridView:gridView frameForCellAtIndexPath:previousEpisodeIndexPath];
            
            cellX = previousEpisodeFrame.origin.x + previousEpisodeFrame.size.width;
            cellWidth = episode.runningTime * kEpisodeIntervalInMinute;
        }
    }

    return CGRectMake(cellX, rowHeight * indexPath.row, cellWidth, rowHeight);
}

@end
