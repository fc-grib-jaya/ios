//
//  AppColor.swift
//  CattleFarmz
//

import SwiftUI

public enum AppColor {
    /// Raw palette colors for design exploration. Prefer semantic tokens in finished UI.
    /// Primitive shades keep the same color in Light and Dark Mode.
    public enum Primitive {
        public enum Primary {
            public static let shade50 = Color("Primitive/Primary/50")
            public static let shade100 = Color("Primitive/Primary/100")
            public static let shade200 = Color("Primitive/Primary/200")
            public static let shade300 = Color("Primitive/Primary/300")
            public static let shade400 = Color("Primitive/Primary/400")
            public static let shade500 = Color("Primitive/Primary/500")
            public static let shade600 = Color("Primitive/Primary/600")
            public static let shade700 = Color("Primitive/Primary/700")
            public static let shade800 = Color("Primitive/Primary/800")
            public static let shade900 = Color("Primitive/Primary/900")
            public static let shade950 = Color("Primitive/Primary/950")
        }

        public enum Secondary {
            public static let shade50 = Color("Primitive/Secondary/50")
            public static let shade100 = Color("Primitive/Secondary/100")
            public static let shade200 = Color("Primitive/Secondary/200")
            public static let shade300 = Color("Primitive/Secondary/300")
            public static let shade400 = Color("Primitive/Secondary/400")
            public static let shade500 = Color("Primitive/Secondary/500")
            public static let shade600 = Color("Primitive/Secondary/600")
            public static let shade700 = Color("Primitive/Secondary/700")
            public static let shade800 = Color("Primitive/Secondary/800")
            public static let shade900 = Color("Primitive/Secondary/900")
            public static let shade950 = Color("Primitive/Secondary/950")
        }

        public enum Neutral {
            public static let shade50 = Color("Primitive/Neutral/50")
            public static let shade100 = Color("Primitive/Neutral/100")
            public static let shade200 = Color("Primitive/Neutral/200")
            public static let shade300 = Color("Primitive/Neutral/300")
            public static let shade400 = Color("Primitive/Neutral/400")
            public static let shade500 = Color("Primitive/Neutral/500")
            public static let shade600 = Color("Primitive/Neutral/600")
            public static let shade700 = Color("Primitive/Neutral/700")
            public static let shade800 = Color("Primitive/Neutral/800")
            public static let shade900 = Color("Primitive/Neutral/900")
            public static let shade950 = Color("Primitive/Neutral/950")
        }

        public enum Base {
            public static let white = Color("Primitive/Base/White")
        }
    }

    public enum Surface {
        public static let canvas = Color("Semantic/Surface/Canvas")
        public static let card = Color("Semantic/Surface/Card")
        public static let inset = Color("Semantic/Surface/Inset")
    }

    public enum Text {
        public static let primary = Color("Semantic/Text/Primary")
        public static let secondary = Color("Semantic/Text/Secondary")
        public static let muted = Color("Semantic/Text/Muted")
        public static let placeholder = Color("Semantic/Text/Placeholder")
    }

    public enum Border {
        public static let subtle = Color("Semantic/Border/Subtle")
        public static let `default` = Color("Semantic/Border/Default")
        public static let focus = Color("Semantic/Border/Focus")
    }

    public enum Button {
        public enum Primary {
            public static let background = Color("Component/Button/Primary/Background")
            public static let foreground = Color("Component/Button/Primary/Foreground")
            public static let pressedBackground = Color("Component/Button/Primary/PressedBackground")
            public static let pressedForeground = Color("Component/Button/Primary/PressedForeground")
        }

        public enum Secondary {
            public static let background = Color("Component/Button/Secondary/Background")
            public static let foreground = Color("Component/Button/Secondary/Foreground")
            public static let pressedBackground = Color("Component/Button/Secondary/PressedBackground")
            public static let pressedForeground = Color("Component/Button/Secondary/PressedForeground")
        }
    }

    public enum Badge {
        public enum Active {
            public static let background = Color("Component/Badge/Active/Background")
            public static let foreground = Color("Component/Badge/Active/Foreground")
        }

        public enum Inactive {
            public static let background = Color("Component/Badge/Inactive/Background")
            public static let foreground = Color("Component/Badge/Inactive/Foreground")
        }
    }

    public enum Tag {
        public enum Characteristic {
            public static let background = Color("Component/Tag/Characteristic/Background")
            public static let foreground = Color("Component/Tag/Characteristic/Foreground")
        }
    }

    public enum Input {
        public static let background = Color("Component/Input/Background")
        public static let text = Color("Component/Input/Text")
    }

    public enum Card {
        public static let background = Color("Component/Card/Background")
    }
}
