//
//  PFARAFilter.m
//  PFARA
//
//  Copyright (c) 2014 Weill Cornell Medical College. All rights reserved.
//

#import "PFARABetaFilter.h"
#import "ROIPoint.h"

@implementation PFARABetaFilter

- (void) initPlugin
{

}

//////////////////////////////////////
//////////	TO DO ////////////////////
//
// revise backup file scheme to include coordinates of each ROI point
// match backup files to ROIPoints in code based on these coordinates; not based on ROI name
// may also want to provide unique identifier to all points within study (0, 1, 2, 3, etc.)
// need to be certain image filenames are updated correctly -> could use the unique ID from above for this
//
//////////////////////////////////////
//////////////////////////////////////


- (long) filterImage:(NSString*) menuName
{
	[NSBundle loadNibNamed:@"PFARA" owner:self];
	
    NSAlert *bugFixAlert = [NSAlert alertWithMessageText:@"Beta Plugin: In development"
                                           defaultButton:@"OK"
                                         alternateButton:nil
                                             otherButton:nil
                               informativeTextWithFormat:@""];
    [bugFixAlert runModal];
    
	roiPoints = [[NSMutableArray alloc] init];
	leftDIEA = 0;
	rightDIEA = 0;
	interfaceIndex = 1; // visible page in the plugin
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	
	// DICOM data needs thisPix before it can work
	///////////////////////////////////////////////////
	// DICOM METADATA!
	NSString        *dcmFilePath;
	NSString		*dcmPatientTag;
	NSString		*dcmMRNTag;
	NSString		*dcmAcqDateTag;
	NSString		*dcmStudyIDTag;
	NSString		*dcmSeriesNumTag;
	
	DCMAttributeTag *dcmTag;
	DCMObject       *dcmObj;
	DCMAttribute    *dcmAttr;
	//DCMAttributeTag *dcmAttrTag;
	
	NSString		*dcmPatientName;
	NSString		*dcmPatientMRN;
	NSString        *dcmPatientAcqDate;
	NSString		*dcmStudyID;
	NSString		*dcmSeriesNum;
	
	
	dcmFilePath = [thisPix sourceFile];
	dcmObj = [DCMObject objectWithContentsOfFile: dcmFilePath decodingPixelData: NO];	
	
	NSString* tmp;
	
	// get patient name
	dcmPatientTag = @"0010,0010"; // patient name
	dcmTag = [DCMAttributeTag tagWithTagString:dcmPatientTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmPatientName = [[dcmAttr value] description];
	
	// get patient MRN
	dcmMRNTag = @"0010,0020"; // MRN
	dcmTag = [DCMAttributeTag tagWithTagString:dcmMRNTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmPatientMRN = [[dcmAttr value] description];
	
	// get acquisition date
	dcmAcqDateTag = @"0008,0022"; // Acquisition Date
	dcmTag = [DCMAttributeTag tagWithTagString:dcmAcqDateTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmPatientAcqDate = [[dcmAttr value] description];

	// get study ID
	dcmStudyIDTag = @"0020,0010"; // study ID
	dcmTag = [DCMAttributeTag tagWithTagString:dcmStudyIDTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmStudyID = [[dcmAttr value] description];

	// get series number
	dcmSeriesNumTag = @"0020,0011"; // series number
	dcmTag = [DCMAttributeTag tagWithTagString:dcmSeriesNumTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmSeriesNum = [[dcmAttr value] description];
	seriesNum = [dcmSeriesNum intValue];
	
	NSString* lastName = @"";
	NSString* firstName = @"";
	
	if([dcmPatientName rangeOfString:@"^"].location == NSNotFound)
	{
		lastName = dcmPatientName;
		//tmp = [NSString stringWithFormat:@"%@-%@/%@/Series %d", dcmPatientMRN, dcmPatientName, dcmPatientAcqDate, seriesNum];
		tmp = [NSString stringWithFormat:@"%@-%@/%@/%@*Series %d", dcmPatientMRN, lastName, dcmPatientAcqDate, dcmStudyID, seriesNum];
	}
	else
	{
		NSArray *substrings = [dcmPatientName componentsSeparatedByString:@"^"];
		lastName = [substrings objectAtIndex:0];
		firstName = [substrings objectAtIndex:1];
		
		tmp = [NSString stringWithFormat:@"%@-%@ %@/%@/%@*Series %d", dcmPatientMRN, lastName, firstName, dcmPatientAcqDate, dcmStudyID, seriesNum];
	}

	///////////////////////////////////////////
	// Create/Set Path to save patient files
	NSError	*error = nil;
	NSString *patientDir = [NSString stringWithFormat:@"%@/Desktop/PFA Reports/%@", NSHomeDirectory(), tmp];
	[[NSFileManager defaultManager] createDirectoryAtPath:patientDir 
							  withIntermediateDirectories:YES
											   attributes:nil
													error:&error];
	if(error != nil)
	{
		NSLog(@"Error creating directory!\n%@", error);
	}

	[txtName setStringValue:[NSString stringWithFormat:@"%@ %@", lastName, firstName]];
	[txtMRN setStringValue:dcmPatientMRN];
	[txtPath setStringValue:patientDir];
	
	///////////////////////////////////////////////////////////
	
	error = nil;
	NSString *archive = [NSString stringWithFormat:@"%@/archive", [txtPath stringValue]];
	[[NSFileManager defaultManager] createDirectoryAtPath:archive 
							  withIntermediateDirectories:YES
											   attributes:nil
													error:&error];
	if(error != nil)
	{
		NSLog(@"Error creating directory!\n%@", error);
	}
	
	pixList = nil;
	thisPix = nil;
	
	return 0;

}

- (IBAction)test:(id)sender
{
	NSAlert *myAlert;
    NSString *outputTo = [cboOutputTo stringValue];

    // determine output type
    if([outputTo isEqualToString:@"Word"]) {
        myAlert = [NSAlert alertWithMessageText:@"Word"
                                  defaultButton:@"OK"
                                alternateButton:nil
                                    otherButton:nil
                      informativeTextWithFormat:@""];
        [myAlert runModal];
    }
    else if([outputTo isEqualToString:@"TextEdit"]){
        myAlert = [NSAlert alertWithMessageText:@"TextEdit"
                                  defaultButton:@"OK"
                                alternateButton:nil
                                    otherButton:nil
                      informativeTextWithFormat:@""];
        [myAlert runModal];
    }
    else{
        myAlert = [NSAlert alertWithMessageText:@"No output format specified"
                                  defaultButton:@"OK"
                                alternateButton:nil
                                    otherButton:nil
                      informativeTextWithFormat:@"Please select from the dropdown"];
        [myAlert runModal];
    }
    
    /*
	for(ROIPoint *pt in roiPoints)
	{
		msg = [NSString stringWithFormat:@"id:%@\nx:%f\ny:%f\nz:%f", pt.roiID, pt.x3D, pt.y3D, pt.z3D];
		myAlert = [NSAlert alertWithMessageText:msg
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@""];
		[myAlert runModal];		
	}
    */
}

- (IBAction)clickRefROI: (id)sender
{
	NSString *msg;
	NSAlert *myAlert;
	
	int i;
	int j;
	int seriesROIs;
	int imageROIs;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	seriesROIs   = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];
	
	BOOL refPtFound = NO;
	
	// check if reference point already exists
	for(i = 0; i < seriesROIs; i++)
	{
		if(refPtFound)
		{
			break;
		}
		
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs       = [roiImageList  count];
		
		for(j = 0; j < imageROIs; j++)
		{
			roi = [roiImageList objectAtIndex:j];
			if([[roi name] isEqualToString:@"IGC"] || [[roi name] isEqualToString:@"SGC"] || [[roi name] isEqualToString:@"SSN"] || [[roi name] isEqualToString:@"UMB"])
			{
				refPtFound = YES;
				[roi setName:[cboRefPt stringValue]];
				[btnPPoints setEnabled:YES];
				
				break;
			}
		}
	}
	
	if(!refPtFound)
	{
		// no reference point already defined
		for(i = 0; i < seriesROIs; i++)
		{
			thisPix      = [pixList       objectAtIndex: i];
			roiImageList = [roiSeriesList objectAtIndex: i];
			imageROIs       = [roiImageList  count];
			
			for(j = 0; j < imageROIs; j++)
			{	
				roi = [roiImageList objectAtIndex:j];
				
				if([roi type] == t2DPoint && ([[roi name] characterAtIndex:0] != 'L' && [[roi name] characterAtIndex:0] != 'R' && [[roi name] characterAtIndex:0] != 'V')) // only find ROI points
				{
					if(refPtFound)
					{
						msg = [NSString stringWithFormat:@"Multiple unnamed points identified!"];
						myAlert = [NSAlert alertWithMessageText:msg
												  defaultButton:@"OK"
												alternateButton:nil
													otherButton:nil
									  informativeTextWithFormat:@"Please review and remove non-reference points"];
						[myAlert runModal];
						break;
						
					}
					refPtFound = YES;
					
					[roi setName:[cboRefPt stringValue]];
					[btnPPoints setEnabled:YES];
				}
			}
		}
		
		if(!refPtFound)
		{
			myAlert = [NSAlert alertWithMessageText:@"No ROI points found in the series"
									  defaultButton:@"OK"
									alternateButton:nil
										otherButton:nil
						  informativeTextWithFormat:@"Please plot the reference point and try again"];
			[myAlert runModal];
		}
	}

}

- (IBAction)clickROIsP:(id)sender
{
	int i;
	int j;
	int seriesROIs;
	int imageROIs;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	seriesROIs   = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];

	BOOL refPtFound = NO;
	short leftSuffix = 1;
	short rightSuffix = 1;
	float refPtX; // using 2D x-coordinate (pixel) here
	
	// find reference point first
	for(i = 0; i < seriesROIs; i++)
	{
		if(refPtFound)
		{
			break;
		}
		
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs       = [roiImageList  count];
		
		for(j = 0; j < imageROIs; j++)
		{
			roi = [roiImageList objectAtIndex:j];
			if([[roi name] isEqualToString:[cboRefPt stringValue]])
			{
				// get x-coordinate for reference point
				refPtX = [roi centroid].x;
				refPtFound = YES;
				
				break;
			}
		}
	}
	
	
	NSMutableArray *pPts = [[NSMutableArray alloc] init];
		
	for(i = 0; i < seriesROIs; i++)
	{
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs       = [roiImageList  count];
			
		for(j = 0; j < imageROIs; j++)
		{			
			roi = [roiImageList objectAtIndex:j];
			
			if([roi type] == t2DPoint) // only find ROI points
			{
				roi = [roiImageList objectAtIndex:j];
				
				if([[roi name] characterAtIndex:0] == 'L' || [[roi name] characterAtIndex:0] == 'R' || [[roi name] characterAtIndex:0] == 'P')
				{
					// add to temp array
					ROIPoint* pt = [[ROIPoint alloc] init];
					pt.roiID = [roi name];
					pt.x2D = [roi centroid].x;
					pt.y2D = [roi centroid].y;
					pt.slice = i;
					pt.distToMid = fabsf(pt.x2D - refPtX);
					
					[pPts addObject:pt];
				}	
			}
		}	
	}
	
	
	// pPts has all unlabeled and L/R-labeled ROI points
	// sort this array to meet labeling convention		
	
	NSSortDescriptor *sortDesc1;
	NSSortDescriptor *sortDesc2;
	
	sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"slice"
											ascending: NO];
	sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"distToMid"
											ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObjects: sortDesc1, sortDesc2, nil];
	
	[pPts sortUsingDescriptors:sortDescriptors];
	
	// (re-)label the points
	for(ROIPoint *pt in pPts)
	{
		roiImageList = [roiSeriesList objectAtIndex:pt.slice];
		
		imageROIs = [roiImageList count];
		
		for(j = 0; j < imageROIs; j++)
		{
			roi = [roiImageList objectAtIndex:j];
			
			if((pt.x2D == [roi centroid].x) && (pt.y2D == [roi centroid].y))
			{
				if(pt.x2D < refPtX)
				{
					if([chkSupine state] == NSOffState)
					{
						//if(([[roi name] characterAtIndex:0] != 'L') || ([[roi name] characterAtIndex:0] != 'R'))
						//{
							// new point found; all following (inferior) points on the same side (L/R) will be re-labeled as one index greater
							// need to deal with backup files that already exist in this case
							// images are also indexed incorrectly in this case
						//}
						
						[roi setName:[NSString stringWithFormat:@"L%d", leftSuffix]];
						leftSuffix = leftSuffix + 1;
					}
					else
					{
						[roi setName:[NSString stringWithFormat:@"R%d", rightSuffix]];
						rightSuffix = rightSuffix + 1;
					}

				}
				else
				{
					if([chkSupine state] == NSOffState)
					{
						[roi setName:[NSString stringWithFormat:@"R%d", rightSuffix]];
						rightSuffix = rightSuffix + 1;	
					}
					else
					{
						[roi setName:[NSString stringWithFormat:@"L%d", leftSuffix]];
						leftSuffix = leftSuffix + 1;
					}
				}

			}
		}
	}

	// validate existing backup/image files with ROIPoints
	
	[pPts release];
	[btnVPoints setEnabled:YES];
}

- (IBAction)clickROIsV:(id)sender
{
	int i;
	int j;

	int seriesROIs;
	int imageROIs;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	seriesROIs   = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];
	
	
	NSMutableArray *vPts = [[NSMutableArray alloc] init];
	
	// find all points to be (re-)labeled as V-points
	for(i = 0; i < seriesROIs; i++)
	{
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs       = [roiImageList  count];
		
		for(j = 0; j < imageROIs; j++)
		{			
			roi = [roiImageList objectAtIndex:j];
			
			if([roi type] == t2DPoint) // only find ROI points
			{
				roi = [roiImageList objectAtIndex:j];
				
				if([[roi name] characterAtIndex:0] == 'V' || [[roi name] characterAtIndex:0] == 'P')
				{
					// only modify points already labeled as a V-point or with default name (e.g. 'Point 1')
										 
					// add to temp array
					ROIPoint* pt = [[ROIPoint alloc] init];
					pt.roiID = [roi name];
					pt.x2D = [roi centroid].x;
					pt.slice = i;
					
					[vPts addObject:pt];
				}	
			}
		}	
	}
	
	// vPts has all ROI points
	// sort this array to meet labeling convention		
	NSSortDescriptor *sortDesc1;
	NSSortDescriptor *sortDesc2;
	
	// descending slice number AND x-coordinate (right V-points come before left V-points)
	sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"slice"
											ascending: NO];
	if([chkSupine state] == NSOffState)
	{
		sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"x2D"
												ascending: NO];
	}
	else
	{
		sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"x2D"
												ascending: YES];
	}

	
	NSArray *sortDescriptors = [NSArray arrayWithObjects: sortDesc1, sortDesc2, nil];
	
	[vPts sortUsingDescriptors:sortDescriptors];
	
	short vIndex = 1;
	
	for(ROIPoint *pt in vPts)
	{
		
		roiImageList = [roiSeriesList objectAtIndex:pt.slice];
		 
		imageROIs = [roiImageList count];
		
		for(j = 0; j < imageROIs; j++)
		{
			roi = [roiImageList objectAtIndex:j];
			
			if(pt.x2D == [roi centroid].x)
			{
				// matching on x value to correctly label sequentially
				// right side v-point always comes before left in descending sort for prone positioning
				// if patient was supine for the scan, the sort is ascending to retain right side v-point first
				[roi setName:[NSString stringWithFormat:@"V%d", vIndex]];
			}
		}
		vIndex = vIndex + 1;	
	}
	
	[vPts release];
}

- (int)getPostProjY2D:(float)yCoord onSlice:(int)slice withX:(float)xCoord
{
	float	*fImage; // greyscale
	
	pixList = [viewerController pixList];
	DCMPix *curPix = [pixList objectAtIndex:slice];
	
	int imgWidth = [curPix pwidth];
	
	if(![curPix isRGB])
	{
		
		fImage = [curPix fImage];
		int y;
		
		short lowIntCount = 0; // use to track neighboring low-intensity pixels
		int ySkinCoord;
		
		for(y = (((int)yCoord * imgWidth) + (int)xCoord); y >= 0; y = y - imgWidth)
		{			
			if(fImage[y] < 100.) // pixel intensity threshold
			{
				lowIntCount++;
				if(lowIntCount == 1)
				{
					// store y-coordinate of first low-intensity pixel
					ySkinCoord = y / imgWidth; // integer division trims off x-coordinate value
					
				}
				else if(lowIntCount == 10) // ten sequential low-intensity pixels to return y-coord
				{
					return ySkinCoord;
				}
			}
			else
			{
				// if less than 10 sequential pixels with low-intensity, start counter over again
				lowIntCount = 0;
			}
		}
	}
	
	// if no sequential dark pixels found, return projection to edge of image
	return 0;
	
}

- (int)getAntProjY2D:(float)yCoord onSlice:(int)slice withX:(float)xCoord
{
	float	*fImage; // greyscale
	
	pixList = [viewerController pixList];
	DCMPix *curPix = [pixList objectAtIndex:slice];
	
	int imgHeight = [curPix pheight];
	int imgWidth = [curPix pwidth];
		
	if(![curPix isRGB])
	{		
		fImage = [curPix fImage];
		unsigned int y;
		
		short lowIntCount = 0; // use to track neighboring low-intensity pixels
		int ySkinCoord;
		
		for(y = (((int)yCoord * imgWidth) + (int)xCoord); y <= (imgHeight * imgWidth); y = y + imgWidth)
		{			
			if(fImage[y] < 100.) // pixel intensity threshold
			{
				lowIntCount++;
				if(lowIntCount == 1)
				{
					// store y-coordinate of first low-intensity pixel
					ySkinCoord = y / imgWidth; // integer division trims off x-coordinate value
					
				}
				else if(lowIntCount == 10) // ten sequential low-intensity pixels to return y-coord
				{
					return ySkinCoord;
				}
			}
			else
			{
				// if less than 10 sequential pixels with low-intensity, start counter over again
				lowIntCount = 0;
			}
		}
	}
	
	// if no sequential dark pixels found, return projection to edge of image
	return 512;
	
}

-(IBAction)clickGetPoints:(id)sender
{
	[self getPoints];
}

-(BOOL)getPoints
{
	NSString *msg;
	NSAlert *myAlert;
	
	short i;
	short j;
	short shROIs;
	short shROISeries;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	shROISeries   = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];
	
	NSPoint curPoint;
	
	[roiPoints removeAllObjects];
	
	for(i = 0; i < shROISeries; i++)
	{
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		shROIs       = [roiImageList  count];
		
		for(j = 0; j < shROIs; j++)
		{	
			[viewerController setImageIndex:(shROISeries - (i + 1))];
			roi = [roiImageList objectAtIndex:j];
			
			if([roi type] == t2DPoint) // only add ROI points
			{
				if(([[roi name] isEqualToString:@"IGC"] || [[roi name] isEqualToString:@"SGC"] || [[roi name] isEqualToString:@"SSN"] || [[roi name] isEqualToString:@"UMB"]) && ![[roi name] isEqualToString:[cboRefPt stringValue]])
				{
					// reference point ROI is labeled differently from what is selected in reference point dropdown
					msg = [NSString stringWithFormat:@"Reference point labeled as %@ in OsiriX, but you selected a report type of %@.\n\nPlease correct before continuing.", [roi name], [cboRefPt stringValue]];
					myAlert = [NSAlert alertWithMessageText:@"Reference point naming mismatch!"
											  defaultButton:@"OK"
											alternateButton:nil
												otherButton:nil
								  informativeTextWithFormat:msg];
					[myAlert runModal];
					
					return NO;
				}
				
				if(!([[roi name] characterAtIndex:0] == 'L' || [[roi name] characterAtIndex:0] == 'R' || [[roi name] characterAtIndex:0] == 'V' || [[roi name] isEqualToString:@"IGC"] || [[roi name] isEqualToString:@"SGC"] || [[roi name] isEqualToString:@"SSN"] || [[roi name] isEqualToString:@"UMB"]))
				{
					// unlabeled point found
					msg = [NSString stringWithFormat:@"Unlabeled ROI point found on image %d", (shROISeries - i)];
					myAlert = [NSAlert alertWithMessageText:msg
											  defaultButton:@"OK"
											alternateButton:nil
												otherButton:nil
								  informativeTextWithFormat:@"You must rename or delete this point before trying again"];
					[myAlert runModal];
					
					return NO;
				}
				
				
				// add point to array in memory
				curPoint = [roi centroid];
				
				[[[viewerController imageView] curDCM] convertPixX:(float)curPoint.x pixY:(float)curPoint.y toDICOMCoords:(float *)dcmCoords];
								
				ROIPoint* pt = [[ROIPoint alloc] init];
				pt.roiID = [roi name];
				pt.group = [pt.roiID characterAtIndex:0];
				pt.x2D = curPoint.x;
				pt.y2D = curPoint.y;
				pt.x3D = dcmCoords[0];
				pt.y3D = dcmCoords[1];
				pt.z3D = dcmCoords[2];
				pt.slice = i;
				pt.antProjY2D = (float)[self getAntProjY2D:pt.y2D onSlice:pt.slice withX:pt.x2D];
				pt.postProjY2D = (float)[self getPostProjY2D:pt.y2D onSlice:pt.slice withX:pt.x2D];
				pt.coursePoints = [[NSMutableArray alloc] init];
				
				// populate diam, len, and course if previously defined
				NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], pt.roiID];
				if([[NSFileManager defaultManager] fileExistsAtPath:attrPath])
				{
					NSString* attributes = [NSString stringWithContentsOfFile:attrPath encoding:NSUTF8StringEncoding error:nil];
					
					// parse with "," delimiter
					NSArray *substrings = [attributes componentsSeparatedByString:@","];
					
					// roiID is substring 0
					pt.diameter = [[substrings objectAtIndex:1] floatValue];
					pt.length = [[substrings objectAtIndex:2] floatValue];
					pt.course = [substrings objectAtIndex:3];
					pt.branchOf = [substrings objectAtIndex:4];
					// distToMid (index 5 in the substrings) is updated after setting up array roiPoints
					pt.distToGracilis = [[substrings objectAtIndex:6] floatValue];
				}
				else
				{
					pt.diameter = 0.0; // in mm
					pt.length = 0.0;
					pt.course = @"";
					pt.branchOf = @"";
					pt.distToGracilis = 0.0;
				}
				
				[roiPoints addObject:pt];
			}
					
		}
	}	
	
	float refPtX; // x-coordinate of the reference point
	float refPtZ; // z-coordinate of the reference point
	
	for(ROIPoint *pt in roiPoints)
	{
		// find reference point
		if([pt.roiID isEqualToString:refPt])
		{
			refPtX = pt.x3D;
			refPtZ = pt.z3D;
		}
	}
	
	
	for(ROIPoint *pt in roiPoints)
	{
		// set distToMid for each ROI if not defined; this is straight linear distance in the x-direction from perforator to reference point
		// distToMid is updated for gluteal case during the save crop process
		pt.distToMid = fabsf(pt.x3D - refPtX);
	}
		
	// sort roiPoints
	NSSortDescriptor *sortDesc1;
	NSSortDescriptor *sortDesc2;
	NSSortDescriptor *sortDesc3;
	
	sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"group"
											ascending:YES];
	sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"slice"
											ascending: NO];
	sortDesc3 = [[NSSortDescriptor alloc] initWithKey:@"distToMid"
											ascending: YES];
	
	NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDesc1, sortDesc2, sortDesc3, nil];
	
	[roiPoints sortUsingDescriptors:sortDescriptors];
	
	// clear perforator dropdown list
	[cboPerforators removeAllItems];
	
	// update distToMid and validate perforator locations
	for(ROIPoint *pt in roiPoints)
	{
		// in SGC case, update distToMid value if prior value exists, else set to zero
		if([refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
		{
			NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], pt.roiID];
			if([[NSFileManager defaultManager] fileExistsAtPath:attrPath])
			{
				NSString* attributes = [NSString stringWithContentsOfFile:attrPath encoding:NSUTF8StringEncoding error:nil];
				
				// parse with "," delimiter
				NSArray *substrings = [attributes componentsSeparatedByString:@","];
				
				pt.distToMid = [[substrings objectAtIndex:5] floatValue];
			}
			else
			{
				pt.distToMid = 0.0;
			}			
		}
		
		if([pt.roiID characterAtIndex:0] == 'L' || [pt.roiID characterAtIndex:0] == 'R')
		{
			// perforator points only
			// check for acceptable z-dimension range among perforators
			if([refPt isEqualToString:@"IGC"] && (refPtZ > pt.z3D) && ((refPtZ - pt.z3D) > 70.))
			{
				// Perforator is more than 7cm below the IGC
				msg = [NSString stringWithFormat:@"%@ is %2.2fcm below the %@\nShall I continue with this point?", pt.roiID, ((refPtZ - pt.z3D) / 10.), refPt];
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"NO"
										alternateButton:@"YES"
											otherButton:nil
							  informativeTextWithFormat:@"If NO, you must delete the ROI and re-label all Perforator ROIs before trying again."];

				NSInteger clicked = [myAlert runModal];
				
				if(clicked == NSAlertDefaultReturn)
				{
					[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
					return NO;
				}
			}
			else if([refPt isEqualToString:@"UMB"])
			{
				if((refPtZ < pt.z3D) && ((pt.z3D - refPtZ) > 30.))
				{
					// Perforator is more than 3cm above the UMB
					msg = [NSString stringWithFormat:@"%@ is %2.2fcm above the %@\nShall I continue with this point?", pt.roiID, ((pt.z3D - refPtZ) / 10.), refPt];
					myAlert = [NSAlert alertWithMessageText:msg
											  defaultButton:@"NO"
											alternateButton:@"YES"
												otherButton:nil
								  informativeTextWithFormat:@"If NO, you must delete the ROI and re-label all Perforator ROIs before trying again."];
					
					NSInteger clicked = [myAlert runModal];
					
					if(clicked == NSAlertDefaultReturn)
					{
						[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
						return NO;
					}
				}
				else if((refPtZ > pt.z3D) && ((refPtZ - pt.z3D) > 100.))
				{
					// Perforator is more than 10cm below the UMB
					msg = [NSString stringWithFormat:@"%@ is %2.2fcm below the %@\nShall I continue with this point?", pt.roiID, ((refPtZ - pt.z3D) / 10.), refPt];
					myAlert = [NSAlert alertWithMessageText:msg
											  defaultButton:@"NO"
											alternateButton:@"YES"
												otherButton:nil
								  informativeTextWithFormat:@"If NO, you must delete the ROI and re-label all Perforator ROIs before trying again."];
					
					NSInteger clicked = [myAlert runModal];
					
					if(clicked == NSAlertDefaultReturn)
					{
						[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
						return NO;
					}
				}

			}

			// add each perforator to the dropdown for annotation drawing
			[cboPerforators addItemWithObjectValue:pt.roiID];
			
		}
		
	}
	
	
	[cboBranchOf removeAllItems];
	[cboCourse removeAllItems];
	ROIPoint* pt;
	if([refPt isEqualToString:@"IGC"])
	{
		// skip to second ROI if first is the reference point (should only occur in case of IGC)
		pt = [roiPoints objectAtIndex:1];
		[cboBranchOf addItemWithObjectValue:@"Inferior Gluteal Artery"];
		[cboBranchOf addItemWithObjectValue:@"Profunda Femoral Artery"];
	}
	else
	{
		pt = [roiPoints objectAtIndex:0];

		if([refPt isEqualToString:@"SGC"])
		{
			[cboBranchOf addItemWithObjectValue:@"Inferior Gluteal Artery"];
			[cboBranchOf addItemWithObjectValue:@"Superior Gluteal Artery"];
		}
		else if([refPt isEqualToString:@"SSN"])
		{
			[cboBranchOf addItemWithObjectValue:@"Thoracodorsal Artery"];
			[cboBranchOf addItemWithObjectValue:@"Intercostal Artery"];
		}
		else if([refPt isEqualToString:@"UMB"])
		{
			[cboBranchOf addItemWithObjectValue:@"Deep Inferior Epigastric Artery"];
			[cboBranchOf addItemWithObjectValue:@"Deep Circumflex Iliac Artery"];
		}
	}

	if([refPt isEqualToString:@"SGC"])
	{
		[cboCourse addItemWithObjectValue:@"Through G. Max"];
		[cboCourse addItemWithObjectValue:@"Between bundles of G. Max"];
		[cboCourse addItemWithObjectValue:@"Between G. Max and G. Min"];
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		[cboCourse addItemWithObjectValue:@"Medial Oblique Inferior"];
		[cboCourse addItemWithObjectValue:@"Lateral Oblique Inferior"];
		[cboCourse addItemWithObjectValue:@"Superior"];
		[cboCourse addItemWithObjectValue:@"Posterior"];
		[cboCourse addItemWithObjectValue:@"Posterior and Inferior"];
		[cboCourse addItemWithObjectValue:@"Paramuscular"];
		[cboCourse addItemWithObjectValue:@"Indeterminate"];
	}
	
	// reset perforator in plugin to the first one (typically L1)
	[txtROI setStringValue:pt.roiID];
	[btnPrevROI setEnabled:NO];
	[btnNextROI setEnabled:YES];
	
	// set image to first perforator
	[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
	
	// round to tenth decimal place for diameter and length
	NSString* diamRounded = [NSString stringWithFormat:@"%.1f", pt.diameter];
	[cboDiameter setStringValue:diamRounded];

	NSString* lenRounded = [NSString stringWithFormat:@"%.1f", pt.length];
	[txtLength setStringValue:lenRounded];
	
	[cboCourse setStringValue:pt.course];
	[cboBranchOf setStringValue:pt.branchOf];
	
	
	// load any saved global attributes
	NSString* globalAttrPath;
	NSString* globalAttr;
	NSArray* substrings;
	
	// load Fat values
	globalAttrPath = [NSString stringWithFormat:@"%@/archive/fat.vals", [txtPath stringValue]];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:globalAttrPath])
	{
		globalAttr = [NSString stringWithContentsOfFile:globalAttrPath encoding:NSUTF8StringEncoding error:nil];
		
		// parse with "," delimiter
		substrings = [globalAttr componentsSeparatedByString:@","];
		
		if([[substrings objectAtIndex:0] floatValue] != 0.0)
		{
			NSString *lFatRounded = [NSString stringWithFormat:@"%.1f", [[substrings objectAtIndex:0] floatValue]];
			[txtFatL setStringValue:lFatRounded];
		}
		
		if([[substrings objectAtIndex:1] floatValue] != 0.0)
		{
			NSString *rFatRounded = [NSString stringWithFormat:@"%.1f", [[substrings objectAtIndex:1] floatValue]];
			[txtFatR setStringValue:rFatRounded];
		}
	}
	
	// load DIEA values
	globalAttrPath = [NSString stringWithFormat:@"%@/archive/diea.vals", [txtPath stringValue]];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:globalAttrPath])
	{
		globalAttr = [NSString stringWithContentsOfFile:globalAttrPath encoding:NSUTF8StringEncoding error:nil];
		
		// parse with "," delimiter
		substrings = [globalAttr componentsSeparatedByString:@","];
		
		if([[substrings objectAtIndex:0] intValue] != 0)
		{
			leftDIEA = [[substrings objectAtIndex:0] intValue];
			[cboLeftDIEA setIntValue:leftDIEA];
		}
		
		if([[substrings objectAtIndex:1] intValue] != 0)
		{
			rightDIEA = [[substrings objectAtIndex:1] intValue];
			[cboRightDIEA setIntValue:rightDIEA];
		}
	}
	
	[chkProjToSkin setEnabled:YES];
	
	// populate the ROI summary table
	[self refreshTable];
	
	return YES;
}

- (void)refreshTable
{	
	[summaryController removeObjects:[summaryController arrangedObjects]];
	
	[tblSummary reloadData];
	
	for(ROIPoint *pt in roiPoints)
	{
		[summaryController addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									  pt.roiID, @"point",
									  [NSNumber numberWithFloat:pt.x3D], @"x",
									  [NSNumber numberWithFloat:pt.y3D], @"y",
									  [NSNumber numberWithFloat:pt.z3D], @"z",
									  [NSNumber numberWithInt:((int)numSlices - pt.slice)], @"img",
									  nil]];		
	}
	
	[tblSummary setSortDescriptors:[NSArray arrayWithObjects:
									[NSSortDescriptor sortDescriptorWithKey:@"z" ascending:NO],
									nil]];
	
	[tblSummary reloadData];
}

- (float)getYOffset
{
	unsigned char	*rgbImage; // rgb
	
	pixList = [viewerController pixList];
	
	int		curSlice = [[viewerController imageView] curImage];
	DCMPix	*curPix = [pixList objectAtIndex:curSlice];
	
	int curPos = [curPix pheight] * [curPix pwidth]; // number of pixels
	
	NSString	*tmp;
	NSAlert		*myAlert;
	
	if([curPix isRGB])
	{
		rgbImage = (unsigned char*) [curPix fImage];
		int x, y;
		
		for(y = 100; y < [curPix pheight]; y++) // start at 100 to avoid pixels containing text in corner of image
		{
			for(x = 0; x < [curPix pwidth]; x++)
			{
				curPos = y * [curPix pwidth] + x;
				short RedValue, GreenValue, BlueValue;
				
				// read pixel values
				RedValue = rgbImage[curPos*4 + 1];
				GreenValue = rgbImage[curPos*4 + 2];
				BlueValue = rgbImage[curPos*4 + 3];
				
				if (RedValue > 0 || GreenValue > 0 || BlueValue > 0)
				{					 
					return (float)y;
				}
				
			}
		}
	}
	else
	{
		// greyscale image
		tmp = [NSString stringWithFormat:@"Incorrect image format!"];
		myAlert = [NSAlert alertWithMessageText:tmp
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please select the correct DICOM image."];
		[myAlert runModal];
	}
	return 0.0;
}


- (IBAction)labelPoints:(id)sender
{	
	// labeling points on the saved 3D image
	float xOffset;
	float yOffset;
	float yBound;
	
	NSArray *displayedViewers = [ViewerController getDisplayed2DViewers];
	
	yBound = [self getYOffset];
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID characterAtIndex:0] == 'V')
		{
			continue;
		}
		
		if(([[txt3DImage stringValue] isEqualToString:@"3D-VR"]) && ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"])) // posterior view for IGC/SGC VR
		{
			if ([chkSupine state] == NSOffState)
			{
				if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
				{
					xOffset = 128.0 + ceil(pt.x2D); // left boundary + (x-coord of orig ROI)
				}
				else if(pt.x2D > 383.5)
				{
					xOffset = 128.0 + floor(pt.x2D); // left boundary + (x-coord of orig ROI)
				}
				else
				{
					xOffset = 128.0 + pt.x2D; // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
				}
			}
			else
			{
				// supine -> left/right is flipped
				if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
				{
					xOffset = 128.0 + (512.-ceil(pt.x2D)); // left boundary + (x-coord of orig ROI)
				}
				else if(pt.x2D > 383.5)
				{
					xOffset = 128.0 + (512.-floor(pt.x2D)); // left boundary + (x-coord of orig ROI)
				}
				else
				{
					xOffset = 128.0 + (512.-pt.x2D); // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
				}								
			}
		}
		else if(([[txt3DImage stringValue] isEqualToString:@"3D-MIP"]) || [refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SSN"]) // anterior view for all 3D MIP images and UMB/SSN 3D-VR
		{
			if([chkSupine state] == NSOffState)
			{
				if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
				{
					xOffset = 128.0 + (512.-ceil(pt.x2D)); // left boundary + (x-coord of orig ROI)
				}
				else if(pt.x2D > 383.5)
				{
					xOffset = 128.0 + (512.-floor(pt.x2D)); // left boundary + (x-coord of orig ROI)
				}
				else
				{
					xOffset = 128.0 + (512.-pt.x2D); // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
				}				
			}
			else
			{
				// supine -> left/right is flipped and x-coordinates of ROIs are inversely 
				if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
				{
					xOffset = 128.0 + ceil(pt.x2D); // left boundary + (x-coord of orig ROI)
				}
				else if(pt.x2D > 383.5)
				{
					xOffset = 128.0 + floor(pt.x2D); // left boundary + (x-coord of orig ROI)
				}
				else
				{
					xOffset = 128.0 + pt.x2D; // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
				}
			}
		}
		
		yOffset = yBound + (((numSlices - (float)pt.slice) / numSlices) * (768. - (2. * yBound)));
		
		int j;
		for(j = 0; j < [displayedViewers count]; j++)
		{
			ViewerController *viewer = [displayedViewers objectAtIndex:j];

			if ([[viewer roiList] count] == 1) { // single image series (saved DCM of 3D view)
				
				// Text ROI version
				NSRect textRect;
				
				// Text ROI version
				if(([[txt3DImage stringValue] isEqualToString:@"3D-VR"]) && ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"])) // posterior view for IGC/SGC VR
				{
					if ([pt.roiID characterAtIndex:0] == 'L')
					{
						textRect = NSMakeRect(xOffset - 10, yOffset - 10, 10, 10);
					}
					else if([pt.roiID characterAtIndex:0] == 'R')
					{
						textRect = NSMakeRect(xOffset + 10, yOffset - 10, 10, 10);
					}
					else
					{
						//reference point
						textRect = NSMakeRect(xOffset, yOffset - 10, 10, 10);
					}
				}
				else if(([[txt3DImage stringValue] isEqualToString:@"3D-MIP"]) || [refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SSN"]) // anterior view for all 3D MIP images and UMB/SSN 3D-VR
				{
					if ([pt.roiID characterAtIndex:0] == 'L')
					{
						textRect = NSMakeRect(xOffset + 10, yOffset - 10, 10, 10);
					}
					else if([pt.roiID characterAtIndex:0] == 'R')
					{
						textRect = NSMakeRect(xOffset - 10, yOffset - 10, 10, 10);
					}
					else
					{
						//reference point
						textRect = NSMakeRect(xOffset, yOffset - 10, 10, 10);
					}
				}
				
				ROI *roiTextLbl = [viewerController newROI:tText];
				[roiTextLbl setROIRect:textRect];
				[roiTextLbl setName:pt.roiID];
				[roiTextLbl setOpacity:1.0];
				[roiTextLbl setDisplayTextualData:YES];
				
				if([[txt3DImage stringValue] isEqualToString:@"3D-VR"])
				{
					// black text
					[roiTextLbl setColor:(RGBColor){0, 0, 0}];
				}
				else if([[txt3DImage stringValue] isEqualToString:@"3D-MIP"])
				{
					// white text
					[roiTextLbl setColor:(RGBColor){65535, 65535, 65535}];
				}
				[[[viewerController roiList] objectAtIndex:0] addObject:roiTextLbl];
				
				/* // Invisible ROI point version // not as friendly for labeling, although they do automatically avoid overlapping
				ROI *newROI = [viewer newROI:t2DPoint];
				
				[newROI setROIRect:myRect];
				[newROI setName:pt.roiID];
				[[[viewer roiList] objectAtIndex:0] addObject:newROI];
				[newROI setOpacity:0.0]; // sets new ROIs to be invisible
				*/
			}			
		}
	}
	
	[viewerController needsDisplayUpdate];
}

-(IBAction)plotCourse:(id)sender
{
	if([[txt3DImage stringValue] isEqualToString:@"3D-MIP"])
	{
		// only plotting course on 3D-VR for now
		return;
	}
	
	float xOffset;
	float yOffset;
	float yBound;
	
	NSArray *displayedViewers = [ViewerController getDisplayed2DViewers];
	
	float minDiameter = 10.0;
	float maxDiameter = 0.0;
	
	// find perforator diameter range
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID characterAtIndex:0] == 'V' || [pt.roiID isEqualToString:refPt])
		{
			// skip V-points and reference point
			continue;
		}
		
		if(pt.diameter < minDiameter)
		{
			minDiameter = pt.diameter;
		}
		
		if(pt.diameter > maxDiameter)
		{
			maxDiameter = pt.diameter;
		}
	}
	
	float sizeInterval = (maxDiameter - minDiameter) / 3;

	float smMedBound = minDiameter + sizeInterval;
	float medLgBound = maxDiameter - sizeInterval;
	
	// plot vessel course
	yBound = [self getYOffset];
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID characterAtIndex:0] == 'V' || [pt.roiID isEqualToString:refPt])
		{
			continue;
		}
		
		// no course to draw for SGC and SSN reference point cases
		if(([[txt3DImage stringValue] isEqualToString:@"3D-VR"]) && [refPt isEqualToString:@"IGC"]) // posterior view for IGC VR
		{
			if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
			{
				xOffset = 128.0 + ceil(pt.x2D); // left boundary + (x-coord of orig ROI)
			}
			else if(pt.x2D > 383.5)
			{
				xOffset = 128.0 + floor(pt.x2D); // left boundary + (x-coord of orig ROI)
			}
			else
			{
				xOffset = 128.0 + pt.x2D; // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
			}			
		}
		else if(([[txt3DImage stringValue] isEqualToString:@"3D-MIP"]) || [refPt isEqualToString:@"UMB"]) // anterior view for all 3D MIP images and UMB 3D-VR
		{
			if (pt.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
			{
				xOffset = 128.0 + (512.-ceil(pt.x2D)); // left boundary + (x-coord of orig ROI)
			}
			else if(pt.x2D > 383.5)
			{
				xOffset = 128.0 + (512.-floor(pt.x2D)); // left boundary + (x-coord of orig ROI)
			}
			else
			{
				xOffset = 128.0 + (512.-pt.x2D); // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
			}
		}
		
		
		yOffset = yBound + (((numSlices - (float)pt.slice) / numSlices) * (768. - (2. * yBound)));
		
		int j;
		for(j = 0; j < [displayedViewers count]; j++)
		{
			ViewerController *viewer = [displayedViewers objectAtIndex:j];

			if ([[viewer roiList] count] == 1)
			{
				// single image series (saved DCM of 3D view)

				// plot vessel course
				ROI *courseROI = [viewerController newROI: tOPolygon];
				 
				NSMutableArray *tmpPoints = [courseROI points];
				
				// plot coords of perforator ROI as first point in tOPolygon
				[tmpPoints addObject:[viewerController newPoint:xOffset :yOffset]];
				 
				for(ROIPoint* coursePoint in [pt coursePoints])
				{
					if(([[txt3DImage stringValue] isEqualToString:@"3D-VR"]) && ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"])) // posterior view for IGC/SGC VR
					{
						if (coursePoint.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
						{
							xOffset = 128.0 + ceil(coursePoint.x2D); // left boundary + (x-coord of orig ROI)
						}
						else if(coursePoint.x2D > 383.5)
						{
							xOffset = 128.0 + floor(coursePoint.x2D); // left boundary + (x-coord of orig ROI)
						}
						else
						{
							xOffset = 128.0 + coursePoint.x2D; // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
						}			
					}
					else if(([[txt3DImage stringValue] isEqualToString:@"3D-MIP"]) || [refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SSN"]) // anterior view for all 3D MIP images and UMB 3D-VR
					{
						if (coursePoint.x2D < 383.5) // 383.5 = horizontal midpoint of image (with width of 768 px)
						{
							xOffset = 128.0 + (512.-ceil(coursePoint.x2D)); // left boundary + (x-coord of orig ROI)
						}
						else if(pt.x2D > 383.5)
						{
							xOffset = 128.0 + (512.-floor(coursePoint.x2D)); // left boundary + (x-coord of orig ROI)
						}
						else
						{
							xOffset = 128.0 + (512.-coursePoint.x2D); // left boundary + (x-coord of orig ROI); (128 = (768 - 512) / 2)	
						}
					}
				 
					yOffset = yBound + (((numSlices - (float)coursePoint.slice) / numSlices) * (768. - (2. * yBound)));
				 
					[tmpPoints addObject:[viewerController newPoint:xOffset  :yOffset]];
				}
				 
				[[[viewerController roiList] objectAtIndex:0] addObject:courseROI];
				[courseROI setOpacity:0.25]; // decreased opacity to make occasional connection of first and last points in tOPolygon nearly invisible
				[courseROI setDisplayTextualData:NO];
				[courseROI setColor:(RGBColor){0, 0, 0}];
				
				if(pt.diameter >= medLgBound)
				{
					[courseROI setThickness:6.0];
				}
				else if((pt.diameter < medLgBound) && (pt.diameter >= smMedBound))
				{
					[courseROI setThickness:4.0];
				}
				else if(pt.diameter < smMedBound)
				{
					[courseROI setThickness:2.0];
				}
			}			
		}
	}
	
	[viewerController needsDisplayUpdate];
}

- (BOOL)roiBackupExists
{
	NSArray *patientDirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[txtPath stringValue] error:nil];
	
	for(NSString* file in patientDirFiles)
	{
		if ([[file pathExtension] isEqualToString:@"rois_series"])
		{
			return YES;
		}
	}
	
	return NO;
}

- (IBAction)saveImage:(id)sender
{
	NSString	*msg;
	NSAlert		*myAlert;	
	
	if(![self roiBackupExists])
	{
		myAlert = [NSAlert alertWithMessageText:@"Default directory for files not set!"
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please set the default directory by saving a file (e.g. ROI series) from within OsiriX to the study/series directory"];
		[myAlert runModal];
		return;
	}
	
	pixList       = [viewerController pixList];	
	int curSlice  = [[viewerController imageView] curImage];
	thisPix       = [pixList objectAtIndex: curSlice];
	roiSeriesList = [viewerController roiList];
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];
	
	// scale to fit
	[[viewerController imageView] scaleToFit];
	
	NSArray *displayedViewers = [ViewerController getDisplayed2DViewers];
	
	short i, j, k;
		
	ROI *curROI;
	BOOL rectFound = NO;
	for(j = 0; j < [displayedViewers count]; j++)
	{
		ViewerController *viewer = [displayedViewers objectAtIndex:j];
		
		if ([[viewer roiList] count] == numSlices) // in 2D axial series
		{
			float imgRotation = [[viewerController imageView] rotation];
			
			if(imgRotation != 0.0 && imgRotation != 180.0)
			{
				myAlert = [NSAlert alertWithMessageText:@"Non-standard rotation detected!"
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Please rotate to 0 or 180 degrees and try again."];
				[myAlert runModal];
				return;
			}			
			
			if([refPt isEqualToString:@"IGC"])
			{
				// find open poly measurement for distance to gracilis
				for(k = 0; k < [roiImageList count]; k++)
				{
					curROI = [roiImageList objectAtIndex:k];
					
					if([curROI type] == tOPolygon)
					{
						float distToGracilis = 0.0;
						NSArray *roiOpenPolyPts = [curROI splinePoints];
						int p;
						
						for(p = 0; p < [roiOpenPolyPts count] - 1; p++)
						{
							distToGracilis = distToGracilis + [curROI LengthFrom:[[roiOpenPolyPts objectAtIndex:p] point] to:[[roiOpenPolyPts objectAtIndex:p+1] point] inPixel:FALSE];
						}
						
						for(ROIPoint *pt in roiPoints)
						{
							if([pt.roiID isEqualToString:[txtROI stringValue]])
							{
								// update the distToGracilis value
								pt.distToGracilis = (distToGracilis * 10); // distToGracilis (from open polygon) is in cm; we want mm
							}
						}
						
						[viewerController deleteROI:curROI]; // delete open Polygon
					}
				}			
			}
			else if([refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
			{
				BOOL measureFound = NO;
				
				for(k = 0; k < [roiImageList count]; k++)
				{
					curROI = [roiImageList objectAtIndex:k];
					
					if([curROI type] == tOPolygon)
					{
						measureFound = YES;
					}
				}
				
				if(!measureFound)
				{
					msg = [NSString stringWithFormat:@"No measurement along the skin was found for the %@ image\nWould you like to continue?", [txtROI stringValue]];
					myAlert = [NSAlert alertWithMessageText:msg
											  defaultButton:@"NO"
											alternateButton:@"YES"
												otherButton:nil
								  informativeTextWithFormat:@""];
					
					NSInteger clicked = [myAlert runModal];
					
					if(clicked == NSAlertDefaultReturn)
					{
						return;
					}
				}
			}
			
			for(k = 0; k < [roiImageList count]; k++)
			{
				curROI = [roiImageList objectAtIndex:k];
				[curROI setOpacity:1.0]; // make all ROIs max visibility
				
				if([curROI type] == tROI)  // rectangle ROI
				{
					[curROI setDisplayTextualData:YES];
					
					 if(rectFound)
					 {
						 // multiple rectangles detected
						 msg = [NSString stringWithFormat:@"Oh dear! An additional rectangle was detected on the %@ image.", [txtROI stringValue]];
						 myAlert = [NSAlert alertWithMessageText:msg
												   defaultButton:@"OK"
												 alternateButton:nil
													 otherButton:nil
									   informativeTextWithFormat:@"Review rectangles so that only one is present to define your crop boundary."];
						 [myAlert runModal];
						 
						 return;
					 }
					
					rectFound = YES;
				}
				else if([curROI type] == tText)
				{
					// set text size so that pre-function zoom level is normalized
					[curROI setThickness:5.0];
					[viewerController needsDisplayUpdate];
				}
			}
			
			for(k = 0; k < [roiImageList count]; k++)
			{
				curROI = [roiImageList objectAtIndex:k];

				if([curROI type] == tROI)  // rectangle ROI
				{
					rectFound = YES;
					
					// prompt user if file(s) exist
					if([self fullImgExists:[txtROI stringValue]] || [self cropImgExists:[txtROI stringValue]])
					{
						msg = [NSString stringWithFormat:@"An image already exists for perforator %@\nWould you like to overwrite?", [txtROI stringValue]];
						myAlert = [NSAlert alertWithMessageText:msg
												  defaultButton:@"NO"
												alternateButton:@"YES"
													otherButton:nil
									  informativeTextWithFormat:@""];
						
						NSInteger clicked = [myAlert runModal];
						
						if(clicked == NSAlertDefaultReturn)
						{
							return;
						}
						else if(clicked != NSAlertDefaultReturn)
						{
							NSFileManager *fileMgr = [NSFileManager defaultManager];
							[fileMgr removeItemAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [txtPath stringValue], [[txtROI stringValue] lowercaseString]] error:NULL];
							[fileMgr removeItemAtPath:[NSString stringWithFormat:@"%@/%@-crop.jpg", [txtPath stringValue], [[txtROI stringValue] lowercaseString]] error:NULL];
						}
					}
					
					[curROI setDisplayTextualData:NO];
					[curROI setOpacity:0.0]; // make invisible
					
					 
					[viewer exportJPEG:(id)sender];
					
					CGEventSourceRef sourceRef = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
					
					// ***** NOTE: keyboard codes are based on a standard US keyboard layout! Errors may occur if using another keyboard layout! *****
					
					// press enter once
					CGEventRef keyPress = CGEventCreateKeyboardEvent(sourceRef, 36, TRUE);
					CGEventRef keyRelease = CGEventCreateKeyboardEvent(sourceRef, 36, FALSE);
					
					CGEventPost(kCGHIDEventTap, keyPress);
					CGEventPost(kCGHIDEventTap, keyRelease);
					
					CFRelease(keyPress);
					CFRelease(keyRelease);
					
					//*****************
					NSString	*roiName = [[txtROI stringValue] lowercaseString];
					
					int tmpCode;
					for(i = 0; i < [roiName length]; i++)
					{						
						if([roiName characterAtIndex:i] == 'l') tmpCode = 37;
						else if([roiName characterAtIndex:i] == 'r') tmpCode = 15;
						else if([roiName characterAtIndex:i] == '1') tmpCode = 18;
						else if([roiName characterAtIndex:i] == '2') tmpCode = 19;
						else if([roiName characterAtIndex:i] == '3') tmpCode = 20;
						else if([roiName characterAtIndex:i] == '4') tmpCode = 21;
						else if([roiName characterAtIndex:i] == '5') tmpCode = 23;
						else if([roiName characterAtIndex:i] == '6') tmpCode = 22;
						else if([roiName characterAtIndex:i] == '7') tmpCode = 26;
						else if([roiName characterAtIndex:i] == '8') tmpCode = 28;
						else if([roiName characterAtIndex:i] == '9') tmpCode = 25;
						else if([roiName characterAtIndex:i] == '0') tmpCode = 29;				
						else if([roiName characterAtIndex:i] == 'u') tmpCode = 32;
						else if([roiName characterAtIndex:i] == 'm') tmpCode = 46;
						else if([roiName characterAtIndex:i] == 'b') tmpCode = 11;				
						else if([roiName characterAtIndex:i] == 'i') tmpCode = 34;
						else if([roiName characterAtIndex:i] == 's') tmpCode = 1;
						else if([roiName characterAtIndex:i] == 'g') tmpCode = 5;
						else if([roiName characterAtIndex:i] == 'c') tmpCode = 8;
						else tmpCode = 6; // if unexpected character in ROI name, use 'z'
						
						
						keyPress = CGEventCreateKeyboardEvent(sourceRef, tmpCode, TRUE);
						keyRelease = CGEventCreateKeyboardEvent(sourceRef, tmpCode, FALSE);
						
						CGEventPost(kCGHIDEventTap, keyPress);
						CGEventPost(kCGHIDEventTap, keyRelease);
						
						CFRelease(keyPress);
						CFRelease(keyRelease);
					}
						
					// press enter once to save to desktop
					keyPress = CGEventCreateKeyboardEvent(sourceRef, 36, TRUE);
					keyRelease = CGEventCreateKeyboardEvent(sourceRef, 36, FALSE);
					
					CGEventPost(kCGHIDEventTap, keyPress);
					CGEventPost(kCGHIDEventTap, keyRelease);
					
					CFRelease(keyPress);
					CFRelease(keyRelease);
					
					CFRelease(sourceRef);					
				
				}
			}
		}			
	}
	
	if(rectFound)
	{
		// send 'Preview' Quit command to separate thread
		[self performSelectorInBackground:@selector(quitPreview) withObject:nil];
		
		// crop the newly saved image with a separate thread
		[self performSelectorInBackground:@selector(saveCrop) withObject:nil];
		
		if ([refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
		{
			// find open poly measurement and send to thread to update object
			for(k = 0; k < [roiImageList count]; k++)
			{
				curROI = [roiImageList objectAtIndex:k];
				
				if([curROI type] == tOPolygon)
				{
					[self performSelectorInBackground:@selector(updateDistToMid:) withObject:curROI];
				}
			}			
		}
	}
	else
	{
		myAlert = [NSAlert alertWithMessageText:@"Oops! You forgot to define your boundary!"
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please draw a rectangular ROI"];
		[myAlert runModal];
		return;
	}
}

-(void)updateDistToMid:(ROI *)curROI
{	
	sleep(1);
	
	// get length measurement from open polygon for SGC case
	float distToMid = 0.0;
	NSArray *roiOpenPolyPts = [curROI splinePoints];
	int p;
	
	for(p = 0; p < [roiOpenPolyPts count] - 1; p++)
	{
		distToMid = distToMid + [curROI LengthFrom:[[roiOpenPolyPts objectAtIndex:p] point] to:[[roiOpenPolyPts objectAtIndex:p+1] point] inPixel:FALSE];
	}
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:[txtROI stringValue]])
		{
			// update the distToMid value
			pt.distToMid = (distToMid * 10); // distToMid (from open polygon) is in cm; want in mm
		}
	}
	
}

-(IBAction) drawRectangle:(id)sender
{
	int curSlice  = [[viewerController imageView] curImage];
	roiSeriesList = [viewerController roiList];
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];
	
	int refPtX, refPtY;
	
	for(ROIPoint *pt in roiPoints)
	{		
		if([pt.roiID isEqualToString:refPt])
		{
			refPtX = pt.x2D;
			refPtY = pt.y2D;
			break;
		}
	}
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:[txtROI stringValue]])
		{
			ROI *cropRect = [viewerController newROI:tROI];
			
			if([refPt isEqualToString:@"UMB"])
			{
				[cropRect setROIRect:NSMakeRect((refPtX - 150), (refPtY - 20), 300, 65)];
			}
			else if([refPt isEqualToString:@"IGC"])
			{
				if([pt.roiID characterAtIndex:0] == 'L')
				{
					[cropRect setROIRect:NSMakeRect((refPtX - 200), (refPtY - 100), 200, 200)];
				}
				else if([pt.roiID characterAtIndex:0] == 'R')
				{
					[cropRect setROIRect:NSMakeRect(refPtX, (refPtY - 100), 200, 200)];
				}
			}
			else if([refPt isEqualToString:@"SGC"])
			{
				[cropRect setROIRect:NSMakeRect((refPtX - 200), (refPtY - 40), 400, 230)];
			}
			else if([refPt isEqualToString:@"SSN"])
			{
				[cropRect setROIRect:NSMakeRect((refPtX - 230), (refPtY - 205), 460, 250)];
			}
			
			[[[viewerController roiList] objectAtIndex:curSlice] addObject:cropRect];
			[cropRect setOpacity:1.0];
		}
	}
	
	[viewerController needsDisplayUpdate];
}

-(IBAction)selectPerforator:(id)sender
{
	[self drawAnnotations:[cboPerforators stringValue]];
}

-(void)drawAnnotations:(NSString*)roiID
{
	int curSlice  = [[viewerController imageView] curImage];
	roiSeriesList = [viewerController roiList];
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];
	
	int refPtX;
	
	if ([refPt isEqualToString:@"IGC"])
	{
		for(ROIPoint *pt in roiPoints)
		{
			if ([pt.roiID isEqualToString:roiID])
			{
				int i;
				ROI *curROI;
				BOOL distFound = NO;
				
				// for IGC case, check if open polygon measurement (dist posterior from posterior margin of gracilis) has been completed
				for(i = 0; i < [roiImageList count]; i++)
				{
					curROI = [roiImageList objectAtIndex:i];
					
					if([curROI type] == tOPolygon)
					{
						distFound = YES;
					}
				}
				
				if ((!distFound) && (pt.distToGracilis == 0.0)) // check if not measured or not previously defined
				{
					NSString *msg;
					NSAlert *myAlert;
					
					// no distance to gracilis measurement found
					msg = [NSString stringWithFormat:@"Please measure the distance from %@ to the posterior margin of gracilis with an open polygon first.", [txtROI stringValue]];
					myAlert = [NSAlert alertWithMessageText:msg
											  defaultButton:@"OK"
											alternateButton:nil
												otherButton:nil
								  informativeTextWithFormat:@"After drawing the open polygon you will be able to draw annotations."];
					[myAlert runModal];
					
					return;
				}				
			}
		}
	}
	
	for(ROIPoint *pt in roiPoints)
	{		
		if([pt.roiID isEqualToString:refPt])
		{
			refPtX = pt.x2D;
			break;
		}
	}
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:roiID])
		{
			ROI *perfArrow = [viewerController newROI:tArrow];
			ROI *roiTextLbl = [viewerController newROI:tText];
			
			NSMutableArray *arrPts = [perfArrow points];
			
			if(pt.x2D < refPtX)
			{
				if([chkSupine state] == NSOffState)
				{
					// orient arrow pointing to downward left
					[arrPts addObject:[viewerController newPoint:(pt.x2D + 5) :(pt.y2D + 5)]];
					[arrPts addObject:[viewerController newPoint:(pt.x2D + 35) :(pt.y2D + 25)]];
					
					[roiTextLbl setROIRect:NSMakeRect((pt.x2D + 42), (pt.y2D + 32), 10, 10)];
				}
				else
				{
					// orient arrow pointing to downward right
					[arrPts addObject:[viewerController newPoint:(pt.x2D - 5) :(pt.y2D + 5)]];
					[arrPts addObject:[viewerController newPoint:(pt.x2D - 35) :(pt.y2D + 25)]];
					
					[roiTextLbl setROIRect:NSMakeRect((pt.x2D - 42), (pt.y2D + 32), 10, 10)];
				}
				
			}
			else
			{
				if([chkSupine state] == NSOffState)
				{
					// orient arrow pointing to downward right
					[arrPts addObject:[viewerController newPoint:(pt.x2D - 5) :(pt.y2D + 5)]];
					[arrPts addObject:[viewerController newPoint:(pt.x2D - 35) :(pt.y2D + 25)]];
					
					[roiTextLbl setROIRect:NSMakeRect((pt.x2D - 42), (pt.y2D + 32), 10, 10)];
				}
				else
				{
					// orient arrow pointing to downward left
					[arrPts addObject:[viewerController newPoint:(pt.x2D + 5) :(pt.y2D + 5)]];
					[arrPts addObject:[viewerController newPoint:(pt.x2D + 35) :(pt.y2D + 25)]];
					
					[roiTextLbl setROIRect:NSMakeRect((pt.x2D + 42), (pt.y2D - 32), 10, 10)];
				}
				
			}
			
			[perfArrow setOpacity:1.0];
			
			[roiTextLbl setName:pt.roiID];
			[roiTextLbl setOpacity:1.0];
			[roiTextLbl setDisplayTextualData:YES];
			[roiTextLbl setColor:(RGBColor){65535, 65535, 65535}]; // white
			
			// draw
			[[[viewerController roiList] objectAtIndex:curSlice] addObject: perfArrow];
			[[[viewerController roiList] objectAtIndex:curSlice] addObject:roiTextLbl];
			
			[viewerController needsDisplayUpdate];
			
			break;
		}
	}	
}

-(void)clickClearAnnotations:(id)sender
{
	int curSlice  = [[viewerController imageView] curImage];
	roiSeriesList = [viewerController roiList];
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];
	int imageROIs = [roiImageList count];
	int i;
	
	for(i = 0; i < imageROIs; i++)
	{		
		roi = [roiImageList objectAtIndex:i];
		
		if(([roi type] == tArrow) || ([roi type] == tText))
		{
			// ROI name contains "ant" or "post" -> delete it
			[viewerController deleteROI:roi];
			imageROIs = [roiImageList count];
			i--; // have to decrement i as imageROIs is dynamically updating with each ROI deletion
		}
	}
	
	[viewerController needsDisplayUpdate];
}
 
-(void) saveCrop
{	
	sleep(1);
	
	if(![self fullImgExists:[txtROI stringValue]])
	{
		NSString* msg = [NSString stringWithFormat:@"Full image for %@ not found in study directory.", [txtROI stringValue]];
		NSAlert* myAlert = [NSAlert alertWithMessageText:msg
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please set the default directory for file export within OsiriX."];
		[myAlert runModal];
		return;
	}
	
	// load full image
	NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", [txtPath stringValue], [[txtROI stringValue] lowercaseString]];
	NSURL *origImage = [NSURL fileURLWithPath:path];
	CGImageRef imageRef = NULL;
	
	CGImageSourceRef loadRef = CGImageSourceCreateWithURL((CFURLRef)origImage, NULL);
	float fullJPGHeight = 0;
	float fullJPGWidth = 0;
	
	if(loadRef != NULL)
	{
		imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0, NULL);
		fullJPGHeight = CGImageGetHeight(imageRef);
		fullJPGWidth = CGImageGetWidth(imageRef);
		CFRelease(loadRef);
	}
	
	///
	
	roiSeriesList = [viewerController roiList];
	int		curSlice = [[viewerController imageView] curImage];
	roiImageList = [roiSeriesList objectAtIndex:curSlice];
	
	pixList = [viewerController pixList];
	
	DCMPix	*curPix = [pixList objectAtIndex:curSlice];
	
	ROI *curROI;
	int i;
	BOOL rectFound = NO;
	for(i = 0; i < [roiImageList count]; i++)
	{
		curROI = [roiImageList objectAtIndex:i];
		
		// end loop upon finding rectangular ROI
		if([curROI type] == tROI)
		{
			rectFound = YES;
			break;
		}
	}
	
	if(!rectFound)
	{
		NSAlert		*myAlert;
		myAlert = [NSAlert alertWithMessageText:@"Oops! You forgot to define your boundary!"
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please draw a rectangular ROI"];
		[myAlert runModal];
		return;
	}
	
	NSRect roiRect = [curROI rect];
	
	// scale to fit
	[[viewerController imageView] scaleToFit];
	
	// hide ROI text
	[curROI setDisplayTextualData:NO];
	[viewerController needsDisplayUpdate];
	
	float rectWidth = ceil(roiRect.size.width);
	float rectHeight = ceil(roiRect.size.height);
	
	float imgRotation = [[viewerController imageView] rotation];
	float rectX = 0.0;
	float rectY = 0.0;
	
	if(imgRotation == 0.0)
	{
		// default orientation
		rectX = floor(roiRect.origin.x);
		rectY = floor(roiRect.origin.y);	
	}
	else if(imgRotation == 180.0)
	{
		// for images rotated 180 degrees...
		rectX = floor(512. - (roiRect.origin.x + rectWidth)); // 512 is a static value, due to size of DCM images (512x512)
		rectY = floor(512. - (roiRect.origin.y + rectHeight));		
	}
	else
	{
		NSAlert		*myAlert;
		myAlert = [NSAlert alertWithMessageText:@"Please rotate to zero or 180 degrees exactly."
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@""];
		[myAlert runModal];
		return;
	}
	
	float dcmHeight = [curPix pheight];
	float dcmWidth = [curPix pwidth];
	
	int cropOriginX = (rectX / dcmWidth) * fullJPGWidth;
	int cropOriginY = (rectY / dcmHeight) * fullJPGHeight;
	int cropWidth = (rectWidth / dcmWidth) * fullJPGWidth;
	int cropHeight = (rectHeight / dcmHeight) * fullJPGHeight;
	
	
	NSPoint pt = [curROI centroid];
	[[[viewerController imageView] curDCM] convertPixX:(float)pt.x pixY:(float)pt.y toDICOMCoords:(float *)dcmCoords];
	
	///////////////////////////////////////////////////////
	
	
	// create cropped image
	CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, CGRectMake(cropOriginX, cropOriginY, cropWidth, cropHeight));
	
	path = [NSString stringWithFormat:@"%@/%@-crop.jpg", [txtPath stringValue], [[txtROI stringValue] lowercaseString]];
	CFURLRef saveURL = (CFURLRef)[NSURL fileURLWithPath:path];
	CGImageDestinationRef dest = CGImageDestinationCreateWithURL(saveURL,
																 kUTTypeJPEG,
																 1,
																 NULL);
	CGImageDestinationAddImage(dest,
							   croppedImage,
							   nil);
	if(!CGImageDestinationFinalize(dest))
	{
		NSLog(@"Failed to write image to %@", saveURL);
	}
	
	CFRelease(dest);
	CFRelease(imageRef);
	CFRelease(croppedImage);
	
	// show rect ROI text and outline so that subsequent rects are also visible
	[curROI setDisplayTextualData:YES];
	[curROI setOpacity:1.0];
	
	if([chkAutoDelete state] == NSOnState)
	{
		// delete rectangle
		[viewerController deleteROI:curROI];
		
		// delete arrow and label notations
		for(i = 0; i < [roiImageList count]; i++)
		{
			curROI = [roiImageList objectAtIndex:i];
			
			if([curROI type] == tText || [curROI type] == tArrow || [curROI type] == tOPolygon)
			{
				[viewerController deleteROI:curROI];
				i = i - 1;
			}
		}		
	}
	
	[viewerController needsDisplayUpdate];
	
	
	
	// open cropped image for review if necessary
	if([chkReviewImg state] == NSOnState)
	{
		[self performSelectorInBackground:@selector(openImage) withObject:nil];
	}

	// increment ROI
	if([btnNextROI isEnabled])
	{
		sleep(1);
		[self nextROI];
	}
	else
	{
		sleep(1);
		[self jumpToFirstPerf];
	}
	
	
	///////////////////////////////////////
	
}

-(BOOL)fullImgExists:(NSString*)imgName
{
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [txtPath stringValue], imgName]])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)cropImgExists:(NSString*)roiID
{
	if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@-crop.jpg", [txtPath stringValue], roiID]])
	{
		return YES;
	}
	else
	{
		return NO;
	}
	
}

-(IBAction) save3DImage:(id)sender
{			
	NSString *msg;
	NSAlert* myAlert;
	
	if(![self roiBackupExists])
	{
		myAlert = [NSAlert alertWithMessageText:@"Default directory for files not set!"
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please set the default directory by saving a file (e.g. ROI series) from within OsiriX to the study/series directory"];
		[myAlert runModal];
		return;
	}
	
	NSArray *displayedViewers = [ViewerController getDisplayed2DViewers];
	
	int i, j;
	BOOL viewerFound = NO;
	
	for(j = 0; j < [displayedViewers count]; j++)
	{
		ViewerController *viewer = [displayedViewers objectAtIndex:j];
		
		if ([[viewer roiList] count] == 1) // single image (2D rendering of 3D view with text-overlay)
		{
			viewerFound = YES;
			
			// prompt user if file(s) exist
			if([self fullImgExists:[txt3DImage stringValue]])
			{
				msg = [NSString stringWithFormat:@"An image already exists for %@\nWould you like to overwrite?", [txt3DImage stringValue]];
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"NO"
										alternateButton:@"YES"
											otherButton:nil
							  informativeTextWithFormat:@""];
				
				NSInteger clicked = [myAlert runModal];
				
				if(clicked == NSAlertDefaultReturn)
				{
					return;
				}
				else if(clicked != NSAlertDefaultReturn)
				{
					NSFileManager *fileMgr = [NSFileManager defaultManager];
					[fileMgr removeItemAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [txtPath stringValue], [txt3DImage stringValue]] error:NULL];
				}
			}
			
			[viewer exportJPEG:(id)sender];
			
			CGEventSourceRef sourceRef = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
			
			// ***** NOTE: keyboard codes are based on a standard US keyboard layout! Errors may occur if using another keyboard layout! *****
			
			// press enter once
			CGEventRef keyPress = CGEventCreateKeyboardEvent(sourceRef, 36, TRUE);
			CGEventRef keyRelease = CGEventCreateKeyboardEvent(sourceRef, 36, FALSE);
			
			CGEventPost(kCGHIDEventTap, keyPress);
			CGEventPost(kCGHIDEventTap, keyRelease);
			
			CFRelease(keyPress);
			CFRelease(keyRelease);
			// ******************
			
			NSString* imgName = [[txt3DImage stringValue] lowercaseString];

			int tmpCode;
			for(i = 0; i < [imgName length]; i++)
			{				
				if([imgName characterAtIndex:i] == '3') tmpCode = 20;
				else if([imgName characterAtIndex:i] == 'd') tmpCode = 2;
				else if([imgName characterAtIndex:i] == '-') tmpCode = 27;
				else if([imgName characterAtIndex:i] == 'v') tmpCode = 9;
				else if([imgName characterAtIndex:i] == 'r') tmpCode = 15;
				else if([imgName characterAtIndex:i] == 'm') tmpCode = 46;
				else if([imgName characterAtIndex:i] == 'i') tmpCode = 34;
				else if([imgName characterAtIndex:i] == 'p') tmpCode = 35;
				else tmpCode = 6; // if unexpected character in ROI name, use 'z'				
				
				keyPress = CGEventCreateKeyboardEvent(sourceRef, tmpCode, TRUE);
				keyRelease = CGEventCreateKeyboardEvent(sourceRef, tmpCode, FALSE);
				
				//CGEventSetFlags(keyPress, modifierFlags);
				CGEventPost(kCGHIDEventTap, keyPress);
				CGEventPost(kCGHIDEventTap, keyRelease);
				
				CFRelease(keyPress);
				CFRelease(keyRelease);
			}
			
			// press enter once to save to patient dir
			keyPress = CGEventCreateKeyboardEvent(sourceRef, 36, TRUE);
			keyRelease = CGEventCreateKeyboardEvent(sourceRef, 36, FALSE);
			
			CGEventPost(kCGHIDEventTap, keyPress);
			CGEventPost(kCGHIDEventTap, keyRelease);
			
			CFRelease(keyPress);
			CFRelease(keyRelease);
			
			CFRelease(sourceRef);					
			
			// send 'Preview' Quit command to separate thread
			[self performSelectorInBackground:@selector(quitPreview) withObject:nil];
			
			[self toggle3DImage];
		}
	}
	
	if(!viewerFound)
	{
		msg = [NSString stringWithFormat:@"Uh-oh! The %@ DICOM image is not open!", [txt3DImage stringValue]];
		myAlert = [NSAlert alertWithMessageText:msg
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Please confirm you have the saved DICOM of the 3D view open in the viewer, then we can try again"];
		[myAlert runModal];
	}
}

-(void)quitPreview
{
    NSLog(@"Quit Preview Called!");

//	sleep(1);
//	// Quit 'Preview' automatically
//	NSDictionary* errorDict;
//	NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:@"tell application \"Preview\"\nquit\nend tell"];
//	[appleScript executeAndReturnError: &errorDict];
}

-(void)quitTextEdit
{
	// Quit 'TextEdit' automatically
	NSDictionary* errorDict;
	NSAppleScript* appleScript = [[NSAppleScript alloc] initWithSource:@"tell application \"TextEdit\"\nquit\nend tell"];
	[appleScript executeAndReturnError: &errorDict];
}

-(BOOL)textEditRunning
{	
	NSArray* runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
	
	for(id curApp in runningApps)
	{
		if ([[curApp localizedName] isEqualToString:@"TextEdit"])
		{
			return YES;
		}
	}
	
	return NO;
	
}

-(BOOL)perfAttrComplete
{
	if (([chkQuickReport state] == NSOnState) && ([cboDiameter floatValue] > 0.0))
	{
		return YES;
	}
	
	if(([cboDiameter floatValue] > 0.0) && (([txtLength floatValue] > 0.0) || ([[cboCourse stringValue] isEqualToString:@"Indeterminate"]) || ([refPt isEqualToString:@"SGC"]) || ([refPt isEqualToString:@"SSN"])) && (![[cboBranchOf stringValue] isEqualToString:@""]))
	{
		if(([refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SGC"]) && [[cboCourse stringValue] isEqualToString:@""])
		{
			return NO;
		}
		else
		{
			return YES;
		}
	}
	else
	{
		return NO;
	}
}

-(void)nextROI
{	
	// find current ROI
	short index = 0;
	
	NSString* curROI = [txtROI stringValue];
	for(ROIPoint *pt in roiPoints)
	{		
		if([pt.roiID isEqualToString:curROI])
		{
			pt.diameter = [cboDiameter floatValue]; // update diameter for curROI
			pt.length = [txtLength floatValue]; // update length for curROI
			pt.course = [cboCourse stringValue]; // update course for curROI
			pt.branchOf = [cboBranchOf stringValue]; // update branchOf for curROI
			
			NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]];
			
			if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]]])
			{		
				// create new file to store ROI object attributes
				[[NSFileManager defaultManager] createFileAtPath:attrPath contents:nil attributes:nil];
			}
			
			// write attributes to text file
			NSString *objDump = [NSString stringWithFormat:@"%@,%f,%f,%@,%@,%f,%f", pt.roiID, pt.diameter, pt.length, pt.course, pt.branchOf, pt.distToMid, pt.distToGracilis];
			[objDump writeToFile:attrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			
			
			// next ROI /////////
			pt = [roiPoints objectAtIndex:(index + 1)];
			
			// update displayed label and show attributes
			[txtROI setStringValue:pt.roiID];
			
			if([chkAutoDelete state] == NSOnState)
			{
				// only update viewer to new perforator if automatically deleting annotations
				// this allows the user to use the same MIP image for multiple crop image saves, if desired
				[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
			}
			
			NSString* diamRounded = [NSString stringWithFormat:@"%.1f", pt.diameter];
			[cboDiameter setStringValue:diamRounded];
						
			NSString* lenRounded = [NSString stringWithFormat:@"%.1f", pt.length];
			[txtLength setStringValue:lenRounded];
						
			[cboCourse setStringValue:pt.course];
			[cboBranchOf setStringValue:pt.branchOf];
			
			[btnPrevROI setEnabled:YES];
			
			if((index + 1) == ([roiPoints count] - 1))
			{
				// reached end of list (case of IGC and no V points)
				[btnNextROI setEnabled:NO];
				return;
			}
			else
			{
				
				pt = [roiPoints objectAtIndex:(index + 2)]; // set to next ROI (will never reach end of list with V-points present)
				
				if (([pt.roiID isEqualToString:@"SGC"]) || ([pt.roiID isEqualToString:@"SSN"]) || ([pt.roiID isEqualToString:@"UMB"]) || ([pt.roiID characterAtIndex:0] == 'V'))
				{
					// if next ROI is SGC/SSN/UMB ref pt OR a V-point (in case of IGC ref pt), end iteration and return
					[btnNextROI setEnabled:NO];
					return;
				}
				
			}
			
			break;
		}
		index++;
	}	
}

-(IBAction)clickNextROI:(id)sender
{
	[self nextROI];
}

-(void)prevROI
{	
	// find current ROI
	short index = 0;
	
	NSString* curROI = [txtROI stringValue];
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:curROI])
		{
			pt.diameter = [cboDiameter floatValue]; // update diameter for curROI
			pt.length = [txtLength floatValue]; // update length for curROI
			pt.course = [cboCourse stringValue]; // update course for curROI
			pt.branchOf = [cboBranchOf stringValue]; // update branchOf for curROI
			
			NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]];
			
			if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]]])
			{		
				// create new file to store ROI object attributes
				[[NSFileManager defaultManager] createFileAtPath:attrPath contents:nil attributes:nil];
			}
			
			// write attributes to text file
			NSString *objDump = [NSString stringWithFormat:@"%@,%f,%f,%@,%@,%f,%f", pt.roiID, pt.diameter, pt.length, pt.course, pt.branchOf, pt.distToMid, pt.distToGracilis];
			[objDump writeToFile:attrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			
			// prev ROI
			pt = [roiPoints objectAtIndex:(index - 1)];
			
			// update displayed label
			[txtROI setStringValue:pt.roiID];
			
			// set image to this perforator
			[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
			
			NSString* diamRounded = [NSString stringWithFormat:@"%.1f", pt.diameter];
			[cboDiameter setStringValue:diamRounded];
			
			NSString* lenRounded = [NSString stringWithFormat:@"%.1f", pt.length];
			[txtLength setStringValue:lenRounded];
			
			[cboCourse setStringValue:pt.course];
			[cboBranchOf setStringValue:pt.branchOf];
			
			[btnNextROI setEnabled:YES];
			
			if([refPt isEqualToString:@"IGC"])
			{
				// IGC is first in sorted array; check if next prev
				if((index - 2) == 0)
				{
					// prev ROI is ref point and beginning of list
					[btnPrevROI setEnabled:NO];
				}
			}
			else if((index - 1) == 0)
			{
				// at first ROI in the list (case of SGC/UMB)
				[btnPrevROI setEnabled:NO];
			}
			
		}		 
		index++;
	}
	
}

-(IBAction)clickPrevROI:(id)sender
{
	[self prevROI];
}

-(void)jumpToFirstPerf
{
	for(ROIPoint *pt in roiPoints)
	{		
		if([pt.roiID isEqualToString:[txtROI stringValue]])
		{
			//////////// update/save attributes for current ROI
			pt.diameter = [cboDiameter floatValue]; // update diameter for current ROI
			pt.length = [txtLength floatValue]; // update length for current ROI
			pt.course = [cboCourse stringValue]; // update course for current ROI
			pt.branchOf = [cboBranchOf stringValue]; // update branchOf for current ROI
			
			NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]];
			
			if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]]])
			{		
				// create new file to store ROI object attributes
				[[NSFileManager defaultManager] createFileAtPath:attrPath contents:nil attributes:nil];
			}
			
			// write attributes to text file
			NSString *objDump = [NSString stringWithFormat:@"%@,%f,%f,%@,%@,%f,%f", pt.roiID, pt.diameter, pt.length, pt.course, pt.branchOf, pt.distToMid, pt.distToGracilis];
			[objDump writeToFile:attrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			////////////
			
			// move to first perforator
			if([refPt isEqualToString:@"IGC"])
			{
				// skip to second ROI if first is the reference point (should only occur in case of IGC)
				pt = [roiPoints objectAtIndex:1];
			}
			else
			{
				pt = [roiPoints objectAtIndex:0];
			}
			
			[txtROI setStringValue:pt.roiID];
			
			// set diameter
			NSString* diamRounded = [NSString stringWithFormat:@"%.1f", pt.diameter];
			[cboDiameter setStringValue:diamRounded];
			
			// set length
			NSString* lenRounded = [NSString stringWithFormat:@"%.1f", pt.length];
			[txtLength setStringValue:lenRounded];
			
			// set IM Course & branch of
			[cboCourse setStringValue:pt.course];
			[cboBranchOf setStringValue:pt.branchOf];
			
			[btnNextROI setEnabled:YES];
			[btnPrevROI setEnabled:NO];
			
			
			// set image to first perforator
			[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
			
		}
	}
}

-(void)jumpToLastPerf
{
	
}

-(IBAction)refPtChanged:(id)sender
{
	[btnNextPage setEnabled:YES];
	
	[btnRefPoint setEnabled:YES];
	refPt = [cboRefPt stringValue];
	
	if ([refPt isEqualToString:@"IGC"])
	{		
		[btnVPoints setHidden:YES];
		[chkQuickReport setState:0];
		[chkQuickReport setHidden:YES];
		[btnPlotCourse setEnabled:YES];
	}
	else if ([refPt isEqualToString:@"SGC"])
	{
		[btnVPoints setHidden:YES];
		[chkQuickReport setState:0];
		[chkQuickReport setHidden:YES];
		[btnPlotCourse setEnabled:NO];
	}
	else if([refPt isEqualToString:@"SSN"])
	{
		[btnVPoints setHidden:YES];
		[chkQuickReport setState:0];
		[chkQuickReport setHidden:YES];
		[btnPlotCourse setEnabled:NO];
	}
	else if ([refPt isEqualToString:@"UMB"])
	{
		[btnVPoints setHidden:NO];
		[chkQuickReport setHidden:NO];
		[btnPlotCourse setEnabled:YES];
	}
}

-(BOOL)dataComplete
{
	NSString* msg;
	NSString* text;
	NSAlert* myAlert;
	
	// check for 3D images
	if(([chkQuickReport state] == NSOffState) && (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/3d-vr.jpg", [txtPath stringValue]]]))
	{		
		myAlert = [NSAlert alertWithMessageText:@"Uh-oh! You forgot the 3D Volume Rendered image."
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Create the image, then we can try again"];
		[myAlert runModal];
		
		return NO;
	}
	else if(([chkQuickReport state] == NSOffState) && (![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/3d-mip.jpg", [txtPath stringValue]]]))
	{		
		myAlert = [NSAlert alertWithMessageText:@"Uh-oh! You forgot the 3D Max Intensity Projection image."
								  defaultButton:@"OK"
								alternateButton:nil
									otherButton:nil
					  informativeTextWithFormat:@"Create the image, then we can try again"];
		[myAlert runModal];
		
		return NO;
	}
	else if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
	{
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:@"IGC"] || [pt.roiID isEqualToString:@"SGC"] || [pt.roiID isEqualToString:@"SSN"])
			{
				// don't attempt to validate attributes on the reference points
				continue;
			}
			
			text = [NSString stringWithFormat:@"Complete the %@ attributes first, then we can try again.", pt.roiID];
			
			if(pt.diameter == 0.0)
			{				
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the diameter for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if([refPt isEqualToString:@"IGC"] && pt.length == 0.0)
			{
				
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the length for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if([refPt isEqualToString:@"SGC"] && [pt.course isEqualToString:@""])
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the course for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if([pt.branchOf isEqualToString:@""])
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to specify the branching for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if([refPt isEqualToString:@"IGC"] && ([[txtFatL stringValue] isEqualToString:@""] || [[txtFatR stringValue] isEqualToString:@""]))
			{
				// no fat volume required for SGC or SSN cases, so only checking for IGC case here
				msg = @"Uh-oh! You forgot to define the fat volume.";
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Define the fat volume, then we can try again."];
				[myAlert runModal];
				
				return NO;
			}
			else if(![self cropImgExists:pt.roiID])
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to create a cropped image for %@.", pt.roiID];;
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Create the cropped image, then we can try again."];
				[myAlert runModal];
				
				return NO;
			}
		}
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:@"UMB"] || ([pt.roiID characterAtIndex:0] == 'V'))
			{
				// don't attempt to validate attributes on the reference point or V-points
				continue;
			}
			
			text = [NSString stringWithFormat:@"Complete the %@ attributes first, then we can try again.", pt.roiID];
			
			if(pt.diameter == 0.0) {
				
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the diameter for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if(([chkQuickReport state] == NSOffState) && (pt.length == 0.0) && (![pt.course isEqualToString:@"Indeterminate"]))
			{
				
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the length for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if(([chkQuickReport state] == NSOffState) && [pt.course isEqualToString:@""])
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to define the course for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if(([chkQuickReport state] == NSOffState) && [pt.branchOf isEqualToString:@""])
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to specify the branching for %@.", pt.roiID];
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:text];
				[myAlert runModal];
				
				return NO;
			}
			else if([[txtFatR stringValue] isEqualToString:@""])
			{
				msg = @"Uh-oh! You forgot to define the fat volume";
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Define the fat volume, then we can try again."];
				[myAlert runModal];
				
				return NO;
			}
			else if(leftDIEA == 0 || rightDIEA == 0)
			{
				msg = @"Uh-oh! You forgot to specify the DIEA branching pattern.";
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Define the branching pattern, then we can try again."];
				[myAlert runModal];
				
				return NO;
			}
			else if(([chkQuickReport state] == NSOffState) && (![self cropImgExists:pt.roiID]))
			{
				msg = [NSString stringWithFormat:@"Uh-oh! You forgot to create a cropped image for %@.", pt.roiID];;
				
				myAlert = [NSAlert alertWithMessageText:msg
										  defaultButton:@"OK"
										alternateButton:nil
											otherButton:nil
							  informativeTextWithFormat:@"Create the cropped image, then we can try again."];
				[myAlert runModal];
				
				return NO;
			}
		}
	}
	
	return YES;
}

-(IBAction)createReport:(id)sender
{
	[winSummary close];
	[btnSummary setState:NSOffState];
	
	short	refPtImgNum;
	float	refPtX;
	float	refPtZ;
	
	NSAlert* myAlert;
	
	// get reference point attributes and set final ROI attributes
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:refPt])
		{
			refPtImgNum = ((short)numSlices - pt.slice);
			refPtX = pt.x3D;
			refPtZ = pt.z3D;
		}
		else if([pt.roiID isEqualToString:[txtROI stringValue]])
		{			
			pt.diameter = [cboDiameter floatValue]; // update diameter for final ROI
			pt.length = [txtLength floatValue]; // update length for final ROI
			pt.course = [cboCourse stringValue]; // update course for final ROI
			
			NSString* attrPath = [NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]];
			
			if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/%@.attr", [txtPath stringValue], [txtROI stringValue]]])
			{		
				// create new file to store ROI object attributes
				[[NSFileManager defaultManager] createFileAtPath:attrPath contents:nil attributes:nil];
			}
			
			// write attributes to text file
			NSString *objDump = [NSString stringWithFormat:@"%@,%f,%f,%@,%@,%f,%f", pt.roiID, pt.diameter, pt.length, pt.course, pt.branchOf, pt.distToMid, pt.distToGracilis];
			[objDump writeToFile:attrPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}
	}
	
	// confirm fat values are backed up
	[self backupFat];
	
	// confirm data is ready for all perforators
	if(![self dataComplete])
	{
		return;
	}
    
    // determine output type
    NSString *outputTo = [cboOutputTo stringValue];
    
    // determine output type
    if([outputTo isEqualToString:@"Word"]) {
        [self outputToWord:refPtImgNum refX:refPtX refZ:refPtZ];
    }
    else if([outputTo isEqualToString:@"TextEdit"]){
        [self outputToTextEdit:refPtImgNum refX:refPtX refZ:refPtZ];
    }
    else{
        myAlert = [NSAlert alertWithMessageText:@"No output format specified"
                                  defaultButton:@"OK"
                                alternateButton:nil
                                    otherButton:nil
                      informativeTextWithFormat:@"Please select from the dropdown"];
        [myAlert runModal];
        
        return;
    }
    
/*
	// alert user to close TextEdit if already running
	if([self textEditRunning])
	{
		myAlert = [NSAlert alertWithMessageText:@"TextEdit needs to be terminated before generating the report"
								  defaultButton:@"OK, Terminate"
								alternateButton:@"NO"
									otherButton:nil
					  informativeTextWithFormat:@"Please save any open documents"];
		
		NSInteger clicked = [myAlert runModal];
		
		if(clicked == NSAlertDefaultReturn)
		{
			[self quitTextEdit];
		}
		else if(clicked != NSAlertDefaultReturn)
		{
			return;
		}
		
	}

	// Applescript
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString* reportGenScript;
	NSAppleScript* scriptObject;
	NSString* patientPos;
	
	if ([chkSupine state] == NSOnState)
	{
		patientPos = @"supine";
	}
	else
	{
		patientPos = @"prone";
	}

	
	if ([refPt isEqualToString:@"IGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (PAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through posterior thigh muscles.\n\nTechnique: MRA of the lower extremities with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superficial femoral and profunda femoris arteries are widely patent.\n\nInferior Gluteal Crease (IGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"SGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (SGAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through gluteal muscles.\n\nTechnique: MRA of the pelvis with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superior and inferior gluteal arteries are widely patent.\n\nSuperior Gluteal Crease (SGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"SSN"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (TDAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate thoracodorsal artery perforators.\n\nTechnique: MRA of the chest with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ with hands above the head for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBilateral internal mammary and thoracodorsal arteries are widely patent.\n\nSuprasternal Notch (SSN): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		if([chkQuickReport state] == NSOnState)
		{
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: CTA of the abdomen and pelvis with and without contrast. The patient was positioned %@. 3D images were post-processed on a computer workstation.\n\nComparison: None\n\nFindings:\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
		}
		else
		{
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: MRA of the abdomen with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D high resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
		}
	}
	else
	{
		//unknown reference point!
		//refPtText = @"UNKNOWN REFERENCE POINT!";
        reportGenScript = @"";
	}
	
	// Generate text header ///////////////////////
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
	
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
		
	///////////////////// Begin Perforator Distance Measurement Table //////////////////////////////
	int i;
	NSString* side = @"Left";
	float distToRef;
	NSString* locRelToRef;
	
	for(i = 0; i < 2; i++)
	{	
		if ([refPt isEqualToString:@"IGC"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Posterior Thigh Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"SGC"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Gluteal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"SSN"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ TDA Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"UMB"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Abdominal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];
		
		
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID characterAtIndex:0] == [side characterAtIndex:0])
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}

				// matches side of iteration
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%@\t%d: %d\t\t\t%4.1f(%@)\t\t%4.1f\t\t\t\t%1.1f\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), locRelToRef, pt.distToMid, pt.diameter];
				
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V points occur after all relevant ROIs for this table
				break;
			}
			else
			{
				// skip reference point or opposite side of iteration
				continue;
			}
			
		}
		
		side = @"Right";
	}
	
	// Spacing
	reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
	
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];

	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
	
	////////////////////// End Perforator Distance Measurement Table ///////////////////////////////
	
	
	///////////////////// Begin 3D Image Insertion //////////////////////////////
	// 3D images only for full report
	if([chkQuickReport state] == NSOffState)
	{
		NSString *filename3D = @"3d-vr"; // start with 3d-vr image
		
		for(i = 0; i < 2; i++)
		{
			// Image insertion
			reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], filename3D];
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			
			// Spacing
			reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
			
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			
			[scriptObject release];
			
			
			filename3D = @"3d-mip"; // update to MIP for second iteration
		}			
	}
	/////////////////////////// End 3D Image Insertion ////////////////////////////////////////////
	
	/////////////////////////////////////LOOP FOR EACH Individual ROI/////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// individual perforator image/text blocks only present in full report
	if([chkQuickReport state] == NSOffState)
	{
		side = @"left";
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:refPt])
			{
				// no image or text necessary for reference point
				continue;
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V-points; should occur last in sorted array (roiPoints) and on report
				break;
				
			}
			else
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}
				
				if([pt.roiID characterAtIndex:0] == 'R')
				{
					side = @"right";
				}
				
				//////// Individual perforator detailed section
				
				// just first text block
				if ([refPt isEqualToString:@"IGC"])
				{
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the inferior gluteal crease, %6$4.1fmm to the %7$@ of midline, and %8$4.1fmm posterior to the posterior margin of gracilis.  Vessel diameter is %9$1.1fmm. It travels %10$3.1fmm with an intramuscular course before joining the %11$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.distToGracilis, pt.diameter, pt.length, [pt.branchOf lowercaseString]];
				}
				else if([refPt isEqualToString:@"SGC"])
				{
					if([pt.course isEqualToString:@"Through G. Max"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels through the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
					else if([pt.course isEqualToString:@"Between bundles of G. Max"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the bundles of the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
					else if([pt.course isEqualToString:@"Between G. Max and G. Med"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the gluteal maximus and gluteal medius before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
				}
				else if([refPt isEqualToString:@"SSN"])
				{
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the suprasternal notch and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. This vessel is a branch of the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					if([pt.branchOf isEqualToString:@"Deep Circumflex Iliac Artery"])
					{
						if ([pt.course isEqualToString:@"Indeterminate"])
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DCIA is %9$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
						}
						else
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join the %7$@ DCIA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
						}
					}
					else if([pt.branchOf isEqualToString:@"Deep Inferior Epigastric Artery"])
					{
						if([pt.course isEqualToString:@"Indeterminate"])
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DIEA is %9$@.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
						}
						else
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join %7$@ DIEA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
						}
					}
				}
								
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
				
				// image /////////////////////
				reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@-crop.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], [pt.roiID lowercaseString]];
				
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
				
				
				// post-image text ///////////////////////////////
				if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
				{
					// more space to try and place one text/image block per page
					reportGenScript = @"set text1 to \"\n\n\n\n\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					reportGenScript = @"set text1 to \"\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
								
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
			}
		}
	}
	///////////////////////////////////END LOOP FOR EACH Individual ROI///////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////
	// additional info for UMB case
	
	if([refPt isEqualToString:@"UMB"])
	{
		reportGenScript = @"set text1 to \"\nBilateral superficial inferior epigastric arteries (SIEA) are less than 1mm.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
		
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		[scriptObject release];
		
		//////
		
		side = @"Left";
		float siev10 = 0.0;
		float siev12 = 0.0;
		
		for(i = 0; i < 2; i++)
		{	
			for(ROIPoint *pt in roiPoints)
			{
				// SIEV points have 3D x-coordinate less than reference point for left side, greater than ref pt for right side
				
				if([side isEqualToString:@"Left"])
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D > refPtX)
					{
						// left side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
						
					}
					
				}
				else
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D < refPtX)
					{
						// right side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
					}
				}
			}
			
			if([side isEqualToString:@"Left"])
			{
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\t\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
			}
			else
			{
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
			}
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			side = @"Right";
			siev10 = 0.0;
			siev12 = 0.0;
		}		
	}
	// end UMB additional info
	//////////////////////////

	
	////// fat volume
	if ([refPt isEqualToString:@"IGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nFat volume of a 6x22cm flap on posterior right thigh is %4.1fcc\n\nFat volume of a 6x22cm flap on posterior left thigh is %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue], [txtFatL floatValue]];
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nVolume of abdominal fat: %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue]];
	}
		
	if([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
	{
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];		
	}
	////// end fat volume section
*/
}

-(void)outputToTextEdit:(short)refPtImgNum refX:(float)refPtX refZ:(float)refPtZ
{
    NSAlert *myAlert;

	// alert user to close TextEdit if already running
	if([self textEditRunning])
	{
		myAlert = [NSAlert alertWithMessageText:@"TextEdit needs to be terminated before generating the report"
								  defaultButton:@"OK, Terminate"
								alternateButton:@"NO"
									otherButton:nil
					  informativeTextWithFormat:@"Please save any open documents"];
		
		NSInteger clicked = [myAlert runModal];
		
		if(clicked == NSAlertDefaultReturn)
		{
			[self quitTextEdit];
		}
		else if(clicked != NSAlertDefaultReturn)
		{
			return;
		}
		
	}
    
	// Applescript
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString* reportGenScript;
	NSAppleScript* scriptObject;
	NSString* patientPos;
	
	if ([chkSupine state] == NSOnState)
	{
		patientPos = @"supine";
	}
	else
	{
		patientPos = @"prone";
	}
    
	
	if ([refPt isEqualToString:@"IGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (PAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through posterior thigh muscles.\n\nTechnique: MRA of the lower extremities with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superficial femoral and profunda femoris arteries are widely patent.\n\nInferior Gluteal Crease (IGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"SGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (SGAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through gluteal muscles.\n\nTechnique: MRA of the pelvis with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superior and inferior gluteal arteries are widely patent.\n\nSuperior Gluteal Crease (SGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"SSN"])
	{
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (TDAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate thoracodorsal artery perforators.\n\nTechnique: MRA of the chest with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ with hands above the head for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBilateral internal mammary and thoracodorsal arteries are widely patent.\n\nSuprasternal Notch (SSN): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		if([chkQuickReport state] == NSOnState)
		{
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: CTA of the abdomen and pelvis with and without contrast. The patient was positioned %@. 3D images were post-processed on a computer workstation.\n\nComparison: None\n\nFindings:\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
		}
		else
		{
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: MRA of the abdomen with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D high resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
		}
	}
	else
	{
		//unknown reference point!
		//refPtText = @"UNKNOWN REFERENCE POINT!";
        reportGenScript = @"";
	}
	
	// Generate text header ///////////////////////
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
	
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
    
	///////////////////// Begin Perforator Distance Measurement Table //////////////////////////////
	int i;
	NSString* side = @"Left";
	float distToRef;
	NSString* locRelToRef;
	
	for(i = 0; i < 2; i++)
	{
		if ([refPt isEqualToString:@"IGC"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Posterior Thigh Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"SGC"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Gluteal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"SSN"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ TDA Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		else if([refPt isEqualToString:@"UMB"])
		{
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Abdominal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
		}
		
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];
		
		
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID characterAtIndex:0] == [side characterAtIndex:0])
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}
                
				// matches side of iteration
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%@\t%d: %d\t\t\t%4.1f(%@)\t\t%4.1f\t\t\t\t%1.1f\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), locRelToRef, pt.distToMid, pt.diameter];
				
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V points occur after all relevant ROIs for this table
				break;
			}
			else
			{
				// skip reference point or opposite side of iteration
				continue;
			}
			
		}
		
		side = @"Right";
	}
	
	// Spacing
	reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
	
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
    
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
	
	////////////////////// End Perforator Distance Measurement Table ///////////////////////////////
	
	
	///////////////////// Begin 3D Image Insertion //////////////////////////////
	// 3D images only for full report
	if([chkQuickReport state] == NSOffState)
	{
		NSString *filename3D = @"3d-vr"; // start with 3d-vr image
		
		for(i = 0; i < 2; i++)
		{
			// Image insertion
			reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], filename3D];
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			
			// Spacing
			reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
			
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			
			[scriptObject release];
			
			
			filename3D = @"3d-mip"; // update to MIP for second iteration
		}
	}
	/////////////////////////// End 3D Image Insertion ////////////////////////////////////////////
	
	/////////////////////////////////////LOOP FOR EACH Individual ROI/////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// individual perforator image/text blocks only present in full report
	if([chkQuickReport state] == NSOffState)
	{
		side = @"left";
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:refPt])
			{
				// no image or text necessary for reference point
				continue;
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V-points; should occur last in sorted array (roiPoints) and on report
				break;
				
			}
			else
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}
				
				if([pt.roiID characterAtIndex:0] == 'R')
				{
					side = @"right";
				}
				
				//////// Individual perforator detailed section
				
				// just first text block
				if ([refPt isEqualToString:@"IGC"])
				{
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the inferior gluteal crease, %6$4.1fmm to the %7$@ of midline, and %8$4.1fmm posterior to the posterior margin of gracilis.  Vessel diameter is %9$1.1fmm. It travels %10$3.1fmm with an intramuscular course before joining the %11$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.distToGracilis, pt.diameter, pt.length, [pt.branchOf lowercaseString]];
				}
				else if([refPt isEqualToString:@"SGC"])
				{
					if([pt.course isEqualToString:@"Through G. Max"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels through the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
					else if([pt.course isEqualToString:@"Between bundles of G. Max"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the bundles of the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
					else if([pt.course isEqualToString:@"Between G. Max and G. Med"])
					{
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the gluteal maximus and gluteal medius before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
					}
				}
				else if([refPt isEqualToString:@"SSN"])
				{
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the suprasternal notch and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. This vessel is a branch of the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					if([pt.branchOf isEqualToString:@"Deep Circumflex Iliac Artery"])
					{
						if ([pt.course isEqualToString:@"Indeterminate"])
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DCIA is %9$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
						}
						else
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join the %7$@ DCIA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
						}
					}
					else if([pt.branchOf isEqualToString:@"Deep Inferior Epigastric Artery"])
					{
						if([pt.course isEqualToString:@"Indeterminate"])
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DIEA is %9$@.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
						}
						else
						{
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join %7$@ DIEA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
						}
					}
				}
                
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
				
				// image /////////////////////
				reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@-crop.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], [pt.roiID lowercaseString]];
				
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
				
				
				// post-image text ///////////////////////////////
				if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
				{
					// more space to try and place one text/image block per page
					reportGenScript = @"set text1 to \"\n\n\n\n\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					reportGenScript = @"set text1 to \"\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
                
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
			}
		}
	}
	///////////////////////////////////END LOOP FOR EACH Individual ROI///////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	////////////////////////////
	// additional info for UMB case
	
	if([refPt isEqualToString:@"UMB"])
	{
		reportGenScript = @"set text1 to \"\nBilateral superficial inferior epigastric arteries (SIEA) are less than 1mm.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
		
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		[scriptObject release];
		
		//////
		
		side = @"Left";
		float siev10 = 0.0;
		float siev12 = 0.0;
		
		for(i = 0; i < 2; i++)
		{
			for(ROIPoint *pt in roiPoints)
			{
				// SIEV points have 3D x-coordinate less than reference point for left side, greater than ref pt for right side
				
				if([side isEqualToString:@"Left"])
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D > refPtX)
					{
						// left side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
						
					}
					
				}
				else
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D < refPtX)
					{
						// right side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
					}
				}
			}
			
			if([side isEqualToString:@"Left"])
			{
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\t\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
			}
			else
			{
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
			}
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			side = @"Right";
			siev10 = 0.0;
			siev12 = 0.0;
		}
	}
	// end UMB additional info
	//////////////////////////
    
	
	////// fat volume
	if ([refPt isEqualToString:@"IGC"])
	{
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nFat volume of a 6x22cm flap on posterior right thigh is %4.1fcc\n\nFat volume of a 6x22cm flap on posterior left thigh is %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue], [txtFatL floatValue]];
	}
	else if([refPt isEqualToString:@"UMB"])
	{
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nVolume of abdominal fat: %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue]];
	}
    
	if([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
	{
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];
	}
	////// end fat volume section
}

-(void)outputToWord:(short)refPtImgNum refX:(float)refPtX refZ:(float)refPtZ
{
    NSAlert *myAlert;
    
	// Applescript
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString* reportGenScript;
	NSAppleScript* scriptObject;
	NSString* patientPos;
	
	if ([chkSupine state] == NSOnState)
	{
		patientPos = @"supine";
	}
	else
	{
		patientPos = @"prone";
	}
    
    // Generate Text Header
    if ([refPt isEqualToString:@"IGC"])
	{
        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new document\ninsert text \"Perforator Flap Angiography Report (PAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through posterior thigh muscles.\n\nTechnique: MRA of the lower extremities with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superficial femoral and profunda femoris arteries are widely patent.\n\nInferior Gluteal Crease (IGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\" at end of text object of active document\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
        /*
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (PAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through posterior thigh muscles.\n\nTechnique: MRA of the lower extremities with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superficial femoral and profunda femoris arteries are widely patent.\n\nInferior Gluteal Crease (IGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
         */
	}
    
	else if([refPt isEqualToString:@"SGC"])
	{
        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new document\ninsert text \"Perforator Flap Angiography Report (SGAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through gluteal muscles.\n\nTechnique: MRA of the pelvis with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superior and inferior gluteal arteries are widely patent.\n\nSuperior Gluteal Crease (SGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\" at end of text object of active document\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
        /*
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (SGAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through gluteal muscles.\n\nTechnique: MRA of the pelvis with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left superior and inferior gluteal arteries are widely patent.\n\nSuperior Gluteal Crease (SGC): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
         */
	}
    
	else if([refPt isEqualToString:@"SSN"])
	{
        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new document\ninsert text \"Perforator Flap Angiography Report (TDAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate thoracodorsal artery perforators.\n\nTechnique: MRA of the chest with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ with hands above the head for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBilateral internal mammary and thoracodorsal arteries are widely patent.\n\nSuprasternal Notch (SSN): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\" at end of text object of active document\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
        /*
		reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (TDAP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate thoracodorsal artery perforators.\n\nTechnique: MRA of the chest with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ with hands above the head for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium, post Gd axial, coronal and sagittal 3D High resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBilateral internal mammary and thoracodorsal arteries are widely patent.\n\nSuprasternal Notch (SSN): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, seriesNum, refPtImgNum];
         */
	}
    
	else if([refPt isEqualToString:@"UMB"])
	{
		if([chkQuickReport state] == NSOnState)
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new document\ninsert text \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: CTA of the abdomen and pelvis with and without contrast. The patient was positioned %@. 3D images were post-processed on a computer workstation.\n\nComparison: None\n\nFindings:\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\" at end of text object of active document\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
            /*
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: CTA of the abdomen and pelvis with and without contrast. The patient was positioned %@. 3D images were post-processed on a computer workstation.\n\nComparison: None\n\nFindings:\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
             */
		}
		else
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new document\ninsert text \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: MRA of the abdomen with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D high resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\" at end of text object of active document\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
            /*
			reportGenScript = [NSString stringWithFormat:@"tell application \"TextEdit\"\nset text of document 1 to \"Perforator Flap Angiography Report (DIEP)\n\nName:\t%@\nMRN:\t%@\n\nClinical History: Undergoing breast reconstruction. Evaluate perforating arteries through abdominal muscles.\n\nTechnique: MRA of the abdomen with and without contrast was performed at 1.5 Tesla using body array coil. The patient was positioned %@ for the following sequences: axial and coronal single shot fast spin echo, axial 3D LAVA pre during post dynamic injection of 10 ml gadofosveset trisodium (preceded by 0.5 mg glucagon to reduce peristalsis), post Gd axial, coronal and sagittal 3D high resolution LAVA. 3D images were post-processed on a computer workstation.\n\nBoth the Right and Left Inferior Epigastric Arteries are widely patent down to insertion on common femoral artery.\n\nLeft DIEA:\t\tType %d branching pattern\nRight DIEA: \tType %d branching pattern\n\nUmbilicus (UMB): Se%i, Im%i\n\nNote: All measurements are in mm.\n\n\"\nend tell", [txtName stringValue], [txtMRN stringValue], patientPos, leftDIEA, rightDIEA, seriesNum, refPtImgNum];
             */
		}
	}
	else
	{
		//unknown reference point!
		//refPtText = @"UNKNOWN REFERENCE POINT!";
        reportGenScript = @"";
	}
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
	
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
    
    
    ///////////////////// Begin Perforator Distance Measurement Table //////////////////////////////
	int i;
	NSString* side = @"Left";
	float distToRef;
	NSString* locRelToRef;
	
	for(i = 0; i < 2; i++) // one iteration for each side (left and right)
	{
        // table header
		if ([refPt isEqualToString:@"IGC"])
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%@ Posterior Thigh Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\n\" at end of text object of active document\nend tell", side, refPt];
            /*
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Posterior Thigh Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
            */
		}
		else if([refPt isEqualToString:@"SGC"])
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%@ Gluteal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\n\" at end of text object of active document\nend tell", side, refPt];
            /*
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Gluteal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
            */
		}
		else if([refPt isEqualToString:@"SSN"])
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%@ TDA Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\n\" at end of text object of active document\nend tell", side, refPt];
            /*
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ TDA Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
            */
		}
		else if([refPt isEqualToString:@"UMB"])
		{
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%@ Abdominal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\n\" at end of text object of active document\nend tell", side, refPt];
            /*
			reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%@ Abdominal Muscle Perforators:\n\n#\tSeries: Image\tDistance to %@\tDistance to Midline\tVessel Diameter\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, refPt];
            */
		}
		
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];
		
		
		// table data
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID characterAtIndex:0] == [side characterAtIndex:0])
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}
                
				// matches side of iteration
                reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"%@\t%d: %d\t\t%4.1f(%@)\t\t%4.1f\t\t\t\t%1.1f\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), locRelToRef, pt.distToMid, pt.diameter];
                /*
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%@\t%d: %d\t\t\t%4.1f(%@)\t\t%4.1f\t\t\t\t%1.1f\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), locRelToRef, pt.distToMid, pt.diameter];
				*/
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V points occur after all relevant ROIs for this table
				break;
			}
			else
			{
				// skip reference point or opposite side of iteration
				continue;
			}
			
		}
		
		side = @"Right";
	}
	
    // NECESSARY??????????????????????
	// Spacing
    /*
	reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
	
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
    
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
	*/
	////////////////////// End Perforator Distance Measurement Table ///////////////////////////////

    ///////////////////// Begin 3D Image Insertion //////////////////////////////
	// 3D images only for full report
	if([chkQuickReport state] == NSOffState)
	{
		NSString *filename3D = @"3d-vr"; // start with 3d-vr image
		
		for(i = 0; i < 2; i++)
		{
			// Image insertion
            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\nmake new inline picture at end of active document with properties {file name:POSIX file \"%@/%@.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\" at end of text object of active document\nend tell", [txtPath stringValue], filename3D];
            /*
			reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], filename3D];
			*/
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			/* ????????????????????????? NECESSARY ???????????????
			// Spacing
			reportGenScript = @"set text1 to \"\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
			
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			
			[scriptObject release];
			*/
			
			filename3D = @"3d-mip"; // update to MIP for second iteration
		}
	}
	/////////////////////////// End 3D Image Insertion ////////////////////////////////////////////


    /////////////////////////////////////LOOP FOR EACH Individual ROI///////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// individual perforator image/text blocks only present in full report
	if([chkQuickReport state] == NSOffState)
	{
		side = @"left";
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:refPt])
			{
				// no image or text necessary for reference point
				continue;
			}
			else if([pt.roiID characterAtIndex:0] == 'V')
			{
				// V-points; should occur last in sorted array (roiPoints) and on report
				break;
				
			}
			else
			{
				distToRef = pt.z3D - refPtZ;
				
				if(distToRef > 0)
				{
					locRelToRef = @"Superior";
				}
				else if(distToRef < 0)
				{
					locRelToRef = @"Inferior";
				}
				else
				{
					// even with ref pt
					locRelToRef = [NSString stringWithFormat:@"at %@", refPt];
				}
				
				if([pt.roiID characterAtIndex:0] == 'R')
				{
					side = @"right";
				}
				
				//////// Individual perforator detailed section
				
				// text + associated image
				if ([refPt isEqualToString:@"IGC"])
				{
                    reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the inferior gluteal crease, %6$4.1fmm to the %7$@ of midline, and %8$4.1fmm posterior to the posterior margin of gracilis.  Vessel diameter is %9$1.1fmm. It travels %10$3.1fmm with an intramuscular course before joining the %11$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%12$@/%13$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.distToGracilis, pt.diameter, pt.length, [pt.branchOf lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                    /*
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the inferior gluteal crease, %6$4.1fmm to the %7$@ of midline, and %8$4.1fmm posterior to the posterior margin of gracilis.  Vessel diameter is %9$1.1fmm. It travels %10$3.1fmm with an intramuscular course before joining the %11$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.distToGracilis, pt.diameter, pt.length, [pt.branchOf lowercaseString]];
                    */
				}
				else if([refPt isEqualToString:@"SGC"])
				{
					if([pt.course isEqualToString:@"Through G. Max"])
					{
                        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels through the gluteal maximus before joining the %9$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                        
                        /*
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels through the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
                         */
					}
					else if([pt.course isEqualToString:@"Between bundles of G. Max"])
					{
                        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the bundles of the gluteal maximus before joining the %9$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                        /*
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the bundles of the gluteal maximus before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
                         */
					}
					else if([pt.course isEqualToString:@"Between G. Max and G. Med"])
					{
                        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the gluteal maximus and gluteal medius before joining the %9$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                        /*
						reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the superior gluteal crease and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels between the gluteal maximus and gluteal medius before joining the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
                         */
					}
				}
				else if([refPt isEqualToString:@"SSN"])
				{
                    reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the suprasternal notch and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. This vessel is a branch of the %9$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                    /*
					reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the suprasternal notch and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. This vessel is a branch of the %9$@.\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.branchOf lowercaseString]];
                     */
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					if([pt.branchOf isEqualToString:@"Deep Circumflex Iliac Artery"])
					{
						if ([pt.course isEqualToString:@"Indeterminate"])
						{
                            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DCIA is %9$@\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                            /*
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DCIA is %9$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
                             */
						}
						else
						{
                            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join the %7$@ DCIA.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%11$@/%12$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length, [txtPath stringValue], [pt.roiID lowercaseString]];
                            /*
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join the %7$@ DCIA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
                             */
						}
					}
					else if([pt.branchOf isEqualToString:@"Deep Inferior Epigastric Artery"])
					{
						if([pt.course isEqualToString:@"Indeterminate"])
						{
                            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DIEA is %9$@.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%10$@/%11$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], [txtPath stringValue], [pt.roiID lowercaseString]];
                            /*
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. The course of the vessel prior to joining the %7$@ DIEA is %9$@.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString]];
                             */
						}
						else
						{
                            reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join %7$@ DIEA.\n\" at end of text object of active document\nmake new inline picture at end of active document with properties {file name:POSIX file \"%11$@/%12$@-crop.jpg\", link to file:false, save with document:true}\ninsert text \"\n\n\n\n\n\" at end of text object of active document\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length, [txtPath stringValue], [pt.roiID lowercaseString]];
                            /*
							reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n%1$@ (Se%2$d, Im%3$d) is located %4$4.1fmm %5$@ to the umbilicus and %6$4.1fmm to the %7$@ of midline.  Vessel diameter is %8$1.1fmm. It travels %9$@ for %10$3.1fmm to join %7$@ DIEA.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", pt.roiID, seriesNum, ((short)numSlices - pt.slice), fabsf(distToRef), [locRelToRef lowercaseString], pt.distToMid, side, pt.diameter, [pt.course lowercaseString], pt.length];
                             */
						}
					}
				}
                
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				
				[scriptObject release];
				
				/* // NOT NEEDED! Images embedded in above textual scripts
				// image /////////////////////
				reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nset f to \"%@/%@-crop.jpg\"\nset p to POSIX path of f\ntell document 1 of application \"TextEdit\"\nmake new attachment with properties {file name:p}\nactivate\nend tell\nend tell", [txtPath stringValue], [pt.roiID lowercaseString]];
				
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
				*/
				
                /*
				// post-image text ///////////////////////////////
				if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"SGC"] || [refPt isEqualToString:@"SSN"])
				{
					// more space to try and place one text/image block per page
					reportGenScript = @"set text1 to \"\n\n\n\n\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
				else if([refPt isEqualToString:@"UMB"])
				{
					reportGenScript = @"set text1 to \"\n\n\n\n\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
				}
                
				scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
				
				returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
				
				if(returnDescriptor != NULL)
				{
					// successful execution
					if(kAENullEvent != [returnDescriptor descriptorType])
					{
						// script returned an AppleScript result
						if(cAEList == [returnDescriptor descriptorType])
						{
							// result is a list of other descriptors
						}
						else
						{
							// coerce the result to the appropriate ObjC type
						}
					}
				}
				else
				{
					// no script result; handle error here
				}
				[scriptObject release];
                */
			}
		}
	}
	///////////////////////////////////END LOOP FOR EACH Individual ROI//////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////
	// additional info for UMB case
	
	if([refPt isEqualToString:@"UMB"])
	{
        reportGenScript = @"tell application \"Microsoft Word\"\nactivate\ninsert text \"\nBilateral superficial inferior epigastric arteries (SIEA) are less than 1mm.\n\" at end of text object of active document\nend tell";
        /*
		reportGenScript = @"set text1 to \"\nBilateral superficial inferior epigastric arteries (SIEA) are less than 1mm.\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell";
		*/
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		[scriptObject release];
		
		//////
		
		side = @"Left";
		float siev10 = 0.0;
		float siev12 = 0.0;
		
		for(i = 0; i < 2; i++)
		{
			for(ROIPoint *pt in roiPoints)
			{
				// SIEV points have 3D x-coordinate less than reference point for left side, greater than ref pt for right side
				
				if([side isEqualToString:@"Left"])
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D > refPtX)
					{
						// left side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
						
					}
					
				}
				else
				{
					if([pt.roiID characterAtIndex:0] == 'V' && pt.x3D < refPtX)
					{
						// right side V-point
						if(siev10 == 0.0)
						{
							siev10 = fabsf(pt.x3D - refPtX);
						}
						else
						{
							siev12 = fabsf(pt.x3D - refPtX);
							break;
						}
					}
				}
			}
			
			if([side isEqualToString:@"Left"])
			{
                reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"%1$@ SIEV:\t\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\" at end of text object of active document\nend tell", side, siev10, [side lowercaseString], siev12];
                /*
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\t\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
                 */
			}
			else
			{
                reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"%1$@ SIEV:\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\" at end of text object of active document\nend tell", side, siev10, [side lowercaseString], siev12];
                /*
				reportGenScript = [NSString stringWithFormat:@"set text1 to \"%1$@ SIEV:\tAt 10cm below the umbilicus, the vessel is %2$3.1fmm to the %3$@\n\t\t\tAt 12cm below the umbilicus, the vessel is %4$3.1fmm to the %3$@\n\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", side, siev10, [side lowercaseString], siev12];
                 */
			}
			
			scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
			
			returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
			
			if(returnDescriptor != NULL)
			{
				// successful execution
				if(kAENullEvent != [returnDescriptor descriptorType])
				{
					// script returned an AppleScript result
					if(cAEList == [returnDescriptor descriptorType])
					{
						// result is a list of other descriptors
					}
					else
					{
						// coerce the result to the appropriate ObjC type
					}
				}
			}
			else
			{
				// no script result; handle error here
			}
			[scriptObject release];
			
			side = @"Right";
			siev10 = 0.0;
			siev12 = 0.0;
		}
	}
	// end UMB additional info
	//////////////////////////

    
    
	////// fat volume
	if ([refPt isEqualToString:@"IGC"])
	{
        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n\nFat volume of a 6x22cm flap on posterior right thigh is %4.1fcc\n\nFat volume of a 6x22cm flap on posterior left thigh is %4.1fcc\" at end of text object of active document\nend tell", [txtFatR floatValue], [txtFatL floatValue]];
        /*
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nFat volume of a 6x22cm flap on posterior right thigh is %4.1fcc\n\nFat volume of a 6x22cm flap on posterior left thigh is %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue], [txtFatL floatValue]];
         */
	}
	else if([refPt isEqualToString:@"UMB"])
	{
        reportGenScript = [NSString stringWithFormat:@"tell application \"Microsoft Word\"\nactivate\ninsert text \"\n\nVolume of abdominal fat: %4.1fcc\" at end of text object of active document\nend tell", [txtFatR floatValue]];
        /*
		reportGenScript = [NSString stringWithFormat:@"set text1 to \"\n\nVolume of abdominal fat: %4.1fcc\"\ntell application \"TextEdit\"\nactivate\ntell application \"System Events\"\ntell process \"TextEdit\"\nset the clipboard to text1 & return\nkeystroke \"v\" using command down\nend tell\nend tell\nend tell", [txtFatR floatValue]];
         */
	}
    
	if([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
	{
		scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
		
		returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
		
		if(returnDescriptor != NULL)
		{
			// successful execution
			if(kAENullEvent != [returnDescriptor descriptorType])
			{
				// script returned an AppleScript result
				if(cAEList == [returnDescriptor descriptorType])
				{
					// result is a list of other descriptors
				}
				else
				{
					// coerce the result to the appropriate ObjC type
				}
			}
		}
		else
		{
			// no script result; handle error here
		}
		
		[scriptObject release];
	}
	////// end fat volume section
    
    ////////// end report generation

}

-(IBAction)click3DImage:(id)sender
{
	[self toggle3DImage];
}

-(void)toggle3DImage
{
	if([[txt3DImage stringValue] isEqualToString:@"3D-VR"])
	{
		[txt3DImage setStringValue:@"3D-MIP"];
		[btnPlotCourse setEnabled:NO];
	}
	else if([[txt3DImage stringValue] isEqualToString:@"3D-MIP"])
	{
		[txt3DImage setStringValue:@"3D-VR"];
		[btnPlotCourse setEnabled:YES];
	}
	else
	{
		[txt3DImage setStringValue:@"ERROR!"];
	}
}

-(IBAction)projToSkin:(id)sender
{
	if([chkProjToSkin state] == NSOnState)
	{
		NSRect myRect;
		
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID characterAtIndex:0] == 'V')
			{
				// don't project v-points to the skin
				break; // v-points always occur at end of sorted roiPoints
			}
			
			// plot anterior projection
			myRect = NSMakeRect(pt.x2D, pt.antProjY2D, 10, 10);
			ROI *antROI = [viewerController newROI:t2DPoint];
			[antROI setROIRect:myRect];
			[[[viewerController roiList] objectAtIndex:pt.slice] addObject:antROI];
			[antROI setName:[NSString stringWithFormat:@"ant%@", pt.roiID]];
			
			// plot posterior projection
			myRect = NSMakeRect(pt.x2D, pt.postProjY2D, 10, 10);
			ROI *postROI = [viewerController newROI:t2DPoint];
			[postROI setROIRect:myRect];
			[[[viewerController roiList] objectAtIndex:pt.slice] addObject:postROI];
			[postROI setName:[NSString stringWithFormat:@"post%@", pt.roiID]];
		}
	}
	else
	{
		int i;
		int j;
		int seriesROIs;
		int imageROIs;
				
		roiSeriesList = [viewerController roiList];
		seriesROIs   = [roiSeriesList count];
		
		for(i = 0; i < seriesROIs; i++)
		{
			roiImageList = [roiSeriesList objectAtIndex: i];
			imageROIs       = [roiImageList  count];
			
			for(j = 0; j < imageROIs; j++)
			{
				roiImageList = [roiSeriesList objectAtIndex:i];
				imageROIs = [roiImageList count];
				
				roi = [roiImageList objectAtIndex:j];
				
				if(([[roi name] rangeOfString:@"ant"].location != NSNotFound) || ([[roi name] rangeOfString:@"post"].location != NSNotFound))
				{
					// ROI name contains "ant" or "post" -> delete it
					[viewerController deleteROI:roi];
					imageROIs = [roiImageList count];
					j--; // have to decrement j as imageROIs is dynamically updating with each ROI deletion
				}
			}
		}
	}
}
 
-(IBAction)setLeftDIEA:(id)sender
{
	leftDIEA = [cboLeftDIEA intValue];
	[self backupDIEA];
}

-(IBAction)setRightDIEA:(id)sender
{
	rightDIEA = [cboRightDIEA intValue];
	[self backupDIEA];
}

-(void)backupDIEA
{
	NSString* dieaPath = [NSString stringWithFormat:@"%@/archive/diea.vals", [txtPath stringValue]];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/diea.vals", [txtPath stringValue]]])
	{		
		// create new file to store ROI object attributes
		[[NSFileManager defaultManager] createFileAtPath:dieaPath contents:nil attributes:nil];
	}
	
	// write attributes to text file
	NSString *objDump = [NSString stringWithFormat:@"%d,%d\n", leftDIEA, rightDIEA];
	[objDump writeToFile:dieaPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(IBAction)fatAPDimChanged:(id)sender
{
	// anteroposterior dimension of rectangle for fat identification (in mm)
	[lblFatRectHeightValue setIntValue:[sldFatRectHeight intValue]];
}

-(IBAction)fatTransverseDimChanged:(id)sender
{
	// transverse dimension of rectangle for fat identification
	[lblFatRectWidthValue setIntValue:[sldFatRectWidth intValue]];
}

-(IBAction)fatThresholdChanged:(id)sender
{
	[lblFatThresholdValue setIntValue:[sldFatThreshold intValue]];
}

-(IBAction)paintFat:(id)sender
{	
	pixList       = [viewerController pixList];
	int curSlice  = [[viewerController imageView] curImage];
	thisPix       = [pixList objectAtIndex: curSlice];
	roiSeriesList = [viewerController roiList];
	
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];

	int seriesROIs = [roiSeriesList count];
	int imageROIs;
	
	
	NSString        *dcmFilePath;
	NSString		*dcmSliceThicknessTag;
	
	DCMAttributeTag *dcmTag;
	DCMObject       *dcmObj;
	DCMAttribute    *dcmAttr;
	
	NSString		*dcmSliceThickness;
	float			sliceThickness;
	
	dcmFilePath = [thisPix sourceFile];
	dcmObj = [DCMObject objectWithContentsOfFile: dcmFilePath decodingPixelData: NO];
	
	// get slice thickness
	dcmSliceThicknessTag = @"0018,0050"; // slice thickness (mm)
	dcmTag = [DCMAttributeTag tagWithTagString:dcmSliceThicknessTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmSliceThickness = [[dcmAttr value] description];
	sliceThickness = [dcmSliceThickness floatValue];
	
	int k, i, j, imgOffset;
	ROI *curROI;
	float refPtX, refPtY;
	int refPtImage;
	int totalSlices = [roiSeriesList count];
	float slicesAboveRef, slicesBelowRef; // for flap
	
	int flapDistAbove = 30; // in mm
	int flapDistBelow = 100; // in mm
	
	// UMB fat volume slice region width and height (in mm)
	float rectHeight = [sldFatRectHeight floatValue];
	float maxRectWidth = [sldFatRectWidth floatValue];
	float minRectWidth = (maxRectWidth / 400) * 30; // 400 is default maxRectWidth; 30 is default minRectWidth; -> (scaling minRectWidth by same ratio as maxRectWidth was scaled)
	
	// image dimensions
	int imgWidth = [thisPix pwidth];
	int imgHeight = [thisPix pheight];
	
	// conversion: length in pixels = length in mm / pixel spacing
	float maxRectWPx = maxRectWidth / [thisPix pixelSpacingX];
	float minRectWPx = minRectWidth / [thisPix pixelSpacingX];
	float rectHPx = rectHeight / [thisPix pixelSpacingY];
	
	BOOL brushFound = NO;
	
	
	for(i = 0; i < seriesROIs; i++)
	{
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs = [roiImageList count];
		
		[viewerController setImageIndex:([roiSeriesList count] - (i + 1))];
		
		j = 0;
		for(k = 0; k < imageROIs; k++)
		{
			curROI = [roiImageList objectAtIndex:j];
			
			if([curROI type] == t2DPoint)
			{
				// set reference point attributes
				refPtX = [curROI centroid].x;
				refPtY = [curROI centroid].y;
				refPtImage = [[viewerController imageView] curImage];
				
				j++;
			}
			else
			{
				brushFound = YES;
				[viewerController deleteROI:curROI];
			}
		}
		
	}
	
	
	slicesAboveRef = flapDistAbove / sliceThickness;
	slicesBelowRef = flapDistBelow / sliceThickness;
	//totalFlapSlices = ceil(slicesAboveRef) + ceil(slicesBelowRef) + 1; // + 1 for the reference point slice
	
	
	////////////////////////////////////////////
	// create width-scaling rectangles to approximate oval shape on abdomen in coronal view
	
	// round # slices above ref pt up (if fractional slice); add 1 to number due to indexing of images vs. image number in viewer
	
	//////////
	// slices superior to reference point
	float supRectScaleFactor = (maxRectWPx - minRectWPx) / ceil(slicesAboveRef);
	
	NSRect newRect;
	
	// only use offset less than -1; offset of -1 is equal to slice with the ref pt
	for(imgOffset = -(ceil(slicesAboveRef) + 1); imgOffset < -1; imgOffset++)
	{		
		[viewerController setImageIndex:(totalSlices - refPtImage + imgOffset)];
		curSlice = [[viewerController imageView] curImage];
		
		// have to reduce imgOffset by 1 to remain correct with differing index schemes (zero-based in API, one-based in OsiriX GUI)
		newRect = NSMakeRect(floor(refPtX - ((maxRectWPx - ((-imgOffset - 1) * supRectScaleFactor)) / 2.)), floor(refPtY - (rectHPx / 2.)), ceil((maxRectWPx - ((-imgOffset - 1) * supRectScaleFactor))), ceil(rectHPx));
		
		ROI *sliceRect = [viewerController newROI:tROI];
		[sliceRect setROIRect:newRect];
		[[[viewerController roiList] objectAtIndex:curSlice] addObject:sliceRect];
		
		[viewerController needsDisplayUpdate];
	}
	
	//////////
	// reference point slice
	[viewerController setImageIndex:(totalSlices - refPtImage - 1)];
	curSlice = [[viewerController imageView] curImage];
	
	newRect = NSMakeRect(floor(refPtX - (maxRectWPx / 2.)), floor(refPtY - (rectHPx / 2.)), ceil(maxRectWPx), ceil(rectHPx));
	
	ROI *sliceRect = [viewerController newROI:tROI];
	[sliceRect setROIRect:newRect];
	[[[viewerController roiList] objectAtIndex:curSlice] addObject:sliceRect];
	
	[viewerController needsDisplayUpdate];	
	
	//////////
	// slices inferior to reference point
	float infRectScaleFactor = (maxRectWPx - minRectWPx) / ceil(slicesBelowRef);
	
	// imgOffset of zero is first image inferior (due to indexing);
	for(imgOffset = 0; imgOffset < ceil(slicesBelowRef); imgOffset++)
	{		 
		[viewerController setImageIndex:(totalSlices - refPtImage + imgOffset)];
		curSlice = [[viewerController imageView] curImage];
		
		newRect = NSMakeRect(floor(refPtX - ((maxRectWPx - ((imgOffset + 1) * infRectScaleFactor)) / 2.)), floor(refPtY - (rectHPx / 2.)), ceil((maxRectWPx - ((imgOffset + 1) * infRectScaleFactor))), ceil(rectHPx));
		
		ROI *sliceRect = [viewerController newROI:tROI];
		[sliceRect setROIRect:newRect];
		[[[viewerController roiList] objectAtIndex:curSlice] addObject:sliceRect];
		
		[viewerController needsDisplayUpdate];
	}
	///// end rectangle creation block
	///////////////////////////////////////////////////////////////////
	
	
	///////////////////////////////////////////////////////////////////
	///// Begin identifying pixels above intensity threshold
	
	ROI *brushROI;
	
	int fatImg;
	BOOL rectFound;
	NSRect rectROI;
	DCMPix *curPix;
	
	// loop through each fat region image (images containing rectangles); goes most superior -> most inferior
	for(fatImg = (totalSlices - refPtImage -(ceil(slicesAboveRef) + 1)); fatImg < (totalSlices - refPtImage + ceil(slicesBelowRef)); fatImg++)
	{
		[viewerController setImageIndex:fatImg];
		
		curSlice = [[viewerController imageView] curImage];
		
		roiImageList  = [roiSeriesList objectAtIndex:curSlice];
		
		// find rectangle coordinates
		rectFound = NO;
		
		for(i = 0; i < [roiImageList count]; i++)
		{
			curROI = [roiImageList objectAtIndex:i];
			
			// end loop upon finding rectangular ROI
			if([curROI type] == tROI)
			{
				rectFound = YES;
				break;
			}
		}
		
		rectROI = [curROI rect];
		curPix = [pixList objectAtIndex:curSlice];
		
		float	*fImage; // greyscale
		unsigned char *buffer = (unsigned char*)malloc((imgWidth * imgHeight) * sizeof(unsigned char));
		
		int pxRow;
		int pxCol;
		
		fImage = [curPix fImage];
		
		// initialize buffer
		for(i = 0; i < (imgWidth * imgHeight); i++)
		{
			buffer[i] = 0x00;
		}
		
		BOOL fatFound;
		
		// update buffer array for pixels inside of rectangle and above threshold
		
		// left to right
		for(pxRow = 0; pxRow < imgHeight; pxRow++)
		{
			fatFound = NO;
			
			for(pxCol = 0; pxCol < imgWidth; pxCol++)
			{
				if(fImage[(pxRow * imgWidth) + pxCol] >= [sldFatThreshold intValue])
				{
					// find bright pixels
					fatFound = YES;
					
					if((pxRow >= (int)rectROI.origin.y) && (pxRow <= ceil(rectROI.origin.y + rectROI.size.height)) && (pxCol >= (int)rectROI.origin.x) && (pxCol <= ceil(rectROI.origin.x + rectROI.size.width)))
					{
						// only include fat within the rectangle
						// found fat -> update buffer array
						buffer[(pxRow * imgWidth) + pxCol] = 0xFF;
					}
				}
				else if(fatFound)
				{
					// already found fat region; end of search in this row
					fatFound = NO;
					break;
				}
				
			}
		}
		
		/////
		
		// right to left
		for(pxRow = 0; pxRow < imgHeight; pxRow++)
		{
			fatFound = NO;
			
			for(pxCol = (imgWidth - 1); pxCol >= 0; pxCol--)
			{
				if(fImage[(pxRow * imgWidth) + pxCol] >= [sldFatThreshold intValue])
				{
					// found bright pixels
					fatFound = YES;
					
					if((pxRow >= (int)rectROI.origin.y) && (pxRow <= ceil(rectROI.origin.y + rectROI.size.height)) && (pxCol >= (int)rectROI.origin.x) && (pxCol <= ceil(rectROI.origin.x + rectROI.size.width)))
					{
						// only include fat within the rectangle
						// found fat -> update buffer array
						buffer[(pxRow * imgWidth) + pxCol] = 0xFF;
					}
				}
				else if(fatFound)
				{
					// already found fat region; end of search in this row
					fatFound = NO;
					break;
				}
				
			}
		}
		
		/////
		
		// anterior to posterior search; not highly beneficial and subject to misidentifying pixels beyond the fat region
		/*
		 msg = [NSString stringWithFormat:@"Anterior to Posterior Search"];
		 myAlert = [NSAlert alertWithMessageText:msg
		 defaultButton:@"OK"
		 alternateButton:nil
		 otherButton:nil
		 informativeTextWithFormat:@""];
		 [myAlert runModal];
		 
		 for(pxCol = 0; pxCol < imgWidth; pxCol++)
		 {
		 fatFound = NO;
		 
		 for(pxRow = (imgHeight - 1); pxRow >= 0; pxRow--)
		 {
		 if(fImage[(pxRow * imgWidth) + pxCol] >= 450.)
		 //if((pxRow >= (int)rectROI.origin.y) && (pxRow <= ceil(rectROI.origin.y + rectROI.size.height)) && (pxCol >= (int)rectROI.origin.x) && (pxCol <= ceil(rectROI.origin.x + rectROI.size.width)))
		 {
		 // found bright pixels
		 fatFound = YES;
		 
		 //if(fImage[(pxRow * imgWidth) + pxCol] >= 450.)
		 if((pxRow >= (int)rectROI.origin.y) && (pxRow <= ceil(rectROI.origin.y + rectROI.size.height)) && (pxCol >= (int)rectROI.origin.x) && (pxCol <= ceil(rectROI.origin.x + rectROI.size.width)))
		 {
		 // only include fat within the rectangle
		 // found fat -> update buffer array
		 buffer[(pxRow * imgWidth) + pxCol] = 0xFF;
		 }
		 }
		 else if(fatFound)
		 {
		 // already found fat region; end of search in this row
		 fatFound = NO;
		 break;
		 }
		 }
		 }
		 */
		/////
		
		[viewerController deleteROI:curROI]; // delete rectangle ROI
		
		brushROI = [[[ROI alloc] initWithTexture:buffer
									   textWidth:imgWidth
									  textHeight:imgHeight
										textName:@"Fat"
									   positionX:0
									   positionY:0
										spacingX:[curPix pixelSpacingX]
										spacingY:[curPix pixelSpacingY]
									 imageOrigin:NSMakePoint(0, 0)] autorelease];
		
		free(buffer);
		
		[[[viewerController roiList] objectAtIndex:curSlice] addObject: brushROI];
		[brushROI setColor:(RGBColor){0,65535,0}];
		[brushROI setOpacity:0.35];
		
		[viewerController needsDisplayUpdate];
		
	}
	
	///// End identifying pixels above intensity threshold
	///////////////////////////////////////////////////////////////////
	
}

-(IBAction)computeFat:(id)sender
{	
	pixList       = [viewerController pixList];
	int curSlice  = [[viewerController imageView] curImage];
	thisPix       = [pixList objectAtIndex: curSlice];
	roiSeriesList = [viewerController roiList];	
	roiImageList  = [roiSeriesList objectAtIndex:curSlice];

	int seriesROIs = [roiSeriesList count];
	int imageROIs;
	
	NSString        *dcmFilePath;
	NSString		*dcmSliceThicknessTag;
	
	DCMAttributeTag *dcmTag;
	DCMObject       *dcmObj;
	DCMAttribute    *dcmAttr;
	
	NSString		*dcmSliceThickness;
	float			sliceThickness;
	
	dcmFilePath = [thisPix sourceFile];
	dcmObj = [DCMObject objectWithContentsOfFile: dcmFilePath decodingPixelData: NO];
	
	// get slice thickness
	dcmSliceThicknessTag = @"0018,0050"; // slice thickness (mm)
	dcmTag = [DCMAttributeTag tagWithTagString:dcmSliceThicknessTag];
	dcmAttr = [dcmObj attributeForTag: dcmTag];
	dcmSliceThickness = [[dcmAttr value] description];
	sliceThickness = [dcmSliceThickness floatValue];
	
	int refPtImage, i, j;
	int totalSlices = [roiSeriesList count];
	float slicesAboveRef, slicesBelowRef; // for flap
	int flapDistAbove = 30; // in mm
	int flapDistBelow = 100; // in mm
	
	slicesAboveRef = flapDistAbove / sliceThickness;
	slicesBelowRef = flapDistBelow / sliceThickness;
	
	ROI *curROI;
	BOOL refPtFound = NO;
	// find image with reference point
	for(i = 0; i < seriesROIs; i++)
	{
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs = [roiImageList count];
		
		[viewerController setImageIndex:([roiSeriesList count] - (i + 1))];
		
		for(j = 0; j < imageROIs; j++)
		{
			curROI = [roiImageList objectAtIndex:j];
			
			if([curROI type] == t2DPoint)
			{
				refPtImage = [[viewerController imageView] curImage];
				refPtFound = YES;
			}
		}
		if(refPtFound)
		{
			break;
		}
	}
	
	int fatImg;
	float fatVolume = 0.0;
	BOOL brushFound;
	// loop through each fat region image (images containing rectangles); goes most superior -> most inferior
	for(fatImg = (totalSlices - refPtImage -(ceil(slicesAboveRef) + 1)); fatImg < (totalSlices - refPtImage + ceil(slicesBelowRef)); fatImg++)
	{
		brushFound = NO;
		
		[viewerController setImageIndex:fatImg];
		
		curSlice = [[viewerController imageView] curImage];
		
		roiImageList  = [roiSeriesList objectAtIndex:curSlice];
		
		for(i = 0; i < [roiImageList count]; i++)
		{
			curROI = [roiImageList objectAtIndex:i];			
			
			// update fat volume with each brush ROI volume
			if([curROI type] == tPlain)
			{
				if((fatImg == (totalSlices - refPtImage -(ceil(slicesAboveRef) + 1))) && ((slicesAboveRef - floor(slicesAboveRef)) > 0))
				{
					// most superior slice is fractional
					fatVolume = fatVolume + ([curROI roiArea] * ((sliceThickness * (slicesAboveRef - floor(slicesAboveRef))) / 10.));			
				}
				else if((fatImg == (totalSlices - refPtImage + ceil(slicesBelowRef)) - 1) && ((slicesBelowRef - floor(slicesBelowRef)) > 0))
				{
					// most inferior slice is fractional
					fatVolume = fatVolume + ([curROI roiArea] * ((sliceThickness * (slicesBelowRef - floor(slicesBelowRef))) / 10.));
				}
				else
				{
					// divide by 10 as slice thickness in mm and brushROI area in cm
					fatVolume = fatVolume + ([curROI roiArea] * (sliceThickness / 10.));
				}
				
				brushFound = YES;
			}
			
		}
		
		if(!brushFound)
		{
			return;
		}
	
		[viewerController needsDisplayUpdate];
	}

	[txtFatR setIntValue:fatVolume]; // cast to int
	[self backupFat];
	
}

-(IBAction)setFat:(id)sender
{
	[self backupFat];
}

-(void)backupFat
{
	NSString* fatPath = [NSString stringWithFormat:@"%@/archive/fat.vals", [txtPath stringValue]];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/archive/fat.vals", [txtPath stringValue]]])
	{		
		// create new file to store ROI object attributes
		[[NSFileManager defaultManager] createFileAtPath:fatPath contents:nil attributes:nil];
	}
	
	// write attributes to text file
	NSString *objDump = [NSString stringWithFormat:@"%f,%f\n", [txtFatL floatValue], [txtFatR floatValue]];
	[objDump writeToFile:fatPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(void)openImage
{
	sleep(1);
	
	NSDictionary* errorDict;
	NSAppleEventDescriptor* returnDescriptor = NULL;
	
	NSString* reportGenScript;
	NSAppleScript* scriptObject;
	
	reportGenScript = [NSString stringWithFormat:@"tell application \"Finder\"\nopen POSIX file \"%@/%@-crop.jpg\"\nend tell", [txtPath stringValue], [[txtROI stringValue] lowercaseString]];
	
	scriptObject = [[NSAppleScript alloc] initWithSource:reportGenScript];
	
	returnDescriptor = [scriptObject executeAndReturnError:&errorDict];
	
	if(returnDescriptor != NULL)
	{
		// successful execution
		if(kAENullEvent != [returnDescriptor descriptorType])
		{
			// script returned an AppleScript result
			if(cAEList == [returnDescriptor descriptorType])
			{
				// result is a list of other descriptors
			}
			else
			{
				// coerce the result to the appropriate ObjC type
			}
		}
	}
	else
	{
		// no script result; handle error here
	}
	
	[scriptObject release];
}

-(IBAction)measureLength:(id)sender
{
	short shROIs;
	short shROISeries;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	shROISeries   = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];
	
	int i, j;
	NSPoint curPoint;
	BOOL ptFound = NO;
	
	// starting point coordinates in segment
	float x0;
	float y0;
	float z0;
	
	// running total distance
	float euclidDist = 0.0;
	

	int tmpROIs = -1 * [roiPoints count]; // subtract the true ROI points
	
	// get number of temporary points for use in measuring
	for(i = 0; i < shROISeries; i++)
	{
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		shROIs       = [roiImageList  count];
		
		tmpROIs = tmpROIs + shROIs;
	}
	
	// find perforator starting point (L1, L2, etc.)
	for(i = 0; i < shROISeries; i++)
	{
		thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		shROIs       = [roiImageList  count];
		
		for(j = 0; j < shROIs; j++)
		{	
			[viewerController setImageIndex:(shROISeries - (i + 1))];
			roi = [roiImageList objectAtIndex:j];

			if ([[roi name] isEqualToString:[txtROI stringValue]]) {
				
				curPoint = [roi centroid];
				
				[[[viewerController imageView] curDCM] convertPixX:(float)curPoint.x pixY:(float)curPoint.y toDICOMCoords:(float *)dcmCoords];
				
				ptFound = YES;
				
				x0 = dcmCoords[0];
				y0 = dcmCoords[1];
				z0 = dcmCoords[2];
				
				break;
				
			}			
		}
		if(ptFound)
		{
			break;
		}
	}
	
	
	NSString* tmpROIName;
	int p;
	
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:[txtROI stringValue]])
		{			
			// clear coursePoints first
			[[pt coursePoints] removeAllObjects];
			
			// find sequential temp ROIs and measure
			for(p = 1; p <= tmpROIs; p++)
			{
				tmpROIName = [NSString stringWithFormat:@"Point %d", p];
				
				ptFound = NO;
				
				for(i = 0; i < shROISeries; i++)
				{
					thisPix      = [pixList       objectAtIndex: i];
					roiImageList = [roiSeriesList objectAtIndex: i];
					shROIs       = [roiImageList  count];
					
					for(j = 0; j < shROIs; j++)
					{	
						[viewerController setImageIndex:(shROISeries - (i + 1))];
						roi = [roiImageList objectAtIndex:j];
						
						if ([[roi name] isEqualToString:tmpROIName]) {
							
							curPoint = [roi centroid];
							
							[[[viewerController imageView] curDCM] convertPixX:(float)curPoint.x pixY:(float)curPoint.y toDICOMCoords:(float *)dcmCoords];
							
							ptFound = YES;
							
							ROIPoint* coursePt = [[ROIPoint alloc] init];
							coursePt.roiID = [roi name];
							coursePt.x2D = [roi centroid].x;
							coursePt.y2D = [roi centroid].y;
							coursePt.slice = i;
							// rest of ROIPoint attributes are irrelevant for measuring the course
							
							[[pt coursePoints] addObject:coursePt];
							
							// compute distance and add to running total
							euclidDist = euclidDist + sqrt(pow(dcmCoords[0] - x0, 2) + pow(dcmCoords[1] - y0, 2) + pow(dcmCoords[2] - z0, 2));
							
							// update coordinates
							x0 = dcmCoords[0];
							y0 = dcmCoords[1];
							z0 = dcmCoords[2];
							
							// delete ROI just measured to
							[viewerController deleteROI:roi];
							
							break;
							
						}			
					}
					if(ptFound)
					{
						break;
					}
				}
			}
		}
	}
		
	NSString* lenRounded = [NSString stringWithFormat:@"%.1f", euclidDist];
	[txtLength setStringValue:lenRounded];
	
	if([btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self nextROI];
	}
	else if(![btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self jumpToFirstPerf];
	}
	else
	{
		// find current perf in roiPoints
		for(ROIPoint *pt in roiPoints)
		{
			if([pt.roiID isEqualToString:[txtROI stringValue]])
			{
				// set image back to same perforator
				[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
			}
		}
	}

	
	
}

-(IBAction)clickClearPoints:(id)sender
{
	[self clearPoints];
}

-(void)clearPoints
{	
	int seriesROIs;
	int imageROIs;
	
	pixList       = [viewerController pixList];	
	thisPix       = [pixList objectAtIndex: 0];
	
	roiSeriesList = [viewerController roiList];
	seriesROIs = [roiSeriesList count];
	numSlices = (float)[roiSeriesList count];
	
	int i, j, p;
	NSString* tmpROIName;
	BOOL ptFound = NO;
	
	int tmpROIs = -1 * [roiPoints count]; // subtract the true ROI points
	
	// get number of temporary points for use in measuring
	for(i = 0; i < seriesROIs; i++)
	{
		//thisPix      = [pixList       objectAtIndex: i];
		roiImageList = [roiSeriesList objectAtIndex: i];
		imageROIs       = [roiImageList  count];
		
		tmpROIs = tmpROIs + imageROIs;
	}
	
	// find sequential temp ROIs and measure
	for(p = 1; p <= tmpROIs; p++)
	{
		tmpROIName = [NSString stringWithFormat:@"Point %d", p];
		
		ptFound = NO;
		
		for(i = 0; i < seriesROIs; i++)
		{
			roiImageList = [roiSeriesList objectAtIndex: i];
			imageROIs       = [roiImageList  count];
			
			for(j = 0; j < imageROIs; j++)
			{	
				roi = [roiImageList objectAtIndex:j];
				
				if ([[roi name] isEqualToString:tmpROIName])
				{
					ptFound = YES;
					
					// delete ROI just found (*** only deletes points with default naming [i.e. "Point 1", "Point 2", etc.])
					[viewerController deleteROI:roi];
					
					break;
					
				}			
			}
			if(ptFound)
			{
				break;
			}
		}
	}
	
	// find current perf in roiPoints
	for(ROIPoint *pt in roiPoints)
	{
		if([pt.roiID isEqualToString:[txtROI stringValue]])
		{
			// set image back to same perforator
			[viewerController setImageIndex:((int)numSlices - pt.slice - 1)];
		}
	}
}

-(IBAction)setDiameter:(id)sender
{
	if([btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self nextROI];
	}
	else if(![btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self jumpToFirstPerf];
	}	
}

-(IBAction)setCourse:(id)sender
{
	if([btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self nextROI];
	}
	else if(![btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self jumpToFirstPerf];
	}
}

-(IBAction)setBranchOf:(id)sender
{
	if([btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self nextROI];
	}
	else if(![btnNextROI isEnabled] && [self perfAttrComplete])
	{
		[self jumpToFirstPerf];
	}
}

-(IBAction)clickNextPage:(id)sender
{
    
    NSLog(@"*****************In Click Next Page*****************");

	switch (interfaceIndex)
	{
		// cases based on visible page when button is clicked
		case 1:
			
			// get ROI points (replaces 'Get ROIs' button from before)
			if(refPt == nil || ![self getPoints])
			{
                NSLog(@"Doing Nothing");
				return;
			}
			
			// hide first page items
			[lblRefPt setHidden:YES];
			[cboRefPt setHidden:YES];
			[chkQuickReport setHidden:YES];
			
			[txtOsiriXLabel setHidden:YES];
			[btnRefPoint setHidden:YES];
			[btnPPoints setHidden:YES];
			[chkSupine setHidden:YES];
			[btnVPoints setHidden:YES];
			
			// show second page items
			[btnPrevROI setHidden:NO];
			[txtROI setHidden:NO];
			[btnNextROI setHidden:NO];
			
			[lblDiameter setHidden:NO];
			[cboDiameter setHidden:NO];
			
			if([chkQuickReport state] == NSOffState)
			{
                NSLog(@"QuickReport State is OffState");
                NSLog([NSString stringWithFormat:@"Point is %@" , refPt]);
				if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
				{
					[lblLength setHidden:NO];
					[txtLength setHidden:NO];
					[btnMeasureLength setHidden:NO];
					[btnClearPoints setHidden:NO];				
				}
				
				[lblBranchOf setHidden:NO];
				[cboBranchOf setHidden:NO];
				
				if ([refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SGC"])
				{
					[lblCourse setHidden:NO];
					[cboCourse setHidden:NO];
				}
				
				[btnDrawRectangle setHidden:NO];
				[lblAnnotate setHidden:NO];
				[cboPerforators setHidden:NO];
				[btnClearAnnotations setHidden:NO];
				[chkAutoDelete setHidden:NO];
				[btnSaveCrop setHidden:NO];
				[chkReviewImg setHidden:NO];
			}
			
			/*
			if([chkQuickReport state] == NSOffState)
			{
				[btnPrev3DImage setHidden:NO];
				[txt3DImage setHidden:NO];
				[btnNext3DImage setHidden:NO];
				
				[chkProjToSkin setHidden:NO];
				
				[btnPlotLabels setHidden:NO];
				[btnPlotCourse setHidden:NO];
				
				[btnSave3DImage setHidden:NO];				
			}
			
			if([refPt isEqualToString:@"UMB"])
			{
				[txtLeftDIEA setHidden:NO];
				[cboLeftDIEA setHidden:NO];
				[txtDIEA setHidden:NO];
				[cboRightDIEA setHidden:NO];
				[txtRightDIEA setHidden:NO];
			}
			*/
			 
			[btnPrevPage setEnabled:YES];
			
			break;
			
		case 2:
			
			// hide second page items
			[btnPrevROI setHidden:YES];
			[txtROI setHidden:YES];
			[btnNextROI setHidden:YES];
			
			[lblDiameter setHidden:YES];
			[cboDiameter setHidden:YES];
			[lblLength setHidden:YES];
			[txtLength setHidden:YES];
			[btnMeasureLength setHidden:YES];
			[btnClearPoints setHidden:YES];
			[lblCourse setHidden:YES];
			[cboCourse setHidden:YES];
			[lblBranchOf setHidden:YES];
			[cboBranchOf setHidden:YES];
			
			[btnDrawRectangle setHidden:YES];
			[lblAnnotate setHidden:YES];
			[cboPerforators setHidden:YES];
			[btnClearAnnotations setHidden:YES];
			[chkAutoDelete setHidden:YES];
			[btnSaveCrop setHidden:YES];
			[chkReviewImg setHidden:YES];
			
			/*
			[btnPrev3DImage setHidden:YES];
			[txt3DImage setHidden:YES];
			[btnNext3DImage setHidden:YES];
			
			[chkProjToSkin setHidden:YES];
			
			[btnPlotLabels setHidden:YES];
			[btnPlotCourse setHidden:YES];
			
			[btnSave3DImage setHidden:YES];
			
			[txtLeftDIEA setHidden:YES];
			[cboLeftDIEA setHidden:YES];
			[txtDIEA setHidden:YES];
			[cboRightDIEA setHidden:YES];
			[txtRightDIEA setHidden:YES];
			*/
			 
			// show third page items
			if([chkQuickReport state] == NSOffState)
			{
				[btnPrev3DImage setHidden:NO];
				[txt3DImage setHidden:NO];
				[btnNext3DImage setHidden:NO];
				
				[chkProjToSkin setHidden:NO];
				
				[btnPlotLabels setHidden:NO];
				[btnPlotCourse setHidden:NO];
				
				[btnSave3DImage setHidden:NO];				
			}
			
			if([refPt isEqualToString:@"UMB"])
			{
				[txtLeftDIEA setHidden:NO];
				[cboLeftDIEA setHidden:NO];
				[txtDIEA setHidden:NO];
				[cboRightDIEA setHidden:NO];
				[txtRightDIEA setHidden:NO];
			}
			
			/*
			[btnPrevROI setHidden:NO];
			[txtROI setHidden:NO];
			[btnNextROI setHidden:NO];
			
			[lblDiameter setHidden:NO];
			[cboDiameter setHidden:NO];
			
			if([chkQuickReport state] == NSOffState)
			{
				if ([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
				{
					[lblLength setHidden:NO];
					[txtLength setHidden:NO];
					[btnMeasureLength setHidden:NO];
					[btnClearPoints setHidden:NO];				
				}
				
				[lblBranchOf setHidden:NO];
				[cboBranchOf setHidden:NO];
				
				if ([refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SGC"])
				{
					[lblCourse setHidden:NO];
					[cboCourse setHidden:NO];
				}
				
				[btnDrawRectangle setHidden:NO];
				[lblAnnotate setHidden:NO];
				[cboPerforators setHidden:NO];
				[btnClearAnnotations setHidden:NO];
				[chkAutoDelete setHidden:NO];
				[btnSaveCrop setHidden:NO];
				[chkReviewImg setHidden:NO];
			}
			*/
			
			break;
			
		case 3:
			
			// hide third page items
			[btnPrev3DImage setHidden:YES];
			[txt3DImage setHidden:YES];
			[btnNext3DImage setHidden:YES];
			
			[chkProjToSkin setHidden:YES];
			
			[btnPlotLabels setHidden:YES];
			[btnPlotCourse setHidden:YES];
			
			[btnSave3DImage setHidden:YES];
			
			[txtLeftDIEA setHidden:YES];
			[cboLeftDIEA setHidden:YES];
			[txtDIEA setHidden:YES];
			[cboRightDIEA setHidden:YES];
			[txtRightDIEA setHidden:YES];
			
			/*
			[btnPrevROI setHidden:YES];
			[txtROI setHidden:YES];
			[btnNextROI setHidden:YES];
			
			[lblDiameter setHidden:YES];
			[cboDiameter setHidden:YES];
			[lblLength setHidden:YES];
			[txtLength setHidden:YES];
			[btnMeasureLength setHidden:YES];
			[btnClearPoints setHidden:YES];
			[lblCourse setHidden:YES];
			[cboCourse setHidden:YES];
			[lblBranchOf setHidden:YES];
			[cboBranchOf setHidden:YES];
			
			[btnDrawRectangle setHidden:YES];
			[lblAnnotate setHidden:YES];
			[cboPerforators setHidden:YES];
			[btnClearAnnotations setHidden:YES];
			[chkAutoDelete setHidden:YES];
			[btnSaveCrop setHidden:YES];
			[chkReviewImg setHidden:YES];
			*/
			 
			// show fourth page items
			if([refPt isEqualToString:@"IGC"])
			{
				//[lblTransverse setHidden:NO];
				//[sldFatRectHeight setHidden:NO];
				//[lblAnteroposterior setHidden:NO];
				//[sldFatRectWidth setHidden:NO];
				//[btnPaintFat setHidden:NO];
				//[btnComputeFat setHidden:NO];
				
				[txtFatLblL setHidden:NO];
				[txtFatL setHidden:NO];
				[lblFatVolume setHidden:NO];
				[txtFatR setHidden:NO];
				[txtFatLblR setHidden:NO];				
			}
			else if([refPt isEqualToString:@"UMB"])
			{
				if([chkQuickReport state] == NSOffState)
				{
					// show interface for automated fat computation
					[lblTransverse setHidden:NO];
					[sldFatRectHeight setHidden:NO];
					[lblFatRectHeightValue setHidden:NO];
					[lblFatRectHeightValue setIntValue:[sldFatRectHeight intValue]];
					
					[lblAnteroposterior setHidden:NO];
					[sldFatRectWidth setHidden:NO];
					[lblFatRectWidthValue setHidden:NO];
					[lblFatRectWidthValue setIntValue:[sldFatRectWidth intValue]];
					
					[lblFatThreshold setHidden:NO];
					[sldFatThreshold setHidden:NO];
					[lblFatThresholdValue setHidden:NO];
					[lblFatThresholdValue setIntValue:[sldFatThreshold intValue]];
					
					[btnPaintFat setHidden:NO];
					[btnComputeFat setHidden:NO];					
				}
				
				// single fat volume for UMB case
				[lblFatVolume setHidden:NO];
				[txtFatR setHidden:NO];
			}
			
            [cboOutputTo setHidden:NO];
			[btnCreateReport setHidden:NO];
			
			// disable next page button
			[btnNextPage setEnabled:NO];
			
			break;
			
		default:
			break;
	}
	
	interfaceIndex++;
}

-(IBAction)clickPrevPage:(id)sender
{
	switch (interfaceIndex)
	{
		// cases based on visible page when button is clicked
		case 2:
			
			// show first page items
			[lblRefPt setHidden:NO];
			[cboRefPt setHidden:NO];
			
			[txtOsiriXLabel setHidden:NO];
			[btnRefPoint setHidden:NO];
			[btnPPoints setHidden:NO];
			[chkSupine setHidden:NO];
			
			if([refPt isEqualToString:@"UMB"])
			{
				[btnVPoints setHidden:NO];
				[chkQuickReport setHidden:NO];
			}
			
			// hide second page items
			[btnPrevROI setHidden:YES];
			[txtROI setHidden:YES];
			[btnNextROI setHidden:YES];
			
			[lblDiameter setHidden:YES];
			[cboDiameter setHidden:YES];
			[lblLength setHidden:YES];
			[txtLength setHidden:YES];
			[btnMeasureLength setHidden:YES];
			[btnClearPoints setHidden:YES];
			[lblCourse setHidden:YES];
			[cboCourse setHidden:YES];
			[lblBranchOf setHidden:YES];
			[cboBranchOf setHidden:YES];
			
			[btnDrawRectangle setHidden:YES];
			[lblAnnotate setHidden:YES];
			[cboPerforators setHidden:YES];
			[btnClearAnnotations setHidden:YES];
			[chkAutoDelete setHidden:YES];
			[btnSaveCrop setHidden:YES];
			[chkReviewImg setHidden:YES];
			
			/*
			[btnPrev3DImage setHidden:YES];
			[txt3DImage setHidden:YES];
			[btnNext3DImage setHidden:YES];
			
			[chkProjToSkin setHidden:YES];
			
			[btnPlotLabels setHidden:YES];
			[btnPlotCourse setHidden:YES];
			
			[btnSave3DImage setHidden:YES];
			
			[txtLeftDIEA setHidden:YES];
			[cboLeftDIEA setHidden:YES];
			[txtDIEA setHidden:YES];
			[cboRightDIEA setHidden:YES];
			[txtRightDIEA setHidden:YES];
			*/
			 
			[btnPrevPage setEnabled:NO];
			
			break;
			
		case 3:
			
			// show second page items
			[btnPrevROI setHidden:NO];
			[txtROI setHidden:NO];
			[btnNextROI setHidden:NO];
			
			[lblDiameter setHidden:NO];
			[cboDiameter setHidden:NO];
			
			if ([chkQuickReport state] == NSOffState)
			{
				if([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
				{
					[lblLength setHidden:NO];
					[txtLength setHidden:NO];
					[btnMeasureLength setHidden:NO];
					[btnClearPoints setHidden:NO];				
				}
				
				[lblBranchOf setHidden:NO];
				[cboBranchOf setHidden:NO];
				
				if ([refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SGC"])
				{
					[lblCourse setHidden:NO];
					[cboCourse setHidden:NO];
				}
				
				[btnDrawRectangle setHidden:NO];
				[lblAnnotate setHidden:NO];
				[cboPerforators setHidden:NO];
				[btnClearAnnotations setHidden:NO];
				[chkAutoDelete setHidden:NO];
				[btnSaveCrop setHidden:NO];
				[chkReviewImg setHidden:NO];
			}
			
			/*
			if([chkQuickReport state] == NSOffState)
			{
				[btnPrev3DImage setHidden:NO];
				[txt3DImage setHidden:NO];
				[btnNext3DImage setHidden:NO];
				
				[chkProjToSkin setHidden:NO];
				
				[btnPlotLabels setHidden:NO];
				[btnPlotCourse setHidden:NO];
				
				[btnSave3DImage setHidden:NO];				
			}
			
			if([refPt isEqualToString:@"UMB"])
			{
				[txtLeftDIEA setHidden:NO];
				[cboLeftDIEA setHidden:NO];
				[txtDIEA setHidden:NO];
				[cboRightDIEA setHidden:NO];
				[txtRightDIEA setHidden:NO];
			}
			*/
			
			// hide third page items
			[btnPrev3DImage setHidden:YES];
			[txt3DImage setHidden:YES];
			[btnNext3DImage setHidden:YES];
			
			[chkProjToSkin setHidden:YES];
			
			[btnPlotLabels setHidden:YES];
			[btnPlotCourse setHidden:YES];
			
			[btnSave3DImage setHidden:YES];
			
			[txtLeftDIEA setHidden:YES];
			[cboLeftDIEA setHidden:YES];
			[txtDIEA setHidden:YES];
			[cboRightDIEA setHidden:YES];
			[txtRightDIEA setHidden:YES];
			
			/*
			[btnPrevROI setHidden:YES];
			[txtROI setHidden:YES];
			[btnNextROI setHidden:YES];
			
			[lblDiameter setHidden:YES];
			[cboDiameter setHidden:YES];
			[lblLength setHidden:YES];
			[txtLength setHidden:YES];
			[btnMeasureLength setHidden:YES];
			[btnClearPoints setHidden:YES];
			[lblCourse setHidden:YES];
			[cboCourse setHidden:YES];
			[lblBranchOf setHidden:YES];
			[cboBranchOf setHidden:YES];
			
			[btnDrawRectangle setHidden:YES];
			[lblAnnotate setHidden:YES];
			[cboPerforators setHidden:YES];
			[btnClearAnnotations setHidden:YES];
			[chkAutoDelete setHidden:YES];
			[btnSaveCrop setHidden:YES];
			[chkReviewImg setHidden:YES];
			*/
			 
			break;
			
		case 4:
			
			// show third page items
			if([chkQuickReport state] == NSOffState)
			{
				[btnPrev3DImage setHidden:NO];
				[txt3DImage setHidden:NO];
				[btnNext3DImage setHidden:NO];
				
				[chkProjToSkin setHidden:NO];
				
				[btnPlotLabels setHidden:NO];
				[btnPlotCourse setHidden:NO];
				
				[btnSave3DImage setHidden:NO];				
			}
			
			if([refPt isEqualToString:@"UMB"])
			{
				[txtLeftDIEA setHidden:NO];
				[cboLeftDIEA setHidden:NO];
				[txtDIEA setHidden:NO];
				[cboRightDIEA setHidden:NO];
				[txtRightDIEA setHidden:NO];
			}
			
			/*
			[btnPrevROI setHidden:NO];
			[txtROI setHidden:NO];
			[btnNextROI setHidden:NO];
			
			[lblDiameter setHidden:NO];
			[cboDiameter setHidden:NO];
			
			if ([chkQuickReport state] == NSOffState)
			{
				if([refPt isEqualToString:@"IGC"] || [refPt isEqualToString:@"UMB"])
				{
					[lblLength setHidden:NO];
					[txtLength setHidden:NO];
					[btnMeasureLength setHidden:NO];
					[btnClearPoints setHidden:NO];				
				}
				
				[lblBranchOf setHidden:NO];
				[cboBranchOf setHidden:NO];
				
				if ([refPt isEqualToString:@"UMB"] || [refPt isEqualToString:@"SGC"])
				{
					[lblCourse setHidden:NO];
					[cboCourse setHidden:NO];
				}
				
				[btnDrawRectangle setHidden:NO];
				[lblAnnotate setHidden:NO];
				[cboPerforators setHidden:NO];
				[btnClearAnnotations setHidden:NO];
				[chkAutoDelete setHidden:NO];
				[btnSaveCrop setHidden:NO];
				[chkReviewImg setHidden:NO];
			}
			*/
			
			// hide fourth page items
			[lblTransverse setHidden:YES];
			[sldFatRectHeight setHidden:YES];
			[lblFatRectHeightValue setHidden:YES];
			[lblAnteroposterior setHidden:YES];
			[sldFatRectWidth setHidden:YES];
			[lblFatRectWidthValue setHidden:YES];
			[lblFatThreshold setHidden:YES];
			[sldFatThreshold setHidden:YES];
			[lblFatThresholdValue setHidden:YES];
			[btnPaintFat setHidden:YES];
			[btnComputeFat setHidden:YES];
			
			[txtFatLblL setHidden:YES];
			[txtFatL setHidden:YES];
			[lblFatVolume setHidden:YES];
			[txtFatR setHidden:YES];
			[txtFatLblR setHidden:YES];				
			
            [cboOutputTo setHidden:YES];
			[btnCreateReport setHidden:YES];
			
			// enable next page button
			[btnNextPage setEnabled:YES];
			
			break;
			
		default:
			break;
	}
	
	interfaceIndex--;
}

-(IBAction)clickAbout:(id)sender
{
	NSAlert *myAlert;
	
	myAlert = [NSAlert alertWithMessageText:@"PFA Reporting Assistant"
							  defaultButton:@"Close"
							alternateButton:nil
								otherButton:nil
				  informativeTextWithFormat:@"Copyright 2015, Weill Cornell Medical College\n\nCreated by: C. Lange, S.R. Boddu, S. Dutruel, N. Thimmappa, and M.R. Prince"];
	
	[myAlert runModal];	
}

-(IBAction)clickSummary:(id)sender
{	
	if([sender state] == NSOnState)
	{
		NSRect interface = [winInterface frame];
		NSRect summary = [winSummary frame];
		
		// position the summary window directly below the main plugin window
		NSPoint position;
		position.x = interface.origin.x;
		position.y = interface.origin.y - summary.size.height;
		
		[winSummary setFrameOrigin:position];
		[winSummary makeKeyAndOrderFront:sender];
	}
	else
	{
		[winSummary close];
	}
}

@synthesize roi;
@synthesize roiPoints;
@synthesize refPt;

@end
