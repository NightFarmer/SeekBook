package top.nightfarmer.seekbook

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result;


class MainActivity() : FlutterActivity() {

    private val CHANNEL = "seekbook.nightfarmer.top/statusbar"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        setStatusBarFullTransparent();

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "show") {
                window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)  //显示状态栏
            } else if (call.method == "hide") {
                window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)  //隐藏状态栏
            }
            result.success(true)
        }
    }

    /**
     * 全透状态栏
     */
    private fun setStatusBarFullTransparent() {
        if (Build.VERSION.SDK_INT >= 21) {//21表示5.0
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.statusBarColor = Color.TRANSPARENT;
        } else if (Build.VERSION.SDK_INT >= 19) {//19表示4.4
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            //虚拟键盘也透明
            //getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        }
    }
}
