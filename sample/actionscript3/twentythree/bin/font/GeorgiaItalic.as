package {
    import mx.core.FontAsset;

    import flash.display.Sprite;
    import flash.system.Security;
    import flash.text.Font;
    import flash.utils.describeType;

    ///Applications/FDTEnterprise/plugins/com.powerflasher.fdt.shippedFlexSDK4_4.0.0.14159_1000/flex_sdk_4/bin/mxmlc "GeorgiaItalic.as" -compiler.as3 -use-network=false -managers flash.fonts.AFEFontManager -static-link-runtime-shared-libraries=true

    public class GeorgiaItalic extends Sprite {

        [Embed( source="ttf/Georgia Italic.ttf",
                mimeType="application/x-font-truetype",
                fontName="Georgia Italic",
                unicodeRange="U+0000-U+007e,U+0095-U+024f,U+0526-U+206f,U+0638-U+20cf,U+2100-U+2183")] public var font:Class;

        public function GeorgiaItalic() {
            FontAsset;

            Security.allowDomain("*");
            var xml:XML = describeType(this);

            for (var i:uint = 0; i < xml.variable.length(); i++) {
                Font.registerFont(this[xml.variable[i].@name]);
            }
        }
    }
}