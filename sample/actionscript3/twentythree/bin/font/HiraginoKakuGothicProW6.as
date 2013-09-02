package {
    import mx.core.FontAsset;

    import flash.display.Sprite;
    import flash.system.Security;
    import flash.text.Font;
    import flash.utils.describeType;

    /*
     *   /Users/jasonlam/Library/Flex/flex_sdk_4/bin/mxmlc "HiraginoKakuGothicProW6.as" -compiler.as3 -use-network=false -managers flash.fonts.AFEFontManager -static-link-runtime-shared-libraries=true
     */
    public class HiraginoKakuGothicProW6 extends Sprite {

        [Embed( source="otf/ヒラギノ角ゴ Pro W6.otf",
                mimeType="application/x-font-truetype",
                fontName="Hiragino Kaku Gothic Pro W6",
                unicodeRange="U+0000-U+30aa,U+30c8,U+30d5,U+30dd,U+30ea,U+30fc")] public var font:Class;
        public function HiraginoKakuGothicProW6() {
            FontAsset;

            Security.allowDomain("*");
            var xml:XML = describeType(this);

            for (var i:uint = 0; i < xml.variable.length(); i++) {
                Font.registerFont(this[xml.variable[i].@name]);
            }
        }
    }
}