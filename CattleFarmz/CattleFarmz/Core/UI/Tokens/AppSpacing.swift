//
//  AppSpacing.swift
//  CattleFarmz
//

import CoreGraphics

public enum AppSpacing {
    public static let xxxs: CGFloat = 2
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let sm: CGFloat = 12
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 20
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 40
    public static let huge: CGFloat = 48
    public static let massive: CGFloat = 64

    public enum Screen {
        public static let compact: CGFloat = AppSpacing.md
        public static let standard: CGFloat = AppSpacing.lg
    }

    public enum Card {
        public static let compact: CGFloat = AppSpacing.md
        public static let regular: CGFloat = AppSpacing.xl
    }

    public enum Button {
        public static let horizontal: CGFloat = AppSpacing.sm
        public static let vertical: CGFloat = AppSpacing.xs
    }

    public enum Input {
        public static let horizontal: CGFloat = AppSpacing.md
        public static let vertical: CGFloat = AppSpacing.sm
    }

    public enum Badge {
        public static let horizontal: CGFloat = AppSpacing.xs
        public static let vertical: CGFloat = AppSpacing.xxs
    }

    public static let contentGap: CGFloat = md
    public static let sectionGap: CGFloat = xl
    public static let largeSectionGap: CGFloat = xxl
    public static let inlineIconGap: CGFloat = xs
    public static let gridGutter: CGFloat = sm
    public static let catalogRowGap: CGFloat = md
}
