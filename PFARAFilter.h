//
//  PFARAFilter.h
//  PFARA
//
//  Copyright (c) 2014 Weill Cornell Medical College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
#import "OsiriX Headers/DCMObject.h"
#import "OsiriX Headers/DCMAttribute.h"
#import "Osirix Headers/DCMAttributeTag.h"
#include <math.h>

@interface PFARAFilter : PluginFilter {

	IBOutlet NSButton		*btnTest;
	
	IBOutlet NSButton		*btnNextPage;
	IBOutlet NSButton		*btnPrevPage;
	
	IBOutlet NSTextField	*lblRefPt;
	IBOutlet NSButton		*chkQuickReport;
	IBOutlet NSTextField	*txtOsiriXLabel;
	
	IBOutlet NSButton		*btnRefPoint;
	IBOutlet NSButton		*btnPPoints;
	IBOutlet NSButton		*btnVPoints;
	IBOutlet NSButton		*chkSupine;
	
	IBOutlet NSButton		*btnPlotLabels;
	IBOutlet NSButton		*btnPlotCourse;
	IBOutlet NSButton		*btnMeasureLength;
	IBOutlet NSButton		*btnClearPoints;
	IBOutlet NSButton		*btnDrawRectangle;
	IBOutlet NSTextField	*lblAnnotate;
	IBOutlet NSComboBox		*cboPerforators;
	IBOutlet NSButton		*btnClearAnnotations;
	IBOutlet NSButton		*btnSaveCrop;
	IBOutlet NSButton		*chkProjToSkin;
	IBOutlet NSButton		*btnPrev3DImage;
	IBOutlet NSButton		*btnNext3DImage;
	IBOutlet NSButton		*btnSave3DImage;
	IBOutlet NSButton		*btnNextROI;
	IBOutlet NSButton		*btnPrevROI;
	IBOutlet NSButton		*chkAutoDelete;
	IBOutlet NSButton		*chkReviewImg;
	IBOutlet NSButton		*btnSummary;
    IBOutlet NSComboBox     *cboOutputTo;
	IBOutlet NSButton		*btnCreateReport;
	
	IBOutlet NSTextField	*txtPath;
	IBOutlet NSTextField	*txtROI;
	IBOutlet NSTextField	*lblDiameter;
	IBOutlet NSComboBox		*cboDiameter;
	IBOutlet NSTextField	*lblLength;
	IBOutlet NSTextField	*txtLength;
	IBOutlet NSTextField	*lblCourse;
	IBOutlet NSComboBox		*cboCourse;
	IBOutlet NSTextField	*lblBranchOf;
	IBOutlet NSComboBox		*cboBranchOf;
	IBOutlet NSComboBox		*cboRefPt;
	IBOutlet NSTextField	*txtDIEA;
	IBOutlet NSComboBox		*cboLeftDIEA;
	IBOutlet NSComboBox		*cboRightDIEA;
	IBOutlet NSTextField	*lblTransverse;
	IBOutlet NSTextField	*lblAnteroposterior;
	IBOutlet NSTextField	*lblFatThreshold;
	IBOutlet NSSlider		*sldFatRectHeight;
	IBOutlet NSSlider		*sldFatRectWidth;
	IBOutlet NSSlider		*sldFatThreshold;
	IBOutlet NSTextField	*lblFatRectHeightValue;
	IBOutlet NSTextField	*lblFatRectWidthValue;
	IBOutlet NSTextField	*lblFatThresholdValue;
	IBOutlet NSButton		*btnPaintFat;
	IBOutlet NSButton		*btnComputeFat;
	IBOutlet NSTextField	*lblFatVolume;
	IBOutlet NSTextField	*txtFatR; // right fat volume OR singular fat volume value
	IBOutlet NSTextField	*txtFatL; // left fat volume
	IBOutlet NSTextField	*txtFatLblR;
	IBOutlet NSTextField	*txtFatLblL;

	IBOutlet NSTextField	*txtRightDIEA;
	IBOutlet NSTextField	*txtLeftDIEA;
	IBOutlet NSTextField	*txt3DImage;
	
	IBOutlet NSTextField	*txtName;
	IBOutlet NSTextField	*txtMRN;
	
	IBOutlet NSButton		*btnAbout;
	
	IBOutlet NSWindow		*winInterface;
	IBOutlet NSWindow		*winSummary;
	IBOutlet NSTableView	*tblSummary;
	IBOutlet NSArrayController	*summaryController;	
	
	DCMPix					*thisPix;
	NSArray					*pixList;
	NSArray					*roiSeriesList;
	NSArray					*roiImageList;
	ROI						*roi;
	NSMutableArray			*roiPoints;	
	
	float		numSlices; // same as shROISeries, needs this value as a float though
	float		dcmCoords[3];
	NSString	*refPt; //
	short		seriesNum;
	short		leftDIEA;
	short		rightDIEA;
	short		interfaceIndex;	
	
}

- (long) filterImage:		(NSString*) menuName;
- (IBAction) test:				(id)sender;
- (IBAction) clickRefROI:		(id)sender;
- (IBAction) clickROIsP:		(id)sender;
- (IBAction) clickROIsV:		(id)sender;
- (IBAction) clickPrevPage:		(id)sender;
- (IBAction) clickNextPage:		(id)sender;
- (int) getPostProjY2D:		(float)yCoord onSlice:(int)slice withX:(float)xCoord;
- (int) getAntProjY2D:		(float)yCoord onSlice:(int)slice withX:(float)xCoord;
- (BOOL)getPoints;
- (IBAction) clickGetPoints:			(id)sender;
- (void)refreshTable;
- (IBAction) labelPoints:		(id)sender;
- (IBAction) plotCourse:		(id)sender;
- (float) getYOffset;
- (BOOL)fullImgExists:			(NSString*)imgName;
- (BOOL)cropImgExists:			(NSString*)roiID;
- (IBAction) saveImage:			(id)sender;
- (void) updateDistToMid:		(ROI*)curROI;
- (IBAction)selectPerforator:	(id)sender;
- (void)drawAnnotations:		(NSString*)roiID;
- (IBAction)clickClearAnnotations:	(id)sender;
- (IBAction) drawRectangle:		(id)sender;
- (void) saveCrop;
- (void) quitPreview;
- (void) quitTextEdit;
- (IBAction) save3DImage:		(id)sender;
- (void)nextROI;
- (void)prevROI;
- (IBAction) clickNextROI:		(id)sender;
- (IBAction) clickPrevROI:		(id)sender;
- (void)jumpToFirstPerf;
- (void)jumpToLastPerf;
- (IBAction) click3DImage:		(id)sender;
- (IBAction) projToSkin:		(id)sender;
- (void) toggle3DImage;
- (IBAction) refPtChanged:		(id)sender;
- (BOOL) textEditRunning;
- (IBAction) createReport:		(id)sender;
- (IBAction) setLeftDIEA:		(id)sender;
- (IBAction) setRightDIEA:		(id)sender;
- (void) backupDIEA;
- (IBAction) fatAPDimChanged:	(id)sender;
- (IBAction) fatTransverseDimChanged:	(id)sender;
- (IBAction) fatThresholdChanged:	(id)sender;
- (IBAction) paintFat:			(id)sender;
- (IBAction) computeFat:		(id)sender;
- (IBAction) setFat:			(id)sender;
- (void) backupFat;
-(void)openImage;
- (IBAction) measureLength:		(id)sender;
- (IBAction) clickClearPoints:	(id)sender;
- (void) clearPoints;
- (IBAction) setDiameter:		(id)sender;
- (IBAction) setCourse:			(id)sender;
- (IBAction) setBranchOf:		(id)sender;
- (IBAction) clickAbout:		(id)sender;
- (IBAction) clickSummary:		(id)sender;

@property (nonatomic, retain) ROI *roi;
@property (nonatomic, retain) NSMutableArray *roiPoints;
@property (nonatomic, retain) NSString *refPt;

@end
