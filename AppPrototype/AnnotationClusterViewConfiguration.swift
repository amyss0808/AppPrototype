//
//  AnnotationClusterViewConfiguration.swift
//  AnnotationClusteringSwift
//
//  Created by Antoine Lamy on 23/9/2016.
//  Copyright (c) 2016 Antoine Lamy. All rights reserved.
//

import UIKit

public struct AnnotationClusterViewConfiguration {

    let templates: [AnnotationClusterTemplate]
	let defaultTemplate: AnnotationClusterTemplate

	public init (templates: [AnnotationClusterTemplate], defaultTemplate: AnnotationClusterTemplate) {
		self.templates = templates
		self.defaultTemplate = defaultTemplate
	}

	public static func `default`() -> AnnotationClusterViewConfiguration {
		var smallTemplate = AnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), sideLength: 38)
		smallTemplate.borderWidth = 3
		smallTemplate.fontSize = 13

		var mediumTemplate = AnnotationClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), sideLength: 48)
		mediumTemplate.borderWidth = 4
		mediumTemplate.fontSize = 14

		var largeTemplate = AnnotationClusterTemplate(range: nil, sideLength: 58)
		largeTemplate.borderWidth = 5
		largeTemplate.fontSize = 15

		return AnnotationClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
	}

	public func templateForCount(count: Int) -> AnnotationClusterTemplate {
		for template in templates {
			if template.range?.contains(count) ?? false {
				return template
			}
		}
		return self.defaultTemplate
	}
}
