package org.linphone;

import android.os.Bundle;
import android.widget.MediaController;
import android.widget.VideoView;

/**
 * Created by root on 18.12.17.
 */

public class VideoViewActivity extends LinphoneGenericActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.video_view);
        VideoView videoView = findViewById(R.id.video_view);
        videoView.setVideoPath("http://192.168.1.100:8081/vod/sample_1280x720.mp4");

        MediaController mediaController = new MediaController(this);
        mediaController.setAnchorView(videoView);
        videoView.setMediaController(mediaController);

        videoView.start();
    }
}