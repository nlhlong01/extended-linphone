package org.linphone;

import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;

import org.linphone.core.LinphoneAddress;
import org.linphone.core.LinphoneCall;
import org.linphone.core.LinphoneChatMessage;
import org.linphone.core.LinphoneChatMessageImpl;
import org.linphone.core.LinphoneContent;
import org.linphone.core.LinphoneContentImpl;
import org.linphone.core.LinphoneCore;
import org.linphone.core.LinphoneCoreListener;
import org.linphone.core.LinphoneCoreListenerBase;
import org.linphone.core.LinphoneInfoMessage;

/**
 * Created by root on 18.12.17.
 */

public class VideoViewActivity extends LinphoneGenericActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinphoneCore lc = LinphoneManager.getLc();
        LinphoneInfoMessage message = lc.createInfoMessage();
        LinphoneContent content = new LinphoneContentImpl("text", null, null, null);
        content.setStringData("start video");
        message.setContent(content);
        LinphoneCall currentCall = lc.getCurrentCall();
        currentCall.sendInfoMessage(message);
        currentCall.getChatRoom().sendMessage("start video");

        setContentView(R.layout.video_view);
        VideoView videoView = findViewById(R.id.video_view);
        videoView.setVideoPath("http://192.168.1.100:8081/vod/sample_1280x720.mp4");

        MediaController mediaController = new MediaController(this);
        mediaController.setAnchorView(videoView);
        videoView.setMediaController(mediaController);

        videoView.start();

    }
}