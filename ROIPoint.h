//
//  ROIPoint.h
//  PFARA
//
//  Created by Radiology on 4/3/14.
//  Copyright 2014 Weill Cornell Medical College. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ROIPoint : NSObject {

	NSString	*roiID; // name/identifier
	char		group; // L, R, I, S, U -> (Left, Right, IGC, SGC/SSN, UMB)
	float		x2D; // 2D x-coordinate (px) from initial 2-dimensional view
	float		y2D; // 2D y-coordinate (px) from initial 2-dimensional view
	float		x3D; // 3D x-coordinate (mm) from initial 2-dimensional view
	float		y3D; // 3D y-coordinate (mm) from initial 2-dimensional view
	float		z3D; // 3D z-coordinate (mm) from initial 2-dimensional view
	float		antProjY2D; // 2D y-coordinate of anterior skin-point projection
	float		postProjY2D; // 2D y-coordinate of posterior skin-point projection
	float		distToMid; // distance left or right from the midline (reference point); for IGC/SGC this is distance on the skin, measured with an open Polygon
	float		distToGracilis; // distance along muscle from perforator to posterior margin of gracilis
	short		slice; // image in series containing the ROI
	float		diameter; // diameter of the vessel
	float		length; // length of the vessel
	NSString	*course; // course of the vessel
	NSString	*branchOf; // for IGC/SGC cases
	NSMutableArray *coursePoints; // holds sequential measurement points for course mapping on 3D-VR image
	//BOOL		isRefPt;

	
}

@property (retain)	NSString	*roiID;
@property	char				group;
@property	float				x2D;
@property	float				y2D;
@property	float				x3D;
@property	float				y3D;
@property	float				z3D;
@property	float				antProjY2D;
@property	float				postProjY2D;
@property	float				distToMid;
@property	float				distToGracilis;
@property	short				slice;
@property	float				diameter;
@property	float				length;
@property (retain)	NSString	*course;
@property (retain)	NSString	*branchOf;
@property (nonatomic, retain) NSMutableArray *coursePoints;
//@property	BOOL				isRefPt;

@end
