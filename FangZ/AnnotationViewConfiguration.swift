//
//  AnnotationViewConfiguration.swift
//  AnnotationClusteringSwift
//
//  Created by Antoine Lamy on 23/9/2016.
//  Copyright (c) 2016 Antoine Lamy. All rights reserved.
//

import UIKit

public struct AnnotationViewConfiguration {

    let templates: [AnnotationTemplate]
	let defaultTemplate: AnnotationTemplate

	public init (templates: [AnnotationTemplate], defaultTemplate: AnnotationTemplate) {
		self.templates = templates
		self.defaultTemplate = defaultTemplate
	}

	public static func `default`() -> AnnotationViewConfiguration {
		var extraSmallTemplate = AnnotationTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 16)), sideLength: 38)
		extraSmallTemplate.borderWidth = 3
		extraSmallTemplate.fontSize = 13

        var smallTemplate = AnnotationTemplate(range: Range(uncheckedBounds: (lower: 16, upper: 51)), sideLength: 43)
        smallTemplate.borderWidth = 3.5
        smallTemplate.fontSize = 13
        
		var mediumTemplate = AnnotationTemplate(range: Range(uncheckedBounds: (lower: 51, upper: 101)), sideLength: 48)
		mediumTemplate.borderWidth = 4
		mediumTemplate.fontSize = 14

		var largeTemplate = AnnotationTemplate(range: Range(uncheckedBounds: (lower: 101, upper: 301)), sideLength: 53)
		largeTemplate.borderWidth = 4.5
		largeTemplate.fontSize = 14
        
        var extraLargeTemplate = AnnotationTemplate(range: nil, sideLength: 58)
        extraLargeTemplate.borderWidth = 5
        extraLargeTemplate.fontSize = 15

		return AnnotationViewConfiguration(templates: [extraSmallTemplate, smallTemplate, mediumTemplate, largeTemplate], defaultTemplate: extraLargeTemplate)
	}

	public func templateForCount(count: Int) -> AnnotationTemplate {
		for template in templates {
			if template.range?.contains(count) ?? false {
				return template
            }
		}
		return self.defaultTemplate
	}
}
