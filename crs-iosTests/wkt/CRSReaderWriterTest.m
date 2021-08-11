//
//  CRSReaderWriterTest.m
//  crs-iosTests
//
//  Created by Brian Osborn on 8/5/21.
//  Copyright © 2021 NGA. All rights reserved.
//

#import "CRSReaderWriterTest.h"
#import "CRSTestUtils.h"
#import "CRSReader.h"
#import "CRSWriter.h"
#import "CRSTextUtils.h"

@implementation CRSReaderWriterTest

/**
 * Test scope
 */
-(void) testScope{
    
    NSString *text = @"SCOPE[\"Large scale topographic mapping and cadastre.\"]";
    CRSReader *reader = [CRSReader createWithText:text];
    NSString *scope = [reader readScope];
    [CRSTestUtils assertNotNil:scope];
    [CRSTestUtils assertEqualWithValue:@"Large scale topographic mapping and cadastre." andValue2:scope];
    CRSWriter *writer = [CRSWriter create];
    [writer writeScope:scope];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];
    
}

/**
 * Test area description
 */
-(void) testAreaDescription{
    
    NSString *text = @"AREA[\"Netherlands offshore.\"]";
    CRSReader *reader = [CRSReader createWithText:text];
    NSString *areaDescription = [reader readAreaDescription];
    [CRSTestUtils assertNotNil:areaDescription];
    [CRSTestUtils assertEqualWithValue:@"Netherlands offshore." andValue2:areaDescription];
    CRSWriter *writer = [CRSWriter create];
    [writer writeAreaDescription:areaDescription];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];
    
}

/**
 * Test geographic bounding box
 */
-(void) testGeographicBoundingBox{
    
    NSString *text = @"BBOX[51.43,2.54,55.77,6.40]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSGeographicBoundingBox *boundingBox = [reader readGeographicBoundingBox];
    [CRSTestUtils assertNotNil:boundingBox];
    [CRSTestUtils assertEqualDoubleWithValue:51.43 andValue2:boundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:2.54 andValue2:boundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:55.77 andValue2:boundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:6.40 andValue2:boundingBox.upperRightLongitude];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@".40" withString:@".4"]
                             andValue2:[boundingBox description]];
    
    text = @"BBOX[-55.95,160.60,-25.88,-171.20]";
    reader = [CRSReader createWithText:text];
    boundingBox = [reader readGeographicBoundingBox];
    [CRSTestUtils assertNotNil:boundingBox];
    [CRSTestUtils assertEqualDoubleWithValue:-55.95 andValue2:boundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:160.60 andValue2:boundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:-25.88 andValue2:boundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:-171.20 andValue2:boundingBox.upperRightLongitude];
    [CRSTestUtils assertEqualWithValue:[[text stringByReplacingOccurrencesOfString:@".60" withString:@".6"]
                                        stringByReplacingOccurrencesOfString:@".20" withString:@".2"]
                             andValue2:[boundingBox description]];
    
}

/**
 * Test vertical extent
 */
-(void) testVerticalExtent{
    
    NSString *text = @"VERTICALEXTENT[-1000,0,LENGTHUNIT[\"metre\",1.0]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSVerticalExtent *verticalExtent = [reader readVerticalExtent];
    [CRSTestUtils assertNotNil:verticalExtent];
    [CRSTestUtils assertEqualDoubleWithValue:-1000 andValue2:verticalExtent.minimumHeight];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:verticalExtent.maximumHeight];
    CRSUnit *lengthUnit = verticalExtent.unit;
    [CRSTestUtils assertNotNil:lengthUnit];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:lengthUnit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:lengthUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[lengthUnit.conversionFactor doubleValue]];
    text = [text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalExtent description]];
    
    text = @"VERTICALEXTENT[-1000,0]";
    reader = [CRSReader createWithText:text];
    verticalExtent = [reader readVerticalExtent];
    [CRSTestUtils assertNotNil:verticalExtent];
    [CRSTestUtils assertEqualDoubleWithValue:-1000 andValue2:verticalExtent.minimumHeight];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:verticalExtent.maximumHeight];
    lengthUnit = verticalExtent.unit;
    [CRSTestUtils assertNil:lengthUnit];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalExtent description]];
    
}

/**
 * Test temporal extent
 */
-(void) testTemporalExtent{
    
    NSString *text = @"TIMEEXTENT[2013-01-01,2013-12-31]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSTemporalExtent *temporalExtent = [reader readTemporalExtent];
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"2013-01-01" andValue2:temporalExtent.start];
    [CRSTestUtils assertTrue:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2013-01-01" andValue2:[temporalExtent.startDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"2013-12-31" andValue2:temporalExtent.end];
    [CRSTestUtils assertTrue:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2013-12-31" andValue2:[temporalExtent.endDateTime description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalExtent description]];
    
    text = @"TIMEEXTENT[\"Jurassic\",\"Quaternary\"]";
    reader = [CRSReader createWithText:text];
    temporalExtent = [reader readTemporalExtent];
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"Jurassic" andValue2:temporalExtent.start];
    [CRSTestUtils assertFalse:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"Quaternary" andValue2:temporalExtent.end];
    [CRSTestUtils assertFalse:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalExtent description]];
    
}

/**
 * Test usage
 */
-(void) testUsage{

    NSMutableString *text = [NSMutableString string];
    [text appendString:@"USAGE[SCOPE[\"Spatial referencing.\"],"];
    [text appendString:@"AREA[\"Netherlands offshore.\"],TIMEEXTENT[1976-01,2001-04]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUsage *usage = [reader readUsage];
    [CRSTestUtils assertNotNil:usage];
    [CRSTestUtils assertEqualWithValue:@"Spatial referencing." andValue2:usage.scope];
    CRSExtent *extent = usage.extent;
    [CRSTestUtils assertNotNil:extent];
    [CRSTestUtils assertEqualWithValue:@"Netherlands offshore." andValue2:extent.areaDescription];
    CRSTemporalExtent *temporalExtent = extent.temporalExtent;
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"1976-01" andValue2:temporalExtent.start];
    [CRSTestUtils assertTrue:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"1976-01" andValue2:[temporalExtent.startDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"2001-04" andValue2:temporalExtent.end];
    [CRSTestUtils assertTrue:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2001-04" andValue2:[temporalExtent.endDateTime description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[usage description]];

}

/**
 * Test usages
 */
-(void) testUsages{

    NSMutableString *text = [NSMutableString string];
    [text appendString:@"USAGE[SCOPE[\"Small scale topographic mapping.\"],"];
    [text appendString:@"AREA[\"Finland - onshore and offshore.\"]],"];
    [text appendString:@"USAGE[SCOPE[\"Cadastre.\"],"];
    [text appendString:@"AREA[\"Finland - onshore between 26°30'E and 27°30'E.\"],"];
    [text appendString:@"BBOX[60.36,26.5,70.05,27.5]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    NSArray<CRSUsage *> *usages = [reader readUsages];
    [CRSTestUtils assertNotNil:usages];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)usages.count];
    CRSUsage *usage = [usages objectAtIndex:0];
    [CRSTestUtils assertEqualWithValue:@"Small scale topographic mapping." andValue2:usage.scope];
    CRSExtent *extent = usage.extent;
    [CRSTestUtils assertNotNil:extent];
    [CRSTestUtils assertEqualWithValue:@"Finland - onshore and offshore." andValue2:extent.areaDescription];
    usage = [usages objectAtIndex:1];
    [CRSTestUtils assertEqualWithValue:@"Cadastre." andValue2:usage.scope];
    extent = usage.extent;
    [CRSTestUtils assertNotNil:extent];
    [CRSTestUtils assertEqualWithValue:@"Finland - onshore between 26°30'E and 27°30'E." andValue2:extent.areaDescription];
    CRSGeographicBoundingBox *boundingBox = extent.geographicBoundingBox;
    [CRSTestUtils assertNotNil:boundingBox];
    [CRSTestUtils assertEqualDoubleWithValue:60.36 andValue2:boundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:26.5 andValue2:boundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:70.05 andValue2:boundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:27.5 andValue2:boundingBox.upperRightLongitude];
    CRSWriter *writer = [CRSWriter create];
    [writer writeUsages:usages];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];

}

/**
 * Test identifier
 */
-(void) testIdentifier{
    
    NSString *text = @"ID[\"Authority name\",\"Abcd_Ef\",7.1]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSIdentifier *identifier = [reader readIdentifier];
    [CRSTestUtils assertNotNil:identifier];
    [CRSTestUtils assertEqualWithValue:@"Authority name" andValue2:identifier.name];
    [CRSTestUtils assertEqualWithValue:@"Abcd_Ef" andValue2:identifier.uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"7.1" andValue2:identifier.version];
    [CRSTestUtils assertEqualWithValue:text andValue2:[identifier description]];
    
    text = @"ID[\"EPSG\",4326]";
    reader = [CRSReader createWithText:text];
    identifier = [reader readIdentifier];
    [CRSTestUtils assertNotNil:identifier];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:identifier.name];
    [CRSTestUtils assertEqualWithValue:@"4326" andValue2:identifier.uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:text andValue2:[identifier description]];
    
    text = @"ID[\"EPSG\",4326,URI[\"urn:ogc:def:crs:EPSG::4326\"]]";
    reader = [CRSReader createWithText:text];
    identifier = [reader readIdentifier];
    [CRSTestUtils assertNotNil:identifier];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:identifier.name];
    [CRSTestUtils assertEqualWithValue:@"4326" andValue2:identifier.uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"urn:ogc:def:crs:EPSG::4326" andValue2:identifier.uri];
    [CRSTestUtils assertEqualWithValue:text andValue2:[identifier description]];
    
    text = @"ID[\"EuroGeographics\",\"ES_ED50 (BAL99) to ETRS89\",\"2001-04-20\"]";
    reader = [CRSReader createWithText:text];
    identifier = [reader readIdentifier];
    [CRSTestUtils assertNotNil:identifier];
    [CRSTestUtils assertEqualWithValue:@"EuroGeographics" andValue2:identifier.name];
    [CRSTestUtils assertEqualWithValue:@"ES_ED50 (BAL99) to ETRS89" andValue2:identifier.uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"2001-04-20" andValue2:identifier.version];
    [CRSTestUtils assertEqualWithValue:text andValue2:[identifier description]];
    
}

/**
 * Test remark
 */
-(void) testRemark{
    
    NSString *text = @"REMARK[\"A remark in ASCII\"]";
    NSString *remark = @"A remark in ASCII";
    CRSReader *reader = [CRSReader createWithText:text];
    [CRSTestUtils assertEqualWithValue:remark andValue2:[reader readRemark]];
    CRSWriter *writer = [CRSWriter create];
    [writer writeRemark:remark];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];
    
    text = @"REMARK[\"Замечание на русском языке\"]";
    remark = @"Замечание на русском языке";
    reader = [CRSReader createWithText:text];
    [CRSTestUtils assertEqualWithValue:remark andValue2:[reader readRemark]];
    writer = [CRSWriter create];
    [writer writeRemark:remark];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];

    NSMutableString *text2 = [NSMutableString string];
    [text2 appendString:@"GEOGCRS[\"S-95\","];
    [text2 appendString:@"DATUM[\"Pulkovo 1995\","];
    [text2 appendString:@"ELLIPSOID[\"Krassowsky 1940\",6378245,298.3,"];
    [text2 appendString:@"LENGTHUNIT[\"metre\",1.0]]],CS[ellipsoidal,2],"];
    [text2 appendString:@"AXIS[\"latitude\",north,ORDER[1]],"];
    [text2 appendString:@"AXIS[\"longitude\",east,ORDER[2]],"];
    [text2 appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],"];
    [text2 appendString:@"REMARK[\"Система Геодеэических Координвт года 1995(СК-95)\"]"];
    [text2 appendString:@"]"];
    NSString *remarkText = @"REMARK[\"Система Геодеэических Координвт года 1995(СК-95)\"]";
    remark = @"Система Геодеэических Координвт года 1995(СК-95)";
    CRSCoordinateReferenceSystem *crs = [CRSReader readCoordinateReferenceSystem:text2 withStrict:YES];
    [CRSTestUtils assertEqualWithValue:remark andValue2:crs.remark];
    writer = [CRSWriter create];
    [writer writeRemark:crs.remark];
    [CRSTestUtils assertEqualWithValue:remarkText andValue2:[writer description]];
    
}

/**
 * Test length unit
 */
-(void) testLengthUnit{
    
    NSString *text = @"LENGTHUNIT[\"metre\",1]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUnit *unit = [reader readLengthUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    [unit setType:CRS_UNIT];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"LENGTHUNIT" withString:@"UNIT"] andValue2:[unit description]];
    
    text = @"LENGTHUNIT[\"German legal metre\",1.0000135965]";
    reader = [CRSReader createWithText:text];
    unit = [reader readLengthUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"German legal metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0000135965 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    [unit setType:CRS_UNIT];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"LENGTHUNIT" withString:@"UNIT"] andValue2:[unit description]];
    
}

/**
 * Test angle unit
 */
-(void) testAngleUnit{
    
    NSString *text = @"ANGLEUNIT[\"degree\",0.0174532925199433]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUnit *unit = [reader readAngleUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    [unit setType:CRS_UNIT];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"ANGLEUNIT" withString:@"UNIT"] andValue2:[unit description]];
    
}

/**
 * Test scale unit
 */
-(void) testScaleUnit{
    
    NSString *text = @"SCALEUNIT[\"parts per million\",1E-06]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUnit *unit = [reader readScaleUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_SCALE andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"parts per million" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1E-06 andValue2:[unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    [unit setType:CRS_UNIT];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"SCALEUNIT" withString:@"UNIT"] andValue2:[unit description]];
    
}

/**
 * Test parametric unit
 */
-(void) testParametricUnit{
    
    NSString *text = @"PARAMETRICUNIT[\"hectopascal\",100]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUnit *unit = [reader readParametricUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_PARAMETRIC andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"hectopascal" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:100 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    
}

/**
 * Test time unit
 */
-(void) testTimeUnit{
    
    NSString *text = @"TIMEUNIT[\"millisecond\",0.001]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUnit *unit = [reader readTimeUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"millisecond" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.001 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    
    text = @"TIMEUNIT[\"calendar month\"]";
    reader = [CRSReader createWithText:text];
    unit = [reader readTimeUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"calendar month" andValue2:unit.name];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    
    text = @"TIMEUNIT[\"calendar second\"]";
    reader = [CRSReader createWithText:text];
    unit = [reader readTimeUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"calendar second" andValue2:unit.name];
    [CRSTestUtils assertEqualWithValue:text andValue2:[unit description]];
    
    text = @"TIMEUNIT[\"day\",86400.0]";
    reader = [CRSReader createWithText:text];
    unit = [reader readTimeUnit];
    [reader reset];
    [CRSTestUtils assertEqualWithValue:unit andValue2:[reader readUnit]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"day" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:86400.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"86400.0" withString:@"86400"] andValue2:[unit description]];
    
}

/**
 * Test geodetic coordinate system
 */
-(void) testGeodeticCoordinateSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,3],AXIS[\"(X)\",geocentricX],"];
    [text appendString:@"AXIS[\"(Y)\",geocentricY],AXIS[\"(Z)\",geocentricZ],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSCoordinateSystem *coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    NSArray<CRSAxis *> *axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_X andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_Y andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualWithValue:@"Z" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_Z andValue2:[axes objectAtIndex:2].direction];
    CRSUnit *unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,3],"];
    [text appendString:@"AXIS[\"(X)\",east],AXIS[\"(Y)\",north],AXIS[\"(Z)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualWithValue:@"Z" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[axes objectAtIndex:2].direction];
    unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[spherical,3],"];
    [text appendString:@"AXIS[\"distance (r)\",awayFrom,ORDER[1],LENGTHUNIT[\"kilometre\",1000]],"];
    [text appendString:@"AXIS[\"longitude (U)\",counterClockwise,BEARING[0],ORDER[2],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"AXIS[\"elevation (V)\",up,ORDER[3],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_SPHERICAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"distance" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"r" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_AWAY_FROM andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"kilometre" andValue2:[axes objectAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1000 andValue2:[[axes objectAtIndex:0].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"longitude" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"U" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_COUNTER_CLOCKWISE andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"elevation" andValue2:[axes objectAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"V" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[axes objectAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:[[axes objectAtIndex:2].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:2].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:text andValue2:[coordinateSystem description]];
    
}

/**
 * Test geographic coordinate system
 */
-(void) testGeographicCoordinateSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CS[ellipsoidal,3],"];
    [text appendString:@"AXIS[\"latitude\",north,ORDER[1],ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"AXIS[\"longitude\",east,ORDER[2],ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"AXIS[\"ellipsoidal height (h)\",up,ORDER[3],LENGTHUNIT[\"metre\",1.0]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSCoordinateSystem *coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    NSArray<CRSAxis *> *axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"latitude" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"longitude" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"ellipsoidal height" andValue2:[axes objectAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"h" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[axes objectAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:[[axes objectAtIndex:2].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[axes objectAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[axes objectAtIndex:2].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[ellipsoidal,2],AXIS[\"(lat)\",north],"];
    [text appendString:@"AXIS[\"(lon)\",east],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"lat" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"lon" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:1].direction];
    CRSUnit *unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:text andValue2:[coordinateSystem description]];
    
}

/**
 * Test projected coordinate system
 */
-(void) testProjectedCoordinateSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,2],"];
    [text appendString:@"AXIS[\"(E)\",east,ORDER[1],LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"AXIS[\"(N)\",north,ORDER[2],LENGTHUNIT[\"metre\",1.0]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSCoordinateSystem *coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    NSArray<CRSAxis *> *axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"E" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[axes objectAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[axes objectAtIndex:0].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"N" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[axes objectAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[axes objectAtIndex:1].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,2],AXIS[\"(E)\",east],"];
    [text appendString:@"AXIS[\"(N)\",north],LENGTHUNIT[\"metre\",1.0]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"E" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"N" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:1].direction];
    CRSUnit *unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,2],AXIS[\"northing (X)\",north,ORDER[1]],"];
    [text appendString:@"AXIS[\"easting (Y)\",east,ORDER[2]],"];
    [text appendString:@"LENGTHUNIT[\"German legal metre\",1.0000135965]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"northing" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"easting" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"German legal metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0000135965 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,2],"];
    [text appendString:@"AXIS[\"easting (X)\",south,"];
    [text appendString:@"MERIDIAN[90,ANGLEUNIT[\"degree\",0.0174532925199433]],ORDER[1]"];
    [text appendString:@"],AXIS[\"northing (Y)\",south,"];
    [text appendString:@"MERIDIAN[180,ANGLEUNIT[\"degree\",0.0174532925199433]],ORDER[2]"];
    [text appendString:@"],LENGTHUNIT[\"metre\",1.0]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"easting" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualDoubleWithValue:90 andValue2:[[axes objectAtIndex:0].meridian doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:0].meridianUnit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:0].meridianUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:0].meridianUnit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"northing" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualDoubleWithValue:180 andValue2:[[axes objectAtIndex:1].meridian doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:1].meridianUnit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:1].meridianUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:1].meridianUnit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,3],AXIS[\"(E)\",east],"];
    [text appendString:@"AXIS[\"(N)\",north],AXIS[\"ellipsoid height (h)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"E" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"N" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualWithValue:@"ellipsoid height" andValue2:[axes objectAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"h" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[axes objectAtIndex:2].direction];
    unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];

}

/**
 * Test vertical coordinate system
 */
-(void) testVerticalCoordinateSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CS[vertical,1],AXIS[\"gravity-related height (H)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSCoordinateSystem *coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_VERTICAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:coordinateSystem.dimension];
    NSArray<CRSAxis *> *axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"gravity-related height" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"H" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[axes objectAtIndex:0].direction];
    CRSUnit *unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[vertical,1],AXIS[\"depth (D)\",down,"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_VERTICAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"depth" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"D" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_DOWN andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[axes objectAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[axes objectAtIndex:0].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
}

/**
 * Test engineering coordinate system
 */
-(void) testEngineeringCoordinateSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,2],"];
    [text appendString:@"AXIS[\"site north (x)\",southeast,ORDER[1]],"];
    [text appendString:@"AXIS[\"site east (y)\",southwest,ORDER[2]],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSCoordinateSystem *coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    NSArray<CRSAxis *> *axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"site north" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"x" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"site east" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH_WEST andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    CRSUnit *unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[[[text stringByReplacingOccurrencesOfString:@"southeast" withString:@"southEast"]
                                        stringByReplacingOccurrencesOfString:@"southwest" withString:@"southWest"]
                                        stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"]
                             andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[polar,2],"];
    [text appendString:@"AXIS[\"distance (r)\",awayFrom,ORDER[1],LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"AXIS[\"bearing (U)\",clockwise,BEARING[234],ORDER[2],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_POLAR andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"distance" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"r" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_AWAY_FROM andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[axes objectAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[axes objectAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[axes objectAtIndex:0].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"bearing" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"U" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_CLOCKWISE andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:234 andValue2:[[axes objectAtIndex:1].bearing doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[axes objectAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[axes objectAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[axes objectAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0]" withString:@"1]"]
                             andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[Cartesian,3],AXIS[\"ahead (x)\",forward,ORDER[1]],"];
    [text appendString:@"AXIS[\"right (y)\",starboard,ORDER[2]],"];
    [text appendString:@"AXIS[\"down (z)\",down,ORDER[3]],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"ahead" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"x" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FORWARD andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"right" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"y" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_STARBOARD andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"down" andValue2:[axes objectAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"z" andValue2:[axes objectAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_DOWN andValue2:[axes objectAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:[[axes objectAtIndex:2].order intValue]];
    unit = coordinateSystem.unit;
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[coordinateSystem description]];
    
    text = [NSMutableString string];
    [text appendString:@"CS[ordinal,2],AXIS[\"Inline (I)\",northEast,ORDER[1]],"];
    [text appendString:@"AXIS[\"Crossline (J)\",northwest,ORDER[2]]"];
    reader = [CRSReader createWithText:text];
    coordinateSystem = [reader readCoordinateSystem];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ORDINAL andValue2:coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:coordinateSystem.dimension];
    axes = coordinateSystem.axes;
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:(int)axes.count];
    [CRSTestUtils assertEqualWithValue:@"Inline" andValue2:[axes objectAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"I" andValue2:[axes objectAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH_EAST andValue2:[axes objectAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[axes objectAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"Crossline" andValue2:[axes objectAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"J" andValue2:[axes objectAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH_WEST andValue2:[axes objectAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[axes objectAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"northwest" withString:@"northWest"] andValue2:[coordinateSystem description]];
    
}

/**
 * Test geodetic datum ensemble
 */
-(void) testGeodeticDatumEnsemble{
 
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"ENSEMBLE[\"WGS 84 ensemble\","];
    [text appendString:@"MEMBER[\"WGS 84 (TRANSIT)\"],MEMBER[\"WGS 84 (G730)\"],"];
    [text appendString:@"MEMBER[\"WGS 84 (G834)\"],MEMBER[\"WGS 84 (G1150)\"],"];
    [text appendString:@"MEMBER[\"WGS 84 (G1674)\"],MEMBER[\"WGS 84 (G1762)\"],"];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378137,298.2572236,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"ENSEMBLEACCURACY[2]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSGeoDatumEnsemble *datumEnsemble = [reader readGeoDatumEnsemble];
    [CRSTestUtils assertNotNil:datumEnsemble];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 ensemble" andValue2:datumEnsemble.name];
    [CRSTestUtils assertEqualIntWithValue:6 andValue2:[datumEnsemble numMembers]];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (TRANSIT)" andValue2:[datumEnsemble memberAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G730)" andValue2:[datumEnsemble memberAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G834)" andValue2:[datumEnsemble memberAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1150)" andValue2:[datumEnsemble memberAtIndex:3].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1674)" andValue2:[datumEnsemble memberAtIndex:4].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1762)" andValue2:[datumEnsemble memberAtIndex:5].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:datumEnsemble.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:datumEnsemble.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.2572236 andValue2:datumEnsemble.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:datumEnsemble.ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:datumEnsemble.ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[datumEnsemble.ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualDoubleWithValue:2 andValue2:datumEnsemble.accuracy];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"]
                             andValue2:[datumEnsemble description]];
    
    text = [NSMutableString string];
    [text appendString:@"ENSEMBLE[\"WGS 84 ensemble\","];
    [text appendString:@"MEMBER[\"WGS 84 (TRANSIT)\",ID[\"EPSG\",1166]],"];
    [text appendString:@"MEMBER[\"WGS 84 (G730)\",ID[\"EPSG\",1152]],"];
    [text appendString:@"MEMBER[\"WGS 84 (G834)\",ID[\"EPSG\",1153]],"];
    [text appendString:@"MEMBER[\"WGS 84 (G1150)\",ID[\"EPSG\",1154]],"];
    [text appendString:@"MEMBER[\"WGS 84 (G1674)\",ID[\"EPSG\",1155]],"];
    [text appendString:@"MEMBER[\"WGS 84 (G1762)\",ID[\"EPSG\",1156]],"];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378137,298.2572236,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"ENSEMBLEACCURACY[2]]"];
    reader = [CRSReader createWithText:text];
    datumEnsemble = [reader readGeoDatumEnsemble];
    [CRSTestUtils assertNotNil:datumEnsemble];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 ensemble" andValue2:datumEnsemble.name];
    [CRSTestUtils assertEqualIntWithValue:6 andValue2:[datumEnsemble numMembers]];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (TRANSIT)" andValue2:[datumEnsemble memberAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:0] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1166" andValue2:[[datumEnsemble memberAtIndex:0] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G730)" andValue2:[datumEnsemble memberAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:1] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1152" andValue2:[[datumEnsemble memberAtIndex:1] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G834)" andValue2:[datumEnsemble memberAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:2] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1153" andValue2:[[datumEnsemble memberAtIndex:2] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1150)" andValue2:[datumEnsemble memberAtIndex:3].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:3] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1154" andValue2:[[datumEnsemble memberAtIndex:3] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1674)" andValue2:[datumEnsemble memberAtIndex:4].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:4] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1155" andValue2:[[datumEnsemble memberAtIndex:4] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1762)" andValue2:[datumEnsemble memberAtIndex:5].name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[datumEnsemble memberAtIndex:5] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1156" andValue2:[[datumEnsemble memberAtIndex:5] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:datumEnsemble.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:datumEnsemble.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.2572236 andValue2:datumEnsemble.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:datumEnsemble.ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:datumEnsemble.ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[datumEnsemble.ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualDoubleWithValue:2 andValue2:datumEnsemble.accuracy];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"]
                             andValue2:[datumEnsemble description]];
    
}

/**
 * Test vertical datum ensemble
 */
-(void) testVerticalDatumEnsemble{
 
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"ENSEMBLE[\"EVRS ensemble\","];
    [text appendString:@"MEMBER[\"EVRF2000\"],MEMBER[\"EVRF2007\"],"];
    [text appendString:@"ENSEMBLEACCURACY[0.01]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSDatumEnsemble *datumEnsemble = [reader readVerticalDatumEnsemble];
    [CRSTestUtils assertNotNil:datumEnsemble];
    [CRSTestUtils assertEqualWithValue:@"EVRS ensemble" andValue2:datumEnsemble.name];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[datumEnsemble numMembers]];
    [CRSTestUtils assertEqualWithValue:@"EVRF2000" andValue2:[datumEnsemble memberAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"EVRF2007" andValue2:[datumEnsemble memberAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.01 andValue2:datumEnsemble.accuracy];
    [CRSTestUtils assertEqualWithValue:text andValue2:[datumEnsemble description]];
    
}

/**
 * Test dynamic
 */
-(void) testDynamic{
    
    NSString *text = @"DYNAMIC[FRAMEEPOCH[2010.0]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSDynamic *dynamic = [reader readDynamic];
    [CRSTestUtils assertEqualDoubleWithValue:2010.0 andValue2:dynamic.referenceEpoch];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"2010.0" withString:@"2010"] andValue2:[dynamic description]];
    
    text = @"DYNAMIC[FRAMEEPOCH[2010.0],MODEL[\"NAD83(CSRS)v6 velocity grid\"]]";
    reader = [CRSReader createWithText:text];
    dynamic = [reader readDynamic];
    [CRSTestUtils assertEqualDoubleWithValue:2010.0 andValue2:dynamic.referenceEpoch];
    [CRSTestUtils assertEqualWithValue:@"NAD83(CSRS)v6 velocity grid" andValue2:dynamic.deformationModelName];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"2010.0" withString:@"2010"] andValue2:[dynamic description]];
    
}

/**
 * Test ellipsoid
 */
-(void) testEllipsoid{
    
    NSString *text = @"ELLIPSOID[\"GRS 1980\",6378137,298.257222101,LENGTHUNIT[\"metre\",1.0]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSEllipsoid *ellipsoid = [reader readEllipsoid];
    [CRSTestUtils assertEqualIntWithValue:CRS_ELLIPSOID_OBLATE andValue2:ellipsoid.type];
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"]
                             andValue2:[ellipsoid description]];
    
    text = @"SPHEROID[\"GRS 1980\",6378137.0,298.257222101]";
    reader = [CRSReader createWithText:text];
    ellipsoid = [reader readEllipsoid];
    [CRSTestUtils assertEqualIntWithValue:CRS_ELLIPSOID_OBLATE andValue2:ellipsoid.type];
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualWithValue:[[text stringByReplacingOccurrencesOfString:@"SPHEROID" withString:@"ELLIPSOID"]
                                        stringByReplacingOccurrencesOfString:@"6378137.0" withString:@"6378137"]
                             andValue2:[ellipsoid description]];
    
    NSMutableString *text2 = [NSMutableString string];
    [text2 appendString:@"ELLIPSOID[\"Clark 1866\",20925832.164,294.97869821,"];
    [text2 appendString:@"LENGTHUNIT[\"US survey foot\",0.304800609601219]]"];
    reader = [CRSReader createWithText:text2];
    ellipsoid = [reader readEllipsoid];
    [CRSTestUtils assertEqualIntWithValue:CRS_ELLIPSOID_OBLATE andValue2:ellipsoid.type];
    [CRSTestUtils assertEqualWithValue:@"Clark 1866" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:20925832.164 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:294.97869821 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"US survey foot" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.304800609601219 andValue2:[ellipsoid.unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:[text2 stringByReplacingOccurrencesOfString:@"0.304800609601219" withString:@"0.3048006096012191"] andValue2:[ellipsoid description]];
    
    text = @"ELLIPSOID[\"Sphere\",6371000,0,LENGTHUNIT[\"metre\",1.0]]";
    reader = [CRSReader createWithText:text];
    ellipsoid = [reader readEllipsoid];
    [CRSTestUtils assertEqualIntWithValue:CRS_ELLIPSOID_OBLATE andValue2:ellipsoid.type];
    [CRSTestUtils assertEqualWithValue:@"Sphere" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6371000 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"] andValue2:[ellipsoid description]];
    
}

/**
 * Test prime meridian
 */
-(void) testPrimeMeridian{
    
    NSString *text = @"PRIMEM[\"Paris\",2.5969213,ANGLEUNIT[\"grad\",0.015707963267949]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSPrimeMeridian *primeMeridian = [reader readPrimeMeridian];
    [CRSTestUtils assertEqualWithValue:@"Paris" andValue2:primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:2.5969213 andValue2:primeMeridian.longitude];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:primeMeridian.longitudeUnit.type];
    [CRSTestUtils assertEqualWithValue:@"grad" andValue2:primeMeridian.longitudeUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.015707963267949 andValue2:[primeMeridian.longitudeUnit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:text andValue2:[primeMeridian description]];

    text = @"PRIMEM[\"Ferro\",-17.6666667]";
    reader = [CRSReader createWithText:text];
    primeMeridian = [reader readPrimeMeridian];
    [CRSTestUtils assertEqualWithValue:@"Ferro" andValue2:primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:-17.6666667 andValue2:primeMeridian.longitude];
    [CRSTestUtils assertEqualWithValue:text andValue2:[primeMeridian description]];

    text = @"PRIMEM[\"Greenwich\",0.0,ANGLEUNIT[\"degree\",0.0174532925199433]]";
    reader = [CRSReader createWithText:text];
    primeMeridian = [reader readPrimeMeridian];
    [CRSTestUtils assertEqualWithValue:@"Greenwich" andValue2:primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:primeMeridian.longitude];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:primeMeridian.longitudeUnit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:primeMeridian.longitudeUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[primeMeridian.longitudeUnit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"0.0," withString:@"0,"] andValue2:[primeMeridian description]];

}

/**
 * Test geodetic reference frame
 */
-(void) testGeodeticReferenceFrame{

    NSMutableString *text = [NSMutableString string];
    [text appendString:@"DATUM[\"North American Datum 1983\","];
    [text appendString:@"ELLIPSOID[\"GRS 1980\",6378137,298.257222101,LENGTHUNIT[\"metre\",1.0]]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSGeoReferenceFrame *geodeticReferenceFrame = [reader readGeoReferenceFrame];
    [CRSTestUtils assertEqualWithValue:@"North American Datum 1983" andValue2:geodeticReferenceFrame.name];
    CRSEllipsoid *ellipsoid = geodeticReferenceFrame.ellipsoid;
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"1.0" withString:@"1"]
                             andValue2:[geodeticReferenceFrame description]];

    text = [NSMutableString string];
    [text appendString:@"TRF[\"World Geodetic System 1984\","];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378388.0,298.257223563,LENGTHUNIT[\"metre\",1.0]]"];
    [text appendString:@"],PRIMEM[\"Greenwich\",0.0]"];
    reader = [CRSReader createWithText:text];
    geodeticReferenceFrame = [reader readGeoReferenceFrame];
    [CRSTestUtils assertEqualWithValue:@"World Geodetic System 1984" andValue2:geodeticReferenceFrame.name];
    ellipsoid = geodeticReferenceFrame.ellipsoid;
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378388.0 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257223563 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"Greenwich" andValue2:geodeticReferenceFrame.primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:geodeticReferenceFrame.primeMeridian.longitude];
    [CRSTestUtils assertEqualWithValue:[[[[text stringByReplacingOccurrencesOfString:@"TRF" withString:@"DATUM"]
                                          stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]
                                          stringByReplacingOccurrencesOfString:@".0," withString:@","]
                                        stringByReplacingOccurrencesOfString:@"6378388.0" withString:@"6378388"]
                             andValue2:[geodeticReferenceFrame description]];
    
    text = [NSMutableString string];
    [text appendString:@"GEODETICDATUM[\"Tananarive 1925\","];
    [text appendString:@"ELLIPSOID[\"International 1924\",6378388.0,297.0,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"ANCHOR[\"Tananarive observatory:21.0191667gS, 50.23849537gE of Paris\"]],"];
    [text appendString:@"PRIMEM[\"Paris\",2.5969213,ANGLEUNIT[\"grad\",0.015707963267949]]"];
    reader = [CRSReader createWithText:text];
    geodeticReferenceFrame = [reader readGeoReferenceFrame];
    [CRSTestUtils assertEqualWithValue:@"Tananarive 1925" andValue2:geodeticReferenceFrame.name];
    ellipsoid = geodeticReferenceFrame.ellipsoid;
    [CRSTestUtils assertEqualWithValue:@"International 1924" andValue2:ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378388.0 andValue2:ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:297.0 andValue2:ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"Tananarive observatory:21.0191667gS, 50.23849537gE of Paris" andValue2:geodeticReferenceFrame.anchor];
    [CRSTestUtils assertEqualWithValue:@"Paris" andValue2:geodeticReferenceFrame.primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:2.5969213 andValue2:geodeticReferenceFrame.primeMeridian.longitude];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:geodeticReferenceFrame.primeMeridian.longitudeUnit.type];
    [CRSTestUtils assertEqualWithValue:@"grad" andValue2:geodeticReferenceFrame.primeMeridian.longitudeUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.015707963267949 andValue2:[geodeticReferenceFrame.primeMeridian.longitudeUnit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:[[[text stringByReplacingOccurrencesOfString:@"GEODETICDATUM" withString:@"DATUM"]
                                        stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]
                                        stringByReplacingOccurrencesOfString:@".0," withString:@","]
                             andValue2:[geodeticReferenceFrame description]];

}

/**
 * Test geodetic coordinate reference system
 */
-(void) testGeodeticCoordinateReferenceSystem{

    NSMutableString *text = [NSMutableString string];
    [text appendString:@"GEODCRS[\"JGD2000\","];
    [text appendString:@"DATUM[\"Japanese Geodetic Datum 2000\","];
    [text appendString:@"ELLIPSOID[\"GRS 1980\",6378137,298.257222101]],"];
    [text appendString:@"CS[Cartesian,3],AXIS[\"(X)\",geocentricX],"];
    [text appendString:@"AXIS[\"(Y)\",geocentricY],AXIS[\"(Z)\",geocentricZ],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0],"];
    [text appendString:@"USAGE[SCOPE[\"Geodesy, topographic mapping and cadastre\"],"];
    [text appendString:@"AREA[\"Japan\"],BBOX[17.09,122.38,46.05,157.64],"];
    [text appendString:@"TIMEEXTENT[2002-04-01,2011-10-21]],"];
    [text appendString:@"ID[\"EPSG\",4946,URI[\"urn:ogc:def:crs:EPSG::4946\"]],"];
    [text appendString:@"REMARK[\"注：JGD2000ジオセントリックは現在JGD2011に代わりました。\"]]"];

    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSGeoCoordinateReferenceSystem *geodeticOrGeographicCrs = [CRSReader readGeo:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geodeticOrGeographicCrs];
    CRSGeoCoordinateReferenceSystem *geodeticCrs = [CRSReader readGeodetic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geodeticCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEODETIC andValue2:geodeticCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:geodeticCrs.categoryType];
    [CRSTestUtils assertEqualWithValue:@"JGD2000" andValue2:geodeticCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Japanese Geodetic Datum 2000" andValue2:geodeticCrs.referenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:geodeticCrs.referenceFrame.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:geodeticCrs.referenceFrame.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:geodeticCrs.referenceFrame.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:geodeticCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:geodeticCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[geodeticCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_X andValue2:[geodeticCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[geodeticCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_Y andValue2:[geodeticCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualWithValue:@"Z" andValue2:[geodeticCrs.coordinateSystem axisAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_GEOCENTRIC_Z andValue2:[geodeticCrs.coordinateSystem axisAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:geodeticCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:geodeticCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[geodeticCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"Geodesy, topographic mapping and cadastre" andValue2:[geodeticCrs usageAtIndex:0].scope];
    [CRSTestUtils assertEqualWithValue:@"Japan" andValue2:[geodeticCrs usageAtIndex:0].extent.areaDescription];
    [CRSTestUtils assertEqualDoubleWithValue:17.09 andValue2:[geodeticCrs usageAtIndex:0].extent.geographicBoundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:122.38 andValue2:[geodeticCrs usageAtIndex:0].extent.geographicBoundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:46.05 andValue2:[geodeticCrs usageAtIndex:0].extent.geographicBoundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:157.64 andValue2:[geodeticCrs usageAtIndex:0].extent.geographicBoundingBox.upperRightLongitude];
    [CRSTestUtils assertEqualWithValue:@"2002-04-01" andValue2:[geodeticCrs usageAtIndex:0].extent.temporalExtent.start];
    [CRSTestUtils assertTrue:[[geodeticCrs usageAtIndex:0].extent.temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2002-04-01" andValue2:[[geodeticCrs usageAtIndex:0].extent.temporalExtent.startDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"2011-10-21" andValue2:[geodeticCrs usageAtIndex:0].extent.temporalExtent.end];
    [CRSTestUtils assertTrue:[[geodeticCrs usageAtIndex:0].extent.temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2011-10-21" andValue2:[[geodeticCrs usageAtIndex:0].extent.temporalExtent.endDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[geodeticCrs identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"4946" andValue2:[geodeticCrs identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"urn:ogc:def:crs:EPSG::4946" andValue2:[geodeticCrs identifierAtIndex:0].uri];
    [CRSTestUtils assertEqualWithValue:@"注：JGD2000ジオセントリックは現在JGD2011に代わりました。" andValue2:geodeticCrs.remark];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[geodeticCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:geodeticCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:geodeticCrs]];

}

/**
 * Test geographic coordinate reference system
 */
-(void) testGeographicCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"GEOGCRS[\"WGS 84 (G1762)\","];
    [text appendString:@"DYNAMIC[FRAMEEPOCH[2005.0]],"];
    [text appendString:@"TRF[\"World Geodetic System 1984 (G1762)\","];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]],"];
    [text appendString:@"CS[ellipsoidal,3],"];
    [text appendString:@"AXIS[\"(lat)\",north,ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"AXIS[\"(lon)\",east,ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"AXIS[\"ellipsoidal height (h)\",up,LENGTHUNIT[\"metre\",1.0]]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSGeoCoordinateReferenceSystem *geodeticOrGeographicCrs = [CRSReader readGeo:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geodeticOrGeographicCrs];
    CRSGeoCoordinateReferenceSystem *geographicCrs = [CRSReader readGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:geographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:geographicCrs.categoryType];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1762)" andValue2:geographicCrs.name];
    [CRSTestUtils assertEqualDoubleWithValue:2005.0 andValue2:geographicCrs.dynamic.referenceEpoch];
    [CRSTestUtils assertEqualWithValue:@"World Geodetic System 1984 (G1762)" andValue2:geographicCrs.referenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:geographicCrs.referenceFrame.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:geographicCrs.referenceFrame.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257223563 andValue2:geographicCrs.referenceFrame.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:geographicCrs.referenceFrame.ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:geographicCrs.referenceFrame.ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[geographicCrs.referenceFrame.ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:geographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:geographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"lat" andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[geographicCrs.coordinateSystem axisAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"lon" andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[geographicCrs.coordinateSystem axisAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"ellipsoidal height" andValue2:[geographicCrs.coordinateSystem axisAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"h" andValue2:[geographicCrs.coordinateSystem axisAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[geographicCrs.coordinateSystem axisAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[geographicCrs.coordinateSystem axisAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[geographicCrs.coordinateSystem axisAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[geographicCrs.coordinateSystem axisAtIndex:2].unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TRF" withString:@"DATUM"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[geographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:geographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:geographicCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"GEOGRAPHICCRS[\"NAD83\","];
    [text appendString:@"DATUM[\"North American Datum 1983\","];
    [text appendString:@"ELLIPSOID[\"GRS 1980\",6378137,298.257222101,LENGTHUNIT[\"metre\",1.0]]],"];
    [text appendString:@"CS[ellipsoidal,2],AXIS[\"latitude\",north],"];
    [text appendString:@"AXIS[\"longitude\",east],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.017453292519943],"];
    [text appendString:@"ID[\"EPSG\",4269],REMARK[\"1986 realisation\"]]"];
 
    crs = [CRSReader read:text withStrict:YES];
    geodeticOrGeographicCrs = [CRSReader readGeo:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geodeticOrGeographicCrs];
    geographicCrs = [CRSReader readGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:geographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:geographicCrs.categoryType];
    [CRSTestUtils assertEqualWithValue:@"NAD83" andValue2:geographicCrs.name];
    [CRSTestUtils assertEqualWithValue:@"North American Datum 1983" andValue2:geographicCrs.referenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:geographicCrs.referenceFrame.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:geographicCrs.referenceFrame.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:geographicCrs.referenceFrame.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:geographicCrs.referenceFrame.ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:geographicCrs.referenceFrame.ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[geographicCrs.referenceFrame.ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:geographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:geographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"latitude" andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"longitude" andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:geographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:geographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.017453292519943 andValue2:[geographicCrs.coordinateSystem.unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[geographicCrs identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"4269" andValue2:[geographicCrs identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"1986 realisation" andValue2:geographicCrs.remark];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"GEOGRAPHICCRS" withString:@"GEOGCRS"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[geographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:geographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:geographicCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"GEOGCRS[\"NTF (Paris)\","];
    [text appendString:@"DATUM[\"Nouvelle Triangulation Francaise\","];
    [text appendString:@"ELLIPSOID[\"Clarke 1880 (IGN)\",6378249.2,293.4660213]],"];
    [text appendString:@"PRIMEM[\"Paris\",2.5969213],CS[ellipsoidal,2],"];
    [text appendString:@"AXIS[\"latitude\",north,ORDER[1]],"];
    [text appendString:@"AXIS[\"longitude\",east,ORDER[2]],"];
    [text appendString:@"ANGLEUNIT[\"grad\",0.015707963267949],"];
    [text appendString:@"REMARK[\"Nouvelle Triangulation Française\"]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    geodeticOrGeographicCrs = [CRSReader readGeo:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geodeticOrGeographicCrs];
    geographicCrs = [CRSReader readGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:geographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:geographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:geographicCrs.categoryType];
    [CRSTestUtils assertEqualWithValue:@"NTF (Paris)" andValue2:geographicCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Nouvelle Triangulation Francaise" andValue2:geographicCrs.referenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"Clarke 1880 (IGN)" andValue2:geographicCrs.referenceFrame.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378249.2 andValue2:geographicCrs.referenceFrame.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:293.4660213 andValue2:geographicCrs.referenceFrame.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualWithValue:@"Paris" andValue2:geographicCrs.referenceFrame.primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:2.5969213 andValue2:geographicCrs.referenceFrame.primeMeridian.longitude];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:geographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:geographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"latitude" andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[geographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[geographicCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"longitude" andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[geographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[geographicCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:geographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"grad" andValue2:geographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.015707963267949 andValue2:[geographicCrs.coordinateSystem.unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Nouvelle Triangulation Française" andValue2:geographicCrs.remark];
    [CRSTestUtils assertEqualWithValue:text andValue2:[geographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:geographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:geographicCrs]];
    
}

/**
 * Test map projection
 */
-(void) testMapProjection{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"CONVERSION[\"UTM zone 10N\","];
    [text appendString:@"METHOD[\"Transverse Mercator\",ID[\"EPSG\",9807]],"];
    [text appendString:@"PARAMETER[\"Latitude of natural origin\",0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],"];
    [text appendString:@"ID[\"EPSG\",8801]],"];
    [text appendString:@"PARAMETER[\"Longitude of natural origin\",-123,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],ID[\"EPSG\",8802]],"];
    [text appendString:@"PARAMETER[\"Scale factor at natural origin\",0.9996,"];
    [text appendString:@"SCALEUNIT[\"unity\",1.0],ID[\"EPSG\",8805]],"];
    [text appendString:@"PARAMETER[\"False easting\",500000,"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0],ID[\"EPSG\",8806]],"];
    [text appendString:@"PARAMETER[\"False northing\",0,LENGTHUNIT[\"metre\",1.0],ID[\"EPSG\",8807]]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSMapProjection *mapProjection = [reader readMapProjection];
    [CRSTestUtils assertEqualWithValue:@"UTM zone 10N" andValue2:mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Transverse Mercator" andValue2:mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[mapProjection.method identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"9807" andValue2:[mapProjection.method identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of natural origin" andValue2:[mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[mapProjection.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[mapProjection.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[mapProjection.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[mapProjection.method parameterAtIndex:0] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8801" andValue2:[[mapProjection.method parameterAtIndex:0] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Longitude of natural origin" andValue2:[mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-123 andValue2:[mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[mapProjection.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[mapProjection.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[mapProjection.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[mapProjection.method parameterAtIndex:1] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8802" andValue2:[[mapProjection.method parameterAtIndex:1] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Scale factor at natural origin" andValue2:[mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.9996 andValue2:[mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_SCALE andValue2:[mapProjection.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"unity" andValue2:[mapProjection.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:2].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[mapProjection.method parameterAtIndex:2] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8805" andValue2:[[mapProjection.method parameterAtIndex:2] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"False easting" andValue2:[mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:500000 andValue2:[mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[mapProjection.method parameterAtIndex:3].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[mapProjection.method parameterAtIndex:3].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:3].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[mapProjection.method parameterAtIndex:3] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8806" andValue2:[[mapProjection.method parameterAtIndex:3] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"False northing" andValue2:[mapProjection.method parameterAtIndex:4].name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[mapProjection.method parameterAtIndex:4].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[mapProjection.method parameterAtIndex:4].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[mapProjection.method parameterAtIndex:4].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:4].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[mapProjection.method parameterAtIndex:4] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8807" andValue2:[[mapProjection.method parameterAtIndex:4] identifierAtIndex:0].uniqueIdentifier];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[mapProjection description]];
    
    text = [NSMutableString string];
    [text appendString:@"CONVERSION[\"UTM zone 10N\","];
    [text appendString:@"METHOD[\"Transverse Mercator\"],"];
    [text appendString:@"PARAMETER[\"Latitude of natural origin\",0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Longitude of natural origin\",-123,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Scale factor at natural origin\",0.9996,"];
    [text appendString:@"SCALEUNIT[\"unity\",1.0]],"];
    [text appendString:@"PARAMETER[\"False easting\",500000,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"PARAMETER[\"False northing\",0,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"ID[\"EPSG\",16010]]"];
    reader = [CRSReader createWithText:text];
    mapProjection = [reader readMapProjection];
    [CRSTestUtils assertEqualWithValue:@"UTM zone 10N" andValue2:mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Transverse Mercator" andValue2:mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"Latitude of natural origin" andValue2:[mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[mapProjection.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[mapProjection.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[mapProjection.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Longitude of natural origin" andValue2:[mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-123 andValue2:[mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[mapProjection.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[mapProjection.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[mapProjection.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Scale factor at natural origin" andValue2:[mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.9996 andValue2:[mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_SCALE andValue2:[mapProjection.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"unity" andValue2:[mapProjection.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:2].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"False easting" andValue2:[mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:500000 andValue2:[mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[mapProjection.method parameterAtIndex:3].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[mapProjection.method parameterAtIndex:3].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:3].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"False northing" andValue2:[mapProjection.method parameterAtIndex:4].name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[mapProjection.method parameterAtIndex:4].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[mapProjection.method parameterAtIndex:4].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[mapProjection.method parameterAtIndex:4].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[mapProjection.method parameterAtIndex:4].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[mapProjection identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"16010" andValue2:[mapProjection identifierAtIndex:0].uniqueIdentifier];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[mapProjection description]];
    
}

/**
 * Test projected geographic coordinate reference system
 */
-(void) testProjectedGeographicCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"PROJCRS[\"ETRS89 Lambert Azimuthal Equal Area CRS\",BASEGEOGCRS[\"ETRS89\","];
    [text appendString:@"DATUM[\"ETRS89\","];
    [text appendString:@"ELLIPSOID[\"GRS 80\",6378137,298.257222101,LENGTHUNIT[\"metre\",1.0]]"];
    [text appendString:@"],ID[\"EuroGeographics\",\"ETRS89-LatLon\"]],"];
    [text appendString:@"CONVERSION[\"LAEA\","];
    [text appendString:@"METHOD[\"Lambert Azimuthal Equal Area\",ID[\"EPSG\",9820]],"];
    [text appendString:@"PARAMETER[\"Latitude of origin\",52.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Longitude of origin\",10.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"False easting\",4321000.0,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"PARAMETER[\"False northing\",3210000.0,LENGTHUNIT[\"metre\",1.0]]"];
    [text appendString:@"],CS[Cartesian,2],AXIS[\"(Y)\",north,ORDER[1]],"];
    [text appendString:@"AXIS[\"(X)\",east,ORDER[2]],LENGTHUNIT[\"metre\",1.0],"];
    [text appendString:@"USAGE[SCOPE[\"Description of a purpose\"],AREA[\"An area description\"]],"];
    [text appendString:@"ID[\"EuroGeographics\",\"ETRS-LAEA\"]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSProjectedCoordinateReferenceSystem *projectedCrs = [CRSReader readProjected:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedCrs];
    CRSProjectedCoordinateReferenceSystem *projectedGeographicCrs = [CRSReader readProjectedGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedGeographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_PROJECTED andValue2:projectedGeographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[projectedGeographicCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"ETRS89 Lambert Azimuthal Equal Area CRS" andValue2:projectedGeographicCrs.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:[projectedGeographicCrs baseType]];
    [CRSTestUtils assertEqualWithValue:@"ETRS89" andValue2:[projectedGeographicCrs baseName]];
    [CRSTestUtils assertEqualWithValue:@"ETRS89" andValue2:[projectedGeographicCrs referenceFrame].name];
    [CRSTestUtils assertEqualWithValue:@"GRS 80" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs referenceFrame].ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EuroGeographics" andValue2:[projectedGeographicCrs baseIdentifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"ETRS89-LatLon" andValue2:[projectedGeographicCrs baseIdentifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"LAEA" andValue2:projectedGeographicCrs.mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Lambert Azimuthal Equal Area" andValue2:projectedGeographicCrs.mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[projectedGeographicCrs.mapProjection.method identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"9820" andValue2:[projectedGeographicCrs.mapProjection.method identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:52.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Longitude of origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:10.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"False easting" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:4321000.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"False northing" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:3210000.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:projectedGeographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:projectedGeographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:projectedGeographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:projectedGeographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[projectedGeographicCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"Description of a purpose" andValue2:[projectedGeographicCrs usageAtIndex:0].scope];
    [CRSTestUtils assertEqualWithValue:@"An area description" andValue2:[projectedGeographicCrs usageAtIndex:0].extent.areaDescription];
    [CRSTestUtils assertEqualWithValue:@"EuroGeographics" andValue2:[projectedGeographicCrs identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"ETRS-LAEA" andValue2:[projectedGeographicCrs identifierAtIndex:0].uniqueIdentifier];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[projectedGeographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:projectedGeographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:projectedGeographicCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"PROJCRS[\"NAD27 / Texas South Central\","];
    [text appendString:@"BASEGEOGCRS[\"NAD27\","];
    [text appendString:@"DATUM[\"North American Datum 1927\","];
    [text appendString:@"ELLIPSOID[\"Clarke 1866\",20925832.164,294.97869821,"];
    [text appendString:@"LENGTHUNIT[\"US survey foot\",0.304800609601219]]]],"];
    [text appendString:@"CONVERSION[\"Texas South Central SPCS27\","];
    [text appendString:@"METHOD[\"Lambert Conic Conformal (2SP)\",ID[\"EPSG\",9802]],"];
    [text appendString:@"PARAMETER[\"Latitude of false origin\",27.83333333333333,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],ID[\"EPSG\",8821]],"];
    [text appendString:@"PARAMETER[\"Longitude of false origin\",-99.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],ID[\"EPSG\",8822]],"];
    [text appendString:@"PARAMETER[\"Latitude of 1st standard parallel\",28.383333333333,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],ID[\"EPSG\",8823]],"];
    [text appendString:@"PARAMETER[\"Latitude of 2nd standard parallel\",30.283333333333,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],ID[\"EPSG\",8824]],"];
    [text appendString:@"PARAMETER[\"Easting at false origin\",2000000.0,"];
    [text appendString:@"LENGTHUNIT[\"US survey foot\",0.304800609601219],ID[\"EPSG\",8826]],"];
    [text appendString:@"PARAMETER[\"Northing at false origin\",0.0,"];
    [text appendString:@"LENGTHUNIT[\"US survey foot\",0.304800609601219],ID[\"EPSG\",8827]]],"];
    [text appendString:@"CS[Cartesian,2],AXIS[\"(X)\",east],"];
    [text appendString:@"AXIS[\"(Y)\",north],"];
    [text appendString:@"LENGTHUNIT[\"US survey foot\",0.304800609601219],"];
    [text appendString:@"REMARK[\"Fundamental point: Meade's Ranch KS, latitude 39°13'26.686\"\"N,"];
    [text appendString:@"longitude 98°32'30.506\"\"W.\"]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    projectedCrs = [CRSReader readProjected:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedCrs];
    projectedGeographicCrs = [CRSReader readProjectedGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedGeographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_PROJECTED andValue2:projectedGeographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[projectedGeographicCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"NAD27 / Texas South Central" andValue2:projectedGeographicCrs.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:[projectedGeographicCrs baseType]];
    [CRSTestUtils assertEqualWithValue:@"NAD27" andValue2:[projectedGeographicCrs baseName]];
    [CRSTestUtils assertEqualWithValue:@"North American Datum 1927" andValue2:[projectedGeographicCrs referenceFrame].name];
    [CRSTestUtils assertEqualWithValue:@"Clarke 1866" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:20925832.164 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:294.97869821 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"US survey foot" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.304800609601219 andValue2:[[projectedGeographicCrs referenceFrame].ellipsoid.unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Texas South Central SPCS27" andValue2:projectedGeographicCrs.mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Lambert Conic Conformal (2SP)" andValue2:projectedGeographicCrs.mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[projectedGeographicCrs.mapProjection.method identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"9802" andValue2:[projectedGeographicCrs.mapProjection.method identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of false origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:27.83333333333333 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:0] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8821" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:0] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Longitude of false origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-99.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:1] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8822" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:1] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of 1st standard parallel" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:28.383333333333 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:2] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8823" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:2] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of 2nd standard parallel" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:30.283333333333 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:3] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8824" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:3] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Easting at false origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].name];
    [CRSTestUtils assertEqualDoubleWithValue:2000000.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.type];
    [CRSTestUtils assertEqualWithValue:@"US survey foot" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.304800609601219 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:4] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8826" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:4] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Northing at false origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:5].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:5].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:5].unit.type];
    [CRSTestUtils assertEqualWithValue:@"US survey foot" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:5].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.304800609601219 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:5].unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:5] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"8827" andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:5] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:projectedGeographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:projectedGeographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:projectedGeographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"US survey foot" andValue2:projectedGeographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.304800609601219 andValue2:[projectedGeographicCrs.coordinateSystem.unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Fundamental point: Meade's Ranch KS, latitude 39°13'26.686\"N,longitude 98°32'30.506\"W." andValue2:projectedGeographicCrs.remark];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"0.304800609601219" withString:@"0.3048006096012191"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[projectedGeographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:projectedGeographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:projectedGeographicCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"PROJCRS[\"NAD83 UTM 10\",BASEGEOGCRS[\"NAD83(86)\","];
    [text appendString:@"DATUM[\"North American Datum 1983\","];
    [text appendString:@"ELLIPSOID[\"GRS 1980\",6378137,298.257222101]],"];
    [text appendString:@"PRIMEM[\"Greenwich\",0]],CONVERSION[\"UTM zone 10N\","];
    [text appendString:@"METHOD[\"Transverse Mercator\"],"];
    [text appendString:@"PARAMETER[\"Latitude of natural origin\",0.0],"];
    [text appendString:@"PARAMETER[\"Longitude of natural origin\",-123.0],"];
    [text appendString:@"PARAMETER[\"Scale factor\",0.9996],"];
    [text appendString:@"PARAMETER[\"False easting\",500000.0],"];
    [text appendString:@"PARAMETER[\"False northing\",0.0],ID[\"EPSG\",16010]],"];
    [text appendString:@"CS[Cartesian,2],"];
    [text appendString:@"AXIS[\"(E)\",east,ORDER[1]],"];
    [text appendString:@"AXIS[\"(N)\",north,ORDER[2]],LENGTHUNIT[\"metre\",1.0],"];
    [text appendString:@"REMARK[\"In this example parameter value units are not given. This is allowed for backward compatibility. However it is strongly recommended that units are explicitly given in the string, as in the previous two examples.\"]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    projectedCrs = [CRSReader readProjected:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedCrs];
    projectedGeographicCrs = [CRSReader readProjectedGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedGeographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_PROJECTED andValue2:projectedGeographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[projectedGeographicCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"NAD83 UTM 10" andValue2:projectedGeographicCrs.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:[projectedGeographicCrs baseType]];
    [CRSTestUtils assertEqualWithValue:@"NAD83(86)" andValue2:[projectedGeographicCrs baseName]];
    [CRSTestUtils assertEqualWithValue:@"North American Datum 1983" andValue2:[projectedGeographicCrs referenceFrame].name];
    [CRSTestUtils assertEqualWithValue:@"GRS 1980" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257222101 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualWithValue:@"Greenwich" andValue2:[projectedGeographicCrs referenceFrame].primeMeridian.name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[projectedGeographicCrs referenceFrame].primeMeridian.longitude];
    [CRSTestUtils assertEqualWithValue:@"UTM zone 10N" andValue2:projectedGeographicCrs.mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Transverse Mercator" andValue2:projectedGeographicCrs.mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"Latitude of natural origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualWithValue:@"Longitude of natural origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-123.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualWithValue:@"Scale factor" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.9996 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualWithValue:@"False easting" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:500000.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualWithValue:@"False northing" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].value];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[projectedGeographicCrs.mapProjection identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"16010" andValue2:[projectedGeographicCrs.mapProjection identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:projectedGeographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:projectedGeographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"E" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"N" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:projectedGeographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:projectedGeographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[projectedGeographicCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"In this example parameter value units are not given. This is allowed for backward compatibility. However it is strongly recommended that units are explicitly given in the string, as in the previous two examples." andValue2:projectedGeographicCrs.remark];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[projectedGeographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:projectedGeographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:projectedGeographicCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"PROJCRS[\"WGS 84 (G1762) / UTM zone 31N 3D\",BASEGEOGCRS[\"WGS 84\","];
    [text appendString:@"DATUM[\"World Geodetic System of 1984 (G1762)\","];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]],"];
    [text appendString:@"CONVERSION[\"UTM zone 31N 3D\","];
    [text appendString:@"METHOD[\"Transverse Mercator (3D)\"],"];
    [text appendString:@"PARAMETER[\"Latitude of origin\",0.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Longitude of origin\",3.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Scale factor\",0.9996,SCALEUNIT[\"unity\",1.0]],"];
    [text appendString:@"PARAMETER[\"False easting\",500000.0,LENGTHUNIT[\"metre\",1.0]],"];
    [text appendString:@"PARAMETER[\"False northing\",0.0,LENGTHUNIT[\"metre\",1.0]]],"];
    [text appendString:@"CS[Cartesian,3],AXIS[\"(E)\",east,ORDER[1]],"];
    [text appendString:@"AXIS[\"(N)\",north,ORDER[2]],"];
    [text appendString:@"AXIS[\"ellipsoidal height (h)\",up,ORDER[3]],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    projectedCrs = [CRSReader readProjected:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedCrs];
    projectedGeographicCrs = [CRSReader readProjectedGeographic:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:projectedGeographicCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_PROJECTED andValue2:projectedGeographicCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[projectedGeographicCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1762) / UTM zone 31N 3D" andValue2:projectedGeographicCrs.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:[projectedGeographicCrs baseType]];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:[projectedGeographicCrs baseName]];
    [CRSTestUtils assertEqualWithValue:@"World Geodetic System of 1984 (G1762)" andValue2:[projectedGeographicCrs referenceFrame].name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257223563 andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs referenceFrame].ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs referenceFrame].ellipsoid.unit.conversionFactor doubleValue] andDelta:0.000000000000001];
    [CRSTestUtils assertEqualWithValue:@"UTM zone 31N 3D" andValue2:projectedGeographicCrs.mapProjection.name];
    [CRSTestUtils assertEqualWithValue:@"Transverse Mercator (3D)" andValue2:projectedGeographicCrs.mapProjection.method.name];
    [CRSTestUtils assertEqualWithValue:@"Latitude of origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Longitude of origin" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:3.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Scale factor" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.9996 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_SCALE andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"unity" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:2].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"False easting" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].name];
    [CRSTestUtils assertEqualDoubleWithValue:500000.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:3].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"False northing" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0 andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[[projectedGeographicCrs.mapProjection.method parameterAtIndex:4].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:projectedGeographicCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:projectedGeographicCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"E" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"N" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"ellipsoidal height" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:2].name];
    [CRSTestUtils assertEqualWithValue:@"h" andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[projectedGeographicCrs.coordinateSystem axisAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:[[projectedGeographicCrs.coordinateSystem axisAtIndex:2].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:projectedGeographicCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:projectedGeographicCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[projectedGeographicCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[projectedGeographicCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:projectedGeographicCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:projectedGeographicCrs]];
    
}

/**
 * Test vertical reference frame
 */
-(void) testVerticalReferenceFrame{
    
    NSString *text = @"VDATUM[\"Newlyn\"]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSVerticalReferenceFrame *verticalReferenceFrame = [reader readVerticalReferenceFrame];
    [CRSTestUtils assertEqualWithValue:@"Newlyn" andValue2:verticalReferenceFrame.name];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalReferenceFrame description]];
    
    text = @"VERTICALDATUM[\"Newlyn\",ANCHOR[\"Mean Sea Level 1915 to 1921.\"]]";
    reader = [CRSReader createWithText:text];
    verticalReferenceFrame = [reader readVerticalReferenceFrame];
    [CRSTestUtils assertEqualWithValue:@"Newlyn" andValue2:verticalReferenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"Mean Sea Level 1915 to 1921." andValue2:verticalReferenceFrame.anchor];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@"VERTICALDATUM" withString:@"VDATUM"] andValue2:[verticalReferenceFrame description]];
    
}

/**
 * Test vertical coordinate reference system
 */
-(void) testVerticalCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"VERTCRS[\"NAVD88\","];
    [text appendString:@"VDATUM[\"North American Vertical Datum 1988\"],"];
    [text appendString:@"CS[vertical,1],AXIS[\"gravity-related height (H)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSVerticalCoordinateReferenceSystem *verticalCrs = [CRSReader readVertical:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:verticalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_VERTICAL andValue2:verticalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[verticalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"NAVD88" andValue2:verticalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"North American Vertical Datum 1988" andValue2:verticalCrs.referenceFrame.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_VERTICAL andValue2:verticalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:verticalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"gravity-related height" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"H" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:verticalCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:verticalCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[verticalCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:verticalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:verticalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"VERTCRS[\"CGVD2013\","];
    [text appendString:@"VRF[\"Canadian Geodetic Vertical Datum of 2013\"],"];
    [text appendString:@"CS[vertical,1],AXIS[\"gravity-related height (H)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0],"];
    [text appendString:@"GEOIDMODEL[\"CGG2013\",ID[\"EPSG\",6648]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    verticalCrs = [CRSReader readVertical:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:verticalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_VERTICAL andValue2:verticalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[verticalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"CGVD2013" andValue2:verticalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Canadian Geodetic Vertical Datum of 2013" andValue2:verticalCrs.referenceFrame.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_VERTICAL andValue2:verticalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:verticalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"gravity-related height" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"H" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:verticalCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:verticalCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[verticalCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"CGG2013" andValue2:verticalCrs.geoidModelName];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:verticalCrs.geoidModelIdentifier.name];
    [CRSTestUtils assertEqualWithValue:@"6648" andValue2:verticalCrs.geoidModelIdentifier.uniqueIdentifier];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"VRF" withString:@"VDATUM"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:verticalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:verticalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"VERTCRS[\"RH2000\","];
    [text appendString:@"DYNAMIC[FRAMEEPOCH[2000.0],MODEL[\"NKG2016LU\"]],"];
    [text appendString:@"VDATUM[\"Rikets Hojdsystem 2000\"],CS[vertical,1],"];
    [text appendString:@"AXIS[\"gravity-related height (H)\",up],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    verticalCrs = [CRSReader readVertical:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:verticalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_VERTICAL andValue2:verticalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[verticalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"RH2000" andValue2:verticalCrs.name];
    [CRSTestUtils assertEqualDoubleWithValue:2000.0 andValue2:verticalCrs.dynamic.referenceEpoch];
    [CRSTestUtils assertEqualWithValue:@"NKG2016LU" andValue2:verticalCrs.dynamic.deformationModelName];
    [CRSTestUtils assertEqualWithValue:@"Rikets Hojdsystem 2000" andValue2:verticalCrs.referenceFrame.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_VERTICAL andValue2:verticalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:verticalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"gravity-related height" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"H" andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[verticalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:verticalCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:verticalCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[verticalCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:verticalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:verticalCrs]];
    
}

/**
 * Test engineering coordinate reference system
 */
-(void) testEngineeringCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"ENGCRS[\"A construction site CRS\","];
    [text appendString:@"EDATUM[\"P1\",ANCHOR[\"Peg in south corner\"]],"];
    [text appendString:@"CS[Cartesian,2],AXIS[\"site east\",southWest,ORDER[1]],"];
    [text appendString:@"AXIS[\"site north\",southEast,ORDER[2]],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0],"];
    [text appendString:@"USAGE[SCOPE[\"Construction\"],TIMEEXTENT[\"date/time t1\",\"date/time t2\"]]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSEngineeringCoordinateReferenceSystem *engineeringCrs = [CRSReader readEngineering:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:engineeringCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_ENGINEERING andValue2:engineeringCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[engineeringCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"A construction site CRS" andValue2:engineeringCrs.name];
    [CRSTestUtils assertEqualWithValue:@"P1" andValue2:engineeringCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"Peg in south corner" andValue2:engineeringCrs.datum.anchor];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:engineeringCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:engineeringCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"site east" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH_WEST andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"site north" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_SOUTH_EAST andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:engineeringCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:engineeringCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[engineeringCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[engineeringCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:engineeringCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:engineeringCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"ENGINEERINGCRS[\"Astra Minas Grid\","];
    [text appendString:@"ENGINEERINGDATUM[\"Astra Minas\"],CS[Cartesian,2],"];
    [text appendString:@"AXIS[\"northing (X)\",north,ORDER[1]],"];
    [text appendString:@"AXIS[\"westing (Y)\",west,ORDER[2]],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0],ID[\"EPSG\",5800]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    engineeringCrs = [CRSReader readEngineering:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:engineeringCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_ENGINEERING andValue2:engineeringCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[engineeringCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"Astra Minas Grid" andValue2:engineeringCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Astra Minas" andValue2:engineeringCrs.datum.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:engineeringCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:engineeringCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"northing" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"X" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"westing" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"Y" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_WEST andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:engineeringCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:engineeringCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[engineeringCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"EPSG" andValue2:[engineeringCrs identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"5800" andValue2:[engineeringCrs identifierAtIndex:0].uniqueIdentifier];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"ENGINEERINGCRS" withString:@"ENGCRS"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"ENGINEERINGDATUM" withString:@"EDATUM"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[engineeringCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:engineeringCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:engineeringCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"ENGCRS[\"A ship-centred CRS\","];
    [text appendString:@"EDATUM[\"Ship reference point\",ANCHOR[\"Centre of buoyancy\"]],"];
    [text appendString:@"CS[Cartesian,3],AXIS[\"(x)\",forward],"];
    [text appendString:@"AXIS[\"(y)\",starboard],AXIS[\"(z)\",down],"];
    [text appendString:@"LENGTHUNIT[\"metre\",1.0]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    engineeringCrs = [CRSReader readEngineering:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:engineeringCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_ENGINEERING andValue2:engineeringCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[engineeringCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"A ship-centred CRS" andValue2:engineeringCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Ship reference point" andValue2:engineeringCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"Centre of buoyancy" andValue2:engineeringCrs.datum.anchor];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:engineeringCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:3 andValue2:engineeringCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"x" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FORWARD andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"y" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_STARBOARD andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualWithValue:@"z" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:2].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_DOWN andValue2:[engineeringCrs.coordinateSystem axisAtIndex:2].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:engineeringCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:engineeringCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[engineeringCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[engineeringCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:engineeringCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:engineeringCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"ENGCRS[\"An analogue image CRS\","];
    [text appendString:@"EDATUM[\"Image reference point\","];
    [text appendString:@"ANCHOR[\"Top left corner of image = 0,0\"]],"];
    [text appendString:@"CS[Cartesian,2],AXIS[\"Column (x)\",columnPositive],"];
    [text appendString:@"AXIS[\"Row (y)\",rowPositive],"];
    [text appendString:@"LENGTHUNIT[\"micrometre\",1E-6]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    engineeringCrs = [CRSReader readEngineering:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:engineeringCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_ENGINEERING andValue2:engineeringCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[engineeringCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"An analogue image CRS" andValue2:engineeringCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Image reference point" andValue2:engineeringCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"Top left corner of image = 0,0" andValue2:engineeringCrs.datum.anchor];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_CARTESIAN andValue2:engineeringCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:engineeringCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Column" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"x" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_COLUMN_POSITIVE andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualWithValue:@"Row" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"y" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_ROW_POSITIVE andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:engineeringCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"micrometre" andValue2:engineeringCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1E-6 andValue2:[engineeringCrs.coordinateSystem.unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"1E-6" withString:@"1E-06"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[engineeringCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:engineeringCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:engineeringCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"ENGCRS[\"A digital image CRS\","];
    [text appendString:@"EDATUM[\"Image reference point\","];
    [text appendString:@"ANCHOR[\"Top left corner of image = 0,0\"]],"];
    [text appendString:@"CS[ordinal,2],"];
    [text appendString:@"AXIS[\"Column pixel (x)\",columnPositive,ORDER[1]],"];
    [text appendString:@"AXIS[\"Row pixel (y)\",rowPositive,ORDER[2]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    engineeringCrs = [CRSReader readEngineering:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:engineeringCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_ENGINEERING andValue2:engineeringCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[engineeringCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"A digital image CRS" andValue2:engineeringCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Image reference point" andValue2:engineeringCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"Top left corner of image = 0,0" andValue2:engineeringCrs.datum.anchor];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ORDINAL andValue2:engineeringCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:engineeringCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Column pixel" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"x" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_COLUMN_POSITIVE andValue2:[engineeringCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"Row pixel" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualWithValue:@"y" andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_ROW_POSITIVE andValue2:[engineeringCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[engineeringCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[engineeringCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:engineeringCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:engineeringCrs]];
    
}

/**
 * Test parametric coordinate reference system
 */
-(void) testParametricCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"PARAMETRICCRS[\"WMO standard atmosphere layer 0\","];
    [text appendString:@"PDATUM[\"Mean Sea Level\",ANCHOR[\"1013.25 hPa at 15°C\"]],"];
    [text appendString:@"CS[parametric,1],"];
    [text appendString:@"AXIS[\"pressure (hPa)\",up],PARAMETRICUNIT[\"HectoPascal\",100.0]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSParametricCoordinateReferenceSystem *parametricCrs = [CRSReader readParametric:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:parametricCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_PARAMETRIC andValue2:parametricCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[parametricCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"WMO standard atmosphere layer 0" andValue2:parametricCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Mean Sea Level" andValue2:parametricCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"1013.25 hPa at 15°C" andValue2:parametricCrs.datum.anchor];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_PARAMETRIC andValue2:parametricCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:parametricCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"pressure" andValue2:[parametricCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"hPa" andValue2:[parametricCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_UP andValue2:[parametricCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_PARAMETRIC andValue2:parametricCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"HectoPascal" andValue2:parametricCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:100.0 andValue2:[parametricCrs.coordinateSystem.unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[parametricCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:parametricCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:parametricCrs]];
    
}

/**
 * Test temporal datum
 */
-(void) testTemporalDatum{
    
    NSString *text = @"TIMEDATUM[\"Gregorian calendar\",CALENDAR[\"proleptic Gregorian\"],TIMEORIGIN[0000-01-01]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSTemporalDatum *temporalDatum = [reader readTemporalDatum];
    [CRSTestUtils assertEqualWithValue:@"Gregorian calendar" andValue2:temporalDatum.name];
    [CRSTestUtils assertEqualWithValue:@"proleptic Gregorian" andValue2:temporalDatum.calendar];
    [CRSTestUtils assertEqualWithValue:@"0000-01-01" andValue2:temporalDatum.origin];
    [CRSTestUtils assertTrue:[temporalDatum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:@"0000-01-01" andValue2:[temporalDatum.originDateTime description]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TIMEDATUM" withString:@"TDATUM"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalDatum description]];
    
    text = @"TDATUM[\"Gregorian calendar\",TIMEORIGIN[\"0001 January 1st\"]]";
    reader = [CRSReader createWithText:text];
    temporalDatum = [reader readTemporalDatum];
    [CRSTestUtils assertEqualWithValue:@"Gregorian calendar" andValue2:temporalDatum.name];
    [CRSTestUtils assertFalse:[temporalDatum hasCalendar]];
    [CRSTestUtils assertEqualWithValue:@"0001 January 1st" andValue2:temporalDatum.origin];
    [CRSTestUtils assertFalse:[temporalDatum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalDatum description]];
    
    text = @"TDATUM[\"Gregorian calendar\"]";
    reader = [CRSReader createWithText:text];
    temporalDatum = [reader readTemporalDatum];
    [CRSTestUtils assertFalse:[temporalDatum hasCalendar]];
    [CRSTestUtils assertFalse:[temporalDatum hasOrigin]];
    [CRSTestUtils assertFalse:[temporalDatum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalDatum description]];
    
}

/**
 * Test temporal coordinate reference system
 */
-(void) testTemporalCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"TIMECRS[\"DateTime\","];
    [text appendString:@"TDATUM[\"Gregorian Calendar\"],"];
    [text appendString:@"CS[TemporalDateTime,1],AXIS[\"Time (T)\",future]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSTemporalCoordinateReferenceSystem *temporalCrs = [CRSReader readTemporal:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:temporalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_TEMPORAL andValue2:temporalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[temporalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"DateTime" andValue2:temporalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Gregorian Calendar" andValue2:temporalCrs.datum.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_TEMPORAL_DATE_TIME andValue2:temporalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:temporalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Time" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"T" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FUTURE andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].direction];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TemporalDateTime" withString:@"temporalDateTime"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:temporalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:temporalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"TIMECRS[\"GPS milliseconds\","];
    [text appendString:@"TDATUM[\"GPS time origin\",TIMEORIGIN[1980-01-01T00:00:00.0Z]],"];
    [text appendString:@"CS[TemporalCount,1],AXIS[\"(T)\",future,TIMEUNIT[\"millisecond (ms)\",0.001]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    temporalCrs = [CRSReader readTemporal:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:temporalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_TEMPORAL andValue2:temporalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[temporalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"GPS milliseconds" andValue2:temporalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"GPS time origin" andValue2:temporalCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"1980-01-01T00:00:00.0Z" andValue2:temporalCrs.datum.origin];
    [CRSTestUtils assertTrue:[temporalCrs.datum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:@"1980-01-01T00:00:00.0Z" andValue2:[temporalCrs.datum.originDateTime description]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_TEMPORAL_COUNT andValue2:temporalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:temporalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"T" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FUTURE andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"millisecond (ms)" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.001 andValue2:[[temporalCrs.coordinateSystem axisAtIndex:0].unit.conversionFactor doubleValue]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TemporalCount" withString:@"temporalCount"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:temporalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:temporalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"TIMECRS[\"Calendar hours from 1979-12-29\","];
    [text appendString:@"TDATUM[\"29 December 1979\",TIMEORIGIN[1979-12-29T00Z]],"];
    [text appendString:@"CS[TemporalCount,1],AXIS[\"Time\",future,TIMEUNIT[\"hour\"]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    temporalCrs = [CRSReader readTemporal:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:temporalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_TEMPORAL andValue2:temporalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[temporalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"Calendar hours from 1979-12-29" andValue2:temporalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"29 December 1979" andValue2:temporalCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"1979-12-29T00Z" andValue2:temporalCrs.datum.origin];
    [CRSTestUtils assertTrue:[temporalCrs.datum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:@"1979-12-29T00Z" andValue2:[temporalCrs.datum.originDateTime description]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_TEMPORAL_COUNT andValue2:temporalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:temporalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Time" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FUTURE andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"hour" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.name];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TemporalCount" withString:@"temporalCount"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:temporalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:temporalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"TIMECRS[\"Decimal Years CE\","];
    [text appendString:@"TDATUM[\"Common Era\",TIMEORIGIN[0000]],"];
    [text appendString:@"CS[TemporalMeasure,1],AXIS[\"Decimal years (a)\",future,TIMEUNIT[\"year\"]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    temporalCrs = [CRSReader readTemporal:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:temporalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_TEMPORAL andValue2:temporalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[temporalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"Decimal Years CE" andValue2:temporalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Common Era" andValue2:temporalCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"0000" andValue2:temporalCrs.datum.origin];
    [CRSTestUtils assertTrue:[temporalCrs.datum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:@"0000" andValue2:[temporalCrs.datum.originDateTime description]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_TEMPORAL_MEASURE andValue2:temporalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:temporalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Decimal years" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"a" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].abbreviation];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FUTURE andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"year" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.name];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TemporalMeasure" withString:@"temporalMeasure"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:temporalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:temporalCrs]];
    
    text = [NSMutableString string];
    [text appendString:@"TIMECRS[\"Unix time\","];
    [text appendString:@"TDATUM[\"Unix epoch\",TIMEORIGIN[1970-01-01T00:00:00Z]],"];
    [text appendString:@"CS[TemporalCount,1],AXIS[\"Time\",future,TIMEUNIT[\"second\"]]]"];
    
    crs = [CRSReader read:text withStrict:YES];
    temporalCrs = [CRSReader readTemporal:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:temporalCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_TEMPORAL andValue2:temporalCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[temporalCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"Unix time" andValue2:temporalCrs.name];
    [CRSTestUtils assertEqualWithValue:@"Unix epoch" andValue2:temporalCrs.datum.name];
    [CRSTestUtils assertEqualWithValue:@"1970-01-01T00:00:00Z" andValue2:temporalCrs.datum.origin];
    [CRSTestUtils assertTrue:[temporalCrs.datum hasOriginDateTime]];
    [CRSTestUtils assertEqualWithValue:@"1970-01-01T00:00:00Z" andValue2:[temporalCrs.datum.originDateTime description]];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_TEMPORAL_COUNT andValue2:temporalCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:temporalCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"Time" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_FUTURE andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_TIME andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"second" andValue2:[temporalCrs.coordinateSystem axisAtIndex:0].unit.name];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TemporalCount" withString:@"temporalCount"]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:temporalCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:temporalCrs]];
    
}

/**
 * Test deriving conversion
 */
-(void) testDerivingConversion{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"DERIVINGCONVERSION[\"conversion name\","];
    [text appendString:@"METHOD[\"method name\",ID[\"authority\",123]],"];
    [text appendString:@"PARAMETER[\"parameter 1 name\",0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],"];
    [text appendString:@"ID[\"authority\",456]],"];
    [text appendString:@"PARAMETER[\"parameter 2 name\",-123,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433],"];
    [text appendString:@"ID[\"authority\",789]]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSDerivingConversion *derivingConversion = [reader readDerivingConversion];
    [CRSTestUtils assertEqualWithValue:@"conversion name" andValue2:derivingConversion.name];
    [CRSTestUtils assertEqualWithValue:@"method name" andValue2:derivingConversion.method.name];
    [CRSTestUtils assertEqualWithValue:@"authority" andValue2:[derivingConversion.method identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"123" andValue2:[derivingConversion.method identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"parameter 1 name" andValue2:[derivingConversion.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:[derivingConversion.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[derivingConversion.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[derivingConversion.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[derivingConversion.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"authority" andValue2:[[derivingConversion.method parameterAtIndex:0] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"456" andValue2:[[derivingConversion.method parameterAtIndex:0] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"parameter 2 name" andValue2:[derivingConversion.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-123 andValue2:[derivingConversion.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[derivingConversion.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[derivingConversion.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[derivingConversion.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"authority" andValue2:[[derivingConversion.method parameterAtIndex:1] identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"789" andValue2:[[derivingConversion.method parameterAtIndex:1] identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:text andValue2:[derivingConversion description]];
    
}

/**
 * Test derived geographic coordinate reference system
 */
-(void) testDerivedGeographicCoordinateReferenceSystem{
    
    NSMutableString *text = [NSMutableString string];
    [text appendString:@"GEOGCRS[\"WMO Atlantic Pole\","];
    [text appendString:@"BASEGEOGCRS[\"WGS 84 (G1762)\","];
    [text appendString:@"DYNAMIC[FRAMEEPOCH[2005.0]],"];
    [text appendString:@"TRF[\"World Geodetic System 1984 (G1762)\","];
    [text appendString:@"ELLIPSOID[\"WGS 84\",6378137,298.257223563,LENGTHUNIT[\"metre\",1.0]]]],"];
    [text appendString:@"DERIVINGCONVERSION[\"Atlantic pole\","];
    [text appendString:@"METHOD[\"Pole rotation\",ID[\"Authority\",1234]],"];
    [text appendString:@"PARAMETER[\"Latitude of rotated pole\",52.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Longitude of rotated pole\",-30.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]],"];
    [text appendString:@"PARAMETER[\"Axis rotation\",-25.0,"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]]],"];
    [text appendString:@"CS[ellipsoidal,2],"];
    [text appendString:@"AXIS[\"latitude\",north,ORDER[1]],AXIS[\"longitude\",east,ORDER[2]],"];
    [text appendString:@"ANGLEUNIT[\"degree\",0.0174532925199433]]"];
    
    CRSObject *crs = [CRSReader read:text withStrict:YES];
    CRSDerivedCoordinateReferenceSystem *derivedCrs = [CRSReader readDerived:text];
    [CRSTestUtils assertEqualWithValue:crs andValue2:derivedCrs];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_DERIVED andValue2:derivedCrs.type];
    [CRSTestUtils assertEqualIntWithValue:CRS_CATEGORY_CRS andValue2:[derivedCrs categoryType]];
    [CRSTestUtils assertEqualWithValue:@"WMO Atlantic Pole" andValue2:derivedCrs.name];
    [CRSTestUtils assertEqualIntWithValue:CRS_TYPE_GEOGRAPHIC andValue2:[derivedCrs baseType]];
    [CRSTestUtils assertEqualWithValue:@"WGS 84 (G1762)" andValue2:[derivedCrs baseName]];
    CRSGeoCoordinateReferenceSystem *baseCrs = (CRSGeoCoordinateReferenceSystem*) [derivedCrs base];
    [CRSTestUtils assertEqualDoubleWithValue:2005.0 andValue2:baseCrs.dynamic.referenceEpoch];
    [CRSTestUtils assertEqualWithValue:@"World Geodetic System 1984 (G1762)" andValue2:baseCrs.referenceFrame.name];
    [CRSTestUtils assertEqualWithValue:@"WGS 84" andValue2:baseCrs.referenceFrame.ellipsoid.name];
    [CRSTestUtils assertEqualDoubleWithValue:6378137 andValue2:baseCrs.referenceFrame.ellipsoid.semiMajorAxis];
    [CRSTestUtils assertEqualDoubleWithValue:298.257223563 andValue2:baseCrs.referenceFrame.ellipsoid.inverseFlattening];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:baseCrs.referenceFrame.ellipsoid.unit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:baseCrs.referenceFrame.ellipsoid.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[baseCrs.referenceFrame.ellipsoid.unit.conversionFactor doubleValue]];
    [CRSTestUtils assertEqualWithValue:@"Atlantic pole" andValue2:derivedCrs.conversion.name];
    [CRSTestUtils assertEqualWithValue:@"Pole rotation" andValue2:derivedCrs.conversion.method.name];
    [CRSTestUtils assertEqualWithValue:@"Authority" andValue2:[derivedCrs.conversion.method identifierAtIndex:0].name];
    [CRSTestUtils assertEqualWithValue:@"1234" andValue2:[derivedCrs.conversion.method identifierAtIndex:0].uniqueIdentifier];
    [CRSTestUtils assertEqualWithValue:@"Latitude of rotated pole" andValue2:[derivedCrs.conversion.method parameterAtIndex:0].name];
    [CRSTestUtils assertEqualDoubleWithValue:52.0 andValue2:[derivedCrs.conversion.method parameterAtIndex:0].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[derivedCrs.conversion.method parameterAtIndex:0].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[derivedCrs.conversion.method parameterAtIndex:0].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[derivedCrs.conversion.method parameterAtIndex:0].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Longitude of rotated pole" andValue2:[derivedCrs.conversion.method parameterAtIndex:1].name];
    [CRSTestUtils assertEqualDoubleWithValue:-30.0 andValue2:[derivedCrs.conversion.method parameterAtIndex:1].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[derivedCrs.conversion.method parameterAtIndex:1].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[derivedCrs.conversion.method parameterAtIndex:1].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[derivedCrs.conversion.method parameterAtIndex:1].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualWithValue:@"Axis rotation" andValue2:[derivedCrs.conversion.method parameterAtIndex:2].name];
    [CRSTestUtils assertEqualDoubleWithValue:-25.0 andValue2:[derivedCrs.conversion.method parameterAtIndex:2].value];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:[derivedCrs.conversion.method parameterAtIndex:2].unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:[derivedCrs.conversion.method parameterAtIndex:2].unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[[derivedCrs.conversion.method parameterAtIndex:2].unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    [CRSTestUtils assertEqualIntWithValue:CRS_CS_ELLIPSOIDAL andValue2:derivedCrs.coordinateSystem.type];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:derivedCrs.coordinateSystem.dimension];
    [CRSTestUtils assertEqualWithValue:@"latitude" andValue2:[derivedCrs.coordinateSystem axisAtIndex:0].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_NORTH andValue2:[derivedCrs.coordinateSystem axisAtIndex:0].direction];
    [CRSTestUtils assertEqualIntWithValue:1 andValue2:[[derivedCrs.coordinateSystem axisAtIndex:0].order intValue]];
    [CRSTestUtils assertEqualWithValue:@"longitude" andValue2:[derivedCrs.coordinateSystem axisAtIndex:1].name];
    [CRSTestUtils assertEqualIntWithValue:CRS_AXIS_EAST andValue2:[derivedCrs.coordinateSystem axisAtIndex:1].direction];
    [CRSTestUtils assertEqualIntWithValue:2 andValue2:[[derivedCrs.coordinateSystem axisAtIndex:1].order intValue]];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_ANGLE andValue2:derivedCrs.coordinateSystem.unit.type];
    [CRSTestUtils assertEqualWithValue:@"degree" andValue2:derivedCrs.coordinateSystem.unit.name];
    [CRSTestUtils assertEqualDoubleWithValue:0.0174532925199433 andValue2:[derivedCrs.coordinateSystem.unit.conversionFactor doubleValue] andDelta:0.00000000000000001];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@"TRF" withString:@"DATUM"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0]" withString:@"]"]];
    text = [NSMutableString stringWithString:[text stringByReplacingOccurrencesOfString:@".0," withString:@","]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[derivedCrs description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[CRSWriter write:derivedCrs]];
    [CRSTestUtils assertEqualWithValue:[CRSTextUtils pretty:text] andValue2:[CRSWriter writePretty:derivedCrs]];
    
}

@end
