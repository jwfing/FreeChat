package cn.leancloud.chatkit.viewholder;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.avos.avoscloud.im.v2.messages.AVIMAudioMessage;

import cn.leancloud.chatkit.R;
import cn.leancloud.chatkit.cache.LCIMLocalCacheUtils;
import cn.leancloud.chatkit.utils.LCIMPathUtils;
import cn.leancloud.chatkit.view.LCIMPlayButton;

/**
 * Created by wli on 15/9/17.
 * 聊天页面中的语音 item 对应的 holder
 */
public class LCIMChatItemAudioHolder extends LCIMChatItemHolder {

  protected LCIMPlayButton playButton;
  protected TextView durationView;

  public LCIMChatItemAudioHolder(Context context, ViewGroup root, boolean isLeft) {
    super(context, root, isLeft);
  }

  @Override
  public void initView() {
    super.initView();
    if (isLeft) {
      conventLayout.addView(View.inflate(getContext(), R.layout.lcim_chat_item_left_audio_layout, null));
    } else {
      conventLayout.addView(View.inflate(getContext(), R.layout.lcim_chat_item_right_audio_layout, null));
    }
    playButton = (LCIMPlayButton) itemView.findViewById(R.id.chat_item_audio_play_btn);
    durationView = (TextView) itemView.findViewById(R.id.chat_item_audio_duration_view);
  }

  @Override
  public void bindData(Object o) {
    super.bindData(o);
    if (o instanceof AVIMAudioMessage) {
      AVIMAudioMessage audioMessage = (AVIMAudioMessage) o;
      durationView.setText(String.format("%.0f\"", audioMessage.getDuration()));
      String localFilePath = audioMessage.getLocalFilePath();
      if (!TextUtils.isEmpty(localFilePath)) {
        playButton.setPath(localFilePath);
      } else {
        String path = LCIMPathUtils.getAudioCachePath(getContext(), audioMessage.getMessageId());
        playButton.setPath(path);
        LCIMLocalCacheUtils.downloadFileAsync(audioMessage.getFileUrl(), path);
      }
    }
  }
}