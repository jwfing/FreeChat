package com.leancloud.freechat;

import cn.leancloud.chatkit.LCChatKit;
import com.avos.avoscloud.AVOSCloud;

/**
 * Created by fengjunwen on 7/5/16.
 */
public class Application extends android.app.Application {
    // appId、appKey 可以在「LeanCloud  控制台 / 设置 / 应用 Key」获取
    private final String APP_ID = "xqbqp3jr39p1mfptkswia72icqkk6i2ic3vi4q1tbpu7ce8b";
    private final String APP_KEY = "cfs0hpk9ai3f8kiwua7atnri8hrleodvipjy0dofj70ebbno";
    private final LeanProfileProvider profileProvider = new LeanProfileProvider();

    @Override
    public void onCreate() {
        super.onCreate();
        AVOSCloud.setDebugLogEnabled(true);
        // 关于 CustomUserProvider 可以参看后面的文档
        LCChatKit.getInstance().setProfileProvider(profileProvider);
        LCChatKit.getInstance().init(getApplicationContext(), APP_ID, APP_KEY);
    }
}
