package org.linphone;

import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.MediaController;
import android.widget.VideoView;

import org.linphone.core.LinphoneCall;
import org.linphone.core.LinphoneChatRoom;
import org.linphone.core.LinphoneCore;

/**
 * Created by root on 18.12.17.
 */

public class VideoViewActivity extends LinphoneGenericActivity {
    private CustomVideoView customvideoView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.video_view);
        } catch (Exception e) {
            e.printStackTrace();
        }

        String method = getIntent().getStringExtra("method");
        if (method.equals("delay")) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        try {
            VideoView videoView = findViewById(R.id.video_view);
            customvideoView = (CustomVideoView) videoView;
            customvideoView.setVideoPath("http://192.168.1.102:8081/vod/BigBuckBunny_320x180.mp4");

            MediaController mediaController = new MediaController(this);
            mediaController.setAnchorView(videoView);
            customvideoView.setMediaController(mediaController);
            customvideoView.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected class CustomVideoView extends VideoView {

        public CustomVideoView(Context context) {
            super(context);
        }

        public CustomVideoView(Context context, AttributeSet attrs) {
            super(context, attrs);
        }

        public CustomVideoView(Context context, AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
        }

        @Override
        public void pause() {
            super.pause();
            LinphoneManager.getLc().getCurrentCall().getChatRoom().sendMessage("video pause");
        }

        @Override
        public void start() {
            super.start();
            LinphoneManager.getLc().getCurrentCall().getChatRoom().sendMessage("video play");
        }
    }

    public CustomVideoView getVideoView() {
        return customvideoView;
    }
}