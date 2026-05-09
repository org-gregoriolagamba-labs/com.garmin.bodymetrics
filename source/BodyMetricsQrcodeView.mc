import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Simple full-screen view displaying the QR code centered
class BodyMetricsQrcodeView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        try {
            var img = WatchUi.loadResource(Rez.Drawables.QrcodeWebsite) as BitmapResource;
            var imgW = img.getWidth();
            var imgH = img.getHeight();
            var imgX = cx - (imgW / 2);
            var imgY = cy - (imgH / 2);
            dc.drawBitmap(imgX, imgY, img);
        } catch (ex) {
            System.println("[BodyMetrics][Qrcode] Failed to load QR code image");
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy, Graphics.FONT_SMALL, "QR Code", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(cx, cy + 20, Graphics.FONT_XTINY, "not available", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

class BodyMetricsQrcodeDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onKey(keyEvent as KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
            return onBack();
        }
        return false;
    }
}
