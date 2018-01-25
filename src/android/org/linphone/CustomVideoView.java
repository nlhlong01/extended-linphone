package org.linphone;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.VideoView;

/**
 * Created by root on 25.01.18.
 */

public class CustomVideoView extends VideoView {

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
