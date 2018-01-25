package org.linphone;

import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.AttributeSet;
import android.widget.MediaController;
import android.widget.VideoView;

import org.linphone.core.LinphoneBuffer;
import org.linphone.core.LinphoneCall;
import org.linphone.core.LinphoneChatMessage;
import org.linphone.core.LinphoneChatRoom;
import org.linphone.core.LinphoneContent;
import org.linphone.core.LinphoneCore;

/**
 * Created by root on 18.12.17.
 */

public class VideoViewActivity extends LinphoneGenericActivity {
    private CustomVideoView customVideoView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.video_view);
        } catch (Exception e) {
            e.printStackTrace();
        }

        String method = getIntent().getStringExtra("method");
        String url = getIntent().getStringExtra("url");

        try {
            VideoView videoView = findViewById(R.id.video_view);
            videoView.setVideoPath(url);

            MediaController mediaController = new MediaController(this);
            mediaController.setAnchorView(videoView);
            videoView.setMediaController(mediaController);
            /*if (method.equals("delay")) {
                Thread.sleep(1500);
            }*/
            videoView.start();

            /*customVideoView = findViewById(R.id.video_view);
            customVideoView.setVideoPath(url);

            MediaController mediaController = new MediaController(this);
            mediaController.setAnchorView(customVideoView);
            customVideoView.setMediaController(mediaController);
            *//*if (method.equals("delay")) {
                Thread.sleep(1500);
            }*//*
            customVideoView.start();*/
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public CustomVideoView getCustomVideoView() {
        return customVideoView;
    }

}