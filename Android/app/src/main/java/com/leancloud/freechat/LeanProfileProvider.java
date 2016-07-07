package com.leancloud.freechat;

import com.avos.avoscloud.AVException;
import com.avos.avoscloud.AVQuery;
import com.avos.avoscloud.AVUser;
import com.avos.avoscloud.AVFile;
import com.avos.avoscloud.FindCallback;

import java.util.ArrayList;
import java.util.List;

import cn.leancloud.chatkit.LCChatKitUser;
import cn.leancloud.chatkit.LCChatProfileProvider;
import cn.leancloud.chatkit.LCChatProfilesCallBack;

/**
 * Created by fengjunwen on 7/5/16.
 */
public class LeanProfileProvider implements LCChatProfileProvider {
    public void fetchProfiles(List<String> userIdList, final LCChatProfilesCallBack profilesCallBack) {
        List<AVQuery<AVUser> > queries = new ArrayList<AVQuery<AVUser> >();
        for (int i = 0; i < userIdList.size(); i++) {
            AVQuery<AVUser> query = AVUser.getQuery();
            query.whereEqualTo("objectId", userIdList.get(i));
            queries.add(query);
        }
        AVQuery<AVUser> finalQuery = AVQuery.or(queries);
        finalQuery.findInBackground(new FindCallback<AVUser>() {
            @Override
            public void done(List<AVUser> list, AVException e) {
                List<LCChatKitUser> result = new ArrayList<LCChatKitUser>(list.size());
                for (AVUser user: list) {
                    AVFile avatarFile = user.getAVFile("avatarFile");
                    String avatarUrl = "http://tva3.sinaimg.cn/crop.110.143.933.933.180/d9b8b8fcjw8ez8a62jkeuj20xc0xc3yw.jpg";
                    if (avatarFile != null && avatarFile.getUrl() != null && avatarFile.getUrl().length() > 0) {
                        avatarUrl = avatarFile.getUrl();
                    }
                    result.add(new LCChatKitUser(user.getObjectId(), user.getUsername(), avatarUrl));
                }
                if (profilesCallBack != null) {
                    profilesCallBack.done(result, e);
                }
            }
        });
    }
}
